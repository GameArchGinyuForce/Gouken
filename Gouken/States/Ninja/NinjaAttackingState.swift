import Foundation
import GameplayKit

class NinjaAttackingState: NinjaBaseState {
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
        print("enter NinjaAttackingState")
        animPlayer = playAnimation(onNode: stateMachine.character!, withSCNFile: characterAnimations[CharacterName.Ninja]![CharacterState.Attacking]!)
        animDuration = animPlayer?.animation.duration
    }
    
    func tick(_ deltaTime: TimeInterval) {
        animTimer? += deltaTime

        if (animTimer >= animDuration) {
            stateMachine.switchState(NinjaIdleState(stateMachine))
        }
    }
    
    func exit() {
        print("exit NinjaAttackingState")
        StopAnimation(onNode: stateMachine.character!)
    }
}
