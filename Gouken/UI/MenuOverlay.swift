import SpriteKit

// Allows us to call functions outside the overlay
protocol SKOverlayDelegate: AnyObject {
    func playButtonPressed()
    // Add more functions as needed for different menu options
}

class MenuSceneOverlay: SKScene {
    weak var overlayDelegate: SKOverlayDelegate?

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        setupMenu()
    }

    private func setupMenu() {
        // Add background
        let backgroundNode = SKSpriteNode(color: .black, size: CGSize(width: 300, height: 200))
        backgroundNode.alpha = 0.7
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(backgroundNode)
        
        
        // Add other buttons
        let buttonSize = CGSize(width: 150, height: 50)
        let buttonSpacing: CGFloat = 20
        
        // Add play button
        let playButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
        playButton.name = "playButton"
        playButton.strokeColor = .white
        playButton.lineWidth = 3
        playButton.fillColor = .black // Set fill color
        addChild(playButton)
        addText(to: playButton, text: "Play") // Add text to button1
        
        // Add settings button
        let settingsButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        settingsButton.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100 - (buttonSize.height + buttonSpacing))
        settingsButton.name = "settingsButton"
        settingsButton.strokeColor = .white
        settingsButton.lineWidth = 3
        settingsButton.fillColor = .black // Set fill color
        addChild(settingsButton)
        addText(to: settingsButton, text: "Settings") // Add text to button1
    }
    
    private func addText(to node: SKNode, text: String) {
        let label = SKLabelNode(text: text)
        label.fontName = "Helvetica"
        label.fontSize = 20
        label.fontColor = .white
        
        // Calculate the position of the label to ensure it's centered on the button
        label.position = CGPoint(x: 0, y: -label.frame.size.height / 2 + 10)
        
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        node.addChild(label)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let node = self.nodes(at: location).first as? SKShapeNode {
            if node.name == "playButton" {
                overlayDelegate?.playButtonPressed()
            }
        }
    }
}
