//
//  AnimationPlayer.swift
//  Gouken
//
//  Created by Jaskaran Chahal on 2024-02-29.
//

import Foundation
import SceneKit

// Abruptly stops an animation on a SCNNode to play another.
func playAnimation(onNode node: SCNNode, withSCNFile anim: String, andBlendOutDuration blendOut: CGFloat = CGFloat(0.0)) -> SCNAnimationPlayer {
    StopAnimation(onNode: node, withBlendOutDuration: blendOut)
    let animPlayer = SCNAnimationPlayer.loadAnimation(fromSceneNamed: anim)
    node.addAnimationPlayer(animPlayer, forKey: anim)
    return animPlayer
}

func StopAnimation(onNode node: SCNNode, withBlendOutDuration blendOut: CGFloat = CGFloat(0.0)) {
    node.removeAllAnimations(withBlendOutDuration: blendOut)
}
