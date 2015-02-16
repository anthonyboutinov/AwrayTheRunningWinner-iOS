//
//  SettingsScene.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/16/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

class SettingsScene: SKScene {
    
    // MARK: UI Elements
    
    private let backButton = SKSpriteNode(texture: backButtonTexture)
    
    // MARK: SKScene override methods
    
    override func didMoveToView(view: SKView) {
        UIDesigner.layoutBackButton(backButton, self)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            for node in self.nodesAtPoint(location) as [SKNode] {
                if node == backButton {
                    presentScene(MainMenuScene(), view!)
                }
            }
        }

    }
}