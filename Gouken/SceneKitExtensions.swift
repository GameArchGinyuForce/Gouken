import SceneKit

extension SCNAnimationPlayer {
    class func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
        let scene = SCNScene( named: sceneName )!
        var animationPlayer: SCNAnimationPlayer! = nil
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }
}

extension SCNTransaction {
    class func animateWithDuration(_ duration: CFTimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, completionBlock: (() -> Void)? = nil, animations: () -> Void) {
        begin()
        self.animationDuration = duration
        self.completionBlock = completionBlock
        self.animationTimingFunction = timingFunction
        animations()
        commit()
    }
}

//extension SCNPhysicsContact {
//    func match(_ category: Int, block: (_ matching: SCNNode, _ other: SCNNode) -> Void) {
//        if self.nodeA.physicsBody!.categoryBitMask == category {
//            block(self.nodeA, self.nodeB)
//        }
//  
//        if self.nodeB.physicsBody!.categoryBitMask == category {
//            block(self.nodeB, self.nodeA)
//        }
//    }
//}

extension SCNAudioSource {
    convenience init(name: String, volume: Float = 1.0, positional: Bool = true, loops: Bool = false, shouldStream: Bool = false, shouldLoad: Bool = true) {
        self.init(named: "game.scnassets/sounds/\(name)")!
        self.volume = volume
        self.isPositional = positional
        self.loops = loops
        self.shouldStream = shouldStream
        if shouldLoad {
            load()
        }
    }
}
