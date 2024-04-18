import Foundation
import SceneKit


// The encoded game statesent through multipeer
class SerializableCharacter : Codable {
    var characterState: CharacterState
    
    var position1z: Float
    var position1y: Float
    
    var position2z: Float
    var position2y: Float
    
    var health1: Int
    var health2: Int
    
    var timestamp: Double
    
    var ticks:Int
    
    var angleP1:Float
    var angleP2:Float

    init(characterState: CharacterState, position1z: Float, position1y: Float, position2z: Float,position2y: Float, health1:Int, health2: Int, timestamp: Double, ticks: Int, angleP1: Float, angleP2: Float) {
        self.characterState = characterState
        self.position1y = position1y
        self.position1z = position1z
        self.position2y = position2y
        self.position2z = position2z
        self.health1 = health1
        self.health2 = health2
        
        self.timestamp = timestamp
             
        self.ticks = ticks
        
        self.angleP1 = angleP1
        self.angleP2 = angleP2
    }
}
