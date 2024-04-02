//
//  GameManager.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-17.
//

import SceneKit

enum StageSelected {
    case
    AmazingBrentwood,
    PyramidOfGiza,
    Map_3
}

enum CharacterSelected {
    case
    Ninja_0,
    Ninja_1,
    Ninja_2
}

enum MatchType {
    case
    CPU,
    MP
}

enum CurrentScene {
    case
    Menu,
    Loading,
    MatchMatching,
    Game
}

class GameManager {
    
    // Initial Implementation, consider better design
    var stageSelected: StageSelected?
    var p1Character: Character?
    var p2Character: Character?
    var matchType: MatchType?
    var currentScene: CurrentScene?
    var cameraNode: SCNNode?
    var playerSpawn: SCNNode?
    var enemySpawn: SCNNode?
    
    // TODO: Additional parameters including Settings (Sound level, etc.), playerId?, matchHistory?
    
    // Singleton Pattern
    static private var Instance_: GameManager?
    
    // Access singleton with this method call
    static func Instance() -> GameManager {
        if (GameManager.Instance_ == nil) {
            GameManager.Instance_ = GameManager()
        }
        return (GameManager.Instance_)!
    }

    // A sample method that can be called from any file
    func doSomething() {
        print("Hey From GameManager Singleton")
    }
    
    func otherCharacter(character: Character) -> Character{
        
        if(character == GameManager.Instance().p1Character!){
            return GameManager.Instance().p2Character!
        }else{
            return GameManager.Instance().p1Character!
        }
    }
    
}
