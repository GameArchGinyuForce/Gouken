//
//  Hurtbox.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-29.
//

import SceneKit

func initHitboxAttack(
    withPlayerNode: SCNNode,
    width: CGFloat = 1.0,
    height: CGFloat = 1.0,
    length: CGFloat = 1.0,
    position: SCNVector3 = SCNVector3(0, 0, 0),
    pside: PlayerType,
    name: String = "",
    rotation: SCNVector3 = SCNVector3(0, 0, 0)
) -> SCNNode {
    // create hit box node with geometry
    let hitboxGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
    let hitBoxNode = SCNNode(geometry: hitboxGeometry)
//    hitboxNode.position.z = 1.0
//    hitboxNode.position.y = 1.0
    hitBoxNode.position = position;
    hitBoxNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: hitboxGeometry, options: nil))
    hitBoxNode.physicsBody?.isAffectedByGravity = false
    hitBoxNode.name = name
    hitBoxNode.eulerAngles = rotation
    
    hitBoxNode.scale = SCNVector3(100, 100, 100) // Scale up by a factor of 10 in all directions
    
    if pside == PlayerType.P2 {
        hitBoxNode.physicsBody?.categoryBitMask = p1HitBox
        hitBoxNode.physicsBody?.collisionBitMask = p2HurtBox
        hitBoxNode.physicsBody?.contactTestBitMask = p2HurtBox
    } else {
        hitBoxNode.physicsBody?.categoryBitMask = p2HitBox
        hitBoxNode.physicsBody?.collisionBitMask = p1HurtBox
        hitBoxNode.physicsBody?.contactTestBitMask = p1HurtBox
    }
    
    
    print("Created a hitbox with category mask: ", hitBoxNode.physicsBody!.categoryBitMask, " and collision mask: ", hitBoxNode.physicsBody!.collisionBitMask, " and test bit mask: ",
          hitBoxNode.physicsBody!.collisionBitMask
    )
 

    
    // create a visible hitbox
    let redColor = UIColor.red.withAlphaComponent(0.8) // Adjust the alpha value for transparency
    let redTransparentMaterial = SCNMaterial()
    redTransparentMaterial.diffuse.contents = redColor
    hitBoxNode.geometry?.materials = [redTransparentMaterial]
    hitBoxNode.isHidden = true
    
    // attach the hitbox to the playerSpawn node
    withPlayerNode.addChildNode(hitBoxNode)
    return hitBoxNode
}

