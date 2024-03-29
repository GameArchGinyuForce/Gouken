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
    var multipeerConnect = NetcodeConnect()
    

    
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
    
        //decide who is p1 and p2
        if("\(multipeerConnect.myPeerId)" > "\(multipeerConnect.connectedPeers.first!)"){
            // Player Spawn Locations (Any stage we create MUST have these).
            playerSpawn = scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!
            enemySpawn = scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!
   
        }else{
            // Player Spawn Locations (Any stage we create MUST have these).
            playerSpawn = scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!
            enemySpawn = scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!
        }
        player1 = Character(withName: CharacterName.Ninja, underParentNode: playerSpawn!, onPSide: PlayerType.P1, playerID: multipeerConnect.myPeerId)
        player2 = Character(withName: CharacterName.Ninja, underParentNode: enemySpawn!, onPSide: PlayerType.P2, playerID: multipeerConnect.connectedPeers.first!)
        

        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // init floor physics
        initWorld(scene: scene)
        initPlayerPhysics(player1: playerSpawn, player2: enemySpawn)
        initHitboxAttack(playerSpawn: playerSpawn)
        
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
        player1?.setState(withState: CharacterState.Running)
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
                    player2?.setState(withState: CharacterState.Stunned)
                }

                player1?.setState(withState: CharacterState.Attacking)
            }
        }


        func thumbstickHandler(_ dPad: GCControllerDirectionPad, _ xValue: Float, _ yValue: Float) {
            //print("Thumbstick x=\(xValue) y=\(yValue)")
            
            //rotate, play running animations, based on thumbstick input
            let deadZone = Float(0.2)
            let player = playerSpawn
            
            if(xValue>0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
                
                player1?.setState(withState: CharacterState.Running)
                runRight = true
                runLeft = false
                player?.eulerAngles.y = 0
                print("Running Right")
                
//                print(String(describing: multipeerConnect.connectedPeers.map(\.displayName)))
//                
//                if (multipeerConnect.connectedPeers.count == 0) {
//                    print("!!!!without connected devices:")
//
//                    multipeerConnect.send(move: Move.left)
//                }
//                if (multipeerConnect.connectedPeers.count > 0) {
//                    print("!!!!with connected devices:")
//                    multipeerConnect.send(move: Move.left)
//                    player2?.setState(withState: CharacterState.Running)
//                }
//                
            
            } else if(xValue<0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
                player1?.setState(withState: CharacterState.Running)
                runRight = false
                runLeft = true
                player?.eulerAngles.y = Float.pi
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
            player?.eulerAngles.y = 0
            print("Running Right")
        }else if(xValue<0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
            player1?.setState(withState: CharacterState.Running)
            runRight = false
            runLeft = true
            player?.eulerAngles.y = Float.pi
            print("Running Left")
        } else if ( abs(xValue)<deadZone) {
            runRight = false
            runLeft = false
            player1?.setState(withState: CharacterState.Idle)
        }
    }

    
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

        let deltaTime = time - lastFrameTime
        
//        player1?.stateMachine?.update(deltaTime)
//        player2?.stateMachine?.update(deltaTime)
        
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
