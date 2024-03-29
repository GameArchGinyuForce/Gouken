import Foundation



class CodableCharacter : Codable {
    var runLeft: Bool
    var runRight: Bool
    var characterState: CharacterState

    init(runLeft: Bool, runRight: Bool, characterState: CharacterState) {
        self.runLeft = runLeft
        self.runRight = runRight
        self.characterState = characterState
    }
}
