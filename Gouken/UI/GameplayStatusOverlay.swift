import SpriteKit

class GameplayStatusOverlay: SKScene {
    
    // Player and Opponent Health properties
    var playerHealth: CGFloat = 1.0 // Full health (1.0 for 100%)
    var opponentHealth: CGFloat = 1.0 // Full health (1.0 for 100%)
    var timerLabel: SKLabelNode!
    var countdownTimer: Timer?
    var START_TIME = 50
    var totalTime = 50 // 2 minutes
    private var healthBars: SKScene
    var MAX_HEALTH = 150
    var hpContainerWidth = 0.0
    var opponentHpContainerWidth = 0.0
    
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
    

    
    func isGamePaused() -> Bool {
        return self.isPaused
    }
    
    func setupGameLoopStats(withViewHeight height: CGFloat, andViewWidth width: CGFloat, players: [Character?]) -> SKScene {
        
        
        self.isPaused = true
        let sceneSize = CGSize(width: width, height: height)
        print("Screen size of ", width, " by ", height)
        skScene = SKScene(size: sceneSize)
        skScene.scaleMode = .resizeFill
        player1 = players[0]
        player2 = players[1]
        
        
        setupPlayer1Stats(skScene: skScene)
        
        // P2 Stats
        setupPlayer2Stats(skScene: skScene)
        
        startNewRound()
                
        timerLabel = SKLabelNode(text: "Gouken") //shows the game title before the game starts with the timer
        timerLabel.position = CGPoint(x: 0.52 * skScene.size.width, y: 0.8 * skScene.size.height)
        timerLabel.fontName = "Chalkduster"
        timerLabel.fontColor = .white
        timerLabel.fontSize = 20
        timerLabel.zPosition = 5
        skScene.addChild(timerLabel)
        
        
        return skScene
    }
    
    
    // TODO: Reset player states & their health here
    func startNewRound(winnerOfRound: String="") {
                
        
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
        updatePlayerHealth(playerHealth)
        updateOpponentHealth(opponentHealth)
        totalTime = START_TIME // Reset timer
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }

            // Remove roundNumberLabel after 5 seconds
            roundNumberLabel.text = "Fight!"

            // Add a delay before setting isPaused to false and starting the timer
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let self = self else { return }

                roundNumberLabel.removeFromParent()

                self.isPaused = false
                self.startTimer()
            }
        }
        
    }
    
    
    func setupPlayer2Stats(skScene: SKScene) {
        // Calculate sizes and positions relative to scene size
        let OpponentHealthBarWidth = 0.5 * skScene.size.width
        let OpponentHealthBarHeight = 0.035 * skScene.size.height
        print(OpponentHealthBarWidth, OpponentHealthBarHeight)
        let OpponentHealthBarPosition = CGPoint(x: 0.8 * skScene.size.width, y: 0.9 * skScene.size.height)
        
        // Create opponent's health bar background
        let OpponentPlayerHPBackground = SKShapeNode(rectOf: CGSize(width: OpponentHealthBarWidth, height: OpponentHealthBarHeight), cornerRadius: 5)
        OpponentPlayerHPBackground.position = OpponentHealthBarPosition
        OpponentPlayerHPBackground.zPosition = 2
        OpponentPlayerHPBackground.strokeColor = .red
        OpponentPlayerHPBackground.fillColor = .black
        skScene.addChild(OpponentPlayerHPBackground)
        
        opponentHpContainerWidth = OpponentHealthBarWidth * (5.6/6.0)
        let OpponentPlayerHPContainer = SKShapeNode(rectOf: CGSize(width: opponentHpContainerWidth, height: OpponentHealthBarHeight * (10.0/11.0)), cornerRadius: 5)
        OpponentPlayerHPContainer.position = OpponentHealthBarPosition
        OpponentPlayerHPContainer.zPosition = 4
        OpponentPlayerHPContainer.strokeColor = .black
        OpponentPlayerHPContainer.lineWidth = 2
        skScene.addChild(OpponentPlayerHPContainer)
        
        opponentHPBar = SKSpriteNode(color: .red, size: CGSize(width: opponentHpContainerWidth * opponentHealth, height: OpponentHealthBarHeight))
        opponentHPBar.position = CGPoint(x: 0.5 * opponentHPBar.size.width, y: 0)
        opponentHPBar.anchorPoint = CGPoint(x: 1, y: 0.5)
        opponentHPBar.zPosition = 3
        OpponentPlayerHPContainer.addChild(opponentHPBar)
        print(opponentHPBar.frame.width)
        
        // Opponent HP Label
//        let opponentHPLabel = SKLabelNode(text: "My name Jeff: \(Int(opponentHealth * 100))%")
//        opponentHPLabel.position = CGPoint(x: 500, y: 330)
//        opponentHPLabel.fontColor = .white
//        opponentHPLabel.fontSize = 12
//        opponentHPLabel.zPosition = 5
//        skScene.addChild(opponentHPLabel)
    }
    
   
    func setupPlayer1Stats(skScene: SKScene) {
        // Calculate sizes and positions relative to scene size
        let healthBarWidth = 0.5 * skScene.size.width
        let healthBarHeight = 0.035 * skScene.size.height
        let healthBarPosition = CGPoint(x: 0.25 * skScene.size.width, y: 0.9 * skScene.size.height)
        
        // Create player's health bar background
        let playerHPBackground = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight), cornerRadius: 5)
        playerHPBackground.position = healthBarPosition
        playerHPBackground.zPosition = 2
        playerHPBackground.strokeColor = .red
        playerHPBackground.fillColor = .black
        skScene.addChild(playerHPBackground)
        
        hpContainerWidth = healthBarWidth * (5.6/6.0)
        let playerHPContainer = SKShapeNode(rectOf: CGSize(width: hpContainerWidth, height: healthBarHeight * (10.0/11.0)), cornerRadius: 5)
        playerHPContainer.position = healthBarPosition
        playerHPContainer.zPosition = 4
        playerHPContainer.strokeColor = .black
        playerHPContainer.lineWidth = 2
        skScene.addChild(playerHPContainer)
        
        playerHPBar = SKSpriteNode(color: .green, size: CGSize(width: hpContainerWidth * playerHealth, height: healthBarHeight))
        playerHPBar.position = CGPoint(x: -playerHPBar.size.width / 2, y: 0)
        playerHPBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        playerHPBar.zPosition = 3
        playerHPContainer.addChild(playerHPBar)
        print(playerHPBar.frame.width)

        

        
        // Add more UI elements here, adjusting their positions and sizes based on the scene size
        
        // Player HP Label
