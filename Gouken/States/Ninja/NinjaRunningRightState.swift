import Foundation
import GameplayKit

class NinjaRunningRightState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        
        stateMachine.character.setState(withState: CharacterState.RunningRight)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.RunningRight]!, loop: true)
        
        if(stateMachine.character.parentNode.eulerAngles.y == Float.pi){
            stateMachine.character.parentNode.eulerAngles.x -= 0.25
            stateMachine.character.animator.setSpeed(-0.8)
        }else if(stateMachine.character.parentNode.eulerAngles.y == 0){
            
            stateMachine.character.animator.setSpeed(0.8)
        }
    }
    
    func tick(_ deltaTime: TimeInterval) {
        
    }
    
    func exit() {
        stateMachine.character.parentNode.eulerAngles.x = 0.0
        stateMachine.character.animator.setSpeed(1)
        
    }
}
