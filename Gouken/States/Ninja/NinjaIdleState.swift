import Foundation
import GameplayKit

// Handles animations and logic related to ninja's idle state
class NinjaIdleState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        stateMachine.character.setState(withState: CharacterState.Idle)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.Idle]!, loop: true)
    }
    
    func tick(_ deltaTime: TimeInterval) {
    }
    
    func exit() {
    }
}
