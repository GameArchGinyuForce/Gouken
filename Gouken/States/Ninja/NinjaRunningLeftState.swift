import Foundation
import GameplayKit

class NinjaRunningLeftState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter NinjaRunningState")
        stateMachine.character.setState(withState: CharacterState.RunningLeft)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.RunningLeft]!, loop: true)

    }
    
    func tick(_ deltaTime: TimeInterval) {
    }
    
    func exit() {
        print("exit NinjaRunningState")
    }
}
