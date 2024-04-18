import Foundation
import GameplayKit

// Defines a protocol for state objects used in a state machine
protocol State {
    // Called when the state is entered
    func enter()

    // Called on each update cycle
    func tick(_ deltaTime: TimeInterval)

    // Called when the state is exited
    func exit()
}
