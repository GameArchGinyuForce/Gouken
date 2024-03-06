//
//  AmazingBrentwood.swift
//  Gouken
//
//  Created by Jas Singh on 2024-03-05.
//

import SceneKit
import GameplayKit

class AmazingBrentwood : Stage {
    
    let stage : StageType = StageType.AmazingBrentwood
    
    init(withManager: EntityManager) {
        let scene : SCNScene = SCNScene(named: StageScnMapper[stage]!)! // If this crashes, there's no stage to load. TODO: have it load training stage and log error.
        
        let components : [GKComponent] = setUpComponents(scene)
        
        super.init(withScene: scene, andComponents: components, inManager: withManager)
    }
    

}

private func setUpComponents(_ scene: SCNScene?) -> [GKComponent] {
    let car = scene!.rootNode.childNode(withName: "car", recursively: true)! // TODO: Clean up strings for car and waypoints.
    let waypoints : [SCNNode] = scene!.rootNode.childNode(withName: "carWaypoints", recursively: true)!.childNodes
    var actions : [SCNAction] = []
    
    var movement = SCNAction.move(to: waypoints[0].worldPosition, duration: 2.8)
    
    var movement2 = SCNAction.move(to: waypoints[1].worldPosition, duration: 0.5)
    var rotation = SCNAction.rotateTo(x: CGFloat(Float.pi/2), y: CGFloat(-Float.pi/2), z: 0, duration: 0.3)

    var currAction = SCNAction.sequence([movement, SCNAction.group([movement2, rotation])])
    
    movement = SCNAction.move(to: waypoints[2].worldPosition, duration: 2.0)
    
    actions.append(SCNAction.sequence([currAction, movement]))

    
    //        let rotation = SCNAction.rotateBy(x: CGFloat(waypoint.eulerAngles.x), y: CGFloat(waypoint.eulerAngles.y), z: CGFloat(waypoint.eulerAngles.z), duration: 2.0)

    
    actions.append(SCNAction.move(to: car.worldPosition, duration: 0.0))
    actions.append(SCNAction.rotateTo(x: CGFloat(Float.pi/2), y: CGFloat(-1.15192), z: 0, duration: 0.0))
    
    return [PerpetualEnvironmentComponent(withActions: actions, onNode: car)]
}
