import Foundation
import GameplayKit

// The base state that contains fields and methods shared by all ninja states
protocol NinjaBaseState: State {
    var stateMachine: NinjaStateMachine! { get }
    init(_ stateMachine: NinjaStateMachine)
}

extension NinjaBaseState {
    func move(_ movement: SCNVector3, _ deltaTime: TimeInterval) {
        stateMachine.character.characterNode.localTranslate(by: movement)
    }
}
