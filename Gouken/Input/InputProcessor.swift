//
//  InputProcessor.swift
//  Gouken
//
//  Created by Jas Singh on 2024-03-28.
//


let bufferSize = 60
let P1Buffer = InputBuffer()
let P2Buffer = InputBuffer()
//let moveSequences : [[ButtonType]] = [[ButtonType.Down, ButtonType.Right, ButtonType.LP]]

/** A thread safe input buffer. */
actor InputBuffer {
    var lastInput : ButtonType = ButtonType.Neutral
    var input : [ButtonType] = Array(repeating: ButtonType.Neutral, count: bufferSize)
    var writeIdx : Int = 0
    
    func insertInput(withPress: ButtonType) {
        lastInput = withPress
    }
    
    func updateInput() {
        input[writeIdx] = lastInput
        writeIdx = (writeIdx + 1) % bufferSize
        lastInput = ButtonType.Neutral
    }
    
    func processInput() {
        updateInput()
        
    }
}


