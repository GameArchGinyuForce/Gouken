import Foundation



class SerializableCharacter : Codable {
    var characterState: CharacterState

    init(characterState: CharacterState) {
        self.characterState = characterState
    }
}
