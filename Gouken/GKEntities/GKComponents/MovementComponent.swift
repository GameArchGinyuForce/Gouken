//
//  MovementComponent.swift
//  Gouken
//
//  Created by Sepehr Mansouri on 2024-02-18.
//

import Foundation
import GameplayKit

class MovementComponent : GKComponent {
    var movementSpeed: CGFloat = 5.0
    var direction: CGVector = CGVector(dx: 0.0, dy: 0.0)
    
    // Add methods to handle movement logic, collisions, etc.
    func move() {
        // Implement movement logic here based on the direction and speed
    }
    
    // You can override GKComponent's update method to update the component's state each frame
    override func update(deltaTime seconds: TimeInterval) {
        // Implement any necessary updates to the component's state
    }
    
}
