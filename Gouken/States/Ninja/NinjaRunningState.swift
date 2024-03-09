import Foundation
import GameplayKit

class NinjaRunningState: NinjaBaseState {
    var stateMachine: NinjaStateMachine
    var animDuration: TimeInterval!
    var animTimer: TimeInterval!
    var animPlayer: SCNAnimationPlayer?
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
        
        animDuration = 0
        animTimer = 0
    }
    
    func enter() {
        print("enter NinjaRunningState")
        animPlayer = playAnimation(onNode: stateMachine.character!, withSCNFile: characterAnimations[CharacterName.Ninja]![CharacterState.Running]!)
        animDuration = animPlayer?.animation.duration
    }
    
    func tick(_ deltaTime: TimeInterval) {
    }
    
    func exit() {
        print("exit NinjaRunningState")
        StopAnimation(onNode: stateMachine.character!)
    }
}
