import Foundation
import GameplayKit

class RoundEntity : GKEntity {
    
    // Player and Opponent Health properties
    var playerHealth: CGFloat = 1.0 // Full health (1.0 for 100%)
    var opponentHealth: CGFloat = 1.0 // Full health (1.0 for 100%)
    var timerLabel: SKLabelNode!
    var countdownTimer: Timer?
    
    var START_TIME = 13.0
    var totalTime = 13.0 // 2 minutes
    
    private var healthBars: SKScene?
    var MAX_HEALTH = 150
    let roundNumberColldown = 0.5
    let fightCooldown = 4.0
    let roundTimer = 13.0
    
    var roundNumberCooldownTimer: Double!
    var fightCooldownTimer: Double!
    
    
    var hasRoundStarted = false
    var timerTextshown = false
    var fighttextshown = false
    var timerHasEnded = false
    var roundHasEnded = true
    
    var isPaused = true

    
    private var playerHP = 150
    var playerHPBar: SKSpriteNode!
    var player1: Character!
    
    private var opponentHP = 150
    var opponentHPBar: SKSpriteNode!
    var player2: Character!
    
    var currentRound = 1 // Initialize current round
    var roundNumberLabel: SKLabelNode!
    var skScene: SKScene!
    var overlay : GameplayOverlay?

    
    init(gameplayOverlay: GameplayOverlay, players: [Character?], isPaused: Bool) {
        super.init()

        player1 = players[0]
        player2 = players[1]
        roundNumberCooldownTimer = roundNumberColldown
        fightCooldownTimer = fightCooldown
        overlay = gameplayOverlay
        self.isPaused = isPaused

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        
        if (roundHasEnded) {
            countDownRoundNumber(seconds)
            countdownFightText(seconds)
        }
        
        if (timerTextshown && fighttextshown && !hasRoundStarted) {
            hasRoundStarted = true
            player2.isPlayerDisabled = false
            player1.isPlayerDisabled = false
            startTimer()
        }
        
        if (hasRoundStarted) {
            updateTimer(seconds)
        }
        
        
    }
    
    
    @objc func updateTimer(_ seconds: TimeInterval) {
       if totalTime > 0 {
           totalTime -= seconds
           overlay?.timerLabel.text = "\(Int(totalTime))"
       } else if (playerHP == 0 || opponentHP == 0) {
           endRound()

       } else {
           endRound()
       }
   }
    
    func endRound() {
        player2.isPlayerDisabled = true
        player1.isPlayerDisabled = true

        self.isPaused = true
        if player1.health.currentHealth > player2.health.currentHealth {
            player1.roundsWon += 1
            print("player 1 has won the round")
        } else if player1.health.currentHealth < player2.health.currentHealth {
            player2.roundsWon += 1
            print("player 2 has won the round")
        }
        hasRoundStarted = false
        roundHasEnded = true
        
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
    
    
    func countDownRoundNumber(_ seconds: TimeInterval) {
        if (!timerTextshown) {
            roundNumberCooldownTimer -= seconds
            if (roundNumberCooldownTimer <= 0) {
                timerTextshown = true
                overlay?.changeTextToFight()
                overlay?.displayNewRoundNumber()
                roundNumberCooldownTimer = roundNumberColldown
            }
        }
    }
    
    func countdownFightText(_ seconds: TimeInterval) {
        if (!fighttextshown) {
            fightCooldownTimer -= seconds
            if (fightCooldownTimer <= 0) {
                fighttextshown = true
                overlay?.removeText()
                self.isPaused = false
                fightCooldownTimer = fightCooldown
            }
        }
    }
    
    
    
    func startNewRound(winnerOfRound: String="") {
                
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

        self.isPaused = false
                
        roundHasEnded = true
        
        timerTextshown = false
        fighttextshown = false
        hasRoundStarted = true
        
        
    }
    
    
    func startTimer() {
           countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
       }
    
    func endMatch() {
        
        var winner: String
        if player1.roundsWon > player2.roundsWon {
            winner = "Green Ninja"
        } else {
            winner = "Red Ninja"
        }
              
        overlay?.displayMatchWinner(winner: winner)
        
        // TODO: Return to main menu after delay

        
    }

}
