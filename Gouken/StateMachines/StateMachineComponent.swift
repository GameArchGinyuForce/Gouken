import Foundation
import GameplayKit

class StateMachineComponent: GKComponent {
    var currentState: State?
    
    func switchState(_ newState: State) {
        currentState?.exit()
        currentState = newState
        currentState?.enter()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        currentState?.tick(seconds)
    }
}
