import Foundation
import AVFoundation

class AudioManager {
    
    var backgroundMusicChannelPlayer: AVAudioPlayer?
    var player1AudioChannelPlayer: AVAudioPlayer?
    var player2AudioChannelPlayer: AVAudioPlayer?
    var effectsAudioChannelPlayer: AVAudioPlayer?
    
    var audioPlayers: [AudioDict: AVAudioPlayer] = [:]
    
    static private var Instance_: AudioManager?
    
    static func Instance() -> AudioManager {
        if (AudioManager.Instance_ == nil) {
            AudioManager.Instance_ = AudioManager()
            AudioManager.Instance_!.loadAudioSounds()
        }
        return (AudioManager.Instance_)!
    }
    
    func loadAudioSounds() {
        for (key, value) in gameAudio {
            AudioManager.Instance().loadSoundAsync(soundName: value[0], audioDictKey: key, ext: value[1]) { audioPlayer, error in
                if let audioPlayer = audioPlayer {
                    // Sound loaded successfully, play it
//                    audioPlayer.play()
                } else if let error = error {
                    // Handle error loading sound
                    print("Error loading sound: \(error.localizedDescription)")
                }
            }
        }
        
        print("Finished loading audioSounds")
        print(audioPlayers)
    }
    
    func loadSoundAsync(soundName: String, audioDictKey: AudioDict, ext: String, completion: @escaping (AVAudioPlayer?, Error?) -> Void) {
        
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: ext) else {
            let error = NSError(domain: "AudioManagerErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Sound file not found"])
            return
        }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.prepareToPlay()

            // Store the audio player in the dictionary
            self.audioPlayers[audioDictKey] = audioPlayer

        } catch {
            print("Issue loading audio file: ", soundName, ext)
        }
        
       }
    
    func playBackgoundMusicSound(audio: AudioDict) {
        guard let audioInfo = gameAudio[audio], let fileName = audioInfo.first, let ext = audioInfo.last, let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("Could not find \(audio.rawValue)?? ")
            return
        }
        
        backgroundMusicChannelPlayer?.stop()
        
        do {
            backgroundMusicChannelPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicChannelPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicChannelPlayer?.volume = 0.3
            backgroundMusicChannelPlayer?.play()
        } catch let error {
            print("Error creating audio player: \(error.localizedDescription)")
        }
    }
    
    func playEffectSound(audio: AudioDict) {
        guard let audioInfo = gameAudio[audio], let fileName = audioInfo.first, let ext = audioInfo.last else {
                    print("Could not find \(audio.rawValue) sound information")
                    return
                }

        if let audioPlayer = audioPlayers[audio] {
            audioPlayer.stop()
            if let soundURL = Bundle.main.url(forResource: fileName, withExtension: ext) {
                do {
                    audioPlayer.currentTime = 0 // Rewind to start
                    audioPlayer.play()
                } catch {
                    print("Error playing sound: \(audio.rawValue)")
                }
            } else {
                print("Sound file not found: \(audio.rawValue)")
            }
        } else {
            print("No available audio players in the pool")
        }
    }

    
    func stopMenuBackgroundMusic() {
        backgroundMusicChannelPlayer?.stop()
    }
    
    func stopAllAudioChannels() {
        backgroundMusicChannelPlayer?.stop()
        for (key, value) in audioPlayers {
            value.stop()
        }
    }
    
}

enum AudioDict: String {
    case Menu
    case Game
    case LightAttack
    case HeavyAttack
    case Stunned
    case Downed
    case Jump
    case Guard
    case RoundStart
    case RoundEnd
    case DragonPunch
}

let gameAudio: [AudioDict: [String]] = [
    .Menu: ["Gouken_Menu_Theme", "mp3"],
    .Game: ["Gouken_Battle_Theme", "mp3"],
    .LightAttack: ["Ninja_Hit_Effect", "mp3"],
    .HeavyAttack: ["Ninja_Hit_Effect", "mp3"],
    .Stunned: ["Gouken_Hurt", "wav"],
    .Downed: ["Gouken_Die", "wav"],
    .Jump: ["Gouken_Jump", "wav"],
    .Guard: ["Gouken_Guard", "wav"],
    .RoundStart: ["Gouken_Round_Start", "wav"],
    .RoundEnd: ["Gouken_Round_End", "wav"],
    .DragonPunch: ["Ninja_Hit_Effect", "mp3"]
]
