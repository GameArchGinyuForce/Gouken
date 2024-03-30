//
//  Hitboxes.swift
//  Gouken
//
//  Created by Jeff Phan on 2024-03-09.
//

import SceneKit

func initHurtboxAttack(
    withParentNode playerSpawn: SCNNode,
    width: CGFloat = 1.0,
    height: CGFloat = 1.0,
    length: CGFloat = 1.0,
    position: SCNVector3 = SCNVector3(0, 0, 0),
    pside: PlayerType
)-> SCNNode{
    // create hit box node with geometry
    let hurtBoxGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
    let hurtBoxNode = SCNNode(geometry: hurtBoxGeometry)
    hurtBoxNode.name = "hitboxNode"
    
    hurtBoxNode.scale = SCNVector3(200, 200, 200) // Scale up by a factor of 10 in all directions
    
    //    hitboxNode.position.z = 1.0
    //    hitboxNode.position.y = 1.0
    hurtBoxNode.position = position;
    hurtBoxNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: hurtBoxGeometry, options: nil))
    hurtBoxNode.physicsBody?.isAffectedByGravity = false
    
    if pside == PlayerType.P1 {
        hurtBoxNode.physicsBody?.categoryBitMask = p1HitBox
        hurtBoxNode.physicsBody?.collisionBitMask = p2HurtBox
        hurtBoxNode.physicsBody?.contactTestBitMask = p2HurtBox
    } else {
        hurtBoxNode.physicsBody?.categoryBitMask = p2HitBox
        hurtBoxNode.physicsBody?.collisionBitMask = p1HurtBox
        hurtBoxNode.physicsBody?.contactTestBitMask = p1HurtBox
    }


    print("Created a hitbox with category mask: ", hurtBoxNode.physicsBody!.categoryBitMask, " and collision mask: ", hurtBoxNode.physicsBody!.collisionBitMask, " and contact bitmask: ", hurtBoxNode.physicsBody!.contactTestBitMask)

    
//    hitboxNode.physicsBody?.categoryBitMask = 1 | 4 | 8
//    hitboxNode.physicsBody?.collisionBitMask = 6

    
    // create a visible hitbox
    let redColor = UIColor.red.withAlphaComponent(0.5) // Adjust the alpha value for transparency
    let redTransparentMaterial = SCNMaterial()
    redTransparentMaterial.diffuse.contents = redColor
    hurtBoxNode.geometry?.materials = [redTransparentMaterial]

    // attach the hitbox to the playerSpawn node
    playerSpawn.addChildNode(hurtBoxNode)
    
    return hurtBoxNode
}
