//
//  HitBoxComponent.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-30.
//

import Foundation
import GameplayKit

// hit Box Component that handles the hitbox/hurtbox
class HitBoxComponent : GKComponent {
    var hitboxes: [SCNNode] = [SCNNode]()
    var hitboxesDict: Dictionary = [String: SCNNode]()  // Dictionary to activate specific hitboxes
    var scene: SCNScene!
    var damage: Int = 0
    var statsUI: GameplayOverlay!
    
    init(scene: SCNScene, statsUI: GameplayOverlay) {
        super.init()
        self.scene = scene
        self.statsUI = statsUI
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /**
     Checks for collisions for characters hitboxes every tick
    */
    override func update(deltaTime seconds: TimeInterval) {
        // Check hitbox collisions
        let contactBitMask = checkCollisions(scene: self.scene)
        
        if contactBitMask == -1 {
            return
        }
        
        let p2HitBool = p1Side == PlayerType.P1 ? (p2HitBox | p1HurtBox) : (p1HitBox | p2HurtBox)
        let p1HitBool = p1Side == PlayerType.P1 ? (p1HitBox | p2HurtBox) : (p2HitBox | p1HurtBox)
                
        // Check which player hit which && whether enemy is not stunned
        if (contactBitMask == p2HitBool && GameManager.Instance().p2Character?.state != CharacterState.Stunned) {
            GameManager.Instance().p2Character?.stateMachine?.character.health.onHit?(GameManager.Instance().p1Character!, GameManager.Instance().p1Character!.hitbox.damage)

        } else if (contactBitMask == p1HitBool && GameManager.Instance().p1Character?.state != CharacterState.Stunned) {
            
            GameManager.Instance().p1Character?.stateMachine?.character.health.onHit?(GameManager.Instance().p2Character!, GameManager.Instance().p2Character!.hitbox.damage)
        }
    }
    
    // Appends hitboxes to the player
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
            let enemyHurtBox = _hitbox.physicsBody!.categoryBitMask == p1HitBox ? p2HurtBox : _hitbox.physicsBody!.collisionBitMask
            if ((_hitbox.physicsBody) == nil) {
                continue
            }
            
            let collision = scene?.physicsWorld.contactTest(with: _hitbox.physicsBody!, options: [SCNPhysicsWorld.TestOption.collisionBitMask: enemyHurtBox])
            if (collision != nil && !collision!.isEmpty) {
                for coll in collision! {
                    
                    if coll.nodeA.physicsBody!.contactTestBitMask != coll.nodeB.physicsBody!.categoryBitMask {
                        continue
                    }
                    return (coll.nodeA.physicsBody!.categoryBitMask) | (coll.nodeB.physicsBody!.categoryBitMask)
                    
                }
            }
            
            var hurtBoxes = GameManager.Instance().p2Character!.hurtBoxes
            if (GameManager.Instance().matchType == MatchType.MP) {
                hurtBoxes = _hitbox.physicsBody!.categoryBitMask == p2HitBox ? GameManager.Instance().p1Character!.hurtBoxes : GameManager.Instance().p2Character!.hurtBoxes
            }
            
            for _hurtBox in hurtBoxes {
                var colls = scene?.physicsWorld.contactTestBetween(_hitbox.physicsBody!, _hurtBox.physicsBody!)
                if (colls != nil && !colls!.isEmpty) {
                    for coll in colls! {
                        
                        if coll.nodeA.physicsBody!.contactTestBitMask != coll.nodeB.physicsBody!.categoryBitMask {
                            continue
                        }
                        
                        return (coll.nodeA.physicsBody!.categoryBitMask) | (coll.nodeB.physicsBody!.categoryBitMask)
                        
                    }
                }
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
        
        if (hitbox == nil) {
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
