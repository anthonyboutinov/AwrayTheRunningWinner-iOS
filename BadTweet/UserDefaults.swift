//
//  UserDefaults.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/22/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

class UserDefaults {
    class func SFXAndMusic() -> (Bool, Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        return (!defaults.boolForKey("soundEffectsAreOff"), !defaults.boolForKey("musicIsOff"))
    }
    
    class func updateSFX(value: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(!value, forKey: "soundEffectsAreOff")
    }
    
    class func updateMusic(value: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(!value, forKey: "musicIsOff")
    }
}