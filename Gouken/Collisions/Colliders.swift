//
//  Colliders.swift
//  Gouken
//
//  Created by Jeff Phan on 2024-03-09.
//

import SceneKit

//let floorMask: Int = 1 << 0  // Binary value: 00000001 (Category 1)
//let p1HitboxMask: Int = 1 << 1  // Binary value: 00000010 (Category 2)
//let p1HurtboxMask: Int = 1 << 2  // Binary value: 00000100 (Category 3)
//let p2HurtboxMask: Int = 1 << 3  // Binary value: 00001000 (Category 4)
//let p2HitboxMask: Int = 1 << 4  // Binary value: 00010000 (Category 5)
//let p1MeshMask: Int = 1 << 5  // Binary value: 00100000 (Category 6)
//let p2MeshMask: Int = 1 << 6  // Binary value: 01000000 (Category 7)

let floorMask: Int = 1 << 2  // Binary value: 00000001 (Category 1)
let p1HitboxMask: Int = 1 << 3  // Binary value: 00000010 (Category 2)
let p1HurtboxMask: Int = 1 << 4  // Binary value: 00000100 (Category 3)
let p2HurtboxMask: Int = 1 << 5  // Binary value: 00001000 (Category 4)
let p2HitboxMask: Int = 1 << 6  // Binary value: 00010000 (Category 5)
let p1MeshMask: Int = 1 << 7  // Binary value: 00100000 (Category 6)
let p2MeshMask: Int = 1 << 8  // Binary value: 01000000 (Category 7)


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
    
    player1?.physicsBody?.categoryBitMask = p1MeshMask
    player1?.physicsBody?.collisionBitMask = floorMask | p2MeshMask

    player2?.physicsBody?.categoryBitMask = p2MeshMask
    player2?.physicsBody?.collisionBitMask = floorMask | p1MeshMask
//    player2?.physicsBody?.categoryBitMask = 2  // Assuming player2 is in category 2
//    player2?.physicsBody?.collisionBitMask = 1 // Assuming floor is in category 1
}

func initWorld(scene:SCNScene){
    // init floor physics
    let floor = scene.rootNode.childNode(withName: "floor", recursively: true)!
    floor.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    floor.physicsBody?.categoryBitMask = floorMask
    floor.physicsBody?.collisionBitMask = p1MeshMask | p2MeshMask
}
