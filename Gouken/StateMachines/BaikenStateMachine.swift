import Foundation
import GameplayKit

class BaikenStateMachine: CharacterStateMachine {
    var baikenStates: [BaikenBaseState.Type] = [
        BaikenIdleState.self,
        BaikenWalkState.self
    ]
    
    init(_ characterNode: SCNNode) {
        super.init()
        
        character = characterNode
        
        switchState(BaikenIdleState(self))
    }
    
    func exampleStateChange() {
        if ((currentState as? BaikenIdleState) != nil) {
            switchState(baikenStates[1].init(self))
        } else {
            switchState(baikenStates[0].init(self))
        }
    }
}
