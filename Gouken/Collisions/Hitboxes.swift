//
//  Hitboxes.swift
//  Gouken
//
//  Created by Jeff Phan on 2024-03-09.
//

import SceneKit

func initHitboxAttack(
    playerSpawn:SCNNode?,
    width: CGFloat = 1.0,
    height: CGFloat = 1.0,
    length: CGFloat = 1.0,
    position: SCNVector3 = SCNVector3(0, 0, 0)
){
    // create hit box node with geometry
    let hitboxGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
    let hitboxNode = SCNNode(geometry: hitboxGeometry)
    hitboxNode.name = "hitboxNode"
    
    hitboxNode.scale = SCNVector3(100, 100, 100) // Scale up by a factor of 10 in all directions
    
//    hitboxNode.position.z = 1.0
//    hitboxNode.position.y = 1.0
    hitboxNode.position = position;
    hitboxNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: hitboxGeometry, options: nil))
    hitboxNode.physicsBody?.isAffectedByGravity = false
    
//    hitboxNode.physicsBody?.categoryBitMask = 4
//    hitboxNode.physicsBody?.collisionBitMask = 2
    
    hitboxNode.physicsBody?.categoryBitMask = 1
    hitboxNode.physicsBody?.collisionBitMask = 2

    
    // create a visible hitbox
    let redColor = UIColor.red.withAlphaComponent(0.5) // Adjust the alpha value for transparency
    let redTransparentMaterial = SCNMaterial()
    redTransparentMaterial.diffuse.contents = redColor
    hitboxNode.geometry?.materials = [redTransparentMaterial]

    // attach the hitbox to the playerSpawn node
    playerSpawn?.addChildNode(hitboxNode)
}
