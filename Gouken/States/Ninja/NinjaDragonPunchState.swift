//
//  NinjaHeavyAttackingState.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-04-01.
//

import Foundation
import GameplayKit

class NinjaDragonPunchState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    let damage: Int = 40
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter NinjaHeavyAttackingState")
        stateMachine.character.setState(withState: CharacterState.DragonPunch)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.DragonPunch]!, loop: false)
        
        // Hardcoded retrieval of move
        let move: CharacterMove = NinjaMoveSet[CharacterState.DragonPunch]!
        stateMachine.character.hitbox.damage = self.damage
        move.addAttackKeyFramesAsAnimationEvents(stateMachine: stateMachine)
        
        // Sound effect for attack
        stateMachine.character.animator.addAnimationEvent(keyTime: CGFloat(0.4)) { node, eventData, playingBackward in
            AudioManager.Instance().playEffectSound(audio: AudioDict.DragonPunch)
        }
        stateMachine.character.animator.addAnimationEvent(keyTime: CGFloat(0.55)) { node, eventData, playingBackward in
            AudioManager.Instance().playEffectSound(audio: AudioDict.DragonPunch)
        }
    }
    
    // TODO: Turn on hitboxes at certain points
    func tick(_ deltaTime: TimeInterval) {
        if (stateMachine.character.animator.currentTimeNormalized >= 1.0) {
            stateMachine.switchState(stateMachine.stateInstances[CharacterState.Idle]!)
        }
    }
    
    func exit() {
        print("exit NinjaHeavyAttackingState")
        stateMachine.character?.hitbox.deactivateHitboxes()    // Clears hitboxes if attack state disrupted
    }
}

