import SpriteKit

class HealthBarScene: SKScene {
    
    // Player and Opponent Health properties
    var playerHealth: CGFloat = 1.0 // Full health (1.0 for 100%)
    var opponentHealth: CGFloat = 1.0 // Full health (1.0 for 100%)
    var timerLabel: SKLabelNode!
     var countdownTimer: Timer?
     var totalTime = 120 // 2 minutes
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Add timer label
        timerLabel = SKLabelNode(text: "Gouken") //shows the game title before the game starts with the timer
        timerLabel.position = CGPoint(x: size.width / 2, y: 320)
        timerLabel.fontName = "Chalkduster"
        timerLabel.fontColor = .white
        timerLabel.fontSize = 20
        timerLabel.zPosition = 5
        addChild(timerLabel)
        
        // Start countdown timer
        startTimer()
        
        // HP bar for player
        let playerHPBackground = SKShapeNode(rectOf: CGSize(width: 180, height: 11), cornerRadius: 5)
        playerHPBackground.position = CGPoint(x: 150, y: 320)
        playerHPBackground.zPosition = 2
        playerHPBackground.strokeColor = .black
        playerHPBackground.fillColor = .black
        addChild(playerHPBackground)
        
        let playerHPContainer = SKShapeNode(rectOf: CGSize(width: 150, height: 10), cornerRadius: 5)
        playerHPContainer.position = CGPoint(x: 160, y: 320)
        playerHPContainer.zPosition = 4
        playerHPContainer.strokeColor = .yellow
        playerHPContainer.lineWidth = 2
        addChild(playerHPContainer)
        
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
        addChild(playerHPLabel)
        
        // HP bar for opponent
        let opponentHPBackground = SKShapeNode(rectOf: CGSize(width: 180, height: 11), cornerRadius: 5)
        opponentHPBackground.position = CGPoint(x: 500, y: 320)
        opponentHPBackground.zPosition = 2
        opponentHPBackground.strokeColor = .black
        opponentHPBackground.fillColor = .black
        addChild(opponentHPBackground)
        
        let opponentHPContainer = SKShapeNode(rectOf: CGSize(width: 150, height: 10), cornerRadius: 5)
        opponentHPContainer.position = CGPoint(x: 510, y: 320)
        opponentHPContainer.zPosition = 4
        opponentHPContainer.strokeColor = .yellow
        opponentHPContainer.lineWidth = 2 //
        addChild(opponentHPContainer)
        
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
        addChild(opponentHPLabel)
    }
    
    func startTimer() {
           countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
       }
       
       // Function to update the timer label every second
       @objc func updateTimer() {
           if totalTime > 0 {
               totalTime -= 1
               timerLabel.text = "\(formatTime(totalTime))"
           } else {
               endGame()
           }
       }
       
       // Function to format time as minutes and seconds
       func formatTime(_ seconds: Int) -> String {
           let minutes = seconds / 60
           let seconds = seconds % 60
           return String(format: "%02d:%02d", minutes, seconds)
       }
       
       // sample endgame function
       func endGame() {
           
           // Determine the winner based on player and opponent health
           var winner: String
           if playerHealth > opponentHealth {
               winner = "Player"
           } else if opponentHealth > playerHealth {
               winner = "Opponent"
           } else {
               winner = "It's a tie!"
           }
           
           print("\(winner) wins!")
           
           // Stop the timer
           countdownTimer?.invalidate()
       }
    
    
    // Function to update player health bar (this is all sample before connecting it to the assets)
    func updatePlayerHealth(_ health: CGFloat) {
        playerHealth = max(min(health, 1.0), 0.0) // Ensure health is between 0 and 1
        // Calculate width of the green bar based on player's health
        if let playerHPContainer = childNode(withName: "playerHPContainer") as? SKShapeNode,
           let playerHPBar = playerHPContainer.childNode(withName: "playerHPBar") as? SKSpriteNode {
            let maxWidth = playerHPContainer.frame.width
            playerHPBar.size.width = maxWidth * playerHealth
        }
        // Update player HP label
        if let playerHPLabel = childNode(withName: "playerHPLabel") as? SKLabelNode {
            playerHPLabel.text = "Player HP: \(Int(playerHealth * 100))%"
        }
    }
    
    // Function to update opponent health bar
    func updateOpponentHealth(_ health: CGFloat) {
        opponentHealth = max(min(health, 1.0), 0.0) // Ensure health is between 0 and 1
        // Calculate width of the green bar based on opponent's health (this is all sample before connecting it to the assets)
        if let opponentHPContainer = childNode(withName: "opponentHPContainer") as? SKShapeNode,
           let opponentHPBar = opponentHPContainer.childNode(withName: "opponentHPBar") as? SKSpriteNode {
            let maxWidth = opponentHPContainer.frame.width
            opponentHPBar.size.width = maxWidth * opponentHealth
        }
        // Update opponent HP label
        if let opponentHPLabel = childNode(withName: "opponentHPLabel") as? SKLabelNode {
            opponentHPLabel.text = "Opponent HP: \(Int(opponentHealth * 100))%"
        }
    }
}

