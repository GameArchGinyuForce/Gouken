import Foundation
import GameplayKit

class NinjaDashingLeftState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    let dashDuration = 0.3
    var dashDistancePerTick = Float(0.1)
    var dashProgress = 0.0
    
    var player1Node: SCNNode
    var player2Node: SCNNode
    var cameraNode: SCNNode
    
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
        self.player1Node = stateMachine.character.parentNode
        self.player2Node = GameManager.Instance().otherCharacter(character:stateMachine.character).parentNode
        
        self.cameraNode = GameManager.Instance().cameraNode!
    }
    
    func enter() {
        print("enter NinjaDashingLeftState")
        dashProgress = 0.0
        
        stateMachine.character.setState(withState: CharacterState.DashingLeft)
        if (player1Node.position.z - player2Node.position.z) < 0 {
            stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.DashingLeft]!, loop: false)
        } else {
            stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.DashingRight]!, loop: false)
        }
        
        // Hardcoded retrieval of move
        let move: CharacterMove = NinjaMoveSet[CharacterState.DashingLeft]!
        move.addAttackKeyFramesAsAnimationEvents(stateMachine: stateMachine)
    }
    
    func tick(_ deltaTime: TimeInterval) {
        dashProgress += deltaTime
        
        if (boundCheckWorld(player1Pos: player1Node.position.z, player2Pos: player2Node.position.z, newPos: player1Node.position.z - Float(dashDistancePerTick)) &&
            boundCheckCamera(player1Pos: player1Node.position.z, player2Pos: player2Node.position.z, newPos: player1Node.position.z - Float(dashDistancePerTick), cameraPos: cameraNode.position.z)) {
            player1Node.position.z =  player1Node.position.z - Float(dashDistancePerTick)
        }
     
        
        
        
        if (stateMachine.character.animator.currentTimeNormalized >= 1.0 || dashProgress >= dashDuration) {
            stateMachine.switchState(stateMachine.stateInstances[CharacterState.Idle]!)
        }
    }
    
    func exit() {
        print("exit NinjaDashingLeftState")
        stateMachine.character?.hitbox.deactivateHitboxes()    // Clears hitboxes if dash state disrupted
        stateMachine.character?.hitbox.activateHurtboxes()    // Clears hurtboxes if dash state disrupted
    }
}
