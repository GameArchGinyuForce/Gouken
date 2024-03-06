import SpriteKit
import GameController

class Overlay: SKScene {
    var virtualController: GCVirtualController?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        setUpSecondaryUI()
    }
    
    override func sceneDidLoad() {
        setUpSecondaryUI()

        let controllerConfig = GCVirtualController.Configuration()
        controllerConfig.elements = [
            GCInputLeftThumbstick,
            GCInputButtonA,
            GCInputButtonB
        ]
        
        virtualController = GCVirtualController(configuration: controllerConfig)
        virtualController?.connect()
        
    }
    
    func setUpSecondaryUI () {
        // Quit button
        let buttonSize = CGSize(width: 20, height: 20)
        let offsetFromMiddle = CGPoint(x: 0, y: -20)
        let buttonSpacing: CGFloat = 10
        
        let settingsButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        settingsButton.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: size.height / 2 + offsetFromMiddle.y - (buttonSize.height + buttonSpacing))
        settingsButton.name = "settingsButton"
        settingsButton.strokeColor = .white
        settingsButton.lineWidth = 3
        settingsButton.fillColor = .black // Set fill color
        addChild(settingsButton)
    }
}
