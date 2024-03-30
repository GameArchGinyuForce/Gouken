//
//  Colliders.swift
//  Gouken
//
//  Created by Jeff Phan on 2024-03-09.
//

import SceneKit


// Below we define all of our bitmasks.

// Unrelated to core game logic, just to stop characters
// from falling through the floor and to let them body-block eachother's
// movement.
let floorBitMask = 1 << 1
let p1MeshBitMask = 1 << 3
let p2MeshBitMask = 1 << 5


// Hitboxes and Hurtboxes bitmasks.
let p1HitBox = 1 << 0
let p2HitBox = 1 << 6
let p1HurtBox = 1 << 4
let p2HurtBox = 1 << 2



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
