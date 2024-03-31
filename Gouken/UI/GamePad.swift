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

class GamePadButton : SKShapeNode {
    
    var type : ButtonType
    var buttonCallback : (InputBuffer, ButtonType) -> Void
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
    
    required init(withBuffer buffer: InputBuffer, ofShape button: SKShapeNode, andButtonType : ButtonType, uponPressed : @escaping (InputBuffer, ButtonType) -> Void) {
        type = andButtonType
        buttonCallback = uponPressed
        print("making dpad")
        buttonShape = button
        inputBuffer = buffer
        super.init()
        addChild(buttonShape)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touched")
        buttonShape.fillColor = pressedColour
        inputBuffer.buttonPressedDown(orNot: true)
        buttonCallback(inputBuffer, type)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("let go")
        buttonShape.fillColor = unpressedColour
        inputBuffer.buttonPressedDown(orNot: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("let go")
        buttonShape.fillColor = unpressedColour
        inputBuffer.buttonPressedDown(orNot: false)
    }
}

func ProcessInput(buffer: InputBuffer, buttonType : ButtonType) {
    buffer.insertInput(withPress: buttonType)
    
    switch buttonType {
    case .Up:
//        print("Up pressed!")
        break
    case .Down:
//        print("Down pressed!")
        break
    case .Right:
//        print("Right pressed!")
        break
    case .Left:
//        print("Left pressed!")
        break
    case .LP:
//        print("Light punch pressed!")
        break
    case .HP:
//        print("Heavy punch pressed!")
        break
    default:
        break
    }
}

func createDpadBtn(onBuffer buffer: InputBuffer, ofSize size: CGSize, andRoundedEdges roundedEdge: CGFloat, andType: ButtonType) -> SKShapeNode {
    
    let button = SKShapeNode(rectOf: size, cornerRadius: roundedEdge)
    button.fillColor = unpressedColour
    button.strokeColor = UIColor.black
    
    return GamePadButton(withBuffer: buffer, ofShape: button, andButtonType: andType, uponPressed: ProcessInput)
}

func createPunchBtn(onBuffer buffer: InputBuffer, withRadius radius: CGFloat, andType type: ButtonType) -> SKShapeNode {
    let button = SKShapeNode(circleOfRadius: radius)
    button.fillColor = unpressedColour	
    return GamePadButton(withBuffer: buffer, ofShape: button, andButtonType: type, uponPressed: ProcessInput)
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
