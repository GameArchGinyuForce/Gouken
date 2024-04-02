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

var p1Side = PlayerType.P1
var p2Side = PlayerType.P2
let debugBoxes = false


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

        
        GameManager.Instance().cameraNode = cameraNode
        
        initLighting(scene:scene)
        
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnViewNew.addGestureRecognizer(tapGesture)
        
        p1Side = PlayerType.P1
        p2Side = PlayerType.P2
        
        var p1Char = CharacterName.Ninja
        var p2Char = CharacterName.Ninja2

        //decide who is player 1 and player 2
        if multipeerConnect.connectedPeers.count > 0 {
            
       
            let myPeerDisplayName = String(multipeerConnect.myPeerId.hash)
            let firstConnectedPeerDisplayName = String(multipeerConnect.connectedPeers.first!.hash)
            
            print("\(myPeerDisplayName) and \(firstConnectedPeerDisplayName)")
            
            if (myPeerDisplayName > firstConnectedPeerDisplayName) {
            
                playerSpawn = scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!
                enemySpawn = scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!
        
                
            } else {
              
                playerSpawn = scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!
                enemySpawn = scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!
                p1Side = PlayerType.P2
                p2Side = PlayerType.P1
                p1Char = CharacterName.Ninja2
                p2Char = CharacterName.Ninja
               
            }
        } else {
            playerSpawn = scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!
            enemySpawn = scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!
           
        }

        player1 = Character(withName: p1Char, underParentNode: playerSpawn!, onPSide: p1Side, withManager: entityManager, scene: scene)
        player2 = Character(withName: p2Char, underParentNode: enemySpawn!, onPSide: p2Side, withManager: entityManager, scene: scene)
        
        GameManager.Instance().p1Character = player1
        GameManager.Instance().p2Character = player2
        
        player1?.setupStateMachine(withStateMachine: NinjaStateMachine(player1!))
        player2?.setupStateMachine(withStateMachine: NinjaStateMachine(player2!))
        player1?.characterNode.name = "Ninja1"
        player2?.characterNode.name = "Ninja2"
        
        player1?.setUpHitBoxes()
        player2?.setUpHitBoxes()
        
        player1?.setUpHurtBoxes()
        player2?.setUpHurtBoxes()
        
        //        GameManager.Instance().camera = cameraNode
                
        var gkEntity = GKEntity()
        var cameraComponent: GKComponent = CameraComponent(camera: cameraNode)
        gkEntity.addComponent(cameraComponent)
        entityManager.addEntity(gkEntity)
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // init floor physics
        initWorld(scene: scene)
//        initPlayerPhysics(player1: playerSpawn, player2: enemySpawn)
        
        if (debugBoxes) {
            scnViewNew.debugOptions = [.showPhysicsShapes]
        }
//        scnViewNew.debugOptions = [.showPhysicsShapes, .showWireframe]
//        scnViewNew.debugOptions = [.showWireframe]
        
        scnViewNew.overlaySKScene = setupGamePad(withViewHeight: scnViewNew.bounds.height, andViewWidth: scnViewNew.bounds.width)
        // Configure the view
        scnViewNew.backgroundColor = UIColor.black
        
        scnView = scnViewNew    // Set reference to newly created scnView to access scene elements?
        
        ticksPassed = 0
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
    var runSpeed = Float(0.06)
    var hitbox = SCNNode()
    var hurtbox = SCNNode()
    
    //added
    var runRight = false
    var runLeft = false
    
    // hitbox debugging
    var toggleHitboxesOn = false
    var toggleHitboxesOff = true
    var isHitboxesOn = true
    
    var ticksPassed : Int?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMenu()
    }

    // TODO: for testing player controls and animations
    func changeAnimationA(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
        if (!hasBeenPressed) { return }
    }
    
    // test collison between node a and node b
    func testCollisionBetween(_ nodeA: SCNNode, _ nodeB: SCNNode) -> Bool {
        guard let physicsBodyA = nodeA.physicsBody, let physicsBodyB = nodeB.physicsBody else {
            return false
        }
        
        let collision = scnView.scene?.physicsWorld.contactTest(with: physicsBodyA, options: nil)
        return collision != nil && !collision!.isEmpty
    }
    
    // TODO: Store array of each character's hitboxes in Character obj
    // On attack, check that character's Hitboxes and check collisions
    func changeAnimationB(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
        if hasBeenPressed {
            player1?.stateMachine?.switchState(NinjaAttackingState((player1!.stateMachine! as! NinjaStateMachine)))            
        }
    }
        
    
    
    /*
     This method is being called every frame and is our update() method.
     */
    @objc
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        //receive data  from the beginning of loop to handle game loop
        multipeerConnect.receivedDataHandler = { [weak self] receivedData in
            self?.handleReceivedData(receivedData)
        }
        
