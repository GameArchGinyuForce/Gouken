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
//        AudioManager.Instance().playEffectSoundByURL(fileName: "Running", ext: ".mp3")

    }
    
    func tick(_ deltaTime: TimeInterval) {
//        //let r = x.truncatingRemainder(dividingBy: 0.75)
//        if (stateMachine.character.animator.currentTimeNormalized.truncatingRemainder(dividingBy: 1.0) == 0) {
//            AudioManager.Instance().playEffectSoundByURL(fileName: "Running", ext: ".mp3")
//        }
    }
    
    func exit() {
//        AudioManager.Instance().st
        print("exit NinjaRunningState")
    }
}