//        let playerHPLabel = SKLabelNode(text: "Deckem Jaskaran: \(Int(playerHealth * 100))%")
//        playerHPLabel.position = CGPoint(x: 150, y: 330)
//        playerHPLabel.fontColor = .white
//        playerHPLabel.fontSize = 12
//        playerHPLabel.zPosition = 5
//        skScene.addChild(playerHPLabel)
        
    
    }
    
//    func playerTakenDamage(amount: Int) {
//        
//        if playerHP == 0 {
//            return
//        }
//        
//        playerHP -= amount
//        
//        if playerHP < 0 {
//            playerHP = 0
//        }
//        playerHPBar.size.width = CGFloat(playerHP)
//    }
//    
//    func opponentTakenDamage(amount: Int) {
//        if opponentHP == 0 {
//            return
//        }
//        opponentHP -= amount
//        if opponentHP < 0 {
//            opponentHP = 0
//        }
//        opponentHPBar.size.width = CGFloat(opponentHP)
//    }
    
    func setOpponentHealth(amount: Int) {
    
        opponentHP = amount
        let opponentPctHP = Double(opponentHP) / Double(MAX_HEALTH)
        opponentHPBar.size.width = CGFloat(opponentPctHP * opponentHpContainerWidth)
    }
    func setPlayerHealth(amount: Int) {
    
        playerHP = amount
        let playerPctHP = Double(playerHP) / Double(MAX_HEALTH)
        playerHPBar.size.width = CGFloat(playerPctHP * hpContainerWidth)
       
    }
    
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
           
           self.isPaused = true
           // Determine the winner based on player and opponent health
           var winner: String
           if playerHealth > opponentHealth {
               winner = "Player"
           } else if opponentHealth > playerHealth {
               winner = "Opponent"
           } else {
               winner = "It's a tie!"
           }
           
           
        
           // Stop the timer
           countdownTimer?.invalidate()
           startNewRound()

       }
    
    
    // Function to update player health bar (this is all sample before connecting it to the assets)
    func updatePlayerHealth(_ health: CGFloat) {
        playerHealth = max(min(health, 1.0), 0.0) // Ensure health is between 0 and 1
        // Calculate width of the green bar based on player's health
        if let playerHPContainer = childNode(withName: "playerHPContainer") as? SKShapeNode,
           let playerHPBar = playerHPContainer.childNode(withName: "playerHPBar") as? SKSpriteNode {
            let maxWidth = playerHPContainer.frame.width
            playerHPBar.size.width = maxWidth * playerHealth
            playerHPBar.position = CGPoint(x: -playerHPBar.size.width / 2, y: 0)
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
            opponentHPBar.position = CGPoint(x: opponentHPBar.size.width / 2, y: 0)
        }
        // Update opponent HP label
        if let opponentHPLabel = childNode(withName: "opponentHPLabel") as? SKLabelNode {
            opponentHPLabel.text = "Opponent HP: \(Int(opponentHealth * 100))%"
        }
    }
}
