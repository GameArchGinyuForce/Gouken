import Foundation
import GameplayKit

class NinjaRunningState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter NinjaRunningState")
        stateMachine.character.setState(withState: CharacterState.Running)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.Running]!, loop: true)
    }
    
    func tick(_ deltaTime: TimeInterval) {
    }
    
    func exit() {
        print("exit NinjaRunningState")
    }
}
