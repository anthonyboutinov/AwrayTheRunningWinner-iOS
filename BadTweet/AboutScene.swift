//
//  AboutScene.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/16/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

class AboutScene: SKScene {
    
    // MARK: Properties
    
    // MARK: UI Elements
    
    private let backButton = SKSpriteNode(texture: backButtonTexture)
    
    // MARK: SKScene override methods
    
    override func didMoveToView(view: SKView) {
        UIDesigner.layoutBackButton(backButton, self)
        
        let title = SKLabelNode(fontNamed: gameFont)
        title.fontSize = 50
        title.text = "About"
        title.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame) - margin - title.frame.height)
        addChild(title)

        
        let lines: [SKLabelNode] = [SKLabelNode](count: 2 * 10, repeatedValue: SKLabelNode(fontNamed: gameFont))
        let texts: [String] = [
            "iOS & OS X Development", "Anthony Boutinov",
            "Android Development", "Mikhail Polyubay",
            "Game & Level Design", "Alevtina Petrova",
            "Visual Design", "...",
            "Twitter-component", "Alexandra Kuzmina",
            "Tests", "Alina Ganieva",
            "", "& Vladimir Burdin",
            "Website", "Alyona Moiseeva",
            "Special thanks to", "Kamil Khadiev",
            "", "Kenney"
        ]
        UIDesigner.layoutTextTable(texts, self, positionOffsetY: -title.frame.height, customMargin: margin * 2.5)
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
    
//    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
//        
//    }
//    
//    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
//        
//    }
//    
//    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
//        
//    }
//    
//    override func update(currentTime: NSTimeInterval) {
//        
//    }
    
}