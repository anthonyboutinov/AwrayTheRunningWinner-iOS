//
//  MainMenu.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/14/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

class MainMenuScene: SKScene {
    
    // MARK: Properties
    
    // MARK: UI Elements
    
    private let playButton = SKSpriteNode(texture: blueButtonTexture)
    private let settingsButton = SKSpriteNode(texture: blueButtonTexture)
    private let aboutButton = SKSpriteNode(texture: blueButtonTexture)
    
    // MARK: SKScene override methods
    
    override func didMoveToView(view: SKView) {
        let elements: [SKSpriteNode] = [playButton, settingsButton, aboutButton]
        let texts: [String] = ["Play", "Settings", "About"]
        UIDesigner.layoutButtonsWithText(scene: self, buttons: elements, texts: texts, zPosition: 2.0)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            for node in self.nodesAtPoint(location) as [SKNode] {
                switch node {
                case playButton:
                    goToPlayScreen()
                case settingsButton:
                    goToSettings()
                case aboutButton:
                    goToAbout()
                default:
                    break
                }
            }
        }

    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
    
    private func goToPlayScreen() {
        presentScene(PlayScene(), view!)
    }
    
    private func goToSettings() {
        presentScene(SettingsScene(), view!)
    }
    
    private func goToAbout() {
        presentScene(AboutScene(), view!)
    }
}