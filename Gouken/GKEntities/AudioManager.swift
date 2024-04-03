import Foundation
import AVFoundation

class AudioManager {
    
    var backgroundMusicChannelPlayer: AVAudioPlayer?
    var player1AudioChannelPlayer: AVAudioPlayer?
    var player2AudioChannelPlayer: AVAudioPlayer?
    var effectsAudioChannelPlayer: AVAudioPlayer?
    
    static private var Instance_: AudioManager?
    
    static func Instance() -> AudioManager {
        if (AudioManager.Instance_ == nil) {
            AudioManager.Instance_ = AudioManager()
        }
        return (AudioManager.Instance_)!
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
    
    func playPlayer1Sound(audio: AudioDict) {
        guard let audioInfo = gameAudio[audio], let fileName = audioInfo.first, let ext = audioInfo.last, let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("Could not find \(audio.rawValue)?? ")
            return
        }
        
        player1AudioChannelPlayer?.stop()
        
        do {
            player1AudioChannelPlayer = try AVAudioPlayer(contentsOf: url)
            player1AudioChannelPlayer?.numberOfLoops = 1 // Play once
            player1AudioChannelPlayer?.volume = 0.3
            player1AudioChannelPlayer?.play()
        } catch let error {
            print("Error creating audio player: \(error.localizedDescription)")
        }
    }
    
    func playPlayer2Sound(audio: AudioDict) {
        guard let audioInfo = gameAudio[audio], let fileName = audioInfo.first, let ext = audioInfo.last, let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("Could not find \(audio.rawValue)?? ")
            return
        }
        
        player2AudioChannelPlayer?.stop()
        
        do {
            player2AudioChannelPlayer = try AVAudioPlayer(contentsOf: url)
            player2AudioChannelPlayer?.numberOfLoops = 1 // Play once
            player2AudioChannelPlayer?.volume = 0.3
            player2AudioChannelPlayer?.play()
        } catch let error {
            print("Error creating audio player: \(error.localizedDescription)")
        }
    }
    
    func playEffectSound(audio: AudioDict) {
        guard let audioInfo = gameAudio[audio], let fileName = audioInfo.first, let ext = audioInfo.last, let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("Could not find \(audio.rawValue)?? ")
            return
        }
        
        effectsAudioChannelPlayer?.stop()
        
        DispatchQueue.global(qos: .background).async { [self] in
            do {
                effectsAudioChannelPlayer = try AVAudioPlayer(contentsOf: url)
                effectsAudioChannelPlayer?.numberOfLoops = 1 // Play once
                effectsAudioChannelPlayer?.volume = 0.3
                effectsAudioChannelPlayer?.play()
            } catch let error {
                print("Error creating audio player: \(error.localizedDescription)")
            }
        }
    }
    
    func stopMenuBackgroundMusic() {
        backgroundMusicChannelPlayer?.stop()
    }
    
    func stopAllAudioChannels() {
        backgroundMusicChannelPlayer?.stop()
        player1AudioChannelPlayer?.stop()
        player2AudioChannelPlayer?.stop()
        effectsAudioChannelPlayer?.stop()
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
    .LightAttack: ["Gouken_Ninja_Hit_Effect", "mp3"],
    .HeavyAttack: ["Gouken_Heavy_Attack", "wav"],
    .Stunned: ["Gouken_Hurt", "wav"],
    .Downed: ["Gouken_Die", "wav"],
    .Jump: ["Gouken_Jump", "wav"],
    .Guard: ["Gouken_Guard", "wav"],
    .RoundStart: ["Gouken_Round_Start", "wav"],
    .RoundEnd: ["Gouken_Round_End", "wav"],
    .DragonPunch: ["Gouken_Dragon_Punch", "wav"]
]
