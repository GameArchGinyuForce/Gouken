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
    case Ninja2
}

let characterNameString = [
    CharacterName.Ninja : "Ninja",
    CharacterName.Ninja2: "Ninja2"
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
    case HeavyAttacking
    case Idle
    case Jumping
    case Blocking
    case Downed
    case DashingLeft
    case DashingRight
    case DragonPunch
}

let runSpeed = 0.06

class Character: Equatable {
    
    static func == (lhs: Character, rhs: Character) -> Bool {
       
         return lhs.characterName == rhs.characterName &&
                lhs.playerSide == rhs.playerSide &&
                lhs.state == rhs.state &&
                lhs.entity == rhs.entity
     }
    
    
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
    var scene             : SCNScene    // Scene reference to handle collision
    var parentNode        : SCNNode
    var hurtBoxes         : [SCNNode] = []
    
    
    
    // Callback Events
    var toggleHitboxesCallback: ((Any, Any?, Bool) -> Void)?
    var activateHitboxesCallback: ((Any, Any?, Bool) -> Void)?
    var activateHitboxByNameCallback: ((Any, Any?, Bool) -> Void)?
    var deactivateHitboxesCallback: ((Any, Any?, Bool) -> Void)?
    
    init(withName name : CharacterName, underParentNode parentNode: SCNNode, onPSide side: PlayerType, components : [GKComponent] = [], withManager : EntityManager, scene: SCNScene, statsUI: GameplayStatusOverlay) {
           characterMesh = SCNScene(named: characterModels[name]!)!.rootNode.childNode(withName: characterNameString[name]!, recursively: true)!
           playerSide = side
        characterMesh = SCNScene(named: characterModels[name]!)!.rootNode.childNode(withName: characterNameString[name]!, recursively: true)!
        playerSide = side
        self.scene = scene
        
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
        health = HealthComponent(maxHealth: 150, statsUI: statsUI)
        entity.addComponent(health)
        
        
        // Add Hitbox Component
        hitbox = HitBoxComponent(scene: scene, statsUI: statsUI)
        entity.addComponent(hitbox)
        
        for component in components {
            entity.addComponent(component)
        }

        state = CharacterState.Idle
        
        self.parentNode = parentNode
        
        withManager.addEntity(entity)
        
        // Bug when seting up boxes in Character
//        setUpHurtBoxes()
//        setUpHitboxes()
        
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
    
    func setUpHurtBoxes() {
        var modelSCNNode = characterNode.childNode(withName: "head", recursively: true)
        var hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.3, height: 0.3, length: 0.3, position: SCNVector3(0, 0, -10), pside: playerSide)
        hurtBoxes.append(hurtbox)
        
        modelSCNNode = characterNode.childNode(withName: "UpperArm_R", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(-10, 0, 0), pside: playerSide)
        hurtBoxes.append(hurtbox)
        
        modelSCNNode = characterNode.childNode(withName: "lowerarm_r", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(-10, 0, 0), pside: playerSide)
        hurtBoxes.append(hurtbox)
        
        modelSCNNode = characterNode.childNode(withName: "UpperArm_L", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(10, 0, 0), pside: playerSide)
        hurtBoxes.append(hurtbox)
        
        modelSCNNode = characterNode.childNode(withName: "lowerarm_l", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(10, 0, 0), pside: playerSide)
        hurtBoxes.append(hurtbox)
        
        modelSCNNode = characterNode.childNode(withName: "Pelvis", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.4, position: SCNVector3(0, 0, 0), pside: playerSide)
        hurtBoxes.append(hurtbox)
        
        modelSCNNode = characterNode.childNode(withName: "spine_02", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.6, height: 0.6, length: 0.2, position: SCNVector3(1, 0, 0), pside: playerSide)
        hurtBoxes.append(hurtbox)
        
        modelSCNNode = characterNode.childNode(withName: "Thigh_R", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.6, height: 0.2, length: 0.2, position: SCNVector3(10, 0, 0), pside: playerSide)
        hurtBoxes.append(hurtbox)
        
        modelSCNNode = characterNode.childNode(withName: "calf_r", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(20, 0, 0), pside: playerSide)
        hurtBoxes.append(hurtbox)
        
        modelSCNNode = characterNode.childNode(withName: "Thigh_L", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.6, height: 0.2, length: 0.2, position: SCNVector3(-10, 0, 0), pside: playerSide)
        hurtBoxes.append(hurtbox)
        
        modelSCNNode = characterNode.childNode(withName: "calf_l", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(-20, 0, 0), pside: playerSide)
        hurtBoxes.append(hurtbox)
    }
    
    func setUpHitBoxes() {
        var modelSCNNode = characterNode.childNode(withName: "Hand_R", recursively: true)
        var hitbox = initHitboxAttack(withPlayerNode: modelSCNNode!, width: 0.2, height: 1.3, length: 0.2, position: SCNVector3(-30, -60, -20), pside: playerSide, name: "Hand_R", rotation: SCNVector3(x: Float.pi/10, y: 0, z: -Float.pi/7))
        hitbox.isHidden = true
        addHitbox(hitboxNode: hitbox)
        
//        var modelSCNNode = characterNode.childNode(withName: "Hand_R", recursively: true)
//        var hitbox = initHitboxAttack(withPlayerNode: modelSCNNode!, width: 0.2, height: 0.2, length: 0.2, position: SCNVector3(0, 0, 0), pside: playerSide, name: "Hand_R")
//        hitbox.isHidden = true
//        addHitbox(hitboxNode: hitbox)
        
//        modelSCNNode = characterNode.childNode(withName: "Hand_L", recursively: true)
//        hitbox = initHitboxAttack(withPlayerNode: modelSCNNode!, width: 0.2, height: 0.2, length: 0.2, position: SCNVector3(0, 0, 0), pside: playerSide, name: "Hand_L")
//        hitbox.isHidden = true
//        addHitbox(hitboxNode: hitbox)
        
//        modelSCNNode = characterNode.childNode(withName: "SM_Wep_Odachi_01", recursively: true)
//        hitbox = initHitboxAttack(withPlayerNode: modelSCNNode!, width: 0.2, height: 1.2, length: 0.2, position: SCNVector3(0, 1.5, 1), pside: playerSide, name: "SM_Wep_Odachi_01", rotation: SCNVector3(x: Float.pi / 4, y: Float.pi / 4, z: Float.pi / 4))
//        hitbox.isHidden = false
//        addHitbox(hitboxNode: hitbox)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
