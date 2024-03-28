//
//  AudioManager.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-28.
//

import AVFoundation

// Singleton AudioManager
// Call methods via AudioManager.Instance().methodName()
// Can be accessed globally
class AudioManager {
    
    // Initial Implementation, consider better design
    var backgroundMusicChannelPlayer: AVAudioPlayer?
    
    var player1AudioChannelPlayer: AVAudioPlayer?
    var player2AudioChannelPlayer: AVAudioPlayer?
    
    var effectsAudioChannelPlayer: AVAudioPlayer?
    
    // Singleton Pattern
    static private var Instance_: AudioManager?
    
    // Access singleton with this method call
    static func Instance() -> AudioManager {
        if (AudioManager.Instance_ == nil) {
            AudioManager.Instance_ = AudioManager()
        }
        return (AudioManager.Instance_)!
    }

    // A sample method that can be called from any file
    func doSomething() {
        print("Hey From AudioManager Singleton")
    }
    
    func playMenuBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") else {
            print("Could not find backgroundMusic.mp3")
            return
        }
        
        do {
            backgroundMusicChannelPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicChannelPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicChannelPlayer?.volume = 0.3
            backgroundMusicChannelPlayer?.play()
        } catch let error {
            print("Error creating audio player: \(error.localizedDescription)")
        }
    }
    
    func stopMenuBackgroundMusic() {
        backgroundMusicChannelPlayer?.stop();
    }
    
    func stopAllAudioChannels() {
        backgroundMusicChannelPlayer?.stop();
        player1AudioChannelPlayer?.stop();
        player2AudioChannelPlayer?.stop();
        effectsAudioChannelPlayer?.stop();
    }

}

