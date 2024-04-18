import Foundation
import GameplayKit

// Manages state transitions and updates for game entities using a finite state machine
class StateMachineComponent: GKComponent {
    var currentState: State?
    
    // Switches from the current state to a new state
    func switchState(_ newState: State) {
        currentState?.exit()
        currentState = newState
        currentState?.enter()
    }
    
    // Progresses the current state
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        currentState?.tick(seconds)
    }
}
