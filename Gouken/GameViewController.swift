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

class GameViewController: UIViewController, SCNSceneRendererDelegate, SKOverlayDelegate, SCNPhysicsContactDelegate {
    var scnView: SCNView!
    var menuLoaded = false
    var multipeerConnect = MultipeerConnection()
    
    func playButtonPressed() {
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
        let menuOverlay = MenuSceneOverlay(size: scnViewNew.bounds.size, multipeerConnect: multipeerConnect)
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
        
        
    }
    
    func loadGame() {
        guard menuLoaded else {
            print("Menu not loaded yet!")
            return
        }
        
        
        // Remove current SKView (menu overlay)
        view.subviews.first(where: { $0 is SCNView })?.removeFromSuperview()
        
        // let scene = SCNScene(named: "art.scnassets/TrainingStage.scn")!
        var stage : Stage = AmazingBrentwood(withManager: entityManager)
        let scene = stage.scene!
        
        
        // Retrieve the SCNView
        let scnViewNew = self.view as! SCNView
        scnViewNew.scene?.physicsWorld.contactDelegate = self
        
        // Set the scene to the view
        scnViewNew.scene = scene
        
        // Set the delegate
        scnViewNew.delegate = self
        
        // create and add a camera to the scene
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        
        initLighting(scene:scene)
        
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnViewNew.addGestureRecognizer(tapGesture)
    
        //decide who is player 1 and player 2
        if multipeerConnect.connectedPeers.count > 0 {
       
            let myPeerDisplayName = multipeerConnect.myPeerId.displayName
            let firstConnectedPeerDisplayName = multipeerConnect.connectedPeers.first!.displayName
            
            if myPeerDisplayName > firstConnectedPeerDisplayName {
            
                playerSpawn = scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!
                enemySpawn = scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!
            } else {
              
                playerSpawn = scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!
                enemySpawn = scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!
            }
        } else {
            print("SINGLEPLAYER")
            playerSpawn = scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!
            enemySpawn = scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!
           
        }

        player1 = Character(withName: CharacterName.Ninja, underParentNode: playerSpawn!, onPSide: PlayerType.P1, withManager: entityManager)
        player2 = Character(withName: CharacterName.Ninja, underParentNode: enemySpawn!, onPSide: PlayerType.P2, withManager: entityManager)
        
        player1?.setupStateMachine(withStateMachine: NinjaStateMachine(player1!))
        player2?.setupStateMachine(withStateMachine: NinjaStateMachine(player2!))
        player1?.characterNode.name = "Ninja1"
        player2?.characterNode.name = "Ninja2"
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // init floor physics
        initWorld(scene: scene)
        initPlayerPhysics(player1: playerSpawn, player2: enemySpawn)

//        initHitboxAttack(playerSpawn: playerSpawn)
        setUpHitboxes(player: player1!)
        setUpHurtBoxes(player: player2!)

        scnViewNew.debugOptions = [.showPhysicsShapes]
//        scnViewNew.debugOptions = [.showPhysicsShapes, .showWireframe]
//        scnViewNew.debugOptions = [.showWireframe]


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
    //    var baikenStateMachine: BaikenStateMachine?
    //    var enemyStateMachine: BaikenStateMachine?
    var displayLink: CADisplayLink?
    var lastFrameTime: Double = 0.0
    var cameraNode : SCNNode = SCNNode()
    var playerSpawn : SCNNode?
    var enemySpawn : SCNNode?
    var runSpeed = Float(0.1)
    var hitbox = SCNNode()
    var hurtbox = SCNNode()
    
    //added
    var runRight = false
    var runLeft = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMenu()
    }
    
