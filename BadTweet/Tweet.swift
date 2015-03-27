//
//  Tweet.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 3/10/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

typealias TweetStruct = (author:String, text:String)

let TweetDefaultSpeed = CGFloat(40.0)

class Tweet: Updatable, HoldsItsSprite {
    
    let sprite: SKSpriteNode
    
    let speed:  CGFloat
    
    var position: CGPoint {
        get {
            return sprite.position
        }
        set {
            sprite.position = newValue
        }
    }
    
    convenience required init(position: CGPoint) {
        let empty = TweetStruct("@unknownauthor", "[Relatively long censored text here]")
        self.init(empty, position: position, speed: TweetDefaultSpeed)
    }
    
    required init(_ content:TweetStruct, position: CGPoint, speed: CGFloat) {
        self.sprite = Tweet.spriteForTweetContent(content)
        self.speed = speed
        self.position = position
    }
    
    func update(delta deltaTimeInterval: CFTimeInterval) {
        let delta = CGFloat(deltaTimeInterval)
        sprite.position.x -= speed * delta
    }
    
    class func spriteForTweetContent(tweet: TweetStruct) -> SKSpriteNode {
        
        let authorLabel = SKLabelNode(fontNamed: gameFont)
        authorLabel.fontSize = 13.0
        authorLabel.fontColor = UIColor.grayColor()
        authorLabel.text = tweet.author
        
        let textLabel = SKLabelNode(fontNamed: gameFont)
        textLabel.fontSize = 15.0
        textLabel.fontColor = UIColor.blackColor()
        textLabel.text = tweet.text
        
        let sprite = SKSpriteNode()
        sprite.addChild(authorLabel)
        sprite.addChild(textLabel)
        
//        let sprite = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(width: tweet.text / 140.0 * 30.0, height: 20.0))
        
        
        return sprite
    }
    
}