import SpriteKit
import GameController

class Overlay: SKScene {
    var virtualController: GCVirtualController?
    
    override func sceneDidLoad() {
        let controllerConfig = GCVirtualController.Configuration()
        controllerConfig.elements = [
            GCInputLeftThumbstick,
            GCInputButtonA,
            GCInputButtonB
        ]
        
        virtualController = GCVirtualController(configuration: controllerConfig)
        virtualController?.connect()
    }
}
