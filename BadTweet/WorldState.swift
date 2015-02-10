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

class WorldState: Printable {
    
    var description: String {
        return "WorldState(\(worldLevel), \(numCoins) coins, \(numLives) lives)"
    }
    
    var numCoins: Int {
        didSet {
            if numCoins % coinsToLifeThreshold == 0 {
                numLives++
            }
        }
    }
    var numLives: Int {
        didSet {
            // Reset game if no lives left
            if numLives < 1 {
                worldLevel.world = 1
                worldLevel.level = 1
                numLives = defaultNumberOfLives
            }
        }
    }
    private var worldLevel: WorldLevel
    
    // delegating variables to private var worldLevel
    var world: Int {
        get {
            return worldLevel.world
        }
        set {
            worldLevel.world = newValue
        }
    }
    var level: Int {
        get {
            return worldLevel.level
        }
        set {
            worldLevel.level = newValue
        }
    }
    var tmxFileName: String {
        return worldLevel.tmxFileName
    }
    
    var gameOver = false
    
    func nextLevel() {
        worldLevel.level++
    }
    
    init(numCoins: Int = 0, numLives: Int = defaultNumberOfLives, world: Int = 1, level: Int = 1) {
        self.numCoins = numCoins
        self.numLives = numLives
        self.worldLevel = WorldLevel(world, level)
    }
    
}