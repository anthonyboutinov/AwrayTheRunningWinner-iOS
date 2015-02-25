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
    
    private var backButton: SKSpriteNode!
    
    private let switchOn = SKTexture(imageNamed: "switch_on")
    private let switchOff = SKTexture(imageNamed: "switch_off")
    
    private var soundEffectsSwitch: SKSpriteNode!
    private var musicSwitch: SKSpriteNode!
    
    private let soundEffectsLabel = SKLabelNode(fontNamed: gameFont)
    private let musicLabel = SKLabelNode(fontNamed: gameFont)
    
    // MARK: SKScene override methods
    
    override func didMoveToView(view: SKView) {
        backButton = UIDesigner.addBackButton(self)
        let title = UIDesigner.addTitle("Settings", self)
        
        soundEffectsLabel.text = "Sound Effects"
        musicLabel.text = "Music"
        
//        let maxLabelLength = max(soundEffectsLabel.frame.width, musicLabel.frame.width)
        
        soundEffectsSwitch = Sound_soundEffects ? SKSpriteNode(texture: switchOn) : SKSpriteNode(texture: switchOff)
        musicSwitch = Sound_music ? SKSpriteNode(texture: switchOn) : SKSpriteNode(texture: switchOff)
        
        let yOffset =  -title.frame.height / 2
        var i = false
        for (label, switchSprite) in [(soundEffectsLabel, soundEffectsSwitch), (musicLabel, musicSwitch)] {
            
            var centerPoint = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + yOffset)
            label.position = CGPoint(x: margin * 3 + label.frame.width / 2, y: centerPoint.y)
            label.position.y += i ? -label.frame.height / 2 : label.frame.height / 2
            
            switchSprite.position = CGPoint(x: CGRectGetMaxY(self.frame), y: centerPoint.y)
            switchSprite.position.y += i ? -switchSprite.size.height / 2 : switchSprite.size.height / 2
            
            addChild(label)
            addChild(switchSprite)
            i = !i
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            for node in self.nodesAtPoint(location) as [SKNode] {
                switch node {
                case backButton:
                    presentScene(MainMenuScene(), view!)
                    
                case soundEffectsSwitch:
                    fallthrough
                case soundEffectsLabel:
                    Sound.toggleSoundEffects()
                    soundEffectsSwitch.texture = Sound_soundEffects ? switchOn : switchOff
                    
                case musicSwitch:
                    fallthrough
                case musicLabel:                    
                    Sound.toggleMusic()
                    musicSwitch.texture = Sound_music ? switchOn : switchOff
                    
                default:
                    break
                }
            }
        }

    }
}