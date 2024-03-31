import Foundation
import GameplayKit

class NinjaStunnedState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter NinjaStunnedState")
        stateMachine.character.setState(withState: CharacterState.Stunned)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.Stunned]!, loop: false)
    }
    
    func tick(_ deltaTime: TimeInterval) {
        if (stateMachine.character.animator.currentTimeNormalized >= 1.0) {
            stateMachine.switchState(stateMachine.stateInstances[CharacterState.Idle]!)
        }
    }
    
    func exit() {
        print("exit NinjaStunnedState")
    }
}
