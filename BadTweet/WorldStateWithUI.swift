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
    
    // TODO: Swift 1.2 will let to make nodes be 'let' not 'var'
    private var nodes: [SKNode]
    
    override var numCoins: Int {
        didSet {
            uiCoinsText.text = String(numCoins)
        }
    }
    override var numLives: Int {
        didSet {
            if oldValue == defaultNumberOfLives && numLives > oldValue {
                
                // Transition from 'x sprites' to 'single sprite times number'
                for i in 1..<defaultNumberOfLives {
                    uiLivesImages[i].hidden = true
                }
                uiLivesLabel.text = " x \(numLives)"
                uiLivesLabel.hidden = false
                
            } else if oldValue == defaultNumberOfLives + 1 && numLives == defaultNumberOfLives {
                
                // Transition from 'single sprite times number' to 'x sprites'
                uiLivesLabel.hidden = true
                for i in 1..<defaultNumberOfLives {
                    uiLivesImages[i].hidden = false
                }
                
            } else if numLives <= defaultNumberOfLives {
                
                // Case 'x sprites'
                for i in 0..<defaultNumberOfLives {
                    if i < numLives {
                        uiLivesImages[i].hidden = false
                    } else {
                        uiLivesImages[i].hidden = true
                    }
                }
                
            } else {
                
                // Case 'single sprite times number'
                uiLivesLabel.text = " x \(numLives)"
            }
        }
    }
    
//    override var world: Int {
//        didSet {
//            updateWorldLevelLabel()
//        }
//    }
//    
//    override var level: Int {
//        didSet {
//            updateWorldLevelLabel()
//        }
//    }
    
    
    override init(numCoins: Int = 0, numLives: Int = 3, world: Int = 1, level: Int = 1) {
        
        nodes = [uiLivesLabel, uiCoinsText, uiCoinsImage, uiWorldLevelLabel]
        
        super.init(numCoins: numCoins, numLives: numLives, world: world, level: level)
        
        for i in 0..<defaultNumberOfLives {
            let life = SKSpriteNode(texture: uiLifeImageTexture)
            life.zPosition = 1
            life.anchorPoint = CGPointMake(0.0, 1.0)
            uiLivesImages.append(life)
        }
        
        uiLivesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        uiCoinsText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        uiWorldLevelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        
        for label in [uiLivesLabel, uiCoinsText] {
            label.fontName = "Helvetica-Nueue-Condensed-Bold"
            label.fontSize = 24
            label.fontColor = SKColor.whiteColor()
        }
        uiWorldLevelLabel.fontColor = uiLivesLabel.fontColor
        uiWorldLevelLabel.fontName = uiLivesLabel.fontName
        uiWorldLevelLabel.fontSize = 14
        
        // Trigger 'didSet's
        self.numLives = numLives
        self.numCoins = numCoins
        self.world = world
        self.level = level
        
        
    }
    
    private func updateWorldLevelLabel() {
        uiWorldLevelLabel.text = "World \(world) Level \(level)"
    }
    
    func removeChildrenFromScene(scene: SKScene) {
        
        uiWorldLevelLabel.parent!.removeChildrenInArray(nodes)
    }
    
    func addChildrenToScene(scene: SKScene) {
        
        // Force update worldLevelLabel, because there are no listeners set
        // for worldLevel's variables
        updateWorldLevelLabel()
        
        // Make a copy of self.nodes and append uiLivesImages to it
        var nodes = self.nodes
        for life in uiLivesImages as [SKNode] {
            nodes.append(life)
        }
        
        // If nodes already have parent node,
        if let parent = uiLivesImages[0].parent {
            // Then remove them from their parent node.
            parent.removeChildrenInArray(uiLivesImages)
            // If that is not true, then they must have been initialized already
            // and have their properties set, so 'else' closure shouldn't be
            // executed.
        } else {
            // Set margin and padding
            let margin = CGFloat(18.0)
            let padding = margin / 3
            
            // Position life image nodes
            for _i in 0..<defaultNumberOfLives {
                let i = CGFloat(_i)
                let life = uiLivesImages[_i]
                life.position = CGPointMake(margin + life.size.width * i + padding, CGRectGetMaxY(scene.frame) - margin)
            }
            
            // Position other nodes
            uiWorldLevelLabel.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMaxY(scene.frame) - margin)
            uiWorldLevelLabel.position.y -= uiWorldLevelLabel.frame.height
            uiCoinsImage.anchorPoint = CGPointMake(1.0, 1.0)
            uiCoinsImage.position = CGPointMake(CGRectGetMaxX(scene.frame) - margin, CGRectGetMaxY(scene.frame) - margin)
            // Next line: shift coin's position more to the left from the pause
            // button so they're not intersecting each other
            uiCoinsImage.position.x -= uiCoinsImage.size.width * 2 + margin
            uiCoinsText.position = CGPointMake(uiCoinsImage.position.x - uiCoinsImage.size.width - padding, uiCoinsImage.position.y)
            uiCoinsText.position.y -= uiCoinsText.frame.height
            uiLivesLabel.position = CGPointMake(uiLivesImages[0].position.x + uiLivesImages[0].size.width, uiCoinsText.position.y)
        }
        
        // Add all nodes to the scene
        for node in nodes {
            scene.addChild(node)
        }
    }
    
}