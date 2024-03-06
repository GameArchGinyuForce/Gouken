//
//  DynamicEnvironmentComponent.swift
//  Gouken
//
//  Created by Jas Chahal on 2024-03-05.
//

import GameplayKit

class DynamicEnvironmentComponent : GKComponent {
    
    var actions     : [SCNAction] = []
    var environment : SCNNode = SCNNode()
    
    init(withActions: [SCNAction], onNode: SCNNode) {
        
        actions = withActions
        environment = onNode
        
        super.init()
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
    
}
