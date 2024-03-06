//
//  EntityManager.swift
//  Gouken
//
//  Created by Sepehr Mansouri on 2024-02-18.
//

import Foundation
import GameplayKit

class EntityManager {
    var entities = Set<GKEntity>()
    
    func addEntity(_ entity: GKEntity) {
        entities.insert(entity)
    }
    
    func removeEntity(_ entity: GKEntity) {
        entities.remove(entity)
    }
    
}
