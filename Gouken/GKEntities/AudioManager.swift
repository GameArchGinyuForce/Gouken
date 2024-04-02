//
//  AudioManager.swift
//  Gouken
//
//  Created by Jugraj Chouhan on 2024-04-01.
//

import Foundation

//
//  AudioManager.swift
//  Gouken
//
//  Created by Nathan Dong on 2024-03-28.
//

import AVFoundation


/*
 // Singleton AudioManager
 // Call methods via AudioManager.Instance().methodName()
 // Can be accessed globally
 
 TODO: Consider loading all possible AVAudioPlayer sounds when loading the game scene
 TODO: Consider multiple channels for each player
 */
class AudioManager {
    
    // Initial Implementation, consider better design
    var backgroundMusicChannelPlayer: AVAudioPlayer?
    
    var player1AudioChannelPlayer: AVAudioPlayer?
    var player2AudioChannelPlayer: AVAudioPlayer?
    
    var HitEffect: AVAudioPlayer?
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
    
    func playBackgoundMusicSoundByURL(fileName: String, ext: String = ".mp3") {
        
        backgroundMusicChannelPlayer?.stop();
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("Could not find " + fileName + ext)
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
    
    func playPlayer1SoundByURL(fileName: String, ext: String = ".mp3") {
        
        player1AudioChannelPlayer?.stop();
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("Could not find " + fileName + ext)
            return
        }
        
        do {
            player1AudioChannelPlayer = try AVAudioPlayer(contentsOf: url)
            player1AudioChannelPlayer?.numberOfLoops = 1 // Play once
            player1AudioChannelPlayer?.volume = 0.3
            player1AudioChannelPlayer?.play()
        } catch let error {
            print("Error creating audio player: \(error.localizedDescription)")
        }
    }
    
    func playPlayer2SoundByURL(fileName: String, ext: String = ".mp3") {
        
        player2AudioChannelPlayer?.stop();
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("Could not find " + fileName + ext)
            return
        }
        
        do {
            player2AudioChannelPlayer = try AVAudioPlayer(contentsOf: url)
            player2AudioChannelPlayer?.numberOfLoops = 1 // Play once
            player2AudioChannelPlayer?.volume = 0.3
            player2AudioChannelPlayer?.play()
        } catch let error {
            print("Error creating audio player: \(error.localizedDescription)")
        }
    }
    
    
    func playHitEffectSoundByURL(fileName: String, ext: String = ".mp3") {
        DispatchQueue.global().async {
            self.HitEffect?.stop()
            print("playHitEffectSoundByURL")
            
            guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
                print("Could not find " + fileName + ext)
                return
            }
            
            do {
                self.HitEffect = try AVAudioPlayer(contentsOf: url)
                self.HitEffect?.numberOfLoops = 0 // Play once
                self.HitEffect?.volume = 1 // Adjust volume as needed
                self.HitEffect?.play()
            } catch let error {
                print("Error creating audio player: \(error.localizedDescription)")
            }
        }
    }

    
    func playEffectSoundByURL(fileName: String, ext: String = ".mp3") {
        DispatchQueue.global().async {
            self.effectsAudioChannelPlayer?.stop();
            
            // Get the current date and time
                var currentTime = Date()
                
                // Create a date formatter
                var dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
                
                // Format the current time as a string
                var formattedTime = dateFormatter.string(from: currentTime)
                
                // Print the formatted time
                print("Before Time: \(formattedTime)")
            
            guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
                print("Could not find " + fileName + ext)
                return
            }
            
            // Get the current date and time
                currentTime = Date()
                
                // Create a date formatter
                dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
                
                // Format the current time as a string
                formattedTime = dateFormatter.string(from: currentTime)
                
                // Print the formatted time
                print("After Time: \(formattedTime)")
            
            do {
                self.effectsAudioChannelPlayer = try AVAudioPlayer(contentsOf: url)
                self.effectsAudioChannelPlayer?.numberOfLoops = 0 // Play once
                self.effectsAudioChannelPlayer?.volume = 1
                self.effectsAudioChannelPlayer?.play()
            } catch let error {
                print("Error creating audio player: \(error.localizedDescription)")
            }
        }
    }

}

