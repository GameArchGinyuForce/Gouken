//
//  Hitboxes.swift
//  Gouken
//
//  Created by Jeff Phan on 2024-03-09.
//

import SceneKit

func initHitboxAttack(playerSpawn:SCNNode?){
    // create hit box node with geometry
    let hitboxGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
    let hitboxNode = SCNNode(geometry: hitboxGeometry)
    hitboxNode.name = "hitboxNode"
    hitboxNode.position.z = 1.0
    hitboxNode.position.y = 1.0
    hitboxNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: hitboxGeometry, options: nil))
    hitboxNode.physicsBody?.categoryBitMask = 4
    hitboxNode.physicsBody?.collisionBitMask = 2


//    // TODO: for testing state machine
//    baikenStateMachine = BaikenStateMachine(player1!.characterNode)
//    let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
//    doubleTapGesture.numberOfTapsRequired = 2
//    scnView.addGestureRecognizer(doubleTapGesture)
//    ninja2StateMachine = NinjaStateMachine(player2!.characterNode)
    
    // create a visible hitbox
    let redColor = UIColor.red.withAlphaComponent(0.5) // Adjust the alpha value for transparency
    let redTransparentMaterial = SCNMaterial()
    redTransparentMaterial.diffuse.contents = redColor
    hitboxNode.geometry?.materials = [redTransparentMaterial]

    // attach the hitbox to the playerSpawn node
    playerSpawn?.addChildNode(hitboxNode)
}
