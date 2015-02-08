//
//  WorldLevel.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/8/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

let levelsPerWorld = 2

class WorldLevel: Printable {
    var world: Int
    var _level: Int
    var level: Int {
        set {
            if newValue > levelsPerWorld {
                _level = 1
                world++
            } else {
                _level = newValue
            }
        }
        get {
            return _level
        }
    }
    
    var description: String {
        return "World \(world) Level \(level)"
    }
    
    var tmxFileName: String {
        return "World\(world)Level\(level).tmx"
    }
    
    init(_ world: Int, _ level: Int) {
        self.world = world
        self._level = level
    }
    
    func inc() {
        level++
    }
}