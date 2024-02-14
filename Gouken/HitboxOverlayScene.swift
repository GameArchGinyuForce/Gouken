//
//  HitboxOverlayScene.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-02-13.
//

import SpriteKit
import SwiftUI

class HitboxOverlayScene: SKScene {
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)

        self.backgroundColor = UIColor.blue

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let start = SKLabelNode(text: "START")
        start.fontColor = .white
        self.addChild(start)
    }


   
}
