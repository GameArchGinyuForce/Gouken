//
//  GameViewController.swift
//  Gouken
//
//  Created by Sepehr Mansouri on 2024-02-08.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import GameplayKit
import GameController

class GameViewController: UIViewController, SCNSceneRendererDelegate, SKOverlayDelegate {
    var scnView: SCNView!
    var menuLoaded = false
    
    func playButtonPressed() {
        // Print a message when play button is pressed
        print("Play button pressed!")
        removeMenuOverlay()
        loadGame()
    }
    
    func removeMenuOverlay() {
        print("Attempting to remove menu overlay...")
        view.subviews.first(where: { $0 is SKView })?.removeFromSuperview()
        print("Menu overlay removed.")
    }
    
    func loadMenu() {
        print("Loading Menu Scene")
        AudioManager.Instance().stopAllAudioChannels()  // Stop all audio Playing
        
        // Remove current SKView (menu overlay)
        view.subviews.first(where: { $0 is SCNView })?.removeFromSuperview()
        
        // Load initial scene
        let scnScene = SCNScene() // Load your SCNScene for fancy background

        // Present the SceneKit scene
        // The menu bug present itself because the emulator confuses what orientation determines whats width/height
        // Introduced a band-aid fix, should review later
//        let scnViewNew = SCNView(frame: CGRect(origin: .zero, size: CGSize(width: max(view.frame.size.height, view.frame.size.width), height: min(view.frame.size.height, view.frame.size.width))))
        let scnViewNew = SCNView(frame: view.bounds)    // original
        
        scnViewNew.scene = scnScene
        let menuOverlay = MenuSceneOverlay(size: scnViewNew.bounds.size)
        menuOverlay.overlayDelegate = self
        scnViewNew.overlaySKScene = menuOverlay
        scnViewNew.backgroundColor = .white
        view.addSubview(scnViewNew)

        // Remove current SKView
        view.subviews.first(where: { $0 is SKView })?.removeFromSuperview()
        
        menuLoaded = true
        
        scnView = scnViewNew    // Set reference to newly created scnView to access scene elements?
        
        // Retrieve the SCNView
        guard let scnViewNew = self.view as? SCNView else {
            return // Ensure self.view is actually an SCNView
        }
        
        GameManager.Instance().doSomething();
        AudioManager.Instance().playMenuBackgroundMusic();
        
    }
    
    func loadGame() {
        guard menuLoaded else {
            print("Menu not loaded yet!")
            return
        }
        
        AudioManager.Instance().stopAllAudioChannels()  // Stop all audio Playing
        
        print("Game Scene Transition")
        
        // Remove current SKView (menu overlay)
        view.subviews.first(where: { $0 is SCNView })?.removeFromSuperview()
        
        // let scene = SCNScene(named: "art.scnassets/TrainingStage.scn")!
        var stage : Stage = AmazingBrentwood(withManager: entityManager)
        let scene = stage.scene!
        
        // create and add a camera to the scene
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 2, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        // Retrieve the SCNView
        let scnViewNew = self.view as! SCNView
        
        // Set the scene to the view
        scnViewNew.scene = scene
        
        // Set the delegate
        scnViewNew.delegate = self
        
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnViewNew.addGestureRecognizer(tapGesture)
        
        // Player Spawn Locations (Any stage we create MUST have these).
        let p1Spawn = scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!
        let p2Spawn = scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!
        playerSpawn = p1Spawn
        enemySpawn = p2Spawn
        
        // Initialize player characters
        player1 = Character(withName: CharacterName.Ninja, underParentNode: p1Spawn, onPSide: PlayerType.P1)
        player2 = Character(withName: CharacterName.Ninja, underParentNode: p2Spawn, onPSide: PlayerType.P2)

        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // init floor physics
        initWorld(scene: scene)
        initPlayerPhysics(player1: playerSpawn, player2: enemySpawn)
        
        initHitboxAttack(playerSpawn: playerSpawn)
        
        // Initialize state machine for testing
        baikenStateMachine = BaikenStateMachine(player1!.characterNode)
        
        // Add gesture recognizers for testing player controls and animations
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scnViewNew.addGestureRecognizer(doubleTapGesture)
        
        // Player Controls Overlay
        let overlayScene = GKScene(fileNamed: "Overlay")
        let overlayNode = overlayScene?.rootNode as? Overlay
        overlayNode?.scaleMode = .aspectFill
        scnViewNew.overlaySKScene = overlayNode
        gamePad = overlayNode?.virtualController?.controller?.extendedGamepad
        gamePad?.leftThumbstick.valueChangedHandler = thumbstickHandler
        gamePad?.buttonA.valueChangedHandler = changeAnimationA
        gamePad?.buttonB.valueChangedHandler = changeAnimationB
        
        // Configure the view
        scnViewNew.backgroundColor = UIColor.black
        
        scnView = scnViewNew    // Set reference to newly created scnView to access scene elements?
    }
    
    var entityManager = EntityManager()
    
    // TODO: for testing state machine, player controls, and animations
    var player1: Character?
    var player2: Character?
    var gamePad: GCExtendedGamepad?
    var baikenStateMachine: BaikenStateMachine?
    var displayLink: CADisplayLink?
    var lastFrameTime: Double = 0.0
    var cameraNode : SCNNode = SCNNode()
    var playerSpawn : SCNNode?
    var enemySpawn : SCNNode?
    var runSpeed = Float(0.1)
    var ninja2StateMachine: NinjaStateMachine?
    
