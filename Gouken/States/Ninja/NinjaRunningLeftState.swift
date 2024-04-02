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

        if(stateMachine.character.parentNode.eulerAngles.y == Float.pi){
            stateMachine.character.animator.setSpeed(0.8)
        }else if(stateMachine.character.parentNode.eulerAngles.y == 0){
            stateMachine.character.parentNode.eulerAngles.x -= 0.25
            stateMachine.character.animator.setSpeed(-0.8)
        }
    }
    
    func tick(_ deltaTime: TimeInterval) {
       
    }
    
    func exit() {
        stateMachine.character.animator.setSpeed(1)
        if(stateMachine.character.parentNode.eulerAngles.y == 0){
            stateMachine.character.parentNode.eulerAngles.x += 0.25
        }
        print("exit NinjaRunningState")
    }
}
