//
//  Colliders.swift
//  Gouken
//
//  Created by Jeff Phan on 2024-03-09.
//

import SceneKit


/**
 Important notes about Gouken physics:
 - We only use the base SceneKit physics simulation for moving the meshes, handling body-blocking, and
   stopping them from falling through the floor.
 
 - We utilize sensors (think Unity triggers) for our actual Hitbox and Hurtbox implementation, with the BitMasks
   defined below.
 */


/* Below we define all of our bitmasks. Nathan and Jas worked on this in crunch-time,
 consider verifying for best practices later. */

// IMPORTANT NOTE: FUCK YOU APPLE, 64 IS MAXIMUM SIZE FOR BIT MASKS.
let floorBitMask = 1 << 5       // Binary: 00000010
let p1MeshBitMask = 1 << 4      // Binary: 00001000
let p2MeshBitMask = 1 << 6      // Binary: 01000000


// Hitboxes and Hurtboxes bitmasks.
let p1HitBox = 1 << 0           // Binary: 00000001
let p2HitBox = 1 << 1      // Binary: 00100000
let p1HurtBox = 8          // Binary: 00010000
let p2HurtBox = 1 << 2          // Binary: 00000100



func initPlayerPhysics(player1:SCNNode?, player2:SCNNode?){
    player1?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    player2?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)

    //prevents wobbly behaviours by locking rotation
    player2?.physicsBody?.angularVelocityFactor = SCNVector3(0, 0, 0)
    player2?.physicsBody?.allowsResting = true
    
    //prevents wobbly behaviours by locking rotation
    player1?.physicsBody?.angularVelocityFactor = SCNVector3(0, 0, 0)
    player1?.physicsBody?.allowsResting = true
    
    // locks lateral movement
    player1?.physicsBody?.velocity.x = 0
    player1?.physicsBody?.velocity.y = 0
    player1?.physicsBody?.velocity.z = 0
    
    // locks lateral movement
    player2?.physicsBody?.velocity.x = 0
    player2?.physicsBody?.velocity.y = 0
    player2?.physicsBody?.velocity.z = 0
    
    player1?.physicsBody?.categoryBitMask = p1MeshBitMask
    player1?.physicsBody?.collisionBitMask = floorBitMask | p2MeshBitMask

    player2?.physicsBody?.categoryBitMask = p2MeshBitMask
    player2?.physicsBody?.collisionBitMask = floorBitMask | p1MeshBitMask
}

func initWorld(scene:SCNScene){
    // init floor physics
    let floor = scene.rootNode.childNode(withName: "floor", recursively: true)!
    floor.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    floor.physicsBody?.categoryBitMask = floorBitMask
    floor.physicsBody?.collisionBitMask = p1MeshBitMask | p2MeshBitMask
}
