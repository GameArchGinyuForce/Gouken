import Foundation
import GameplayKit

class HealthComponent : GKComponent {
    var maxHealth: Int!
    var currentHealth: Int!
    
    var onHit: ((_ hitter: Character, _ damage: Int) -> Void)?
    var onDamage: (() -> Void)?
    var onHeal: (() -> Void)?
    var onDie: (() -> Void)?
    
    init(maxHealth: Int) {
        super.init()
        
        self.maxHealth = maxHealth
        currentHealth = maxHealth
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
    }
    
    func damage(_ amount: Int) {
        currentHealth = currentHealth - amount < 0 ? 0 : currentHealth - amount;
        
        onDamage?()
        
        if (currentHealth == 0) {
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
