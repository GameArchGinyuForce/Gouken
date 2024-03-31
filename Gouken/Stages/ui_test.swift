//
//  ui_test.swift
//  Gouken
//
//  Created by Jugraj Chouhan on 2024-03-31.
//
import SceneKit
import GameplayKit
import Foundation
import UIKit
import SpriteKit

class HealthBarScene: SKScene {
    
    var playerHealth: Int = 100
    var opponentHealth: Int = 100
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // HP bar for opponent
        let opponentHPbackground = SKShapeNode(rectOf: CGSize(width: 180, height: 11), cornerRadius: 5)
        opponentHPbackground.position = CGPoint(x: 100, y: 100)
        opponentHPbackground.zPosition = 2
        opponentHPbackground.strokeColor = .black
        opponentHPbackground.fillColor = .black
        addChild(opponentHPbackground)
        
        let oppponentHPContainer = SKShapeNode(rectOf: CGSize(width: 150, height: 10), cornerRadius: 5)
        oppponentHPContainer.position = CGPoint(x: 100, y: 100)
        oppponentHPContainer.strokeColor = .lightGray
        opponentHPbackground.lineWidth = 2
        self.addChild(oppponentHPContainer)
        
        let opponentHPLabel = SKLabelNode(text: "Jaskaran: the zestlord")
        opponentHPLabel.horizontalAlignmentMode = .center
        opponentHPLabel.position = CGPoint(x: 110, y: 110)
        opponentHPLabel.fontColor = UIColor.orange
        opponentHPLabel.fontName = "AmericanTypewriter-Bold"
        opponentHPLabel.fontSize = 12
        opponentHPLabel.zPosition = 3
        self.addChild(opponentHPLabel)
        
        // You can continue adding your SpriteKit nodes and setup here
    }
    
    // Additional methods and functions for handling health updates, damage, etc. can be added here
    
}




