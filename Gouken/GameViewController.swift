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

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    var entityManager = EntityManager()
    
    // TODO: for testing state machine, player controls, and animations
    var player1: SCNNode?
    var player2: SCNNode?
    var gamePad: GCExtendedGamepad?
    var baikenStateMachine: BaikenStateMachine?
    var displayLink: CADisplayLink?
    var lastFrameTime: Double = 0.0
    var cameraNode : SCNNode = SCNNode()
    @objc func screenUpdated(displayLink: CADisplayLink) {
        update(currentTime: Date.timeIntervalSinceReferenceDate as Double)
    }
    func update(currentTime: Double) {
        let deltaTime = currentTime - lastFrameTime
        
        baikenStateMachine?.update(deltaTime)
        
        lastFrameTime = currentTime
    }
    // ----------------------------- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: for testing state machine
        let screenUpdated = #selector(screenUpdated(displayLink:))
        displayLink = CADisplayLink(target: self, selector: screenUpdated)
        displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        // ----------------------------- //
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/TrainingStage.scn")!
        
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
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        scnView.debugOptions = [
            SCNDebugOptions.renderAsWireframe
        ]
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        //scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        scnView.delegate = self
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        
        // ---------------------------- //
        
        // Spawn Ninja and play idle animation
        let ninjaScene = SCNScene(named: "art.scnassets/Synty_Ninja_NoAnim.scn")!
        scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!.addChildNode(ninjaScene.rootNode)
        player1 = scene.rootNode.childNode(withName: "p1Spawn", recursively: true)!.childNode(withName: "Synty_Ninja_Root", recursively: true)!
        let animPlayer = SCNAnimationPlayer.loadAnimation(fromSceneNamed: AnimationList.idle)
        player1?.addAnimationPlayer(animPlayer, forKey: AnimationList.idle)
        
        let ninja2Scene = SCNScene(named: "art.scnassets/Synty_Ninja_NoAnim.scn")!
        scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!.addChildNode(ninja2Scene.rootNode)
        player2 = scene.rootNode.childNode(withName: "p2Spawn", recursively: true)!.childNode(withName: "Synty_Ninja_Root", recursively: true)!
        let anim2Player = SCNAnimationPlayer.loadAnimation(fromSceneNamed: AnimationList.idle)
        player2!.addAnimationPlayer(anim2Player, forKey: AnimationList.idle)

//        ninja?.eulerAngles.y = Float.pi
        // ---------------------------- //

        
        // TODO: for testing state machine
        baikenStateMachine = BaikenStateMachine(player1!)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(doubleTapGesture)
        
        // Player Controls Overlay
        let overlayScene = GKScene(fileNamed: "Overlay")
        let overlayNode = overlayScene?.rootNode as? Overlay
        overlayNode?.scaleMode = .aspectFill
        scnView.overlaySKScene = overlayNode
        gamePad = overlayNode?.virtualController?.controller?.extendedGamepad
        gamePad?.leftThumbstick.valueChangedHandler = thumbstickHandler
        gamePad?.buttonA.valueChangedHandler = changeAnimationA
        gamePad?.buttonB.valueChangedHandler = changeAnimationB
        // ---------------------------- //
        
        // TODO: for testing player controls and animations
        func changeAnimationA(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
            if (!hasBeenPressed) { return }
            
            player1?.removeAllAnimations(withBlendOutDuration: 1.0)
            let animPlayer = SCNAnimationPlayer.loadAnimation(fromSceneNamed: AnimationList.run)
            player1?.addAnimationPlayer(animPlayer, forKey: AnimationList.run)
        }
        
        func changeAnimationB(_ button: GCControllerButtonInput, _ pressure: Float, _ hasBeenPressed: Bool) {
            if (!hasBeenPressed) { return }

            player1?.removeAllAnimations(withBlendOutDuration: 1.0)
            let animPlayer = SCNAnimationPlayer.loadAnimation(fromSceneNamed: AnimationList.attack)
            player1?.addAnimationPlayer(animPlayer, forKey: AnimationList.attack)
        }
        
        func thumbstickHandler(_ dPad: GCControllerDirectionPad, _ xValue: Float, _ yValue: Float) {
//            print("Thumbstick x=\(xValue) y=\(yValue)")
//            cameraNode.eulerAngles.z += xValue * 0.003
//            cameraNode.eulerAngles.y += xValue * 0.003
        }

        // The following code initializes the Entities for our GKEntity set
        let playerEntity = PlayerEntity()
        entityManager.addEntity(playerEntity)
    }
    
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
        let bu = Int.random(in: 0..<100)
        if bu == 1 {
            print ("jas is gayy!!!!!!")
        }
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
