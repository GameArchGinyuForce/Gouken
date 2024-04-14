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
    pside: PlayerType,
    name: String = ""
)-> SCNNode{
    // create hit box node with geometry
    let hurtBoxGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
    let hurtBoxNode = SCNNode(geometry: hurtBoxGeometry)
    hurtBoxNode.name = "hurtBoxNode"
    
    hurtBoxNode.scale = SCNVector3(100, 100, 100) // Scale up by a factor of 10 in all directions
    
    //    hitboxNode.position.z = 1.0
    //    hitboxNode.position.y = 1.0
    hurtBoxNode.position = position;
    hurtBoxNode.name = name
    hurtBoxNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: hurtBoxGeometry, options: nil))
    hurtBoxNode.physicsBody?.isAffectedByGravity = false
    
    if pside == PlayerType.P2 {
        hurtBoxNode.physicsBody?.categoryBitMask = p1HurtBox
        hurtBoxNode.physicsBody?.collisionBitMask = p2HitBox
        hurtBoxNode.physicsBody?.contactTestBitMask = p2HitBox
    } else {
        hurtBoxNode.physicsBody?.categoryBitMask = p2HurtBox
        hurtBoxNode.physicsBody?.collisionBitMask = p1HitBox
        hurtBoxNode.physicsBody?.contactTestBitMask = p1HitBox
    }


    print("Created a hurtbox with category mask: ", hurtBoxNode.physicsBody!.categoryBitMask, " and collision mask: ", hurtBoxNode.physicsBody!.collisionBitMask, " and contact bitmask: ", hurtBoxNode.physicsBody!.contactTestBitMask)

    var alpha = 0.0
    // create a visible hitbox
    if (debugBoxes) {
        alpha = 0.1
    }
    let greenColor = UIColor.green.withAlphaComponent(alpha) // Adjust the alpha value for transparency
    let greenTransparentMaterial = SCNMaterial()
    greenTransparentMaterial.diffuse.contents = greenColor
    hurtBoxNode.geometry?.materials = [greenTransparentMaterial]
//    hurtBoxNode.isHidden = true

    // attach the hitbox to the playerSpawn node
    playerSpawn.addChildNode(hurtBoxNode)
    
    return hurtBoxNode
}
