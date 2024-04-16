import Foundation
import GameplayKit

class HealthComponent : GKComponent {
    var maxHealth: Int!
    var currentHealth: Int!
    var statsUI: GameplayStatusOverlay!
    
    
    var onHit: ((_ hitter: Character, _ damage: Int) -> Void)?
    var onDamage: [(_ damage: Int) -> Void] = []
    var onHeal: (() -> Void)?
    var onDie: (() -> Void)?
    
    init(maxHealth: Int, statsUI: GameplayStatusOverlay) {
        super.init()
        
        self.maxHealth = maxHealth
        self.statsUI = statsUI
        currentHealth = maxHealth
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func update(deltaTime seconds: TimeInterval) {    }
    
    func damage(_ amount: Int) {
        currentHealth = currentHealth - amount < 0 ? 0 : currentHealth - amount;
        
        for closure in onDamage {
            closure(amount)
        }
        
        print("whats our health here? ", currentHealth)
        if (currentHealth == 0) {
            print("do we ever die?")
            die()
        }
    }
    
    func heal(_ amount: Int) {
        currentHealth = currentHealth + amount > maxHealth ? maxHealth : currentHealth + amount;
        
        onHeal?()
    }
    
    func die() {
        onDie?()
    }
}
