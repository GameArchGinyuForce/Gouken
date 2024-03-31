import Foundation
import GameplayKit

class NinjaRunningRightState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter NinjaRunningState")
        stateMachine.character.setState(withState: CharacterState.RunningRight)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.RunningRight]!, loop: true)
    }
    
    func tick(_ deltaTime: TimeInterval) {
    }
    
    func exit() {
        print("exit NinjaRunningState")
    }
}