    //added
    var runRight = false
    var runLeft = false
    
//    @objc func screenUpdated(displayLink: CADisplayLink) {
//        update(currentTime: Date.timeIntervalSinceReferenceDate as Double)
//    }
//    func update(currentTime: Double) {
//        let deltaTime = currentTime - lastFrameTime
//        
//        baikenStateMachine?.update(deltaTime)
//        
//        lastFrameTime = currentTime
        
        //added
//        if(runRight){
//            scene.rootNode.childNode(withName: "p1Spawn", recursively: true).position.z += 1
//        }
//        if(runLeft){
//            scene.rootNode.childNode(withName: "p1Spawn", recursively: true).position.z -= 1
//        }
//    }
    // ----------------------------- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMenu()
    }
    
    // TODO: for testing player controls and animations
    func changeAnimationA(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
        if (!hasBeenPressed) { return }
        player1?.setState(withState: CharacterState.Running)
//            player1?.removeAllAnimations()
//            let animPlayer = SCNAnimationPlayer.loadAnimation(fromSceneNamed: CharacterAnimations[CharacterName.Ninja]!.run)
//            player1?.addAnimationPlayer(animPlayer, forKey: CharacterAnimations[CharacterName.Ninja]!.run)
    }

        // test collison between node a and node b
        func testCollisionBetween(_ nodeA: SCNNode, _ nodeB: SCNNode) -> Bool {
            guard let physicsBodyA = nodeA.physicsBody, let physicsBodyB = nodeB.physicsBody else {
                return false
            }

            let collision = scnView.scene?.physicsWorld.contactTest(with: physicsBodyA, options: nil)
            return collision != nil && !collision!.isEmpty
        }

        func changeAnimationB(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
            if hasBeenPressed {
                // Check if enemySpawn is colliding with hitboxNode
                if let hitboxNode = playerSpawn?.childNode(withName: "hitboxNode", recursively: true),
                   let enemySpawn = enemySpawn,
                   testCollisionBetween(hitboxNode, enemySpawn) {
                    print("COLLISION OCCURED!")
                    ninja2StateMachine?.health?.damage(25)
                }

                player1?.setState(withState: CharacterState.Attacking)
            }
        }


        func thumbstickHandler(_ dPad: GCControllerDirectionPad, _ xValue: Float, _ yValue: Float) {
            //print("Thumbstick x=\(xValue) y=\(yValue)")
            
            //rotate, play running animations, based on thumbstick input
            let deadZone = Float(0.2)
            let player = scnView.scene!.rootNode.childNode(withName: "p1Spawn", recursively: true)!
            
            if(xValue>0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
                player1?.setState(withState: CharacterState.Running)
                runRight = true
                runLeft = false
                player.eulerAngles.y = 0
                print("Running Right")
            }else if(xValue<0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
                player1?.setState(withState: CharacterState.Running)
                runRight = false
                runLeft = true
                player.eulerAngles.y = Float.pi
                print("Running Left")
            } else if ( abs(xValue)<deadZone) {
                runRight = false
                runLeft = false
                player1?.setState(withState: CharacterState.Idle)
            }
        
        if(xValue>0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
            player1?.setState(withState: CharacterState.Running)
            runRight = true
            runLeft = false
            player.eulerAngles.y = 0
            print("Running Right")
        }else if(xValue<0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
            player1?.setState(withState: CharacterState.Running)
            runRight = false
            runLeft = true
            player.eulerAngles.y = Float.pi
            print("Running Left")
        } else if ( abs(xValue)<deadZone) {
            runRight = false
            runLeft = false
            player1?.setState(withState: CharacterState.Idle)
        }
    }

    // The following code initializes the Entities for our GKEntity set
//        let playerEntity = CharacterEntity()
//        entityManager.addEntity(playerEntity)
    
    // TODO: for testing state machine
    @objc
    func handleDoubleTap(_ gestureRecognize: UIGestureRecognizer) {
        baikenStateMachine?.exampleStateChange()
    }
    // ---------------------------- //
    
    
    /*
     This method is being called every frame and is our update() method.
     */
    @objc
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Update loop for any calls (our game loop)
        entityManager.entities.forEach { entity in
            if let component = entity.component(ofType: MovementComponent.self) {
                // Update entity based on movement component
                //component.move()
            }
        }
        
        let player = playerSpawn!
        
        if(runRight){
            player.position.z += runSpeed
        }
        if(runLeft){
            player.position.z -= runSpeed
        }

//        let bu = Int.random(in: 0..<100)
//        if bu == 1 {
//            print ("jas is gayy!!!!!!")
//        }
//        print(cameraNode.eulerAngles)
//        print(gamePad?.leftThumbstick)
       // print(player2?.presentation.transform)
        
        let deltaTime = time - lastFrameTime
        
        ninja2StateMachine?.update(deltaTime)

        lastFrameTime = time
    }
    

    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
            // Check which nodes collided
            let nodeA = contact.nodeA
            let nodeB = contact.nodeB

            // Example handling of collision
            if nodeA == playerSpawn || nodeB == playerSpawn {
                // Handle collision with playerSpawn
                print("Collision with player")
            }

            if nodeA == enemySpawn || nodeB == enemySpawn {
                // Handle collision with enemySpawn
                print("Collision with enemy")
            }
        }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscapeLeft
        } else {
            return .all
        }
    }

}
