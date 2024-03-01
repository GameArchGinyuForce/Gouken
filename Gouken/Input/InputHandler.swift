//
//  InputHandler.swift
//  Gouken
//
//  Created by Jaskaran Chahal on 2024-03-01.
//

import GameController

enum InputKeys {
    case Neutral
    case Up
    case UpForward
    case Forward
    case DownForward
    case Down
    case DownBackward
    case Backward
    case UpBackward
    case LP
    case HP
}

let deadZone = 0.0001

func readInput(fromGamePad gamePad: GCExtendedGamepad, deltaTime time: TimeInterval) {
    let analogueStick = gamePad.leftThumbstick
    let lpBtn = gamePad.buttonA
    let hpBtn = gamePad.buttonB

    if (analogueStick.xAxis.value > 0.0001 && analogueStick.yAxis.value > 0.0001) {
        var valuesStringified = "(\(analogueStick.xAxis.value), \(analogueStick.yAxis.value))"
        print("Movement ", valuesStringified, " at time: ", time)
    }
    
    if (lpBtn.isPressed) {
        print("Light Punch pressed at time: ", time)
    }
    
    if (hpBtn.isPressed) {
        print("Heavy Punch pressed at time: ", time)
    }

}
