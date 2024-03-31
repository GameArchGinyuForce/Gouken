//
//  HitBoxComponent.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-30.
//

import Foundation
import GameplayKit

class HitBoxComponent : GKComponent {
    var hitboxes: [SCNNode] = [SCNNode]()
    var hitboxesDict: Dictionary = [String: SCNNode]()  // Dictionary to activate specific hitboxes
    var scene: SCNScene!
    
    init(scene: SCNScene) {
        super.init()
        self.scene = scene
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // Check hitbox collisions
        let attackerBitMask = checkCollisions(scene: self.scene)
        if attackerBitMask == -1 {
            return
        }
        
        // Check which player hit which && whether enemy is not stunned
        if (attackerBitMask == p1HitBox && GameManager.Instance().p2Character?.state != CharacterState.Stunned) {
            GameManager.Instance().p2Character?.stateMachine?.character.health.onHit?(GameManager.Instance().p1Character!, 10)
        } else if (attackerBitMask == p2HitBox && GameManager.Instance().p1Character?.state != CharacterState.Stunned) {
            GameManager.Instance().p1Character?.stateMachine?.character.health.onHit?(GameManager.Instance().p2Character!, 10)
        }
    }
    
    func addHitbox(hitbox: SCNNode) {
        hitboxes.append(hitbox)
        hitboxesDict[hitbox.name ?? ""] = hitbox
    }
    
    /**
     Returns the bitmask of the hitbox that collided with a hurtbox
     
     Returns -1 if no collision occured
     */
    func checkCollisions (scene: SCNScene?) -> Int? {
        if scene == nil {
            return -1
        }
        
        for _hitbox in hitboxes {
            if ((_hitbox.physicsBody) == nil) {
                continue
            }
            let collision = scene?.physicsWorld.contactTest(with: _hitbox.physicsBody!, options: nil)
            if (collision != nil && !collision!.isEmpty) {
                print("First detected collision:", collision?[0])
                return collision?[0].nodeA.categoryBitMask
                
            }
        }
        return -1
    }
    
    /**
     Activates the hitboxes of the character
     
     There was a inconsistency where if a hitbox is hidden while still colliding with another
     physics body, a collision would continuously happen even if the player moved away.
     To fix this, I removed and replaced the physics body of the hitbox SCNNode. This "updates"
     the node to ensure that collisions behave consistently
     */
    func activateHitboxes() {
        for _hitbox in hitboxes {
            // Remove & Add physics body
            let originalPhysicsBody = _hitbox.physicsBody
            _hitbox.physicsBody = nil
            _hitbox.physicsBody = originalPhysicsBody
            
            _hitbox.isHidden = false
        }
    }
    
    /**
     Activate a player's hitbox by its name
     
     The name of a hitbox is the same as the SCNNode's name it is
     a child of on the character model
     */
    func activateHitboxByName(name: String) {
        let hitbox: SCNNode? = hitboxesDict[name]
        print(hitbox)
        
        if (hitbox == nil) {
            print("Not hitbox found with name: ", name)
            return
        }
        
        // Remove & Add physics body
        let originalPhysicsBody = hitbox!.physicsBody
        hitbox!.physicsBody = nil
        hitbox!.physicsBody = originalPhysicsBody
        
        hitbox!.isHidden = false
    }
    
    /**
     Deactivates the hitboxes of the character
     
     See activateHitboxes() docs for more info
     */
    func deactivateHitboxes() {
        for _hitbox in hitboxes {
            // Remove & Add physics body
            let originalPhysicsBody = _hitbox.physicsBody
            _hitbox.physicsBody = nil
            _hitbox.physicsBody = originalPhysicsBody
            
            _hitbox.isHidden = true
        }
    }
}
