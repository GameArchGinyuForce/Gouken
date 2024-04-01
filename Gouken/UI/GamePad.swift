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

enum ButtonType : Int {
    case Up
    case Left
    case Right
    case Down
    case LP
    case HP
    case Neutral
}


/** This class handles gamepad buttons.
 */
class GamePadButton : SKShapeNode {
    
    var type : ButtonType
    var buttonShape : SKShapeNode
    var inputBuffer : InputBuffer

    /** Forces an interactable button */
    override var isUserInteractionEnabled: Bool {
        set {
            // ignore
        }
        get {
            return true
        }
    }
    
    required init(withBuffer buffer: InputBuffer, ofShape button: SKShapeNode, andButtonType : ButtonType) {
        type = andButtonType
        buttonShape = button
        inputBuffer = buffer

        
        super.init()
        addChild(buttonShape)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonShape.fillColor = pressedColour
        inputBuffer.buttonPressedDown(orNot: true)
        inputBuffer.insertInput(withPress: type)
    }
    
    func buttonReleased() {
        buttonShape.fillColor = unpressedColour
        inputBuffer.buttonPressedDown(orNot: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonReleased()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonReleased()
    }
}


func createDpadBtn(onBuffer buffer: InputBuffer, ofSize size: CGSize, andRoundedEdges roundedEdge: CGFloat, andType: ButtonType) -> SKShapeNode {
    
    let button = SKShapeNode(rectOf: size, cornerRadius: roundedEdge)
    button.fillColor = unpressedColour
    button.strokeColor = UIColor.black
    
    return GamePadButton(withBuffer: buffer, ofShape: button, andButtonType: andType)
}

func createPunchBtn(onBuffer buffer: InputBuffer, withRadius radius: CGFloat, andType type: ButtonType) -> SKShapeNode {
    let button = SKShapeNode(circleOfRadius: radius)
    button.fillColor = unpressedColour	
    return GamePadButton(withBuffer: buffer, ofShape: button, andButtonType: type)
}




func setupHealthBars(withViewHeight height: CGFloat, andViewWidth width: CGFloat) -> SKScene {
    
    let sceneSize = CGSize(width: width, height: height)
    print("Screen size of ", width, " by ", height)
    let skScene = SKScene(size: sceneSize)
    skScene.scaleMode = .resizeFill
    
    var timerLabel: SKLabelNode!
    var countdownTimer: Timer?
    var totalTime = 120 // 2 minutes
    var playerHealth: CGFloat = 1.0 // Full health (1.0 for 100%)
    var opponentHealth: CGFloat = 1.0 // Full health (1.0 for 100%)
    
    
    timerLabel = SKLabelNode(text: "Gouken") //shows the game title before the game starts with the timer
    timerLabel.position = CGPoint(x: width / 2, y: 320)
    timerLabel.fontName = "Chalkduster"
    timerLabel.fontColor = .white
    timerLabel.fontSize = 20
    timerLabel.zPosition = 5
    
    skScene.addChild(timerLabel)
    
    /*startTimer*/()
    
    // HP bar for player
    let playerHPBackground = SKShapeNode(rectOf: CGSize(width: 180, height: 11), cornerRadius: 5)
    playerHPBackground.position = CGPoint(x: 150, y: 320)
    playerHPBackground.zPosition = 2
    playerHPBackground.strokeColor = .black
    playerHPBackground.fillColor = .black
    skScene.addChild(playerHPBackground)
    
    let playerHPContainer = SKShapeNode(rectOf: CGSize(width: 150, height: 10), cornerRadius: 5)
    playerHPContainer.position = CGPoint(x: 160, y: 320)
    playerHPContainer.zPosition = 4
    playerHPContainer.strokeColor = .yellow
    playerHPContainer.lineWidth = 2
    skScene.addChild(playerHPContainer)
    
    let playerHPBar = SKSpriteNode(color: .green, size: CGSize(width: 150, height: 8))
    playerHPBar.position = CGPoint(x: -playerHPBar.size.width / 2, y: 0)
    playerHPBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
    playerHPBar.zPosition = 3
    playerHPContainer.addChild(playerHPBar)
    
    // Player HP Label
    let playerHPLabel = SKLabelNode(text: "Deckem Jaskaran: \(Int(playerHealth * 100))%")
    playerHPLabel.position = CGPoint(x: 150, y: 330)
    playerHPLabel.fontColor = .white
    playerHPLabel.fontSize = 12
    playerHPLabel.zPosition = 5
    skScene.addChild(playerHPLabel)
    
    // HP bar for opponent
    let opponentHPBackground = SKShapeNode(rectOf: CGSize(width: 180, height: 11), cornerRadius: 5)
    opponentHPBackground.position = CGPoint(x: 500, y: 320)
    opponentHPBackground.zPosition = 2
    opponentHPBackground.strokeColor = .black
    opponentHPBackground.fillColor = .black
    skScene.addChild(opponentHPBackground)
    
    let opponentHPContainer = SKShapeNode(rectOf: CGSize(width: 150, height: 10), cornerRadius: 5)
    opponentHPContainer.position = CGPoint(x: 510, y: 320)
    opponentHPContainer.zPosition = 4
    opponentHPContainer.strokeColor = .yellow
    opponentHPContainer.lineWidth = 2 //
    skScene.addChild(opponentHPContainer)
    
    let opponentHPBar = SKSpriteNode(color: .green, size: CGSize(width: 150, height: 8))
    opponentHPBar.position = CGPoint(x: -opponentHPBar.size.width / 2, y: 0)
    opponentHPBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
    opponentHPBar.zPosition = 3
    opponentHPContainer.addChild(opponentHPBar)
    
    // Opponent HP Label
    let opponentHPLabel = SKLabelNode(text: "My name Jeff: \(Int(opponentHealth * 100))%")
    opponentHPLabel.position = CGPoint(x: 500, y: 330)
    opponentHPLabel.fontColor = .white
    opponentHPLabel.fontSize = 12
    opponentHPLabel.zPosition = 5
    skScene.addChild(opponentHPLabel)

    
    return skScene
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
    
    // Create all DPad Buttons
    let dpadUp = createDpadBtn(onBuffer: P1Buffer, ofSize: CGSize(width: buttonLength, height: buttonLength), andRoundedEdges: 5.0, andType: ButtonType.Up)
    dpadUp.position.x = initXPos
    dpadUp.position.y = initYPos
    
    let dpadDown = createDpadBtn(onBuffer: P1Buffer, ofSize: CGSize(width: buttonLength, height: buttonLength), andRoundedEdges: 5.0, andType: ButtonType.Down)
    dpadDown.position.x = initXPos
    dpadDown.position.y = initYPos - (2 * buttonLength)
    
    let dpadRight = createDpadBtn(onBuffer: P1Buffer, ofSize: CGSize(width: buttonLength, height: buttonLength), andRoundedEdges: 5.0, andType: ButtonType.Right)
    dpadRight.position.x = initXPos + buttonLength
    dpadRight.position.y = initYPos - buttonLength
    
    let dpadLeft = createDpadBtn(onBuffer: P1Buffer, ofSize: CGSize(width: buttonLength, height: buttonLength), andRoundedEdges: 5.0, andType: ButtonType.Left)
    dpadLeft.position.x = initXPos - buttonLength
    dpadLeft.position.y = initYPos - buttonLength

    skScene.addChild(dpadUp)
    skScene.addChild(dpadDown)
    skScene.addChild(dpadLeft)
    skScene.addChild(dpadRight)
    
    let lpBtn = createPunchBtn(onBuffer: P1Buffer, withRadius: buttonLength / 1.2, andType: ButtonType.LP)
    lpBtn.position.x = 4 * (initXPos)
    lpBtn.position.y = initYPos - 1.5 * buttonLength
    
    let hpBtn = createPunchBtn(onBuffer: P1Buffer, withRadius: buttonLength / 1.2, andType: ButtonType.HP)
    hpBtn.position.x = 4.8 * (initXPos)
    hpBtn.position.y = initYPos - 0.5 * buttonLength

    skScene.addChild(lpBtn)
    skScene.addChild(hpBtn)
    
    return skScene
}
