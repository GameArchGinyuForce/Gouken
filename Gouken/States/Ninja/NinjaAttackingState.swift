import Foundation
import GameplayKit

class NinjaAttackingState: NinjaBaseState {
    var stateMachine: NinjaStateMachine!
    
    required init(_ stateMachine: NinjaStateMachine) {
        self.stateMachine = stateMachine
    }
    
    func enter() {
        print("enter NinjaAttackingState")
        stateMachine.character.setState(withState: CharacterState.Attacking)
        stateMachine.character.animator.changeAnimation(animName: characterAnimations[CharacterName.Ninja]![CharacterState.Attacking]!, loop: false)
        
        // Assume 1 attack for now
        // Hardcoded adding of events for hitbox toggling
//            player1?.animator.addAnimationEvent(keyTime: 0.1, callback: (player1?.activateHitboxesCallback)!)
        stateMachine.character.animator.addAnimationEvent(keyTime: 0.1) { node, eventData, playingBackward in
            self.stateMachine.character.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
        }
        
        stateMachine.character.animator.addAnimationEvent(keyTime: 0.2, callback: (stateMachine.character?.deactivateHitboxesCallback)!)
//            player1?.animator.addAnimationEvent(keyTime: 0.3, callback: (player1?.activateHitboxesCallback)!)
        stateMachine.character.animator.addAnimationEvent(keyTime: 0.3) { node, eventData, playingBackward in
            self.stateMachine.character.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
        }
        
        stateMachine.character.animator.addAnimationEvent(keyTime: 0.4, callback: (stateMachine.character?.deactivateHitboxesCallback)!)
//            player1?.animator.addAnimationEvent(keyTime: 0.5, callback: (player1?.activateHitboxesCallback)!)
        stateMachine.character.animator.addAnimationEvent(keyTime: 0.5) { node, eventData, playingBackward in
            self.stateMachine.character.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
        }
        
        stateMachine.character.animator.addAnimationEvent(keyTime: 0.6, callback: (stateMachine.character?.deactivateHitboxesCallback)!)
    }
    
    // TODO: Turn on hitboxes at certain points
    func tick(_ deltaTime: TimeInterval) {
        if (stateMachine.character.animator.currentTimeNormalized >= 1.0) {
            stateMachine.switchState(NinjaIdleState(stateMachine))
        }
    }
    
    func exit() {
        print("exit NinjaAttackingState")
        stateMachine.character?.hitbox.deactivateHitboxes()    // Clears hitboxes if attack state disrupted
    }
}
