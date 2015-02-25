//
//  Sound.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/25/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation
import AVFoundation

// TODO: Swift 1.2 make it class vars of Sound class

var Sound_music = false
var Sound_soundEffects = false

var backgroundMusic = AVAudioPlayer()

class Sound {
    
    class func initSharedInstance() {
        (Sound_soundEffects, Sound_music) = UserDefaults.SFXAndMusic()
        
        backgroundMusic = Sound.setupAudioPlayer(file: "6dfcd1ecc4db", ofType:"mp3")
        backgroundMusic.volume = 0.3
        if Sound_music {
            backgroundMusic.play()
        }

    }
    
    class func setupAudioPlayer(#file:NSString, ofType type:NSString) -> AVAudioPlayer  {
        let path = NSBundle.mainBundle().pathForResource(file, ofType:type)
        let audioPlayer: AVAudioPlayer? = AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(path!), error: nil)
        return audioPlayer!
    }
    
    class func toggleSoundEffects() {
        Sound_soundEffects = !Sound_soundEffects
        UserDefaults.updateSFX(Sound_soundEffects)
    }
    
    class func toggleMusic() {
        Sound_music = !Sound_music
        UserDefaults.updateMusic(Sound_music)
        if Sound_music {
            backgroundMusic.play()
        } else {
            backgroundMusic.pause()
        }
    }
    
}