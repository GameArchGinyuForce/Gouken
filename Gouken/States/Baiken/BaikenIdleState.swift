import Foundation
import GameplayKit

class BaikenIdleState: BaikenBaseState {
    var stateMachine: BaikenStateMachine
    
    required init(_ stateMachine: BaikenStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter BaikenIdleState")
    }
    
    func tick(_ deltaTime: TimeInterval) {
        move(SCNVector3(0.01, 0.01, 0.01), deltaTime)
    }
    
    func exit() {
        print("exit BaikenIdleState")
    }
}
