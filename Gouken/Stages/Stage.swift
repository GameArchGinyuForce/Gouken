//
//  Stage.swift
//  Gouken
//
//  Created by Jaskaran Chahal on 2024-03-05.
//

import GameplayKit
import SceneKit

enum StageType {
    case AmazingBrentwood
    case PyramidOfGiza
    case Temple
}

let StageScnMapper : Dictionary = [
    StageType.AmazingBrentwood: "art.scnassets/AmazingBrentwood.scn",
    StageType.PyramidOfGiza: "art.scnassets/PyramidOfGiza.scn",
    StageType.Temple:   "art.scnassets/Temple.scn"
]

let StageName : Dictionary = [
    StageType.AmazingBrentwood: "The Amazing Brentwood",
    StageType.PyramidOfGiza: "Pyramid of Giza",
    StageType.Temple:           "The Temple"
]


class Stage {
    
    var scene  : SCNScene?
    let entity : GKEntity = GKEntity()
    
    init(withScene : SCNScene, andComponents components : [GKComponent], inManager : EntityManager) {
        
        scene = withScene
        
        for component in components {
            entity.addComponent(component)
        }
        
        inManager.addEntity(entity)
    }
}