    func setUpHurtBoxes(player: Character?) {
        // Player 1 Hurtboxes Start
        var modelSCNNode = player2?.characterNode.childNode(withName: "head", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.15, height: 0.15, length: 0.15, position: SCNVector3(0, 0, -10), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "UpperArm_R", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(-10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "lowerarm_r", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(-10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "UpperArm_L", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "lowerarm_l", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "Pelvis", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.2, position: SCNVector3(0, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "spine_02", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.3, height: 0.3, length: 0.1, position: SCNVector3(1, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "Thigh_R", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.3, height: 0.1, length: 0.1, position: SCNVector3(10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "calf_r", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(20, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "Thigh_L", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.3, height: 0.1, length: 0.1, position: SCNVector3(-10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "calf_l", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(-20, 0, 0), pside: player2!.playerSide)
        
        // Player 1 Hurtboxes Start
        modelSCNNode = player1?.characterNode.childNode(withName: "head", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.15, height: 0.15, length: 0.15, position: SCNVector3(0, 0, -10), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "UpperArm_R", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(-10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "lowerarm_r", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(-10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "UpperArm_L", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "lowerarm_l", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "Pelvis", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.2, position: SCNVector3(0, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "spine_02", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.3, height: 0.3, length: 0.1, position: SCNVector3(1, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "Thigh_R", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.3, height: 0.1, length: 0.1, position: SCNVector3(10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "calf_r", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(20, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "Thigh_L", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.3, height: 0.1, length: 0.1, position: SCNVector3(-10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "calf_l", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.2, height: 0.1, length: 0.1, position: SCNVector3(-20, 0, 0), pside: player1!.playerSide)
    }
    
    func setUpHitboxes(player: Character?) {
//        var modelSCNNode = player1?.characterNode.childNode(withName: "Hand_R", recursively: true)
        var modelSCNNode = player1?.characterNode.childNode(withName: "Hand_R", recursively: true)
        hitbox = initHitboxAttack(withPlayerNode: modelSCNNode!, width: 0.2, height: 0.2, length: 0.2, position: SCNVector3(0, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "Hand_L", recursively: true)
        hitbox = initHitboxAttack(withPlayerNode: modelSCNNode!, width: 0.2, height: 0.2, length: 0.2, position: SCNVector3(0, 0, 0), pside: player1!.playerSide)
    }

    // TODO: for testing player controls and animations
    func changeAnimationA(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
        if (!hasBeenPressed) { return }
        player1?.stateMachine?.switchState(NinjaRunningState((player1!.stateMachine! as! NinjaStateMachine)))
    }
    
    // test collison between node a and node b
    func testCollisionBetween(_ nodeA: SCNNode, _ nodeB: SCNNode) -> Bool {
        guard let physicsBodyA = nodeA.physicsBody, let physicsBodyB = nodeB.physicsBody else {
            return false
        }
        
        let collision = scnView.scene?.physicsWorld.contactTest(with: physicsBodyA, options: nil)
        print(collision)
        return collision != nil && !collision!.isEmpty
    }
    
    func changeAnimationB(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
        if hasBeenPressed {
            // Check if enemySpawn is colliding with hitboxNode
//            testCollisionBetween(hitbox, hurtbox)
            let collision = scnView.scene?.physicsWorld.contactTest(with: hitbox.physicsBody!, options: nil)
            print(collision)

//            if let hitboxNode = playerSpawn?.childNode(withName: "hitboxNode", recursively: true),
//               let enemySpawn = enemySpawn,
//               testCollisionBetween(hitboxNode, enemySpawn) {
//                print("COLLISION OCCURED!")
//                player2?.health.damage(10)
//            }
//            
//            player1?.stateMachine?.switchState(NinjaAttackingState((player1!.stateMachine! as! NinjaStateMachine)))
        }
    }
        
        func thumbstickHandler(_ dPad: GCControllerDirectionPad, _ xValue: Float, _ yValue: Float) {
            //print("Thumbstick x=\(xValue) y=\(yValue)")
            
            //rotate, play running animations, based on thumbstick input
            let deadZone = Float(0.2)
            let player = playerSpawn
            
            if(xValue>0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
                player1?.stateMachine?.switchState(NinjaRunningState((player1!.stateMachine! as! NinjaStateMachine)))
                runRight = true
                runLeft = false
                player?.eulerAngles.y = 0
                print("Running Right")
            } else if(xValue<0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
                player1?.stateMachine?.switchState(NinjaRunningState((player1!.stateMachine! as! NinjaStateMachine)))
                runRight = false
                runLeft = true
                player?.eulerAngles.y = Float.pi
                print("Running Left")
                
                print(String(describing: multipeerConnect.connectedPeers.map(\.displayName)))
                
                if (multipeerConnect.connectedPeers.count == 0) {
                    print("!!!!without connected devices:")
                }
                if (multipeerConnect.connectedPeers.count > 0) {
                    print("!!!!with connected devices:")
                    multipeerConnect.send(player: CodableCharacter(runLeft: runLeft, runRight: runRight, characterState: CharacterState.Running))
                }	
                
            } else if ( abs(xValue)<deadZone) {
                runRight = false
                runLeft = false
                player1?.stateMachine?.switchState(NinjaIdleState((player1!.stateMachine! as! NinjaStateMachine)))
            }
    }

    @objc
    func handleDoubleTap(_ gestureRecognize: UIGestureRecognizer) {
    }
    
    
    /*
     This method is being called every frame and is our update() method.
     */
    @objc
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let deltaTime = lastFrameTime == 0.0 ? 0.0 : time - lastFrameTime
        lastFrameTime = time
        
        // Update loop for any calls (our game loop)
        entityManager.entities.forEach { entity in
            
            entity.update(deltaTime: deltaTime)
            
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

        lastFrameTime = time
        
        multipeerConnect.receivedDataHandler = { [weak self] receivedData in
            // Handle received data here
            // For example, update game state with received data
            self?.handleReceivedData(receivedData)
        }
        
    }
    
    
    func handleReceivedData(_ receivedData: PlayerData) {
        // Handle received data here
        // For example, update game state with received data

        print("Received data: \(receivedData)")
        // Example: Update game state based on received data
        // You can access player data like receivedData.player.characterState, receivedData.timestamp, etc.
    
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
            print("Contact Delegate Called")
        }
    
    func initLighting(scene:SCNScene){
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
