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
    var level: Int {
        didSet {
            if level > levelsPerWorld {
                level = 1
                world++
            }
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
        self.level = level
    }
    
}