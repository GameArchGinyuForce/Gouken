import Foundation
import GameplayKit

class NinjaBlockingState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter NinjaBlockingState")
        
        AudioManager.Instance().playEffectSound(audio: AudioDict.Guard)
        
        stateMachine.character.setState(withState: CharacterState.Blocking)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.Blocking]!, loop: true)
    }
    
    func tick(_ deltaTime: TimeInterval) {
    }
    
    func exit() {
        print("exit NinjaBlockingState")
    }
}
