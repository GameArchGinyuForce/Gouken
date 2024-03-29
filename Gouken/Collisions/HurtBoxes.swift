//
//  HurtBoxes.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-28.
//

import SceneKit

func initHurtboxAttack(
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
//    hitboxNode.position.z = 1.0
//    hitboxNode.position.y = 1.0
    hitboxNode.position = position;
    hitboxNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: hitboxGeometry, options: nil))
    hitboxNode.physicsBody?.isAffectedByGravity = false
    
//    hitboxNode.physicsBody?.categoryBitMask = 4
//    hitboxNode.physicsBody?.collisionBitMask = 2
    hitboxNode.physicsBody?.categoryBitMask = 2 // Assuming hurt boxes are in category 2
    hitboxNode.physicsBody?.collisionBitMask = 1 // Set collision bit mask to include category 1 (hotboxes)
    

    
    // create a visible hitbox
    let whiteColor = UIColor.white.withAlphaComponent(0.5) // Adjust the alpha value for transparency
    let whiteTransparentMaterial = SCNMaterial()
    whiteTransparentMaterial.diffuse.contents = whiteColor
    hitboxNode.geometry?.materials = [whiteTransparentMaterial]

    // attach the hitbox to the playerSpawn node
    playerSpawn?.addChildNode(hitboxNode)
}

