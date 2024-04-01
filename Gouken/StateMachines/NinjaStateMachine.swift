import Foundation
import GameplayKit

class NinjaStateMachine: CharacterStateMachine {
    var stateInstances: [CharacterState: NinjaBaseState]!
    
    override init(_ character: Character) {
        super.init(character)
        
        stateInstances = [
            CharacterState.Stunned: NinjaStunnedState(self),
            CharacterState.RunningLeft: NinjaRunningLeftState(self),
            CharacterState.RunningRight: NinjaRunningRightState(self),
            CharacterState.Attacking: NinjaAttackingState(self),
            CharacterState.Idle: NinjaIdleState(self),
            CharacterState.Blocking: NinjaBlockingState(self),
            CharacterState.Downed: NinjaDownedState(self)
        ]
        
        character.health.onHit = { hitter, damage in
            if (character.state == CharacterState.Blocking) {
                hitter.stateMachine!.switchState((hitter.stateMachine as! NinjaStateMachine).stateInstances[CharacterState.Stunned]!)
            } else {
                character.health.damage(damage)
            }
        }
        character.health.onDamage = {
            self.switchState(self.stateInstances[CharacterState.Stunned]!)
        }
        character.health.onDie = {
            self.switchState(self.stateInstances[CharacterState.Downed]!)
        }
        
        self.switchState(self.stateInstances[CharacterState.Idle]!)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
