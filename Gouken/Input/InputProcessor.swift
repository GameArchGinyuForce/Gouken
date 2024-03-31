//
//  InputProcessor.swift
//  Gouken
//
//  Created by Jas Singh on 2024-03-28.
//
import Atomics

let bufferSize = 60
let P1Buffer = InputBuffer()
let P2Buffer = InputBuffer()
let moveSequences : [([ButtonType], Int)] = [([ButtonType.Down, ButtonType.Right, ButtonType.LP], 26)]

/** An input buffer with thread-safe insertions. If the caller uses it correctly, no race conditions should occur.
  * Whatever we take input from - a virtual controller or network socket, doesn't matter - should store input updates
  * via the insertInput function. If a button is held down or released, buttonPressedDown should be called as well.
   
  * Finally, the update loop should call "updateInput" before reading the buffer array underlying the actual buffer itself.
  * This will "flush" the last input received into the buffer.
 */
class InputBuffer {
    private var isPressedDown = ManagedAtomic<Bool>(false) // atomic value to signal a button being held down
    private var lastInput = ManagedAtomic<Int>(ButtonType.Neutral.rawValue) // the last input the user made
    var buffer : [ButtonType] = Array(repeating: ButtonType.Neutral, count: bufferSize) // the buffer itself, only to be accessed through the update loop
    var writeIdx : Int = 0
    
    // This function is to be used for anything that is to input into the buffer.
    func insertInput(withPress: ButtonType) {
        lastInput.store(withPress.rawValue, ordering: AtomicStoreOrdering.relaxed)
    }
    
    func buttonPressedDown(orNot: Bool) {
        isPressedDown.store(orNot, ordering: AtomicStoreOrdering.relaxed)
    }
    
    // takes the last input stored, adds it to the buffer and clears it if the user isn't holding down.
    func updateInput() {
        buffer[writeIdx] = ButtonType(rawValue: lastInput.load(ordering: AtomicLoadOrdering.relaxed))!
        writeIdx = (writeIdx + 1) % bufferSize

        if (!isPressedDown.load(ordering: AtomicLoadOrdering.relaxed)) {
            lastInput.store(ButtonType.Neutral.rawValue, ordering: AtomicStoreOrdering.relaxed)
        }
    }
}

/**
 Read an Input Buffer belonging to a specific character and update them.
ONLY USE THIS FUNCTION INSIDE OF THE RENDERER DELEGATE OF SCENEKIT.
THIS IS BECAUSE THE ACTUAL INPUT BUFFER ITSELF ISN'T THREAD SAFE, ONLY ONE FLOW OF CONTR0L SHOULD
TOUCH IT OTHERWISE BU HA0
*/
//TODO: Clean up input handling and add sequence reading for Hadouken. Earlier commit hash has the sequence reading algo.
func processBuffer(fromBuffer buffer: InputBuffer, onCharacter player: Character) {
    buffer.updateInput()
    
    // below dinky shit bc swift does not have negative modulus
    let readIdx = (buffer.writeIdx - 1) < 0 ? bufferSize - 1 : (buffer.writeIdx - 1) % bufferSize
    let input = buffer.buffer[readIdx]
    let isCharIdle = player.state == CharacterState.Idle
    let canEnterNeutral = player.state == CharacterState.RunningLeft || player.state == CharacterState.RunningRight
    
    if (input == ButtonType.Right && isCharIdle) {
        player.stateMachine?.switchState((player.stateMachine! as! NinjaStateMachine).stateInstances[CharacterState.RunningRight]!)
    } else if (input == ButtonType.Left && isCharIdle) {
        player.stateMachine?.switchState((player.stateMachine! as! NinjaStateMachine).stateInstances[CharacterState.RunningLeft]!)
    } else if (player.state != CharacterState.Attacking && input == ButtonType.LP && isCharIdle) {
        player.stateMachine?.switchState((player.stateMachine! as! NinjaStateMachine).stateInstances[CharacterState.Attacking]!)
        
        // Hardcoded adding of events for hitbox toggling
//            player1?.animator.addAnimationEvent(keyTime: 0.1, callback: (player1?.activateHitboxesCallback)!)
        player.animator.addAnimationEvent(keyTime: 0.1) { node, eventData, playingBackward in
            player.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
        }
        
        player.animator.addAnimationEvent(keyTime: 0.2, callback: (player.deactivateHitboxesCallback)!)
//            player1?.animator.addAnimationEvent(keyTime: 0.3, callback: (player1?.activateHitboxesCallback)!)
        player.animator.addAnimationEvent(keyTime: 0.3) { node, eventData, playingBackward in
            player.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
        }
        
        player.animator.addAnimationEvent(keyTime: 0.4, callback: (player.deactivateHitboxesCallback)!)
//            player1?.animator.addAnimationEvent(keyTime: 0.5, callback: (player1?.activateHitboxesCallback)!)
        player.animator.addAnimationEvent(keyTime: 0.5) { node, eventData, playingBackward in
            player.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
        }
        
        player.animator.addAnimationEvent(keyTime: 0.6, callback: (player.deactivateHitboxesCallback)!)

    } else if (canEnterNeutral && input == ButtonType.Neutral) {
        player.stateMachine?.switchState((player.stateMachine! as! NinjaStateMachine).stateInstances[CharacterState.Idle]!)
    }
}
