//
//  NinjaMoveData.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-30.
//

import CoreFoundation


// Character player side
enum BoxType {
    case Hitbox
    case Hurtbox
}
// Whether to Activate or Deactivate
enum BoxModifier {
    case Active
    case Inactive
}

/**
 enum ButtonType : Int {
     case Up
     case Left
     case Right
     case Down
     case LP
     case HP
     case Neutral
 }
 */
class CharacterMove {
    var sequence: [ButtonType]
    var stateChages: CharacterState
    var priority: Int
    var frameLeniency: Int
    var attackKeyFrames: [AttackKeyFrame]
    var damage: Float
    var isProjectile  : Bool = false
    
    init(sequence: [ButtonType], stateChages: CharacterState, priority: Int, frameLeniency: Int, attackKeyFrames: [AttackKeyFrame], isProjectile: Bool = false, damage: Float = 10.0) {
        self.sequence = sequence
        self.stateChages = stateChages
        self.priority = priority
        self.frameLeniency = frameLeniency
        self.attackKeyFrames = attackKeyFrames
        self.isProjectile = isProjectile
        self.damage = damage
    }
    
    func addAttackKeyFramesAsAnimationEvents (stateMachine: NinjaStateMachine) {
        for attackKeyFrame in attackKeyFrames {
            if attackKeyFrame.boxType == BoxType.Hitbox {
                if attackKeyFrame.setAll {
                    stateMachine.character?.animator.addAnimationEvent(
                        keyTime: CGFloat(attackKeyFrame.keyTime),
                        callback: (stateMachine.character?.deactivateHitboxesCallback)!)
                    print("turned hitboxes off")
                } else {
                    stateMachine.character.animator.addAnimationEvent(keyTime: CGFloat(attackKeyFrame.keyTime)) { node, eventData, playingBackward in
                        stateMachine.character.activateHitboxByNameCallback!(attackKeyFrame.name, eventData, playingBackward)
                    }
                    print("turned hitboxes on")
                }
            } else {
                print("HurtBox Modifications not implemented yet")
            }
        }
    }
}

class AttackKeyFrame {
    var keyTime:        Float  // 0.0 - 1.0
    var name:           String = ""
    var boxType:        BoxType = BoxType.Hitbox
    var boxModifier:    BoxModifier = BoxModifier.Active    // Turn box active or inactive
    var setAll:         Bool = false    // Deactivate all of type boxType
    
    init(keyTime: Float, name: String = "", boxType: BoxType, boxModifier: BoxModifier, setAll: Bool = false) {
        self.keyTime = keyTime
        self.name = name
        self.boxType = boxType
        self.boxModifier = boxModifier
        self.setAll = setAll
    }
}

let NinjaMoveSet : Dictionary = [
    CharacterState.Attacking: CharacterMove(sequence: [ButtonType.LP], stateChages: CharacterState.Attacking, priority: 1, frameLeniency: 2, attackKeyFrames: [
        AttackKeyFrame(keyTime: 0.1, name: "Hand_R", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Active),
        AttackKeyFrame(keyTime: 0.2, name: "", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Inactive, setAll: true),
        AttackKeyFrame(keyTime: 0.3, name: "Hand_R", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Active),
        AttackKeyFrame(keyTime: 0.4, name: "", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Inactive, setAll: true),
        AttackKeyFrame(keyTime: 0.5, name: "Hand_R", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Active),
        AttackKeyFrame(keyTime: 0.6, name: "", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Inactive, setAll: true)
    ]),
    CharacterState.HeavyAttacking: CharacterMove(sequence: [ButtonType.HP], stateChages: CharacterState.HeavyAttacking, priority: 1, frameLeniency: 2, attackKeyFrames: [
        AttackKeyFrame(keyTime: 0.5, name: "Hand_R", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Active),
        AttackKeyFrame(keyTime: 0.7, name: "", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Inactive, setAll: true)
    ]),
    CharacterState.DashingRight: CharacterMove(sequence: [ButtonType.Right, ButtonType.Neutral, ButtonType.Right], stateChages: CharacterState.DashingRight, priority: 1, frameLeniency: 20, attackKeyFrames: []),
    CharacterState.DashingLeft: CharacterMove(sequence: [ButtonType.Left, ButtonType.Neutral, ButtonType.Left], stateChages: CharacterState.DashingLeft, priority: 1, frameLeniency: 20, attackKeyFrames: []),
    CharacterState.Blocking: CharacterMove(sequence: [ButtonType.Down], stateChages: CharacterState.Blocking, priority: 1, frameLeniency: 1, attackKeyFrames: []),
    CharacterState.RunningLeft: CharacterMove(sequence: [ButtonType.Left], stateChages: CharacterState.RunningLeft, priority: 1, frameLeniency: 1, attackKeyFrames: []),
    CharacterState.RunningRight: CharacterMove(sequence: [ButtonType.Right], stateChages: CharacterState.RunningRight, priority: 1, frameLeniency: 1, attackKeyFrames: []),

    
]
