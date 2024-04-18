import SpriteKit

// Overlay that shows up during
class GameplayOverlay: SKScene {
    
    // Player and Opponent Health properties
    var playerHealth: CGFloat = 1.0 // Full health (1.0 for 100%)
    var opponentHealth: CGFloat = 1.0 // Full health (1.0 for 100%)
    var timerLabel: SKLabelNode!
    var countdownTimer: Timer?
    var START_TIME = 13
    var totalTime = 13 // 2 minutes
    private var healthBars: SKScene
    var MAX_HEALTH = 150
    
    private var playerHP = 150
    var playerHPBar: SKSpriteNode!
    var player1: Character!
    
    private var opponentHP = 150
    var opponentHPBar: SKSpriteNode!
    var player2: Character!
    
    var currentRound = 1 // Initialize current round
    var roundNumberLabel: SKLabelNode!
    var skScene: SKScene!

    
    override init(size: CGSize) {
        self.healthBars = SKScene(size: size)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Checks if the game is paused
    func isGamePaused() -> Bool {
        return self.isPaused
    }
    
    // Sets up the player health bars and all the stats that are supposed to be displayed during gameplay
    func setupGameLoopStats(withViewHeight height: CGFloat, andViewWidth width: CGFloat, players: [Character?]) -> SKScene {
        
        
        // Grabs the scene size and the player details
        let sceneSize = CGSize(width: width, height: height)
        skScene = SKScene(size: sceneSize)
        skScene.scaleMode = .resizeFill
        player1 = players[0]
        player2 = players[1]
        
        // Sets up Player 1 & Player 2 healthbars in the scene
        setupPlayer1Stats(skScene: skScene)
        setupPlayer2Stats(skScene: skScene)
        
                
        timerLabel = SKLabelNode(text: "Gouken") //shows the game title before the game starts with the timer
        timerLabel.position = CGPoint(x: width / 2, y: 320)
        timerLabel.fontName = "Chalkduster"
        timerLabel.fontColor = .white
        timerLabel.fontSize = 20
        timerLabel.zPosition = 5
        skScene.addChild(timerLabel)
        
        
        return skScene
    }
    
    // Function to display the round number
    func displayNewRoundNumber(roundNum: Int = 1) {
        roundNumberLabel = SKLabelNode(text: "Round \(roundNum)")
        roundNumberLabel.fontSize = 30
        roundNumberLabel.fontName = "Arial-BoldMT"
        roundNumberLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        roundNumberLabel.fontColor = .red
        roundNumberLabel.fontSize = 30
        roundNumberLabel.zPosition = 10
        skScene.addChild(roundNumberLabel)
    }
    
    // Function to change the current text label to "Fight!"
    func changeTextToFight() {
        roundNumberLabel?.text = "Fight!"
    }
    
    // Removes the text label
    func removeText() {
        roundNumberLabel.removeFromParent()
    }
    
    // Display the match winner, once the match is finished
    func displayMatchWinner(winner: String) {
        
        let color = winner.contains("Red") ? UIColor.red : UIColor.green
        roundNumberLabel = SKLabelNode(text: "\(winner) Has Won!")
        roundNumberLabel.fontSize = 30
        roundNumberLabel.fontName = "Arial-BoldMT"
        roundNumberLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        roundNumberLabel.fontColor = color
        roundNumberLabel.fontSize = 30
        roundNumberLabel.zPosition = 10
        skScene.addChild(roundNumberLabel)
    }
    
    // Starts the new round with a new text
    func startNewRound() {
                
        self.isPaused = true
        roundNumberLabel = SKLabelNode(text: "Round \(currentRound)")
        roundNumberLabel.fontSize = 30
        roundNumberLabel.fontName = "Arial-BoldMT"
        roundNumberLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        roundNumberLabel.fontColor = .red
        roundNumberLabel.fontSize = 30
        roundNumberLabel.zPosition = 10
        skScene.addChild(roundNumberLabel)
        
        // Reset both player states
        player1?.state = CharacterState.Idle
        player2?.state = CharacterState.Idle
        player1?.stateMachine?.switchState(NinjaIdleState((player1!.stateMachine! as! NinjaStateMachine)))
        player2?.stateMachine?.switchState(NinjaIdleState((player2!.stateMachine! as! NinjaStateMachine)))
        
        playerHPBar?.size.width = CGFloat(MAX_HEALTH)
        opponentHPBar?.size.width = CGFloat(MAX_HEALTH)
        playerHP = MAX_HEALTH
        opponentHP = MAX_HEALTH
        player1?.health.currentHealth = MAX_HEALTH
        player2?.health.currentHealth = MAX_HEALTH
        
        currentRound += 1
        totalTime = START_TIME // Reset timer
        
        
    }
    
    // Sets Up the player 2 stats UI on the health bar
    func setupPlayer2Stats(skScene: SKScene) {
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
        
        opponentHPBar = SKSpriteNode(color: .red, size: CGSize(width: opponentHP, height: 8))
        opponentHPBar.position = CGPoint(x: -opponentHPBar.size.width / 2, y: 0)
        opponentHPBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        opponentHPBar.zPosition = 3
        opponentHPContainer.addChild(opponentHPBar)


    }
    
    //Function that registers player damage
    func playerTakenDamage(amount: Int) {
        
        if playerHP == 0 {
            return
        }
        
        playerHP -= amount
        
        if playerHP < 0 {
            playerHP = 0
        }
        playerHPBar.size.width = CGFloat(playerHP)
    }
    
    //Function that registers enemy damage
    func opponentTakenDamage(amount: Int) {
        if opponentHP == 0 {
            return
        }
        opponentHP -= amount
        if opponentHP < 0 {
            opponentHP = 0
        }
        opponentHPBar.size.width = CGFloat(opponentHP)
    }

    // Sets the opponent health
    func setOpponentHealth(amount: Int) {
    
        opponentHP = amount
        opponentHPBar.size.width = CGFloat(opponentHP)
    }


    // Sets the player health
    func setPlayerHealth(amount: Int) {
    
        playerHP = amount
        playerHPBar.size.width = CGFloat(playerHP)
       
    }
    
    // Sets Up the player 1 stats UI on the health bar
    func setupPlayer1Stats(skScene: SKScene) {
        
        // HP bar for player
        let playerHPBackground = SKShapeNode(rectOf: CGSize(width: 180, height: 11), cornerRadius: 5)
        playerHPBackground.position = CGPoint(x: 150, y: 320)
        playerHPBackground.zPosition = 2
        playerHPBackground.strokeColor = .black
        playerHPBackground.fillColor = .black
        skScene.addChild(playerHPBackground)
        
        //HP container for player
        let playerHPContainer = SKShapeNode(rectOf: CGSize(width: 150, height: 10), cornerRadius: 5)
        playerHPContainer.position = CGPoint(x: 160, y: 320)
        playerHPContainer.zPosition = 4
        playerHPContainer.strokeColor = .yellow
        playerHPContainer.lineWidth = 2
        skScene.addChild(playerHPContainer)
        
        playerHPBar = SKSpriteNode(color: .green, size: CGSize(width: playerHP, height: 8))
        playerHPBar.position = CGPoint(x: -playerHPBar.size.width / 2, y: 0)
        playerHPBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        playerHPBar.zPosition = 3
        playerHPContainer.addChild(playerHPBar)
    
    }
    

    //function with timer functionality
    func startTimer() {
           countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
       }
       
       // Function to update the timer label every second
       @objc func updateTimer() {
           if totalTime > 0 {
               totalTime -= 1
               timerLabel.text = "\(totalTime)"
           } else if (playerHP == 0 || opponentHP == 0) {
               endRound()
           } else {
               endRound()
           }
       }
       

    // Function to format time as seconds
    func formatTime(_ seconds: Int) -> String {
        return String(format: "%02d", seconds)
    }

       
       // sample endgame function
       func endRound() {
           
           if playerHPBar.size.width > opponentHPBar.size.width {
               player1.roundsWon += 1
               print("player 1 has won the round")
           } else if playerHPBar.size.width < opponentHPBar.size.width {
               player2.roundsWon += 1
               print("player 2 has won the round")
           }
           
           
           
           countdownTimer?.invalidate()
           
           if (matchHasEnded()) {
               endMatch()
           } else {
               startNewRound()
           }
       }
    
    func matchHasEnded() -> Bool {
        return player1.roundsWon > 1 || player2.roundsWon > 1
    }
    

    //real endgame function
    func endMatch() {
        
        var winner: String
        var color: UIColor
        if player1.roundsWon > player2.roundsWon {
            winner = "Green Ninja"
            color = UIColor.green
        } else {
            winner = "Red Ninja"
            color = UIColor.red
        }
        
        roundNumberLabel = SKLabelNode(text: "\(winner) Has Won!")
        roundNumberLabel.fontSize = 30
        roundNumberLabel.fontName = "Arial-BoldMT"
        roundNumberLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        roundNumberLabel.fontColor = color
        roundNumberLabel.fontSize = 30
        roundNumberLabel.zPosition = 10
        skScene.addChild(roundNumberLabel)
        
        
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