import Foundation
import GameplayKit

protocol State {
    func enter()
    func tick(_ deltaTime: TimeInterval)
    func exit()
}
