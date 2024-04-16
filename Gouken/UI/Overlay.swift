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
    
    func setUpSecondaryUI() {
        // Calculate button size and spacing relative to scene size
        let buttonSize = CGSize(width: size.width * 0.1, height: size.width * 0.1)
        let buttonSpacing = size.width * 0.02
        
        // Calculate button position relative to scene size
        let offsetX = size.width * 0.4
        let offsetY = size.height * 0.4
        
        // Quit button
        let settingsButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        settingsButton.position = CGPoint(x: offsetX, y: offsetY)
        settingsButton.name = "settingsButton"
        settingsButton.strokeColor = .white
        settingsButton.lineWidth = size.width * 0.01
        settingsButton.fillColor = .black
        addChild(settingsButton)
    }

}
