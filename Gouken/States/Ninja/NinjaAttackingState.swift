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
    }
    
    func tick(_ deltaTime: TimeInterval) {
        if (stateMachine.character.animator.currentTimeNormalized >= 1.0) {
            stateMachine.switchState(NinjaIdleState(stateMachine))
        }
    }
    
    func exit() {
        print("exit NinjaAttackingState")
    }
}
