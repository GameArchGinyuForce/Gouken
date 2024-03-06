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
        print("Hey from menu")
        
        // Remove current SKView (menu overlay)
        view.subviews.first(where: { $0 is SCNView })?.removeFromSuperview()
        
        // Load initial scene
        let scnScene = SCNScene() // Load your SCNScene for fancy background

        // Present the SceneKit scene
        let scnViewNew = SCNView(frame: view.bounds)
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
    }
    
    func loadGame() {
        guard menuLoaded else {
            print("Menu not loaded yet!")
            return
        }
        
        print("Game Scene Transition")
        
        // Remove current SKView (menu overlay)
        view.subviews.first(where: { $0 is SCNView })?.removeFromSuperview()
        
        let scene = SCNScene(named: "art.scnassets/TrainingStage.scn")!
            
        // Create and add a camera to the scene
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        
        // Create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 2, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // Create and add an ambient light to the scene
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
        
        // Initialize player characters
        player1 = Character(withName: CharacterName.Ninja, underParentNode: p1Spawn, onPSide: PlayerType.P1)
        player2 = Character(withName: CharacterName.Ninja, underParentNode: p2Spawn, onPSide: PlayerType.P2)
        
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
    var runSpeed = Float(0.1)
    
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
        // create a new scene
//        let scene = SCNScene(named: "art.scnassets/TrainingStage.scn")!
//        
//        // TODO: for testing state machine
////        let screenUpdated = #selector(screenUpdated(displayLink:))
////        displayLink = CADisplayLink(target: self, selector: screenUpdated)
////        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
//        // ----------------------------- //
//        
//        // create and add a camera to the scene
//        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
//
//        // create and add a light to the scene
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light!.type = .omni
//        lightNode.position = SCNVector3(x: 0, y: 2, z: 10)
//        scene.rootNode.addChildNode(lightNode)
//        
//        // create and add an ambient light to the scene
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light!.type = .ambient
//        ambientLightNode.light!.color = UIColor.darkGray
//        scene.rootNode.addChildNode(ambientLightNode)
//        
//        
//        // retrieve the SCNView
//        let scnView = self.view as! SCNView
        
//        scnView.debugOptions = [
//            SCNDebugOptions.renderAsWireframe
//        ]
        
        // set the scene to the view
//        scnView.scene = scene
//        
//        // allows the user to manipulate the camera
//        // scnView.allowsCameraControl = true
//        
//        // show statistics such as fps and timing information
//        //scnView.showsStatistics = true
//        
//        // configure the view
//        scnView.backgroundColor = UIColor.black
//        
//        scnView.delegate = self
//        
//        // add a tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        scnView.addGestureRecognizer(tapGesture)
//        
//        // Player Spawn Locations (Any stage we create MUST have these).
//        let p1Spawn = scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!
//        let p2Spawn = scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!
//        playerSpawn = p1Spawn
//        
//        player1 = Character(withName: CharacterName.Ninja, underParentNode: p1Spawn, onPSide: PlayerType.P1)
//        player2 = Character(withName: CharacterName.Ninja, underParentNode: p2Spawn, onPSide: PlayerType.P2)
//        
//        print(player1!.characterNode.presentation.worldPosition)
//        
//        
//        // TODO: for testing state machine
//        baikenStateMachine = BaikenStateMachine(player1!.characterNode)
//        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
//        doubleTapGesture.numberOfTapsRequired = 2
//        scnView.addGestureRecognizer(doubleTapGesture)
//        
//        // Player Controls Overlay
//        let overlayScene = GKScene(fileNamed: "Overlay")
//        let overlayNode = overlayScene?.rootNode as? Overlay
//        overlayNode?.scaleMode = .aspectFill
//        scnView.overlaySKScene = overlayNode
//        gamePad = overlayNode?.virtualController?.controller?.extendedGamepad
//        gamePad?.leftThumbstick.valueChangedHandler = thumbstickHandler
//        gamePad?.buttonA.valueChangedHandler = changeAnimationA
//        gamePad?.buttonB.valueChangedHandler = changeAnimationB
//        // ---------------------------- //
//        
////        loadMenu()


    }
    
    
    // TODO: for testing player controls and animations
    func changeAnimationA(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
        if (!hasBeenPressed) { return }
        player1?.setState(withState: CharacterState.Running)
//            player1?.removeAllAnimations()
//            let animPlayer = SCNAnimationPlayer.loadAnimation(fromSceneNamed: CharacterAnimations[CharacterName.Ninja]!.run)
//            player1?.addAnimationPlayer(animPlayer, forKey: CharacterAnimations[CharacterName.Ninja]!.run)
    }
    
    func changeAnimationB(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
        if (!hasBeenPressed) { return }
        player1?.setState(withState: CharacterState.Attacking)
//            player1?.removeAllAnimations()
//            let animPlayer = SCNAnimationPlayer.loadAnimation(fromSceneNamed: CharacterAnimations[CharacterName.Ninja]!.attack)
//            player1?.addAnimationPlayer(animPlayer, forKey: CharacterAnimations[CharacterName.Ninja]!.attack)
    }
    
    func thumbstickHandler(_ dPad: GCControllerDirectionPad, _ xValue: Float, _ yValue: Float) {
        print("Thumbstick x=\(xValue) y=\(yValue)")
        
        //rotate, play running animations, based on thumbstick input
        let deadZone = Float(0.2)
        let player = scnView.scene!.rootNode.childNode(withName: "p1Spawn", recursively: true)!
        
        if(xValue>0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
            player1?.setState(withState: CharacterState.Running)
            runRight = true
            runLeft = false
            //player1?.characterNode.eulerAngles.y = Float.pi
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
    
        
//            cameraNode.eulerAngles.z += xValue * 0.003
//            cameraNode.eulerAngles.y += xValue * 0.003
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
