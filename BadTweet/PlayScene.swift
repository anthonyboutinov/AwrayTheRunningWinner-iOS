//
//  PlayScene.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/17/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

class PlayScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        
        // For now, skip to the GameLevelScene immediately
        let scene = GameLevelScene()
        scene.worldState = WorldStateWithUI()
        presentScene(scene, view)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
    }
}