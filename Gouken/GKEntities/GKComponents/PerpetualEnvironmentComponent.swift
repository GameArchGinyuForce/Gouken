//
//  DynamicEnvironmentComponent.swift
//  Gouken
//
//  Created by Jas Chahal on 2024-03-05.
//

import GameplayKit
import SceneKit

class PerpetualEnvironmentComponent : GKComponent {
    
    var actions     : [SCNAction] = []
    var environment : SCNNode = SCNNode()
    
    init(withActions: [SCNAction], onNode: SCNNode) {
        
        actions = withActions
        environment = onNode
        
        super.init()
        
        environment.runAction(SCNAction.repeatForever(SCNAction.sequence(actions)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func update(deltaTime seconds: TimeInterval) {
    }

}
