//
//  GameViewController.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/6/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameLevelScene()
        scene.worldLevel = WorldLevel(1, 1)
        
        // Configure the view
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        // Disable multiple touch
//        skView.multipleTouchEnabled = false
        // Set anchor point to lower left corner
        scene.anchorPoint = CGPointMake(0.0, 0.0)
        scene.scaleMode = .ResizeFill
        scene.size = skView.bounds.size
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
                
        skView.presentScene(scene)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
