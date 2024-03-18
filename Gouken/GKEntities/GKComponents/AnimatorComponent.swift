import SceneKit
import GameplayKit

class AnimatorComponent: GKComponent {
    private var animPlayer: SCNAnimationPlayer!
    private var character: SCNNode!
    private var _currentTime : TimeInterval = 0
    
    var currentTime: TimeInterval {
        get {
            return _currentTime
        }
    }
    
    var currentTimeNormalized: TimeInterval {
        get {
            return _currentTime / animPlayer!.animation.duration
        }
    }
    
    init(character: SCNNode, defaultAnimName: String, loop: Bool) {
        super.init()
        
        self.character = character
        
        changeAnimation(animName: defaultAnimName, loop: loop)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        _currentTime += seconds
    }
    
    func setSpeed(_ speed: CGFloat) {
        animPlayer.speed = speed
    }
    
    func changeAnimation(animName: String, loop: Bool) {
        _currentTime = 0
        character.removeAllAnimations()
        animPlayer = SCNAnimationPlayer.loadAnimation(fromSceneNamed: animName)
        if (!loop) {
            animPlayer.animation.repeatCount = 1
        }
        character.addAnimationPlayer(animPlayer, forKey: animName)
        
        // Reset _currentTime for looping animations
        let onAnimationEnd: (Any, Any?, Bool) -> Void = { animation, animatedObject, playingBackward in
            self._currentTime = 0
        }
        addAnimationEvent(keyTime: 1.0, callback: onAnimationEnd)
    }
    
    func addAnimationEvent(keyTime: CGFloat, callback: @escaping (Any, Any?, Bool) -> Void) {
        let event = SCNAnimationEvent(keyTime: keyTime, block: callback)
        if (animPlayer.animation.animationEvents == nil) {
            animPlayer.animation.animationEvents = []
        }
        animPlayer.animation.animationEvents?.append(event)
    }
}
