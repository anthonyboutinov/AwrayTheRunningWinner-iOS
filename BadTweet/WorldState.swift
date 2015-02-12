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
// TODO: Make it 'class let' for WorldLevel
let levelsPerWorld = 2


class WorldState: Printable {
    
    // MARK: - Inner classes
    
    class WorldLevel: Printable {
        
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
    
    // MARK: - Variables
    
    var description: String {
        return "WorldState(\(worldLevel), \(numCoins) coins, \(numLives) lives)"
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
                worldLevel.world = 1
                worldLevel.level = 1
                numLives = defaultNumberOfLives
                numCoins = 0
            }
        }
    }
    private var worldLevel: WorldLevel
    
    // Delegating variables to private var worldLevel
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
        
    // MARK: - Methods
    
    init(numCoins: Int = 0, numLives: Int = defaultNumberOfLives, world: Int = 1, level: Int = 1) {
        self.numCoins = numCoins
        self.numLives = numLives
        self.worldLevel = WorldLevel(world, level)
    }
    
    func advanceToTheNextLevel() {
        worldLevel.level++
    }
    
}