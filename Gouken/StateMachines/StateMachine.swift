import Foundation
import GameplayKit

class StateMachine {
    var currentState: State?
    
    func switchState(_ newState: State) {
        currentState?.exit()
        currentState = newState
        currentState?.enter()
    }
    
    func update(_ deltaTime: TimeInterval) {
        currentState?.tick(deltaTime)
    }
}
