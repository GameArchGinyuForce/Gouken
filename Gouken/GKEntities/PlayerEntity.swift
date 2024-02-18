//
//  PlayerEntity.swift
//  Gouken
//
//  Created by Sepehr Mansouri on 2024-02-18.
//

import GameplayKit
import Foundation

class PlayerEntity : GKEntity {
    override init() {
        super.init()
        
        // The following code adds individual Components for our Player Entity
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        // You need to implement decoding logic here if you intend to encode and decode your entity
    }
}
