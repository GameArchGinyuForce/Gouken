//
//  CameraComponent.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-04-02.
//

import Foundation
import GameplayKit

/*
CameraComponent is responsible for lerping the camera to be between both characters
*/
class CameraComponent : GKComponent {
    var camera: SCNNode?
    var player1: Character?
    var player2: Character?
    var action: SCNAction?
    
    init(camera: SCNNode) {
        super.init()
        self.camera = camera
        self.player1 = GameManager.Instance().p1Character
        self.player2 = GameManager.Instance().p2Character
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // Change Camera Position
        
        let initialPosition = camera!.position
        
        let targetPosition: SCNVector3
        if (player1?.characterNode.parent!.position.z)! - (player2?.characterNode.parent!.position.z)! < 0.0 {
            
            targetPosition = SCNVector3(x: initialPosition.x, y: initialPosition.y, z: (player2?.characterNode.parent!.position.z)! - abs((player2?.characterNode.parent!.position.z)! - (player1?.characterNode.parent!.position.z)!) / 2 + 0.1) // 0.1 to account for character model width
        } else {
            targetPosition = SCNVector3(x: initialPosition.x, y: initialPosition.y, z: (player2?.characterNode.parent!.position.z)! - -(abs((player2?.characterNode.parent!.position.z)! - (player1?.characterNode.parent!.position.z)!)) / 2 + 0.1) // 0.1 to account for character model width
        }
        
        let playerZDistance = (player2?.characterNode.parent!.position.z)! - (player1?.characterNode.parent!.position.z)!

        // Define the duration for the movement based on the distance
        let duration = 0.1

        // Action to lerp to target position
        let moveAction = SCNAction.move(to: targetPosition, duration: duration)
        
        camera!.runAction(moveAction)
    }
}
