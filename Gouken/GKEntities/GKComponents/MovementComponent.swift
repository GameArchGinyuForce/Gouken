//
//  MovementComponent.swift
//  Gouken
//
//  Created by Sepehr Mansouri on 2024-02-18.
//

import GameplayKit

class MovementComponent : GKComponent {
    
    init(onSide : PlayerType) {
        super.init()
        
        // TODO set the input buffer to read from after implementing it
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move() {
        print("Player move called")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
    }
    
}
