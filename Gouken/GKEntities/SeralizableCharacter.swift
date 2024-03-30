import Foundation



class SeralizableCharacter : Codable {
    var characterState: CharacterState

    init(characterState: CharacterState) {
        self.characterState = characterState
    }
}
