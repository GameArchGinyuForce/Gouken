//
//  BoundChecker.swift
//  Gouken
//
//  Created by Jeff Phan on 2024-04-02.
//

import Foundation
import SceneKit

let worldBoundSize: Float = 15
let insidePlayerBoundSize: Float = 0.6
let pushPlayerBoundSize: Float = 0.8
var cameraBoundSize: Float = 3
var pushSpeed: Float = 0.05

func boundCheckAll(player1Node: SCNNode, player2Node: SCNNode, newPos: Float, cameraPos: Float) -> Float {
    
    var player1Pos = player1Node.position.z
    var player2Pos = player2Node.position.z
    
    let adjustedPos = boundCheckPlayer(player1Node: player1Node, player2Node: player2Node, newPos: newPos)
    if let adjustedPos = adjustedPos {
        return adjustedPos
    }
    
    
    if (boundCheckWorld(player1Pos: player1Pos, player2Pos: player2Pos, newPos: newPos) &&
        boundCheckCamera(player1Pos: player1Pos, player2Pos: player2Pos, newPos: newPos, cameraPos: cameraPos)) {
        return newPos
    } else {
        return player1Pos
    }
}

func boundCheckPlayer(player1Node: SCNNode, player2Node: SCNNode, newPos: Float) -> Float? {
    
    var player1Pos = player1Node.position.z
    var player2Pos = player2Node.position.z
    
    let distance = abs(player1Pos - player2Pos)
    let distanceAfterMove = abs(newPos - player2Pos)
    
    if distance < insidePlayerBoundSize {
        //inside another player, push out
        if player1Pos > player2Pos {
            return player2Pos - insidePlayerBoundSize - pushSpeed
        } else {
            return player2Pos + insidePlayerBoundSize + pushSpeed
        }
    }
    if distance < pushPlayerBoundSize && (distanceAfterMove<distance){
        //push player zone
        player2Node.position.z += (newPos-player1Pos)/2
        return player1Pos + (newPos-player1Pos)/2
    }
    return nil
}

func boundCheckWorld(player1Pos: Float, player2Pos: Float, newPos: Float) -> Bool {
    let lowerBound = -worldBoundSize / 2
    let upperBound = worldBoundSize / 2
    return newPos >= lowerBound && newPos <= upperBound
}

func boundCheckCamera(player1Pos: Float, player2Pos: Float, newPos: Float, cameraPos: Float) -> Bool {
    let lowerBound = -cameraBoundSize
    let upperBound = cameraBoundSize
    return newPos >= lowerBound && newPos <= upperBound
}
