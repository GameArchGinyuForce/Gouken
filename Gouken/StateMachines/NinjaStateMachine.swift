import Foundation
import GameplayKit

class NinjaStateMachine: CharacterStateMachine {
    
    override init(_ character: Character) {
        super.init(character)
        
        character.health.onDamage = {
            self.switchState(NinjaStunnedState(self))
        }
        character.health.onDie = {
            self.switchState(NinjaDownedState(self))
        }
        
        switchState(NinjaIdleState(self))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
