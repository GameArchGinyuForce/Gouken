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
    
    let moveSequencesNinja =
    [
        ([ButtonType.Down, ButtonType.Right, ButtonType.LP], 1, 55),
        ([ButtonType.LP], 1, 1),
        ([ButtonType.Down], 1, 1),
        ([ButtonType.Right], 1, 1),
        ([ButtonType.Left], 1, 1),
        ([ButtonType.Up], 1, 1),
        ([ButtonType.HP], 1, 1)
    ]
    
    print(readSequences(fromList: moveSequencesNinja, andBuffer: buffer))    
}


func readSequences(fromList seq: [([ButtonType], Int, Int)], andBuffer buffer: InputBuffer) -> ([ButtonType], Int, Int) {
    for (moveSequence, movePriority, frameLeniency) in seq {
        var currentBufferFrame = 0
        var sequenceIdx = moveSequence.count - 1
        while (currentBufferFrame < frameLeniency) {
            let readIdx = (buffer.writeIdx - currentBufferFrame - 1) < 0 ? bufferSize - currentBufferFrame - 1 : (buffer.writeIdx - currentBufferFrame - 1) % bufferSize
            
            if (moveSequence[sequenceIdx] == buffer.buffer[readIdx]) {
                sequenceIdx -= 1
            }
            
            if (sequenceIdx == -1) {
                return (moveSequence, movePriority, frameLeniency)
            }
            
            currentBufferFrame += 1
        }
    }
    
    return ([ButtonType.Neutral], 0, 0)
}
