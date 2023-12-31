//
//  SKTAudio.swift
//  JurassicQuack
//
//  Created by Serena Savarese on 14/12/23.
//

import AVFoundation

class SKTAudio {
    
    var bgMusic: AVAudioPlayer?
    var soundEffect: AVAudioPlayer?
    
    static func sharedInstance() -> SKTAudio {
        return SKTAudioInstance
    }
    
    /*
     Per tornare ad una sola canzone, basta togliere le paremntesi quadre a String,
     eliminare randomIndex e selectFileName ed infine
     mettere fileNamed al posto di selectedFileName in url
     */
    func playBGMusic(_ fileNamed: [String]) {
        if !SKTAudio.musicEnabled { return }
        
        //Random music
        let randomIndex = Int.random(in: 0..<fileNamed.count)
        let selectedFileName = fileNamed[randomIndex]
        
        guard let url = Bundle.main.url(forResource: selectedFileName, withExtension: nil) else { return }
        
        do {
            bgMusic = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            bgMusic = nil
        }
        
        if let bgMusic = bgMusic {
            bgMusic.numberOfLoops = -1
            bgMusic.prepareToPlay()
            bgMusic.play()
        }
            
    }
    
    func stopBGMusic() {
        if let bgMusic = bgMusic {
            if bgMusic.isPlaying { bgMusic.stop() }
        }
        
    }
    
    func pauseBGMusic() {
        if let bgMusic = bgMusic {
            if bgMusic.isPlaying { bgMusic.pause() }
        }
    }
    
    func resumeBGMusic() {
        if let bgMusic = bgMusic {
            if !bgMusic.isPlaying { bgMusic.play() }
        }
    }
    
    func playSoundEffect (_ fileNamed: String) {
        guard let url = Bundle.main.url(forResource: fileNamed, withExtension: nil) else { return }
        
        do{
            soundEffect = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            soundEffect = nil
        }
        
        if let soundEffect = soundEffect {
            soundEffect.numberOfLoops = 0
            soundEffect.prepareToPlay()
            soundEffect.play()
        }
        
    }
    
    static let keyMusic = "keyMusic"
    static var musicEnabled: Bool = {
        return !UserDefaults.standard.bool(forKey: keyMusic)
    } () {
        didSet {
            let value = !musicEnabled
            UserDefaults.standard.set(value, forKey: keyMusic)
            
            if value { SKTAudio.sharedInstance().stopBGMusic() }
        }
    }
    
}

private let SKTAudioInstance = SKTAudio()
