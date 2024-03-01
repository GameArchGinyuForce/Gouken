import Foundation
import GameplayKit

class BaikenWalkState: BaikenBaseState {
    var stateMachine: BaikenStateMachine
    
    required init(_ stateMachine: BaikenStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter BaikenWalkState")
    }
    
    func tick(_ deltaTime: TimeInterval) {
        move(SCNVector3(-0.01, -0.01, -0.01), deltaTime)
    }
    
    func exit() {
        print("exit BaikenWalkState")
    }
}
