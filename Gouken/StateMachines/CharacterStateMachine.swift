import Foundation
import GameplayKit

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
