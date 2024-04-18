import Foundation
import GameplayKit

// A state machine for handling the states of any character
class CharacterStateMachine: StateMachineComponent {
    var character: Character!
    
    init(_ character: Character) {
        super.init()
        
        self.character = character
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
