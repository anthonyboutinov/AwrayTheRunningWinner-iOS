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
    
    private var backButton: SKSpriteNode!
    private let website = SKLabelNode(fontNamed: gameFont)
    
    // MARK: SKScene override methods
    
    override func didMoveToView(view: SKView) {
        backButton = UIDesigner.addBackButton(self)
        let title = UIDesigner.addTitle("About", self)

        let fontSize = CGFloat(15) // iPhone 4s, 5, 5s
        
        // Credits
        let lines: [SKLabelNode] = [SKLabelNode](count: 2 * 11, repeatedValue: SKLabelNode(fontNamed: gameFont))
        let texts: [String] = [
            "iOS & OS X Development", "Anthony Boutinov",
            "Android Development", "Mikhail Polyubay",
            "Design", "Alevtina Petrova",
            "Twitter-component", "Alexandra Kuzmina",
            "Level Design", "Alina Ganieva",
            "Tests", "Vladimir Burdin",
            "Website", "Alyona Moiseeva",
            "Special thanks to", "Kamil Khadiev",
            "", "Regina Kamaleeva",
            "", "Kenney",
            "", "Jake Gundersen"
        ]
        UIDesigner.layoutTextTable(texts, self, positionOffsetY: -title.frame.height / 2, margin: margin * 2.5)
        
        // Website
        website.text = "arwaytherunningwinner.com"
        website.fontSize = fontSize
        website.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMinY(frame) + margin + website.frame.height / 2)
        addChild(website)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            for node in self.nodesAtPoint(location) as [SKNode] {
                if node == backButton {
                    presentScene(MainMenuScene(), view!)
                } else if node == website {
                    UIApplication.sharedApplication().openURL(NSURL(string: "http://arwaytherunningwinner.com")!)
                }
            }
        }
    }
    
}