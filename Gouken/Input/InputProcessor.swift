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
    var lastInput = ManagedAtomic<Int>(ButtonType.Neutral.rawValue)
    var buffer : [ButtonType] = Array(repeating: ButtonType.Neutral, count: bufferSize)
    var writeIdx : Int = 0
    
    func insertInput(withPress: ButtonType) {
        lastInput.store(withPress.rawValue, ordering: AtomicStoreOrdering.relaxed)
    }
    
    func updateInput() {
        buffer[writeIdx] = ButtonType(rawValue: lastInput.load(ordering: AtomicLoadOrdering.relaxed))!
        writeIdx = (writeIdx + 1) % bufferSize
        lastInput.store(ButtonType.Neutral.rawValue, ordering: AtomicStoreOrdering.relaxed)
    }
    
    func processInput() {
        updateInput()
        for moveSequence in moveSequences {
            var sequenceCtr = moveSequence.0.count - 1
            for i in 0..<moveSequence.1 {
                var input = buffer[(writeIdx + bufferSize - 1 - i) % bufferSize]
                
                if input == moveSequence.0[sequenceCtr] {
                    sequenceCtr -= 1
                }
                
                if sequenceCtr == -1 {
                    print("WE HAVE A HADOUKEN")
                    break
                }
            }
        }
    }
}


