//
//  NinjaMoveData.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-30.
//


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
 enum Move: String, CaseIterable, Codable {
     case left, right, jump, crouch, lowDash, midDash, block
 }
 */
class CharacterMove {
    var sequence: [Move]
    var stateChages: CharacterState
    var priority: Int
    var frameLeniency: Int
    var attackKeyFrames: AttackKeyFrames
    
    init(sequence: [Move], stateChages: CharacterState, priority: Int, frameLeniency: Int, attackKeyFrames: AttackKeyFrames) {
        self.sequence = sequence
        self.stateChages = stateChages
        self.priority = priority
        self.frameLeniency = frameLeniency
        self.attackKeyFrames = attackKeyFrames
    }
}

class AttackKeyFrames {
    var keyTime:        Float  // 0.0 - 1.0
    var pside:          PlayerType
    var name:           String = ""
    var boxType:        BoxType = BoxType.Hitbox
    var boxModifier:    BoxModifier = BoxModifier.Active    // Turn box active or inactive
    var setAll:         Bool = false    // Deactivate all of type boxType
    
    init(keyTime: Float, pside: PlayerType, name: String = "", boxType: BoxType, boxModifier: BoxModifier, setAll: Bool = false) {
        self.keyTime = keyTime
        self.pside = pside
        self.name = name
        self.boxType = boxType
        self.boxModifier = boxModifier
        self.setAll = setAll
    }
}

let NinjaMoveSet : Dictionary = [
    CharacterName.Ninja: [
        CharacterState.Attacking    : [
            AttackKeyFrame(keyTime: 0.1, pside: PlayerType.P1, name: "Hand_R", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Active),
            AttackKeyFrame(keyTime: 0.2, pside: PlayerType.P1, name: "", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Inactive, setAll: true),
            AttackKeyFrame(keyTime: 0.3, pside: PlayerType.P1, name: "Hand_R", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Active),
            AttackKeyFrame(keyTime: 0.4, pside: PlayerType.P1, name: "", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Inactive, setAll: true),
            AttackKeyFrame(keyTime: 0.5, pside: PlayerType.P1, name: "Hand_R", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Active),
            AttackKeyFrame(keyTime: 0.6, pside: PlayerType.P1, name: "", boxType: BoxType.Hitbox, boxModifier: BoxModifier.Inactive, setAll: true)
        ]
    ]
]


