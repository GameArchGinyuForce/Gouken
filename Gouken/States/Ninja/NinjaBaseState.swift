import Foundation
import GameplayKit

protocol NinjaBaseState: State {
    var stateMachine: NinjaStateMachine! { get }
    init(_ stateMachine: NinjaStateMachine)
}

extension NinjaBaseState {
    func move(_ movement: SCNVector3, _ deltaTime: TimeInterval) {
        stateMachine.character.characterNode.localTranslate(by: movement)
    }
}
