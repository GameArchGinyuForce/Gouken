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
        
        // Move to player, attack if within range
        if (distanceToPlayer() <= aiAttackRange) {
            if (ai.state != CharacterState.Attacking && !isAIAttackOnCooldown) {
                switchAIState(state: CharacterState.Attacking)
                isAIAttackOnCooldown = true
            }
        } else {
            if (canAIMove()) {
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
        if (Int.random(in: 1..<10) == 1) {
            
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
