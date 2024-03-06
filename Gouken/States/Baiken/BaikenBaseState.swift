import Foundation
import GameplayKit

protocol BaikenBaseState: State {
    var stateMachine: BaikenStateMachine { get }
    init(_ stateMachine: BaikenStateMachine)
}

extension BaikenBaseState {
    func move(_ movement: SCNVector3, _ deltaTime: TimeInterval) {
        stateMachine.character?.localTranslate(by: movement)
    }
}
