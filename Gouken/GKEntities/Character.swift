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
enum CharacterState : String, Codable {
    case Stunned
    case RunningLeft
    case RunningRight
    case Attacking
    case Idle
    case Jumping
    case Blocking
    case Downed
}

class Character {
    
    var entity            : GKEntity = GKEntity() // composition over inheritance :^) - omg so smart
    var characterNode     : SCNNode
    var characterName     : CharacterName
    var characterMesh     : SCNNode
    var playerSide        : PlayerType
    var state             : CharacterState
    var animator          : AnimatorComponent
    var stateMachine      : CharacterStateMachine?
    var health            : HealthComponent
    var hitbox            : HitBoxComponent
    
    // Callback Events
    var toggleHitboxesCallback: ((Any, Any?, Bool) -> Void)?
    var activateHitboxesCallback: ((Any, Any?, Bool) -> Void)?
    var activateHitboxByNameCallback: ((Any, Any?, Bool) -> Void)?
    var deactivateHitboxesCallback: ((Any, Any?, Bool) -> Void)?
    
    init(withName name : CharacterName, underParentNode parentNode: SCNNode, onPSide side: PlayerType, components : [GKComponent] = [], withManager : EntityManager) {
           characterMesh = SCNScene(named: characterModels[name]!)!.rootNode.childNode(withName: characterNameString[name]!, recursively: true)!
           playerSide = side
        characterMesh = SCNScene(named: characterModels[name]!)!.rootNode.childNode(withName: characterNameString[name]!, recursively: true)!
        playerSide = side
        
        parentNode.addChildNode(characterMesh)
        characterNode = parentNode.childNodes[parentNode.childNodes.count - 1]
        characterName = name
        
        // The following code adds individual Components for our Character Entity
        let movementComponent = MovementComponent(onSide: side)
        entity.addComponent(movementComponent)
        
        // Add Animator Component
        animator = AnimatorComponent(character: characterNode, defaultAnimName: characterAnimations[CharacterName.Ninja]![CharacterState.Idle]!, loop: true)
        entity.addComponent(animator)
        
        // Add Health Component
        health = HealthComponent(maxHealth: 100)
        entity.addComponent(health)
        
        
        // Add Hitbox Component
        hitbox = HitBoxComponent(true)
        entity.addComponent(hitbox)
        
        for component in components {
            entity.addComponent(component)
        }

        state = CharacterState.Idle
        
        withManager.addEntity(entity)
        
        
        // Set up callbacks
        toggleHitboxesCallback = { [weak self] param1, param2, param3 in
            self?.togglePlayerHitboxes()
        }
        activateHitboxesCallback = { [weak self] param1, param2, param3 in
            self?.activateHitboxes()
        }
        activateHitboxByNameCallback = { [weak self] param1, param2, param3 in
            self?.activateHitboxByName(name: param1 as! String)
        }
        deactivateHitboxesCallback = { [weak self] param1, param2, param3 in
            self?.deactivateHitboxes()
        }
    }
    
    func togglePlayerHitboxes() {
        print("Toggling hitboxes")
        for _hitbox in hitbox.hitboxes {
            _hitbox.isHidden = !_hitbox.isHidden
        }
        print("Completed Toggling hitboxes")
    }
    
    func addHitbox(hitboxNode: SCNNode) {
        hitbox.addHitbox(hitbox: hitboxNode)
    }
    
    func activateHitboxes() {
        hitbox.activateHitboxes()
    }
    
    func activateHitboxByName(name: String) {
        hitbox.activateHitboxByName(name: name)
    }
    
    func deactivateHitboxes() {
        hitbox.deactivateHitboxes()    }
    
    func update(deltaTime seconds : TimeInterval) {
        entity.update(deltaTime: seconds)
    }
    
    func setState(withState: CharacterState) {
        state = withState
    }
    
    func setupStateMachine(withStateMachine: CharacterStateMachine) {
        if (stateMachine == nil) {
            stateMachine = withStateMachine
            entity.addComponent(stateMachine!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
