//
//  HitBoxComponent.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-30.
//

import Foundation
import GameplayKit

class HitBoxComponent : GKComponent {
//    var activateHitboxes: (() -> Void)?
//    var deactivateHitboxes: (() -> Void)?
    var hitboxes: [SCNNode] = [SCNNode]()
    var hitboxesDict: Dictionary = [String: SCNNode]()  // Dictionary to activate specific hitboxes
    
    init(_ smt: Bool) {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
    }
    
    func addHitbox(hitbox: SCNNode) {
        hitboxes.append(hitbox)
        hitboxesDict[hitbox.name ?? ""] = hitbox
    }
    
    func checkCollisions (scene: SCNScene?) -> Bool{
        
        if scene == nil {
            return false
        }
        
        for _hitbox in hitboxes {
            if ((_hitbox.physicsBody) == nil) {
                continue
            }
            let collision = scene?.physicsWorld.contactTest(with: _hitbox.physicsBody!, options: nil)
            if (collision != nil && !collision!.isEmpty) {
                print("First detected collision:", collision?[0])
                return true
            }
        }
        return false
    }
    
    /**
     Activates the hitboxes of the character
     
     There was a inconsistency where if a hitbox is hidden while still colliding with another
     physics body, a collision would continuously happen even if the player moved away.
     To fix this, I removed and replaced the physics body of the hitbox SCNNode. This "updates"
     the node to ensure that collisions behave consistently
     */
    func activateHitboxes() {
        print("Activating hitboxes")
        for _hitbox in hitboxes {
            // Remove & Add physics body
            let originalPhysicsBody = _hitbox.physicsBody
            _hitbox.physicsBody = nil
            _hitbox.physicsBody = originalPhysicsBody
            
            _hitbox.isHidden = false
        }
        print("Completed Activating hitboxes")
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
        print("Deactivating hitboxes")
        for _hitbox in hitboxes {
            // Remove & Add physics body
            let originalPhysicsBody = _hitbox.physicsBody
            _hitbox.physicsBody = nil
            _hitbox.physicsBody = originalPhysicsBody
            
            _hitbox.isHidden = true
        }
        print("Completed Deactivating hitboxes")
    }
}