//
//  NinjaMoveData.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-30.
//


/**
 // Hardcoded adding of events for hitbox toggling
//            player1?.animator.addAnimationEvent(keyTime: 0.1, callback: (player1?.activateHitboxesCallback)!)
 player1?.animator.addAnimationEvent(keyTime: 0.1) { node, eventData, playingBackward in
     self.player1?.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
 }
 
 player1?.animator.addAnimationEvent(keyTime: 0.2, callback: (player1?.deactivateHitboxesCallback)!)
//            player1?.animator.addAnimationEvent(keyTime: 0.3, callback: (player1?.activateHitboxesCallback)!)
 player1?.animator.addAnimationEvent(keyTime: 0.3) { node, eventData, playingBackward in
     self.player1?.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
 }
 
 player1?.animator.addAnimationEvent(keyTime: 0.4, callback: (player1?.deactivateHitboxesCallback)!)
//            player1?.animator.addAnimationEvent(keyTime: 0.5, callback: (player1?.activateHitboxesCallback)!)
 player1?.animator.addAnimationEvent(keyTime: 0.5) { node, eventData, playingBackward in
     self.player1?.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
 }
 
 player1?.animator.addAnimationEvent(keyTime: 0.6, callback: (player1?.deactivateHitboxesCallback)!)
 */
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

class AttackKeyFrame {
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


