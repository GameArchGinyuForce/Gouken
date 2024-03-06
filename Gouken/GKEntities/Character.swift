//
//  PlayerEntity.swift
//  Gouken
//
//  Created by Sepehr Mansouri on 2024-02-18.
//

import GameplayKit
import Foundation

// Character List
enum CharacterName {
    case Ninja
}

let characterNameString = [
    CharacterName.Ninja : "Ninja"
]

// Character player side
enum PlayerType {
    case P1
    case P2
    case AI // stretch goal for Fatal Fury / Golden Axe mode
}

// States that characters can go into
enum CharacterState {
    case Stunned
    case Running
    case Attacking
    case Idle
    case Jumping
    case Blocking
}

class Character {
    
    var entity            : GKEntity = GKEntity() // composition over inheritance :^)
    var characterNode     : SCNNode
    var characterName     : CharacterName
    var characterMesh     : SCNNode
    var playerSide        : PlayerType
    var state             : CharacterState
    
    init(withName name : CharacterName, underParentNode parentNode: SCNNode, onPSide side: PlayerType, components : [GKComponent] = []) {
        characterMesh = SCNScene(named: characterModels[name]!)!.rootNode.childNode(withName: characterNameString[name]!, recursively: true)!
        playerSide = side
        
        parentNode.addChildNode(characterMesh)
        characterNode = parentNode.childNodes[parentNode.childNodes.count - 1]
        characterName = name
        
        
        // The following code adds individual Components for our Character Entity
        let movementComponent = MovementComponent(onSide: side)
        entity.addComponent(movementComponent)
        
        for component in components {
            entity.addComponent(component)
        }
        self.state = CharacterState.Idle
        setState(withState: CharacterState.Idle)
    }
    
    func update(deltaTime seconds : TimeInterval) {
        entity.update(deltaTime: seconds)
    }
    
    func setState(withState: CharacterState) {
        self.state = withState
        let anims = characterAnimations[characterName]!
        playAnimation(onNode: characterNode, withSCNFile: anims[withState] ?? anims[CharacterState.Idle]!) // every character MUST have an idle state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
