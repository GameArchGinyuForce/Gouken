import Foundation
import GameplayKit

class NinjaDashingRightState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    let dashDuration = 0.3
    let dashDistancePerTick = Float(0.1)
    var dashProgress = 0.0
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter NinjaDashingRightState")
        dashProgress = 0.0
        
        stateMachine.character.setState(withState: CharacterState.DashingRight)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.DashingRight]!, loop: false)
    }
    
    func tick(_ deltaTime: TimeInterval) {
        dashProgress += deltaTime
        stateMachine.character.characterNode.parent!.position.z += dashDistancePerTick
        
        if (stateMachine.character.animator.currentTimeNormalized >= 1.0 || dashProgress >= dashDuration) {
            stateMachine.switchState(stateMachine.stateInstances[CharacterState.Idle]!)
        }
    }
    
    func exit() {
        print("exit NinjaDashingRightState")
    }
}
