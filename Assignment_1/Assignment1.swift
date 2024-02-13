//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab03: Make a rotating cube with a crate texture that can be toggled
//
//====================================================================

import SceneKit

class Assignment1: SCNScene {
    var rotAngle = CGSize.zero // Keep track of drag gesture numbers
    var rot = CGSize.zero // Keep track of rotation angle
    var rot2 = CGSize.zero
    var isRotating = true // Keep track of if rotation is toggled
    var cameraNode = SCNNode() // Initialize camera node
    var coordinates = ""
    
    
    // Catch if initializer in init() fails
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initializer
    override init() {
        super.init() // Implement the superclass' initializer
        
        background.contents = UIColor.black // Set the background colour to black
        
        setupCamera()
        addCube()
        addSecondCube()
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
    }
    
    // Function to setup the camera node
    func setupCamera() {
        let camera = SCNCamera() // Create Camera object
        cameraNode.camera = camera // Give the cameraNode a camera
        cameraNode.position = SCNVector3(5, 5, 5) // Set the position to (0, 0, 2)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/4, Float.pi/4, 0) // Set the pitch, yaw, and roll to 0
        rootNode.addChildNode(cameraNode) // Add the cameraNode to the scene
    }
    
    func addSecondCube() {
        let theSecondCube = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
        theSecondCube.name = "The Cube 2"
        theSecondCube.position = SCNVector3(2, -1, 2)
        
        let textures = [UIImage(named: "Textures/crate.jpg"), UIImage(named: "Textures/rock.jpeg"), UIImage(named: "Textures/grass.jpeg"), UIImage(named: "Textures/painting.jpeg"), UIImage(named: "Textures/wooden.jpeg"), UIImage(named: "Textures/tile.jpeg")] // List of materials for each side        var nextMaterial: SCNMaterial // Initialize temporary variable to store each texture
        theSecondCube.geometry?.firstMaterial?.diffuse.contents = textures[0] // Diffuse the red colour material across the whole cube
        
        var nextMaterial: SCNMaterial // Initialize temporary variable to store each textur
        nextMaterial = SCNMaterial() // Empty the variable
        
        nextMaterial.diffuse.contents = textures[1] // Set the material of the temporary variable to the material at index 1 in the list
        theSecondCube.geometry?.insertMaterial(nextMaterial, at: 1) // Set the side of the cube at index 1 to the material stored in the temporary variable
        
        //Repeat for side at index 2
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = textures[2]
        theSecondCube.geometry?.insertMaterial(nextMaterial, at: 2)
        
        //Repeat for side at index 3
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = textures[3]
        theSecondCube.geometry?.insertMaterial(nextMaterial, at: 3)
        
        //Repeat for side at index 4
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = textures[4]
        theSecondCube.geometry?.insertMaterial(nextMaterial, at: 4)
        
        //Repeat for side at index 5
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = textures[5]
        theSecondCube.geometry?.insertMaterial(nextMaterial, at: 5)
        /// Comment **^
        
        rootNode.addChildNode(theSecondCube)
    }
    
    func addCube() {
        let theCube = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
        theCube.name = "The Cube" // Name the node so we can reference it later
        let materials = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.cyan, UIColor.magenta] // List of materials for each side
        theCube.geometry?.firstMaterial?.diffuse.contents = materials[0] // Diffuse the red colour material across the whole cube
        
        /// Comment **v
        var nextMaterial: SCNMaterial // Initialize temporary variable to store each texture
        
        nextMaterial = SCNMaterial() // Empty the variable
        nextMaterial.diffuse.contents = materials[1] // Set the material of the temporary variable to the material at index 1 in the list
        theCube.geometry?.insertMaterial(nextMaterial, at: 1) // Set the side of the cube at index 1 to the material stored in the temporary variable
        
        //Repeat for side at index 2
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = materials[2]
        theCube.geometry?.insertMaterial(nextMaterial, at: 2)
        
        //Repeat for side at index 3
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = materials[3]
        theCube.geometry?.insertMaterial(nextMaterial, at: 3)
        
        //Repeat for side at index 4
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = materials[4]
        theCube.geometry?.insertMaterial(nextMaterial, at: 4)
        
        //Repeat for side at index 5
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = materials[5]
        theCube.geometry?.insertMaterial(nextMaterial, at: 5)
        /// Comment **^
        theCube.position = SCNVector3(0, 0, 0) // Put the cube at position (0, 0, 0)
        rootNode.addChildNode(theCube) // Add the cube node to the scene
    }
    
    @MainActor
    func firstUpdate() {
        reanimate() // Call reanimate on the first graphics update frame
    }
    
    @MainActor
    func reanimate() {
        let theCube = rootNode.childNode(withName: "The Cube", recursively: true)
        let theSecondCube = rootNode.childNode(withName: "The Cube 2", recursively: true)
        rot2.width += 0.02
        
        if (isRotating) {
            rot.width += 0.02
        } else {
            rot = rotAngle
        }
        
        theCube?.eulerAngles = SCNVector3(Double(rot.height / 50), Double(rot.width / 50), 0)
        
        // Second cube euler movement
        theSecondCube?.eulerAngles = SCNVector3(Double(rot2.height / 50), Double(rot2.width / 50), 0)
        
        Task { try! await Task.sleep(nanoseconds: 10000)
            reanimate()
            updateCoordinates()
        }
    }
    
    @MainActor
    // Function to be called by double-tap gesture
    func handleDoubleTap() {
        isRotating = !isRotating // Toggle rotation
    }
    
    @MainActor
    func dragCube() {
        
    }
    
    
    
    @MainActor
    func handlePinchZoom(scale: CGFloat) {
        
        let newFieldOfView = (cameraNode.camera?.fieldOfView ?? 60) + (scale > 1 ? -scale : scale)
        
        // Ensure the fieldOfView does not exceed 100
        if newFieldOfView <= 100 && newFieldOfView >= 28 {
            cameraNode.camera?.fieldOfView = newFieldOfView
        }
    }
    
    @MainActor
    func handleDrag(offset: CGSize) {
        rotAngle = offset // Get the width and height components of the CGSize, which only gives us two, and put them into the x and y rotations of the flashlight
    }
    
    @MainActor
    func resetPosition() {
        let theCube = rootNode.childNode(withName: "The Cube", recursively: true)
        theCube?.position = SCNVector3(0, 0, 0)
        rot = CGSize.zero
        rotAngle = CGSize.zero
    }
    
    @MainActor
    func updateCoordinates() -> String {
        guard let theCube = rootNode.childNode(withName: "The Cube", recursively: true) else {
            return "Cube not found"
        }
        
        // Access the position directly without optional binding
        let position = theCube.position
        
        // Ensure the position is not nil before using it
        if position != nil {
            let rotation = theCube.eulerAngles
            
            let xRotation = String(format: "%.2f", rotation.x)
            let yRotation = String(format: "%.2f", rotation.y)
            let zRotation = String(format: "%.2f", rotation.z)
            let xPosition = String(format: "%.2f", position.x)  // Unwrap position here
            let yPosition = String(format: "%.2f", position.y)  // Unwrap position here
            let zPosition = String(format: "%.2f", position.z)  // Unwrap position here
            
            return "Rotation: (\(xRotation), \(yRotation), \(zRotation))\nPosition: (\(xPosition), \(yPosition), \(zPosition))"
        } else {
            return "Position not available"
        }
    }
}

