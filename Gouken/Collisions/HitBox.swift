//
//  Hurtbox.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-29.
//

import SceneKit

func initHitboxAttack(
    playerSpawn:SCNNode?,
    width: CGFloat = 1.0,
    height: CGFloat = 1.0,
    length: CGFloat = 1.0,
    position: SCNVector3 = SCNVector3(0, 0, 0),
    pside: PlayerType
) -> SCNNode {
    // create hit box node with geometry
    let hitboxGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
    let hurtboxNode = SCNNode(geometry: hitboxGeometry)
    hurtboxNode.name = "hurtboxNode"
//    hitboxNode.position.z = 1.0
//    hitboxNode.position.y = 1.0
    hurtboxNode.position = position;
    hurtboxNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: hitboxGeometry, options: nil))
    hurtboxNode.physicsBody?.isAffectedByGravity = false
    
    if pside == PlayerType.P1 {
        hurtboxNode.physicsBody?.categoryBitMask = p1HurtBox
        hurtboxNode.physicsBody?.collisionBitMask = p2HitBox
        hurtboxNode.physicsBody?.contactTestBitMask = p2HitBox
    } else {
        hurtboxNode.physicsBody?.categoryBitMask = p2HurtBox
        hurtboxNode.physicsBody?.collisionBitMask = p1HitBox
        hurtboxNode.physicsBody?.contactTestBitMask = p1HitBox
    }
    
    
    print("Created a hurtbox with category mask: ", hurtboxNode.physicsBody!.categoryBitMask, " and collision mask: ", hurtboxNode.physicsBody!.collisionBitMask, " and test bit mask: ",
          hurtboxNode.physicsBody!.collisionBitMask
    )

//    hurtboxNode.physicsBody?.categoryBitMask = 2 | 8
//    hurtboxNode.physicsBody?.collisionBitMask = 4
    

    
    // create a visible hitbox
    let whiteColor = UIColor.white.withAlphaComponent(0.5) // Adjust the alpha value for transparency
    let whiteTransparentMaterial = SCNMaterial()
    whiteTransparentMaterial.diffuse.contents = whiteColor
    hurtboxNode.geometry?.materials = [whiteTransparentMaterial]

    // attach the hitbox to the playerSpawn node
    playerSpawn?.addChildNode(hurtboxNode)
    return hurtboxNode
}

