import Foundation
import GameplayKit

class NinjaStateMachine: CharacterStateMachine {
    
    init(_ characterNode: SCNNode) {
        super.init()
        
        character = characterNode
        
        health = HealthComponent(maxHealth: 100)
        health?.onDamage = {
            self.switchState(NinjaStunnedState(self))
        }
        health?.onDie = {
            self.switchState(NinjaDownedState(self))
        }
        
        self.switchState(NinjaIdleState(self))
    }
}
