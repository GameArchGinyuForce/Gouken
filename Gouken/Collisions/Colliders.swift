//
//  Colliders.swift
//  Gouken
//
//  Created by Jeff Phan on 2024-03-09.
//

import SceneKit


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
    
    player1?.physicsBody?.categoryBitMask = 1
    player1?.physicsBody?.collisionBitMask = 3

    player2?.physicsBody?.categoryBitMask = 2
    player2?.physicsBody?.collisionBitMask = 3
}

func initWorld(scene:SCNScene){
    // init floor physics
    let floor = scene.rootNode.childNode(withName: "floor", recursively: true)!
    floor.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    floor.physicsBody?.categoryBitMask = 1
    floor.physicsBody?.collisionBitMask = 3
}
