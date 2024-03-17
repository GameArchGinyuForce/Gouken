//
//  GamePad.swift
//  Gouken
//
//  Created by Jaskaran Chahal on 2024-03-17.
//

import SpriteKit

let unpressedColour : UIColor = UIColor(red: 128.0, green: 128.0, blue: 128.0, alpha: 0.7)
let pressedColour   : UIColor = UIColor(red: 128.0, green: 128.0, blue: 128.0, alpha: 0.4)

let BUTTON_RATIO = 0.152
let XPOS_RATIO   = 0.1701
let YPOS_RATIO   = 0.4835

func createDpadBtn(ofSize size: CGSize, andRoundedEdges roundedEdge: CGFloat) -> SKShapeNode {
    
    let button = SKShapeNode(rectOf: size, cornerRadius: roundedEdge)
    button.fillColor = pressedColour
    button.strokeColor = UIColor.black
    button.isUserInteractionEnabled = false
    return button
}

func setupGamePad(withViewHeight height: CGFloat, andViewWidth width: CGFloat) -> SKScene {
    let sceneSize = CGSize(width: width, height: height)
    print("Screen size of ", width, " by ", height)
    let skScene = SKScene(size: sceneSize)
    skScene.scaleMode = .resizeFill
    
    // Ratios for responsiveness across different screens
    let buttonLength = BUTTON_RATIO * height
    let initXPos     = XPOS_RATIO * width
    let initYPos     = YPOS_RATIO * height
    
    let dpadUp = createDpadBtn(ofSize: CGSize(width: buttonLength, height: buttonLength), andRoundedEdges: 5.0)
    dpadUp.position.x = initXPos
    dpadUp.position.y = initYPos;
    
    let dpadDown = createDpadBtn(ofSize: CGSize(width: buttonLength, height: buttonLength), andRoundedEdges: 5.0)
    dpadDown.position.x = initXPos;
    dpadDown.position.y = initYPos - (2 * buttonLength);
    
    let dpadRight = createDpadBtn(ofSize: CGSize(width: buttonLength, height: buttonLength), andRoundedEdges: 5.0)
    dpadRight.position.x = initXPos + buttonLength;
    dpadRight.position.y = initYPos - buttonLength;
    
    let dpadLeft = createDpadBtn(ofSize: CGSize(width: buttonLength, height: buttonLength), andRoundedEdges: 5.0)
    dpadLeft.position.x = initXPos - buttonLength;
    dpadLeft.position.y = initYPos - buttonLength;

    skScene.addChild(dpadUp)
    skScene.addChild(dpadDown)
    skScene.addChild(dpadLeft)
    skScene.addChild(dpadRight)

    return skScene
}
