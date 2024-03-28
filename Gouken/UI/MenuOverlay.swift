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
    
    var menuContainer: SKNode = SKNode()
    
    // Add other buttons
    let buttonSize = CGSize(width: 150, height: 50)
    let offsetFromMiddle = CGPoint(x: 0, y: -20)
    let buttonSpacing: CGFloat = 10

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
        
//        setupMenu()
        showMenu();
        addChild(menuContainer)
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
    
    func showSelectGameMode() {
        menuContainer.removeAllChildren()
        
        // Title
        let label = SKLabelNode(text: "Gouken")
        label.fontName = "Helvetica"
        label.fontSize = 96
        label.fontColor = .white
        
        // Calculate the position of the label to ensure it's centered on the button
        label.position = CGPoint(x: frame.width / 2, y: frame.height / 2 + 40)

        menuContainer.addChild(label)
        
        // Back button
        let backButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        backButton.position = CGPoint(x: buttonSize.width / 2, y: size.height - buttonSize.height / 2)
        backButton.name = "backToMenuButton"
        backButton.strokeColor = .white
        backButton.lineWidth = 3
        backButton.fillColor = .black // Set fill color
        menuContainer.addChild(backButton)
        addText(to: backButton, text: "Back")
        
        // Select PVE button
        let selectPVEButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        selectPVEButton.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: size.height / 2 + offsetFromMiddle.y - (buttonSize.height + buttonSpacing) * 1)
        selectPVEButton.name = "selectPVEButton"
        selectPVEButton.strokeColor = .white
        selectPVEButton.lineWidth = 3
        selectPVEButton.fillColor = .black // Set fill color
        menuContainer.addChild(selectPVEButton)
        addText(to: selectPVEButton, text: "PVE")
        
        // Select PVP button
        let selectPVPButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        selectPVPButton.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: size.height / 2 + offsetFromMiddle.y - (buttonSize.height + buttonSpacing) * 2)
        selectPVPButton.name = "selectPVPButton"
        selectPVPButton.strokeColor = .white
        selectPVPButton.lineWidth = 3
        selectPVPButton.fillColor = .black // Set fill color
        menuContainer.addChild(selectPVPButton)
        addText(to: selectPVPButton, text: "PVP")
    }
    
    func showFindPlayers() {
        menuContainer.removeAllChildren()
        
        // Players found Nearby
        let label = SKLabelNode(text: "Players Found Nearby")
        label.fontName = "Helvetica"
        label.fontSize = 48
        label.fontColor = .white
        // Calculate the position of the label to ensure it's centered on the button
        label.position = CGPoint(x: frame.width / 2, y: frame.height - 60)
        menuContainer.addChild(label)
        
        // Back button
        let backButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        backButton.position = CGPoint(x: buttonSize.width / 2, y: size.height - buttonSize.height / 2)
        backButton.name = "backToSelectGameModeButton"
        backButton.strokeColor = .white
        backButton.lineWidth = 3
        backButton.fillColor = .black // Set fill color
        menuContainer.addChild(backButton)
        addText(to: backButton, text: "Back")
        
        // Player 1 Placeholder
        var selectPlayer1 = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        selectPlayer1.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: frame.height - 40 - (buttonSize.height + buttonSpacing) * 1)
        selectPlayer1.name = "selectPlayerButton"
        selectPlayer1.strokeColor = .white
        selectPlayer1.lineWidth = 3
        selectPlayer1.fillColor = .black // Set fill color
        menuContainer.addChild(selectPlayer1)
        addText(to: selectPlayer1, text: "Player 1")
        
        // Player 2 Placeholder
        selectPlayer1 = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        selectPlayer1.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: frame.height - 40 - (buttonSize.height + buttonSpacing) * 2)
        selectPlayer1.name = "selectPlayerButton"
        selectPlayer1.strokeColor = .white
        selectPlayer1.lineWidth = 3
        selectPlayer1.fillColor = .black // Set fill color
        menuContainer.addChild(selectPlayer1)
        addText(to: selectPlayer1, text: "Player 2")
        
        // Player 3 Placeholder
        selectPlayer1 = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        selectPlayer1.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: frame.height - 40 - (buttonSize.height + buttonSpacing) * 2)
        selectPlayer1.name = "selectPlayerButton"
        selectPlayer1.strokeColor = .white
        selectPlayer1.lineWidth = 3
        selectPlayer1.fillColor = .black // Set fill color
        menuContainer.addChild(selectPlayer1)
        addText(to: selectPlayer1, text: "Player 3")
    }
    
    func showMenu() {
        menuContainer.removeAllChildren()

        // Add play button
        let playButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        playButton.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: size.height / 2 + offsetFromMiddle.y)
        playButton.name = "playButton"
        playButton.strokeColor = .white
        playButton.lineWidth = 3
        playButton.fillColor = .black // Set fill color
        menuContainer.addChild(playButton)
        addText(to: playButton, text: "Play")
        
        
        // Title
        let label = SKLabelNode(text: "Gouken")
        label.fontName = "Helvetica"
        label.fontSize = 96
        label.fontColor = .white
        
        // Calculate the position of the label to ensure it's centered on the button
        label.position = CGPoint(x: frame.width / 2, y: frame.height / 2 + 40)

        menuContainer.addChild(label)
        
        // Add settings button
        let settingsButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        settingsButton.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: size.height / 2 + offsetFromMiddle.y - (buttonSize.height + buttonSpacing))
        settingsButton.name = "settingsButton"
        settingsButton.strokeColor = .white
        settingsButton.lineWidth = 3
        settingsButton.fillColor = .black // Set fill color
        menuContainer.addChild(settingsButton)
        addText(to: settingsButton, text: "Settings")
        
        // Add quit button
        let quitButton = SKShapeNode(rect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height), cornerRadius: 10)
        quitButton.position = CGPoint(x: size.width / 2 + offsetFromMiddle.x, y: size.height / 2 + offsetFromMiddle.y - (buttonSize.height + buttonSpacing) * 2) // 2 buttons down from first
        quitButton.name = "quitButton"
        quitButton.strokeColor = .white
        quitButton.lineWidth = 3
        quitButton.fillColor = .black // Set fill color
        menuContainer.addChild(quitButton)
        addText(to: quitButton, text: "Quit")
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
//                    overlayDelegate?.playButtonPressed()
                    showSelectGameMode()
                case "backToMenuButton":
                    showMenu()
                case "backToSelectGameModeButton":
                    showSelectGameMode()
                case "selectPVEButton":
                    overlayDelegate?.playButtonPressed()    // Calls a method in GameViewController to swap scenes
                case "selectPVPButton":
                    showFindPlayers()
                case "selectPlayerButton":
                    overlayDelegate?.playButtonPressed()    // Calls a method in GameViewController to swap scenes
                default:
                    break
                }
            }
        }
    }
}
