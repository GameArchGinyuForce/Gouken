import Foundation
import GameplayKit

class AIComponent : GKEntity {
    var player: Character!
    var ai: Character!
    var playerNode: SCNNode!
    var aiNode: SCNNode!
    
    var aiRunSpeed = Float(0.01)
    var aiAttackRange = Float(1.25)
    var isAIAttackOnCooldown = false
    let aiAttackCooldown = 3.0
    var aiAttackTimer: Double!
    
    init(player: Character, ai: Character) {
        super.init()
        
        self.player = player
        self.ai = ai
        playerNode = player.characterNode.parent!
        aiNode = ai.characterNode.parent!
        
        aiAttackTimer = aiAttackCooldown
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        tickAIAttackTimer(seconds)
        
        // Block if player is attacking
        if (player.state == CharacterState.Attacking || player.state == CharacterState.HeavyAttacking) {
            tryBlock()
        } else {
            if (ai.state == CharacterState.Blocking) {
                switchAIState(state: CharacterState.Idle)
            }
        }
        
        // Move to player, attack if within range
        if (distanceToPlayer() <= aiAttackRange) {
            
            // If player is attack, try move out of range
            if (isPlayerAttacking()) {
                tryDash()
            }
            
            // Attack if not already attacking and attack is not on cooldown
            if (ai.state != CharacterState.Attacking && !isAIAttackOnCooldown) {
                switchAIState(state: CharacterState.Attacking)
                isAIAttackOnCooldown = true
            }
        } else {
            if (canAIMove() && !isPlayerAttacking()) {
                moveToPlayer()
            }
        }
        
        // AI direction
        if (isPlayerOnLeftSide()) {
            turnAILeft()
        } else {
            turnAIRight()
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
        if (canAIBlock() && Int.random(in: 1..<100) == 1) {
            switchAIState(state: CharacterState.Blocking)
        }
    }
    
    func tickAIAttackTimer(_ seconds: TimeInterval) {
        if (isAIAttackOnCooldown) {
            aiAttackTimer -= seconds
            if (aiAttackTimer <= 0) {
                isAIAttackOnCooldown = false
                aiAttackTimer = aiAttackCooldown
            }
        }
    }
    
    func moveToPlayer() {
        if (isPlayerOnLeftSide()) {
            if (ai.state != CharacterState.RunningLeft) {
                switchAIState(state: CharacterState.RunningLeft)
            }
            aiNode.position.z -= aiRunSpeed
        } else {
            if (ai.state != CharacterState.RunningRight) {
                switchAIState(state: CharacterState.RunningRight)
            }
            aiNode.position.z += aiRunSpeed
        }
    }
    
    func canAIMove() -> Bool {
        return ai.state == CharacterState.Idle
    }
    
    func canAIDash() -> Bool {
        if (ai.state != CharacterState.DashingLeft &&
            ai.state != CharacterState.DashingRight &&
            ai.state != CharacterState.Attacking) {
            return true
        }
        return false
    }
    
    func canAIBlock() -> Bool {
        if (ai.state != CharacterState.Blocking &&
            ai.state != CharacterState.DashingLeft &&
            ai.state != CharacterState.DashingRight) {
            return true
        }
        return false
    }
    
    func isPlayerAttacking() -> Bool {
        return player.state == CharacterState.Attacking || player.state == CharacterState.HeavyAttacking
    }
    
    func distanceToPlayer() -> Float {
        return abs(playerNode.position.z - aiNode.position.z)
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
}
