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
    var onDirectionalChange : ([ButtonType]) -> [ButtonType]
    
    init(sequence: [ButtonType], stateChages: CharacterState, priority: Int, frameLeniency: Int, attackKeyFrames: [AttackKeyFrame], isProjectile: Bool = false, damage: Float = 10.0, directionalChange : @escaping ([ButtonType]) -> [ButtonType] = {orig in return orig}) {
        self.sequence = sequence
        self.stateChages = stateChages
        self.priority = priority
        self.frameLeniency = frameLeniency
        self.attackKeyFrames = attackKeyFrames
        self.isProjectile = isProjectile
        self.damage = damage
        self.onDirectionalChange = directionalChange
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
            } else if attackKeyFrame.boxType == BoxType.Hurtbox {
                if attackKeyFrame.setAll {
                    if attackKeyFrame.boxModifier == BoxModifier.Active {
                        stateMachine.character?.animator.addAnimationEvent(
                            keyTime: CGFloat(attackKeyFrame.keyTime),
                            callback: (stateMachine.character?.activateHurtboxesCallback)!)
                        print("turned hurtboxes off")
                    } else {
                        stateMachine.character?.animator.addAnimationEvent(
                            keyTime: CGFloat(attackKeyFrame.keyTime),
                            callback: (stateMachine.character?.deactivateHurtboxesCallback)!)
                        print("turned hurtboxes on")
                    }
                } else {
                    if attackKeyFrame.boxModifier == BoxModifier.Active {
                        stateMachine.character.animator.addAnimationEvent(keyTime: CGFloat(attackKeyFrame.keyTime)) { node, eventData, playingBackward in
                            stateMachine.character.activateHurtboxByNameCallback!(attackKeyFrame.name, eventData, playingBackward)
                        }
                        print("turned hurtboxes on")
                    } else {
                        stateMachine.character.animator.addAnimationEvent(keyTime: CGFloat(attackKeyFrame.keyTime)) { node, eventData, playingBackward in
                            stateMachine.character.deactivateHurtboxByNameCallback!(attackKeyFrame.name, eventData, playingBackward)
                        }
                        print("turned hurtboxes off")
                    }
                }
            } else {
                print("Invalid box type")
            }
        }
    }
    
    func updateOnDirectionalChange() {
        self.sequence = onDirectionalChange(self.sequence)
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

func oppositeDirection(ofButton btn: ButtonType) -> ButtonType {
    switch (btn) {
    case ButtonType.Left:
        return ButtonType.Right
    case ButtonType.Right:
        return ButtonType.Left
    default:
        return btn
    }
}

// swapping moves for directional changes of palyer, should refactor into component/entity loop later.
func swapMovesHorizontalDirections(inMoveSequence seq : [ButtonType]) -> [ButtonType] {
    var arr : [ButtonType] = []
    for button in seq {
        arr.append(oppositeDirection(ofButton: button))
    }

    return arr
}

let directionalSwappingMoves : [CharacterState] = [
    CharacterState.DragonPunch
]

func swapMoves() {
    for move in directionalSwappingMoves {
        NinjaMoveSet[move]!.updateOnDirectionalChange()
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
        AttackKeyFrame(keyTime: 0.7, name: "", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Inactive, setAll: true),
    ]),
    CharacterState.DashingRight: CharacterMove(sequence: [ButtonType.Right, ButtonType.Neutral, ButtonType.Right], stateChages: CharacterState.DashingRight, priority: 2, frameLeniency: 15, attackKeyFrames: [
        AttackKeyFrame(keyTime: 0.1, name: "", boxType: BoxType.Hurtbox, boxModifier: BoxModifier.Inactive, setAll: true),
        AttackKeyFrame(keyTime: 0.5, name: "", boxType: BoxType.Hurtbox, boxModifier: BoxModifier.Active, setAll: true),
    ]),
    CharacterState.DashingLeft: CharacterMove(sequence: [ButtonType.Left, ButtonType.Neutral, ButtonType.Left], stateChages: CharacterState.DashingLeft, priority: 2, frameLeniency: 15, attackKeyFrames: [
        AttackKeyFrame(keyTime: 0.1, name: "", boxType: BoxType.Hurtbox, boxModifier: BoxModifier.Inactive, setAll: true),
        AttackKeyFrame(keyTime: 0.5, name: "", boxType: BoxType.Hurtbox, boxModifier: BoxModifier.Active, setAll: true),
//        AttackKeyFrame(keyTime: 0.1, name: "head", boxType: BoxType.Hurtbox, boxModifier: BoxModifier.Inactive),
    ]),
    CharacterState.Blocking: CharacterMove(sequence: [ButtonType.Down], stateChages: CharacterState.Blocking, priority: 1, frameLeniency: 1, attackKeyFrames: []),
    CharacterState.RunningLeft: CharacterMove(sequence: [ButtonType.Left], stateChages: CharacterState.RunningLeft, priority: 1, frameLeniency: 1, attackKeyFrames: []),
    CharacterState.RunningRight: CharacterMove(sequence: [ButtonType.Right], stateChages: CharacterState.RunningRight, priority: 1, frameLeniency: 1, attackKeyFrames: []),
    CharacterState.Jumping: CharacterMove(sequence: [ButtonType.Up], stateChages: CharacterState.Jumping, priority: 1, frameLeniency: 1, attackKeyFrames: []),
    CharacterState.DragonPunch: CharacterMove(sequence: [ButtonType.Right, ButtonType.Down, ButtonType.Right, ButtonType.HP], stateChages: CharacterState.DragonPunch, priority: 10, frameLeniency: 60, attackKeyFrames: [], directionalChange: swapMovesHorizontalDirections)

]