//        if (player2?.state == CharacterState.Idle) {
//            player2?.stateMachine?.switchState((player2?.stateMachine! as! NinjaStateMachine).stateInstances[CharacterState.Attacking]!)
//        }
        
        //handle game logic
        ticksPassed!+=1
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
        processBuffer(fromBuffer: P1Buffer, onCharacter: player1!)

        lookAtOpponent(player: playerSpawn!, enemy: enemySpawn!)
        
        //send data at the end of the game loop
        multipeerConnect.send(player: SerializableCharacter(characterState: player1!.state, position1z: playerSpawn!.position.z,
                                                           position1y: playerSpawn!.position.y, position2z: enemySpawn!.position.z, position2y: enemySpawn!.position.y,
                                                            health1:player1!.health.currentHealth,health2:player2!.health.currentHealth,  timestamp:Date().timeIntervalSince1970, ticks:ticksPassed!, angleP1:playerSpawn!.eulerAngles.y, angleP2:enemySpawn!.eulerAngles.y))

    }
    
    func lookAtOpponent(player:SCNNode, enemy:SCNNode ){
        
        var relativePos1 = player.position.z - enemy.position.z
      
        if(relativePos1 >= 0){
            player.eulerAngles.y = Float.pi
            enemy.eulerAngles.y = 0
        }else{
            player.eulerAngles.y = 0
            enemy.eulerAngles.y = Float.pi
        }
        
    }

    
    func handleReceivedData(_ receivedData: PlayerData) {
        
        if(receivedData.player.ticks % 1 == 0){
            if(playerSpawn?.name == Optional("p1Spawn") ){
                
                //print("P1's version: enemySpawn= \(enemySpawn?.position.z) and PlayerSpawn=\(playerSpawn?.position.z)")
                
                enemySpawn?.position.z = receivedData.player.position1z
                enemySpawn?.position.y = receivedData.player.position1y
                playerSpawn?.position.z = receivedData.player.position2z
                playerSpawn?.position.y = receivedData.player.position2y
                
                player1!.health.currentHealth = receivedData.player.health1
                player2!.health.currentHealth = receivedData.player.health2
            }

        }
        
                     
        var enemyState = receivedData.player.characterState
        convertEnemyDataToClient(enemyState: enemyState)
                     
    }
    
    func convertEnemyDataToClient(enemyState: CharacterState) {
        guard let player2 = player2,
              let stateMachine = player2.stateMachine,
              player2.state != enemyState else {
            return
        }
        
        switch enemyState {
        case .Stunned:
            guard player2.state != .Stunned else { return }
            stateMachine.switchState(NinjaStunnedState(stateMachine as! NinjaStateMachine))
        case .RunningRight:
            stateMachine.switchState(NinjaRunningRightState(stateMachine as! NinjaStateMachine))
        case .RunningLeft:
            stateMachine.switchState(NinjaRunningLeftState(stateMachine as! NinjaStateMachine))
        case .Idle:
            stateMachine.switchState(NinjaIdleState(stateMachine as! NinjaStateMachine))
        case .Attacking:
            stateMachine.switchState(NinjaAttackingState(stateMachine as! NinjaStateMachine))
        case .HeavyAttacking:
            stateMachine.switchState(NinjaHeavyAttackingState(stateMachine as! NinjaStateMachine))
        case .Jumping:
            stateMachine.switchState(NinjaJumpState(stateMachine as! NinjaStateMachine))
        case .Blocking:
            stateMachine.switchState(NinjaBlockingState(stateMachine as! NinjaStateMachine))
        case .Downed:
            stateMachine.switchState(NinjaDownedState(stateMachine as! NinjaStateMachine))
        case .DashingLeft:
            stateMachine.switchState(NinjaDashingLeftState(stateMachine as! NinjaStateMachine))
        case .DashingRight:
            stateMachine.switchState(NinjaDashingRightState(stateMachine as! NinjaStateMachine))
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
