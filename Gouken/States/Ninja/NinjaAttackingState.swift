import Foundation
import GameplayKit

class NinjaAttackingState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter NinjaAttackingState")
        stateMachine.character.setState(withState: CharacterState.Attacking)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.Attacking]!, loop: false)
        
        // Hardcoded retrieval of move
        let move = NinjaMoveSet[3]
        
        move.addAttackKeyFramesAsAnimationEvents(stateMachine: stateMachine)
    }
    
    // TODO: Turn on hitboxes at certain points
    func tick(_ deltaTime: TimeInterval) {
        if (stateMachine.character.animator.currentTimeNormalized >= 1.0) {
            stateMachine.switchState(stateMachine.stateInstances[CharacterState.Idle]!)
        }
    }
    
    func exit() {
        print("exit NinjaAttackingState")
        stateMachine.character?.hitbox.deactivateHitboxes()    // Clears hitboxes if attack state disrupted
    }
}
