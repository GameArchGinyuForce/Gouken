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

/** A thread safe input buffer. */
class InputBuffer {
    var isPressedDown = ManagedAtomic<Bool>(false)
    var lastInput = ManagedAtomic<Int>(ButtonType.Neutral.rawValue)
    var buffer : [ButtonType] = Array(repeating: ButtonType.Neutral, count: bufferSize)
    var writeIdx : Int = 0
    
    func insertInput(withPress: ButtonType) {
        lastInput.store(withPress.rawValue, ordering: AtomicStoreOrdering.relaxed)
    }
    
    func buttonPressedDown(orNot: Bool) {
        isPressedDown.store(orNot, ordering: AtomicStoreOrdering.relaxed)
    }
    
    func updateInput() {
        buffer[writeIdx] = ButtonType(rawValue: lastInput.load(ordering: AtomicLoadOrdering.relaxed))!
        writeIdx = (writeIdx + 1) % bufferSize

        if (!isPressedDown.load(ordering: AtomicLoadOrdering.relaxed)) {
            lastInput.store(ButtonType.Neutral.rawValue, ordering: AtomicStoreOrdering.relaxed)
        }
    }
}

// Read an Input Buffer belonging to a specific character and update them.
func processBuffer(fromBuffer buffer: InputBuffer, onCharacter player: Character) {
    buffer.updateInput()
    
    // below dinky shit bc swift does not have negative modulus
    let readIdx = (buffer.writeIdx - 1) < 0 ? bufferSize - 1 : (buffer.writeIdx - 1) % bufferSize
    let input = buffer.buffer[readIdx]
    let isCharIdle = player.state == CharacterState.Idle
    
    if (input == ButtonType.Right && isCharIdle) {
        player.stateMachine?.switchState(NinjaRunningRightState((player.stateMachine! as! NinjaStateMachine)))
    } else if (input == ButtonType.Left && isCharIdle) {
        player.stateMachine?.switchState(NinjaRunningLeftState((player.stateMachine! as! NinjaStateMachine)))
    } else if (input == ButtonType.Neutral) {
        player.stateMachine?.switchState(NinjaIdleState((player.stateMachine! as! NinjaStateMachine)))
    }
}
