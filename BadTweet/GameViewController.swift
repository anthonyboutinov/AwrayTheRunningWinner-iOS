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
    
    var backgroundMusic = AVAudioPlayer()
    
    func setupAudioPlayer(#file:NSString, ofType type:NSString) -> AVAudioPlayer  {
        let path = NSBundle.mainBundle().pathForResource(file, ofType:type)
        let audioPlayer:AVAudioPlayer? = AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(path!), error: nil)
        return audioPlayer!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add background music
        backgroundMusic = self.setupAudioPlayer(file: "6dfcd1ecc4db", ofType:"mp3")
        backgroundMusic.volume = 0.3
        backgroundMusic.play()
        
        // Init scene and world state
        let scene = MainMenuScene()
        
        // Configure the view
        let skView = self.view as SKView
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        presentScene(scene, skView)
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
