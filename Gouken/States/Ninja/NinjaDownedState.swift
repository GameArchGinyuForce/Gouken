import Foundation
import GameplayKit

class NinjaDownedState: NinjaBaseState {
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
        print("enter NinjaDownedState")
        animPlayer = playAnimation(onNode: stateMachine.character!, withSCNFile: characterAnimations[CharacterName.Ninja]![CharacterState.Downed]!)
        animDuration = animPlayer?.animation.duration
    }
    
    func tick(_ deltaTime: TimeInterval) {
    }
    
    func exit() {
        print("exit NinjaDownedState")
        StopAnimation(onNode: stateMachine.character!)
    }
}
