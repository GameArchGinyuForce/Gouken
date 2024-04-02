//
//  NinjaJumpState.swift
//  Gouken
//
//  Created by Jeff Phan on 2024-03-31.
//

import Foundation
import GameplayKit

class NinjaJumpState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    var initialPositionY: Float
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
        self.initialPositionY = stateMachine.character.parentNode.position.y
    }
    
    func enter() {
        print("enter NinjaJump state")
        self.initialPositionY = stateMachine.character.parentNode.position.y
        stateMachine.character.setState(withState: CharacterState.Jumping)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.Jumping]!, loop: false)
        
    }
    
    // TODO: Turn on hitboxes at certain points
    func tick(_ deltaTime: TimeInterval) {
        
//        if(stateMachine.character.parentNode.eulerAngles.y == Float.pi){
//            stateMachine.character.parentNode.position.z -= 0.06
//        }else if(stateMachine.character.parentNode.eulerAngles.y == 0){
//            stateMachine.character.parentNode.position.z += 0.06
//        }
        
        if (stateMachine.character.animator.currentTimeNormalized <= 0.4) {
            stateMachine.character.parentNode.position.y += 0.07
        }
        else if (stateMachine.character.animator.currentTimeNormalized >= 0.4 && stateMachine.character.animator.currentTimeNormalized < 0.8) {
            stateMachine.character.parentNode.position.y -= 0.07
        }
        else if (stateMachine.character.animator.currentTimeNormalized >= 0.8) {
            stateMachine.switchState(stateMachine.stateInstances[CharacterState.Idle]!)
        }
    }
    
    func exit() {
        print("exit NinjaAttackingState")
        stateMachine.character.parentNode.position.y = initialPositionY
    }
}

