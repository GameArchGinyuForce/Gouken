import Foundation
import GameplayKit

// Health Component that stores health info of the players
class HealthComponent : GKComponent {
    var maxHealth: Int!
    var currentHealth: Int!
    var statsUI: GameplayOverlay!
    
    
    var onHit: ((_ hitter: Character, _ damage: Int) -> Void)?
    var onDamage: [() -> Void] = []
    var onHeal: (() -> Void)?
    var onDie: (() -> Void)?
    
    // Initializes the max health of a player
    init(maxHealth: Int, statsUI: GameplayOverlay) {
        super.init()
        
        self.maxHealth = maxHealth
        self.statsUI = statsUI
        currentHealth = maxHealth
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func update(deltaTime seconds: TimeInterval) {    }
    
    // Function that handles the damage taken on a player, reduces the current health provided the amount of damage taken
    func damage(_ amount: Int) {
        currentHealth = currentHealth - amount < 0 ? 0 : currentHealth - amount;
        
        for closure in onDamage {
            closure()
        }
        
        print("whats our health here? ", currentHealth)
        if (currentHealth == 0) {
            print("do we ever die?")
            die()
        }
    }
    
    // Heals the player
    func heal(_ amount: Int) {
        currentHealth = currentHealth + amount > maxHealth ? maxHealth : currentHealth + amount;
        
        onHeal?()
    }
    
    // Function that handles the death of a player
    func die() {
        onDie?()
    }
}
