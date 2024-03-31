import Foundation
import SceneKit



class SeralizableCharacter : Codable {
    
    var characterState: CharacterState

    var timestamp: Double
    
    var data = 0

    init(characterState: CharacterState, timestamp: Double) {
        self.characterState = characterState
        
        self.timestamp = timestamp
        
    }
}
