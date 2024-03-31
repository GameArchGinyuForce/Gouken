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
        var stage : Stage = PyramidOfGiza(withManager: entityManager)
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
//        let overlayScene = GKScene(fileNamed: "Overlay")
//        let overlayNode = overlayScene?.rootNode as? Overlay
//        overlayNode?.scaleMode = .aspectFill
//        scnViewNew.overlaySKScene = overlayNode
//        gamePad = overlayNode?.virtualController?.controller?.extendedGamepad
//        gamePad?.leftThumbstick.valueChangedHandler = thumbstickHandler
//        gamePad?.buttonA.valueChangedHandler = changeAnimationA
//        gamePad?.buttonB.valueChangedHandler = changeAnimationB
        scnViewNew.overlaySKScene = setupGamePad(withViewHeight: scnViewNew.bounds.height, andViewWidth: scnViewNew.bounds.width)
        // Configure the view
        scnViewNew.backgroundColor = UIColor.black
        
        scnView = scnViewNew    // Set reference to newly created scnView to access scene elements?
        
        
    }
    
    var entityManager = EntityManager()
    var player1: Character?
    var player2: Character?
    var gamePad: GCExtendedGamepad?
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
    
    // hitbox debugging
    var toggleHitboxesOn = false
    var toggleHitboxesOff = true
    var isHitboxesOn = true
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMenu()
    }
    
    func setUpHurtBoxes(player: Character?) {
        // Player 1 Hurtboxes Start
        var modelSCNNode = player1?.characterNode.childNode(withName: "head", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.3, height: 0.3, length: 0.3, position: SCNVector3(0, 0, -10), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "UpperArm_R", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(-10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "lowerarm_r", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(-10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "UpperArm_L", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "lowerarm_l", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "Pelvis", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.4, position: SCNVector3(0, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "spine_02", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.6, height: 0.6, length: 0.2, position: SCNVector3(1, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "Thigh_R", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.6, height: 0.2, length: 0.2, position: SCNVector3(10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "calf_r", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(20, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "Thigh_L", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.6, height: 0.2, length: 0.2, position: SCNVector3(-10, 0, 0), pside: player1!.playerSide)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "calf_l", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(-20, 0, 0), pside: player1!.playerSide)
        
        // Player 2 Hurtboxes Start
        modelSCNNode = player2?.characterNode.childNode(withName: "head", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.3, height: 0.3, length: 0.3, position: SCNVector3(0, 0, -10), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "UpperArm_R", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(-10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "lowerarm_r", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(-10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "UpperArm_L", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "lowerarm_l", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "Pelvis", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.4, position: SCNVector3(0, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "spine_02", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.6, height: 0.6, length: 0.2, position: SCNVector3(1, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "Thigh_R", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.6, height: 0.2, length: 0.2, position: SCNVector3(10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "calf_r", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(20, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "Thigh_L", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.6, height: 0.2, length: 0.2, position: SCNVector3(-10, 0, 0), pside: player2!.playerSide)
        
        modelSCNNode = player2?.characterNode.childNode(withName: "calf_l", recursively: true)
        hurtbox = initHurtboxAttack(withParentNode: modelSCNNode!, width: 0.4, height: 0.2, length: 0.2, position: SCNVector3(-20, 0, 0), pside: player2!.playerSide)
    }
    
    func setUpHitboxes(player: Character?) {
        var modelSCNNode = player1?.characterNode.childNode(withName: "Hand_R", recursively: true)
        var _hitbox = initHitboxAttack(withPlayerNode: modelSCNNode!, width: 0.2, height: 0.2, length: 0.2, position: SCNVector3(0, 0, 0), pside: player1!.playerSide, name: "Hand_R")
        player1?.addHitbox(hitboxNode: _hitbox)
        
        modelSCNNode = player1?.characterNode.childNode(withName: "Hand_L", recursively: true)
        _hitbox = initHitboxAttack(withPlayerNode: modelSCNNode!, width: 0.2, height: 0.2, length: 0.2, position: SCNVector3(0, 0, 0), pside: player1!.playerSide, name: "Hand_L")
        player1?.addHitbox(hitboxNode: _hitbox)
        
    }

    // TODO: for testing player controls and animations
    func changeAnimationA(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
        if (!hasBeenPressed) { return }
//        player1?.stateMachine?.switchState(NinjaRunningState((player1!.stateMachine! as! NinjaStateMachine)))
        
        // Bugfixing functionality
        if isHitboxesOn {
            toggleHitboxesOff = true
        } else {
            toggleHitboxesOn = true
        }
        isHitboxesOn = !isHitboxesOn
        
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
    
    // TODO: Store array of each character's hitboxes in Character obj
    // On attack, check that character's Hitboxes and check collisions
    func changeAnimationB(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
        if hasBeenPressed {
            player1?.stateMachine?.switchState(NinjaAttackingState((player1!.stateMachine! as! NinjaStateMachine)))
            
            // Hardcoded adding of events for hitbox toggling
//            player1?.animator.addAnimationEvent(keyTime: 0.1, callback: (player1?.activateHitboxesCallback)!)
            player1?.animator.addAnimationEvent(keyTime: 0.1) { node, eventData, playingBackward in
                self.player1?.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
            }
            
            player1?.animator.addAnimationEvent(keyTime: 0.2, callback: (player1?.deactivateHitboxesCallback)!)
//            player1?.animator.addAnimationEvent(keyTime: 0.3, callback: (player1?.activateHitboxesCallback)!)
            player1?.animator.addAnimationEvent(keyTime: 0.3) { node, eventData, playingBackward in
                self.player1?.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
            }
            
            player1?.animator.addAnimationEvent(keyTime: 0.4, callback: (player1?.deactivateHitboxesCallback)!)
//            player1?.animator.addAnimationEvent(keyTime: 0.5, callback: (player1?.activateHitboxesCallback)!)
            player1?.animator.addAnimationEvent(keyTime: 0.5) { node, eventData, playingBackward in
                self.player1?.activateHitboxByNameCallback!("Hand_R", eventData, playingBackward)
            }
            
            player1?.animator.addAnimationEvent(keyTime: 0.6, callback: (player1?.deactivateHitboxesCallback)!)
            
        }
    }
        
        func thumbstickHandler(_ dPad: GCControllerDirectionPad, _ xValue: Float, _ yValue: Float) {
            //print("Thumbstick x=\(xValue) y=\(yValue)")
            
            //rotate, play running animations, based on thumbstick input
            let deadZone = Float(0.2)
            let player = playerSpawn
            
            // Control everything therough state
            if(xValue>0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
                
                print(String(describing: multipeerConnect.connectedPeers.map(\.displayName)))
                player1?.stateMachine?.switchState(NinjaRunningRightState((player1!.stateMachine! as! NinjaStateMachine)))
                
            } else if(xValue<0 && abs(xValue)>deadZone && player1?.state==CharacterState.Idle){
                
                player1?.stateMachine?.switchState(NinjaRunningLeftState((player1!.stateMachine! as! NinjaStateMachine)))
                
//                if (multipeerConnect.connectedPeers.count == 0) {
//                    print("!!!!without connected devices:")
//                }
//                if (multipeerConnect.connectedPeers.count > 0) {
//                    print("!!!!with connected devices:")
//                    multipeerConnect.send(player: SeralizableCharacter(characterState: '')(runLeft: runLeft, runRight: runRight, characterState: CharacterState.Running))
//                }
//                
            } else if ( abs(xValue)<deadZone) {
                
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
            
            // Check hitbox collisions
            if let component: HitBoxComponent = entity.component(ofType: HitBoxComponent.self) {
                component.checkCollisions(scene: scnView.scene)
            }
        }
        

        // Hitboxes bugfixing
        if toggleHitboxesOn {
            print("toggleHitboxesOn")
            toggleHitboxesOn = false
            player1?.hitbox.activateHitboxes()
        }
        if toggleHitboxesOff {
            print("toggleHitboxesOff")
            toggleHitboxesOff = false
            player1?.hitbox.deactivateHitboxes()
        }
        
        processBuffer(fromBuffer: P1Buffer, onCharacter: player1!)
        
        multipeerConnect.send(player: SerializableCharacter(characterState: player1!.state, position1z: playerSpawn!.position.z,
                                                           position1y: playerSpawn!.position.y, position2z: enemySpawn!.position.z, position2y: enemySpawn!.position.y,
                                                           health1:player1!.health.currentHealth,health2:player2!.health.currentHealth))


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

        lastFrameTime = time
        
        
        multipeerConnect.receivedDataHandler = { [weak self] receivedData in
            self?.handleReceivedData(receivedData)
        }
        
    }
    
    
    func handleReceivedData(_ receivedData: PlayerData) {
        var enemyState = receivedData.player.characterState
        
        //refactor this later
        if (player2?.state != CharacterState.RunningRight && enemyState == CharacterState.RunningRight){
            
            player2?.stateMachine?.switchState(NinjaRunningRightState((player2!.stateMachine! as! NinjaStateMachine)))
            
        } else if (player2?.state != CharacterState.RunningLeft && enemyState == CharacterState.RunningLeft){
            
            player2?.stateMachine?.switchState(NinjaRunningLeftState((player2!.stateMachine! as! NinjaStateMachine)))
            
        } else if (player2?.state != CharacterState.Idle && enemyState == CharacterState.Idle){
            
            player2?.stateMachine?.switchState(NinjaIdleState((player2!.stateMachine! as! NinjaStateMachine)))
            
        }else if (player2?.state != CharacterState.Stunned && enemyState == CharacterState.Stunned && enemyState == CharacterState.Stunned){
    
            player2?.stateMachine?.switchState(NinjaStunnedState((player2!.stateMachine! as! NinjaStateMachine)))
            
        }else if (player2?.state != CharacterState.Attacking && enemyState == CharacterState.Attacking){
            
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
