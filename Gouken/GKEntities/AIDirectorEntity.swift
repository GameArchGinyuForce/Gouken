import Foundation
import GameplayKit

class AIComponent : GKEntity {
    var player: Character!
    var ai: Character!
    var playerNode: SCNNode!
    var aiNode: SCNNode!
    
    // Constants
    let aiAttackCooldown = 3.0
    let aiAggressiveCooldown = 4.0
    let aiAttackRange = Float(1.5)
    let aiRunAwayFromPlayerDuration = 0.3
    let aiMaxDamagedPlayerCount = 3
    let aiMinDistanceToPlayer = Float(1.0)
    
    // Variables
    var isAIAttackOnCooldown = false
    var aiAttackCooldownTimer: Double!
    var isAIAggressiveOnCooldown = true
    var aiAggressiveCooldownTimer: Double!
    var isAIAggressive = false
    var aiRunAwayFromPlayerTimer: Double!
    var isAIRunningAwayFromPlayer = false
    var aiDamagedPlayerCount: Int!
    
    init(player: Character, ai: Character) {
        super.init()
        
        self.player = player
        self.ai = ai
        playerNode = player.characterNode.parent!
        aiNode = ai.characterNode.parent!
        
        aiAttackCooldownTimer = aiAttackCooldown
        aiAggressiveCooldownTimer = aiAggressiveCooldown
        aiRunAwayFromPlayerTimer = aiRunAwayFromPlayerDuration
        aiDamagedPlayerCount = 0
        
        ai.health.onDamage.append { [self] in
            enterAIAggressiveState()
        }
        player.health.onDamage.append { [self] in
            aiDamagedPlayerCount += 1
            // If AI damages player too many times, give player some breathing room
            if (aiDamagedPlayerCount >= aiMaxDamagedPlayerCount) {
                exitAIAggressiveState()
                isAIAggressiveOnCooldown = true
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        tickAIAttackCooldownTimer(seconds)
        tickAIAggressiveCooldownTimer(seconds)
        
        if (ai.state == CharacterState.Downed || ai.state == CharacterState.Stunned) { return }
        
        // AI moves away from player after being too aggressive
        if (isAIRunningAwayFromPlayer) {
            moveAwayFromPlayer()
            tickAIRunAwayFromPlayerTimer(seconds)
        }
        
        // Block if player is attacking
        if (isPlayerAttacking()) {
            tryBlock()
        } else {
            if (ai.state == CharacterState.Blocking) {
                returnToIdle()
            }
        }
        
        // AI becomes aggressive either when timer expires or when they get damaged
        if (!isAIAggressiveOnCooldown && !isAIAggressive) {
            enterAIAggressiveState()
        }
        
        if (isAIAggressive) {
            beAggressive()
        }
        
        // AI direction
        if (isPlayerOnLeftSide()) {
            turnAILeft()
        } else {
            turnAIRight()
        }

    }
    
    func beAggressive() {
        // Move to player, attack if within range
        if (distanceToPlayer() <= aiAttackRange) {
            
            // Prevent being stuck in running state
            if (isAIRunning()) {
                returnToIdle()
            }
            
            // If player is attacking, try move out of range
            if (isPlayerAttacking()) {
                tryDash()
            }
            
            // Attack if not already attacking and attack is not on cooldown
            if (!isAIAttacking() && !isAIAttackOnCooldown) {
                switchAIState(state: CharacterState.Attacking)
                isAIAttackOnCooldown = true
            }
            
        } else { // If not within attack range
            
            // Prime heavy attack
            if (isPlayerMovingTowardsAI()) {
                tryHeavyAttack()
            }
            
            if (canAIMove() && !isPlayerAttacking()) {
                moveToPlayer()
            }
        }
    }
    
    func returnToIdle() {
        if (ai.state != CharacterState.Idle) {
            switchAIState(state: CharacterState.Idle)
        }
    }
    
    func tryDash() {
        if (canAIDash() && Int.random(in: 1..<100) == 1) {
            if (isPlayerOnLeftSide()) {
                switchAIState(state: CharacterState.DashingRight)
            } else {
                switchAIState(state: CharacterState.DashingLeft)
            }
        }
    }
    
    func tryBlock() {
        if (canAIBlock() && Int.random(in: 1...100) == 1) {
            switchAIState(state: CharacterState.Blocking)
        }
    }
    
    func tryHeavyAttack() {
        if (canAIAttack() && Int.random(in: 1...100) == 1) {
            switchAIState(state: CharacterState.HeavyAttacking)
        }
    }
    
    func tickAIAttackCooldownTimer(_ seconds: TimeInterval) {
        if (isAIAttackOnCooldown) {
            aiAttackCooldownTimer -= seconds
            if (aiAttackCooldownTimer <= 0) {
                isAIAttackOnCooldown = false
                aiAttackCooldownTimer = aiAttackCooldown
            }
        }
    }
    
    func tickAIAggressiveCooldownTimer(_ seconds: TimeInterval) {
        if (isAIAggressiveOnCooldown) {
            aiAggressiveCooldownTimer -= seconds
            if (aiAggressiveCooldownTimer <= 0) {
                isAIAggressiveOnCooldown = false
                aiAggressiveCooldownTimer = aiAggressiveCooldown
            }
        }
    }
    
    func tickAIRunAwayFromPlayerTimer(_ seconds: TimeInterval) {
        if (isAIRunningAwayFromPlayer) {
            aiRunAwayFromPlayerTimer -= seconds
            if (aiRunAwayFromPlayerTimer <= 0) {
                isAIRunningAwayFromPlayer = false
                aiRunAwayFromPlayerTimer = aiRunAwayFromPlayerDuration
                returnToIdle()
            }
        }
    }
    
    func moveToPlayer() {
        if (distanceToPlayer() <= aiMinDistanceToPlayer && isAIRunning()) {
            returnToIdle()
            return
        }
        
        if (isPlayerOnLeftSide()) {
            if (ai.state != CharacterState.RunningLeft) {
                switchAIState(state: CharacterState.RunningLeft)
            }
        } else {
            if (ai.state != CharacterState.RunningRight) {
                switchAIState(state: CharacterState.RunningRight)
            }
        }
    }
    
    func moveAwayFromPlayer() {
        if (isPlayerOnLeftSide()) {
            if (ai.state != CharacterState.RunningRight) {
                switchAIState(state: CharacterState.RunningRight)
            }
        } else {
            if (ai.state != CharacterState.RunningLeft) {
                switchAIState(state: CharacterState.RunningLeft)
            }
        }
    }
    
    func moveTo(_ zPos: Float) {
        if (zPos < aiNode.position.z) {
            if (ai.state != CharacterState.RunningLeft) {
                switchAIState(state: CharacterState.RunningLeft)
            }
        } else {
            if (ai.state != CharacterState.RunningRight) {
                switchAIState(state: CharacterState.RunningRight)
            }
        }
    }
    
    func enterAIAggressiveState() {
        isAIAggressive = true
    }
    
    func exitAIAggressiveState() {
        aiDamagedPlayerCount = 0
        isAIAggressive = false
        isAIRunningAwayFromPlayer = true
    }
    
    func canAIAttack() -> Bool {
        if (!isAIAttacking() &&
            ai.state != CharacterState.Stunned) {
            return true
        }
        return false
    }
    
    func canAIMove() -> Bool {
        return ai.state == CharacterState.Idle
    }
    
    func canAIDash() -> Bool {
        if (!isAIDashing() &&
            ai.state != CharacterState.Stunned) {
            return true
        }
        return false
    }
    
    func canAIBlock() -> Bool {
        if (ai.state != CharacterState.Blocking &&
            ai.state != CharacterState.Stunned &&
            ai.state != CharacterState.DashingLeft &&
            ai.state != CharacterState.DashingRight) {
            return true
        }
        return false
    }
    
    func isPlayerAttacking() -> Bool {
        return player.state == CharacterState.Attacking || player.state == CharacterState.HeavyAttacking
    }
    
    func isAIAttacking() -> Bool {
        return ai.state == CharacterState.Attacking || ai.state == CharacterState.HeavyAttacking
    }
    
    func isAIDashing() -> Bool {
        return ai.state == CharacterState.DashingLeft || ai.state == CharacterState.DashingRight
    }
    
    func isAIRunning() -> Bool {
        return ai.state == CharacterState.RunningLeft || ai.state == CharacterState.RunningRight
    }
    
    func distanceToPlayer() -> Float {
        return abs(playerNode.position.z - aiNode.position.z)
    }

    func distanceBetween(_ a: Float, _ b: Float) -> Float {
        return abs(a - b)
    }
                
    func isPlayerMovingTowardsAI() -> Bool {
        if (isPlayerOnLeftSide() && player.state == CharacterState.RunningRight) {
            return true
        }
        if (!isPlayerOnLeftSide() && player.state == CharacterState.RunningLeft) {
            return true
        }
        return false
    }
    
    func isPlayerOnLeftSide() -> Bool {
        return (playerNode.position.z - aiNode.position.z) < 0
    }
    
    func turnAILeft() {
        aiNode.eulerAngles.y = Float.pi
    }
    
    func turnAIRight() {
        aiNode.eulerAngles.y = 0
    }
    
    func switchAIState(state: CharacterState) {
        ai.stateMachine?.switchState((ai.stateMachine! as! NinjaStateMachine).stateInstances[state]!)
    }
    
    // TODO: needs a cooldown or else switches between back and forth too quickly
//    func moveBackAndForth() {
//        // If roll a 1, left direction
//        // If roll a 2, right direction
//        // If roll a 3, idle
//        // If exceed max deviation, move the opposite of roll direction
//
//        let roll = Int.random(in: 1...3)
//        let leftPos = aiNode.position.z - aiRunSpeed
//        let rightPos = aiNode.position.z + aiRunSpeed
//        var direction: CharacterState!
//
//        // Decide final direction to move in
//        if (roll == 1) {
//            direction = CharacterState.RunningLeft
//            if (distanceBetween(leftPos, aiPassivePosition) > aiMaxDeviationFromPassivePosition) {
//                direction = CharacterState.RunningRight
//            }
//        }
//        if (roll == 2) {
//            direction = CharacterState.RunningRight
//            if (distanceBetween(rightPos, aiPassivePosition) > aiMaxDeviationFromPassivePosition) {
//                direction = CharacterState.RunningLeft
//            }
//        }
//        if (roll == 3) {
//            direction = CharacterState.Idle
//        }
//
//        // Apply final direction to move in
//        if (direction == CharacterState.RunningLeft) {
//            if (ai.state != CharacterState.RunningLeft) {
//                switchAIState(state: CharacterState.RunningLeft)
//            }
//        }
//        if (direction == CharacterState.RunningRight) {
//            if (ai.state != CharacterState.RunningRight) {
//                switchAIState(state: CharacterState.RunningRight)
//            }
//        }
//        if (direction == CharacterState.Idle) {
//            if (ai.state != CharacterState.Idle) {
//                switchAIState(state: CharacterState.Idle)
//            }
//        }
//    }
}
