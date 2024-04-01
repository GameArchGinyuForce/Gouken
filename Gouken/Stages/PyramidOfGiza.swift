//
//  AmazingBrentwood.swift
//  Gouken
//
//  Created by Jas Singh on 2024-03-05.
//

import SceneKit
import GameplayKit

class PyramidOfGiza : Stage {
    
    let stage : StageType = StageType.PyramidOfGiza
    
    init(withManager: EntityManager) {
        let scene : SCNScene = SCNScene(named: StageScnMapper[stage]!)! // If this crashes, there's no stage to load. TODO: have it load training stage and log error.
        
        let components : [GKComponent] = setUpComponents(scene)
        
        super.init(withScene: scene, andComponents: components, inManager: withManager)
    }
    

}

private func setUpComponents(_ scene: SCNScene?) -> [GKComponent] {

    var actions : [SCNAction] = []
    
    return [PerpetualEnvironmentComponent(withActions: actions, onNode: SCNNode())]
}
