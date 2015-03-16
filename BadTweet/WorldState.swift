//
//  WorldState.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/8/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

// TODO: Make it 'class let'
let defaultNumberOfLives = 3
let coinsToLifeThreshold = 500
// TODO: Make it 'class let'
let levelsPerWorld = 2


class WorldState: Printable {
    
    // MARK: - Variables
    
    var description: String {
        return "WorldState(World \(world) Level \(level), \(numCoins) coins, \(numLives) lives)"
    }
    
    var numCoins: Int {
        didSet {
            if numCoins != 0 && numCoins % coinsToLifeThreshold == 0 {
                numLives++
            }
        }
    }
    var numLives: Int {
        didSet {
            // Reset game if no lives left
            if numLives < 1 {
                world = 1
                level = 1
                numLives = defaultNumberOfLives
                numCoins = 0
            }
        }
    }
    
    var world: Int
    
    // When player finishes the last level of a world, player transitions
    // to the next world and level numeration starts over.
    var level: Int {
        didSet {
            if level > levelsPerWorld {
                level = 1
                world++
            }
        }
    }
    
    var tmxFileName: String {
        return "World\(world)Level\(level).tmx"
    }
    
    var gameOver = false
        
    // MARK: - Methods
    
    init(numCoins: Int = 0, numLives: Int = defaultNumberOfLives, world: Int = 1, level: Int = 1) {
        self.numCoins = numCoins
        self.numLives = numLives
        self.world = world
        self.level = level
    }
    
    func advanceToTheNextLevel() {
        level++
        UserDefaults.save(worldState: self)
    }
    
}