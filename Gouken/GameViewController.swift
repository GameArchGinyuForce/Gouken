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
        initHitboxAttack(playerSpawn: playerSpawn)
        
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
    
    
    //added
    var runRight = false
    var runLeft = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMenu()
    }
    
    // TODO: for testing player controls and animations
    func changeAnimationA(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
        if (!hasBeenPressed) { return }
//        player1?.stateMachine?.switchState(NinjaRunningState((player1!.stateMachine! as! NinjaStateMachine)))
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
                player2?.health.damage(10)
            }
            
            player1?.stateMachine?.switchState(NinjaAttackingState((player1!.stateMachine! as! NinjaStateMachine)))
        }
    }
        
        func thumbstickHandler(_ dPad: GCControllerDirectionPad, _ xValue: Float, _ yValue: Float) {
            //print("Thumbstick x=\(xValue) y=\(yValue)")
            
            //rotate, play running animations, based on thumbstick input
            let deadZone = Float(0.2)
            let player = playerSpawn
            
            // Control everything therough state
            if(xValue>0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
                player1?.stateMachine?.switchState(NinjaRunningRightState((player1!.stateMachine! as! NinjaStateMachine)))
                print("Running Right")
            } else if(xValue<0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
                player1?.stateMachine?.switchState(NinjaRunningLeftState((player1!.stateMachine! as! NinjaStateMachine)))
                //player?.eulerAngles.y = Float.pi
                print("Running Left")
                // print(String(describing: multipeerConnect.connectedPeers.map(\.displayName)))
                
                // if (multipeerConnect.connectedPeers.count == 0) {
                //     print("!!!!without connected devices:")
                // }
                // if (multipeerConnect.connectedPeers.count > 0) {
                //     print("!!!!with connected devices:")
                //     multipeerConnect.send(player: CodableCharacter(runLeft: runLeft, runRight: runRight, characterState: CharacterState.Running))
                // }
                
            } else if ( abs(xValue)<deadZone) {
                // runRight = false
                // runLeft = false
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
        
        multipeerConnect.send(player: SeralizableCharacter(characterState: player1!.state))

        if (player1?.state == CharacterState.RunningLeft) {
            playerSpawn?.position.z -= runSpeed
            playerSpawn?.eulerAngles.y = Float.pi
            
        } else if (player1?.state == CharacterState.RunningRight) {
            playerSpawn?.position.z += runSpeed
            playerSpawn?.eulerAngles.y = 0
        }
        

        if (player2?.state == CharacterState.RunningLeft) {
            enemySpawn?.position.z -= runSpeed
            enemySpawn?.eulerAngles.y = Float.pi
        } else if (player2?.state == CharacterState.RunningRight) {
            enemySpawn?.position.z += runSpeed
            enemySpawn?.eulerAngles.y = 0

        }



       // let player = playerSpawn!
        
        // if(runRight){
        //     player.position.z += runSpeed
        // }
        // if(runLeft){
        //     player.position.z -= runSpeed
        // }

        lastFrameTime = time
        
        
        multipeerConnect.receivedDataHandler = { [weak self] receivedData in
            // Handle received data here
            // For example, update game state with received data
            print("receiving")
            self?.handleReceivedData(receivedData)
        }
        
    }
    
    
    func handleReceivedData(_ receivedData: PlayerData) {
        print("Received data: \(receivedData)")
        var enemyState = receivedData.player.characterState
        
        if (player2?.state != CharacterState.RunningRight && enemyState == CharacterState.RunningRight){
            print("enemy running right")
            player2?.stateMachine?.switchState(NinjaRunningRightState((player2!.stateMachine! as! NinjaStateMachine)))
        } else if (player2?.state != CharacterState.RunningLeft && enemyState == CharacterState.RunningLeft){
            print("enemy running left")
            player2?.stateMachine?.switchState(NinjaRunningLeftState((player2!.stateMachine! as! NinjaStateMachine)))
        } else if (player2?.state != CharacterState.Idle && enemyState == CharacterState.Idle){
            print("enemy idle")
            player2?.stateMachine?.switchState(NinjaIdleState((player2!.stateMachine! as! NinjaStateMachine)))
        }else if (player2?.state != CharacterState.Stunned && enemyState == CharacterState.Stunned && enemyState == CharacterState.Stunned){
            print("enemy stunned")
            player2?.stateMachine?.switchState(NinjaStunnedState((player2!.stateMachine! as! NinjaStateMachine)))
        }else if (player2?.state != CharacterState.Attacking && enemyState == CharacterState.Attacking){
            print("enemy attacking")
            player2?.stateMachine?.switchState(NinjaAttackingState((player2!.stateMachine! as! NinjaStateMachine)))
        }
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
