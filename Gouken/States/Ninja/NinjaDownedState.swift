import Foundation
import GameplayKit

class NinjaDownedState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter NinjaDownedState")
        
        AudioManager.Instance().playEffectSound(audio: AudioDict.Downed)
        
        stateMachine.character.setState(withState: CharacterState.Downed)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.Downed]!, loop: true)
    }
    
    func tick(_ deltaTime: TimeInterval) {
    }
    
    func exit() {
        print("exit NinjaDownedState")
    }
}
