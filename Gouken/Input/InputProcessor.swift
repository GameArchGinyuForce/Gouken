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
func processBuffer(fromBuffer buffer: InputBuffer, onCharacter player: Character) {
    buffer.updateInput()
    
    if (player.state == CharacterState.Downed || player.state == CharacterState.Stunned) {
        return // character is dead or stunned
    }

    
    let stateToChangeTo = readSequences(fromList: NinjaMoveSet, andBuffer: buffer).stateChages
    let isCharIdle = player.state == CharacterState.Idle
    let canEnterNeutral = player.state == CharacterState.RunningLeft || player.state == CharacterState.RunningRight || player.state == CharacterState.Blocking
    let playerStateChanger = {(state : CharacterState) in
        player.stateMachine?.switchState((player.stateMachine! as! NinjaStateMachine).stateInstances[state]!)
    }
    
    
    
    switch (stateToChangeTo) {
    case .Stunned:
        playerStateChanger(.Stunned)
        break
    case .Downed:
        playerStateChanger(.Downed)
        break
    case .RunningLeft:
        if (isCharIdle) {
            playerStateChanger(.RunningLeft)
        }
        break
    case .RunningRight:
        if (isCharIdle) {
            playerStateChanger(.RunningRight)
        }
        break
    case .Attacking:
        if (isCharIdle) {
            playerStateChanger(.Attacking)
        }
        break
    case .Idle:
        if (canEnterNeutral) {
            playerStateChanger(.Idle)
        }
        break
    case .Jumping:
        if (isCharIdle) {
            playerStateChanger(.Jumping)
        }
        break
    case .Blocking:
        if (isCharIdle) {
            playerStateChanger(.Blocking)
        }
        break
    case .DashingLeft:
        if (isCharIdle) {
            playerStateChanger(.DashingLeft)
        }
        break
    case .DashingRight:
        if (isCharIdle) {
            playerStateChanger(.DashingRight)
        }
        break
    case .HeavyAttacking:
        if (isCharIdle) {
            playerStateChanger(.HeavyAttacking)
        }
        break
    case .DragonPunch:
        if (isCharIdle) {
            playerStateChanger(.DragonPunch)
        }
        break
    }
}


/**
 * This takes a movelist and parses the input buffer to return the move with the highest priority
 * whose sequence is found (with its respective frame leniency). As of now this is just a linear
 * scan with no sub-leniencies (e.g. we don't have strings like Mishima 1-1-2 Flash Punch in Tekken).
 */
func readSequences(fromList seq: [CharacterState: CharacterMove], andBuffer buffer: InputBuffer) -> CharacterMove {
    var currentMovesPrio = -1
    var currentMove = CharacterMove(sequence: [ButtonType.Neutral], stateChages: CharacterState.Idle, priority: 1, frameLeniency: 1, attackKeyFrames: [])
    for (_, move) in seq {
        let moveSequence = move.sequence
        let frameLeniency = move.frameLeniency
        var currentBufferFrame = 0
        var sequenceIdx = moveSequence.count - 1
        while (currentBufferFrame < frameLeniency) {
            if move.priority < currentMovesPrio {
                break
            }
            let readIdx = (buffer.writeIdx - currentBufferFrame - 1) < 0 ? bufferSize - currentBufferFrame - 1 : (buffer.writeIdx - currentBufferFrame - 1) % bufferSize
            
            if (moveSequence[sequenceIdx] == buffer.buffer[readIdx]) {
                sequenceIdx -= 1
            }
            
            if (sequenceIdx == -1) {
                currentMove = move
                currentMovesPrio = currentMove.priority
                break
            }
            
            currentBufferFrame += 1
        }
    }
    
    return currentMove    
}
