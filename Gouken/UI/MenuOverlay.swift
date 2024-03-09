import SpriteKit
import AVFoundation


// Allows us to call functions outside the overlay
protocol SKOverlayDelegate: AnyObject {
    func playButtonPressed()
    // Add more functions as needed for different menu options
}

class MenuSceneOverlay: SKScene {
    weak var overlayDelegate: SKOverlayDelegate?
    var backgroundMusicPlayer: AVAudioPlayer?

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        let backgroundImage = SKSpriteNode(imageNamed: "background.jpg")

        // Set the position to the center of the scene
        backgroundImage.position = CGPoint(x: size.width / 2, y: size.height / 2)

        // Make the image cover the entire scene
        backgroundImage.size = size

        // Add the image to the scene
        addChild(backgroundImage)
        
        // Set the background color to clear to make the image visible
        backgroundColor = .clear
        
        // Play background music
        playBackgroundMusic()
        
        setupMenu()
    }

    private func setupMenu() {
        
        
        
        
        // Add other buttons
        let buttonSize = CGSize(width: 150, height: 50)
        let offsetFromMiddle = CGPoint(x: 0, y: -20)
        let buttonSpacing: CGFloat = 10
        
        // Add play button
        let playButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        playButton.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: size.height / 2 + offsetFromMiddle.y)
        playButton.name = "playButton"
        playButton.strokeColor = .white
        playButton.lineWidth = 3
        playButton.fillColor = .black // Set fill color
        addChild(playButton)
        addText(to: playButton, text: "Play")
        
        
        
        let label = SKLabelNode(text: "Gouken")
        label.fontName = "Helvetica"
        label.fontSize = 96
        label.fontColor = .white
        
        // Calculate the position of the label to ensure it's centered on the button
        label.position = CGPoint(x: 0, y: 100)
//
//        label.verticalAlignmentMode = .center
//        label.horizontalAlignmentMode = .center
        playButton.addChild(label)
        
        // Add settings button
        let settingsButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        settingsButton.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: size.height / 2 + offsetFromMiddle.y - (buttonSize.height + buttonSpacing))
        settingsButton.name = "settingsButton"
        settingsButton.strokeColor = .white
        settingsButton.lineWidth = 3
        settingsButton.fillColor = .black // Set fill color
        addChild(settingsButton)
        addText(to: settingsButton, text: "Settings")
        
        // Add quit button
        let quitButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        quitButton.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: size.height / 2 + offsetFromMiddle.y - (buttonSize.height + buttonSpacing) * 2) // 2 buttons down from first
        quitButton.name = "quitButton"
        quitButton.strokeColor = .white
        quitButton.lineWidth = 3
        quitButton.fillColor = .black // Set fill color
        addChild(quitButton)
        addText(to: quitButton, text: "Quit")
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
    
    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") else {
            print("Could not find backgroundMusic.mp3")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = 0.3
            backgroundMusicPlayer?.play()
        } catch {
            print("Could not create audio player: \(error)")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if let name = node.name {
                switch name {
                case "playButton":
                    overlayDelegate?.playButtonPressed()
                // Add cases for other buttons if needed
                default:
                    break
                }
            }
        }
    }
}
