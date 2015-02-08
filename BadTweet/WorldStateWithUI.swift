//
//  WorldStateUI.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/9/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

class WorldStateWithUI: WorldState {
    
    let uiCoinsImage = SKSpriteNode(imageNamed: "hud_coins")
    let uiCoinsText = SKLabelNode()
    let uiLivesImages: [SKSpriteNode] = [SKSpriteNode]()
    // for displaying more than defaultNumberOfLifes
    let uiLivesLabel = SKLabelNode()
    let uiWorldLevelLabel = SKLabelNode()
    
    private let uiLifeImageTexture = SKTexture(imageNamed: "hud_heartFull")
    
    override var numCoins: Int {
        didSet {
            uiCoinsText.text = String(numCoins)
        }
    }
    override var numLives: Int {
        didSet {
            if oldValue == defaultNumberOfLives {
                if numLives > defaultNumberOfLives {
                    // Transition from 'x sprites' to 'single sprite times number'
                } else {
                    // Transition from 'single sprite times number' to 'x sprites'
                }
            } else {
                if numLives < defaultNumberOfLives {
                    // Case 'x sprites'
                    
                } else {
                    // Case 'single sprite times number'
                    uiLivesLabel.text = " x \(numLives)"
                }
            }
        }
    }
    
    override var world: Int {
        didSet {
            updateWorldLevelLabel()
        }
    }
    
    override var level: Int {
        didSet {
            updateWorldLevelLabel()
        }
    }
    
    
    override init(numCoins: Int = 0, numLives: Int = 3, world: Int = 1, level: Int = 1) {
        super.init(numCoins: numCoins, numLives: numLives, world: world, level: level)
        
        for i in 0..<defaultNumberOfLives {
            let life = SKSpriteNode(texture: uiLifeImageTexture)
            life.zPosition = 1
            life.anchorPoint = CGPointMake(0.0, 1.0)
            uiLivesImages.append(life)
        }
    }
    
    private func updateWorldLevelLabel() {
        uiWorldLevelLabel.text = "W \(world) L \(level)"
    }
    
    func addChildrenToScene(scene: SKScene) {
        let margin = CGFloat(18.0)
        for _i in 0..<defaultNumberOfLives {
            let i = CGFloat(_i)
            let life = uiLivesImages[_i]
            life.position = CGPointMake(margin + life.size.width * i, CGRectGetMaxY(scene.frame) - margin)
        }
    }
    
}