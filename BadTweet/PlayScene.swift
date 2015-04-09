//
//  PlayScene.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/17/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

class PlayScene: SKScene {
    
    private var backButton: SKSpriteNode!
    
    private var newGameButton = UIDesigner.button()
    private var continueGameButton = UIDesigner.button()
    
    private var worldState: WorldStateWithUI?
    
    override func didMoveToView(view: SKView) {
        
        if let worldState = UserDefaults.loadWorldState() {
            self.worldState = worldState
            
            // Layout this scene with two buttons

            backButton = UIDesigner.addBackButton(self)
            
            let elements: [SKSpriteNode] = [newGameButton, continueGameButton]
            let texts: [String] = ["New Game", "Continue"]
            UIDesigner.layoutButtonsWithText(scene: self, buttons: elements, texts: texts, zPosition: 2.0)
            
        } else {
            playNewGame()
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            for node in self.nodesAtPoint(location) as! [SKNode] {
                if node == backButton {
                    presentScene(MainMenuScene(), view!)
                } else if node == newGameButton {
                    playNewGame()
                } else if node == continueGameButton {
                    continueGame()
                }
            }
        }
    }
    
    func playNewGame() {
        let scene = GameLevelScene()
        scene.worldState = WorldStateWithUI()
        presentScene(scene, view!)
    }
    func continueGame() {
        let scene = GameLevelScene()
        scene.worldState = worldState
        presentScene(scene, view!)
    }
}