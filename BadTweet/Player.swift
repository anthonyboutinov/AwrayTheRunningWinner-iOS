//
//  Player.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/7/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

class Player {
    
    // MARK: - Variables
    // MARK: Sprite
    
    let sprite: SKSpriteNode
    private let walkTextures: [SKTexture] = [
        SKTexture(imageNamed: "alienGreen_walk1"),
        SKTexture(imageNamed: "alienGreen_walk2")
    ]
    private let jumpTexture = SKTexture(imageNamed: "alienGreen_jump")
    private let hurtTexture = SKTexture(imageNamed: "alienGreen_hurt")
//    private var spriteWalkAnimationAction: SKAction?
    
    // MARK: Physical properties
    
    var velocity = CGPoint(x: 0.0, y: 0.0)
    
    let gravity: CGPoint
    
    var collisionBoundingBox: CGRect {
        let boundingBox = CGRectInset(sprite.frame, 2, 0)
        let diff = CGPointMake(desiredPosition.x - sprite.position.x, desiredPosition.y - sprite.position.y)
        return CGRectOffset(boundingBox, diff.x, diff.y)
    }
    
    var position: CGPoint {
        get {
            return sprite.position
        }
        set {
            sprite.position = newValue
        }
    }
    
    var onGround = false
    
    var desiredPosition: CGPoint

    // MARK: - Methods
    
    init(gravity: CGPoint, position: CGPoint) {
        
        self.gravity = gravity
        
        sprite = SKSpriteNode(texture: walkTextures[0])
//        sprite.anchorPoint = CGPointMake(0, 0)
        sprite.zPosition = 15
        
//        let animateWalkAction = SKAction.animateWithTextures(walkTextures, timePerFrame: 0.40);
        //        let moveAction = SKAction.moveBy(CGVector(view.bounds.width,0), duration: 1.4);
        //        let group = SKAction.group([ animateAction,moveAction]);
//        spriteWalkAnimationAction = SKAction.repeatActionForever(animateWalkAction);
//        sprite.runAction(spriteWalkAnimationAction)
        
        self.desiredPosition = position
        sprite.position = position
    }
    
    func update(delta deltaTimeInterval: CFTimeInterval) {
        // Make delta to be CGFloat
        let delta = CGFloat(deltaTimeInterval as Double)
        
        let gravityStep = CGPointMake(gravity.x * delta, gravity.y * delta)
        velocity.x += gravityStep.x
        velocity.y += gravityStep.y
        let velocityStep = CGPointMake(velocity.x * delta, velocity.y * delta)
        
        desiredPosition.x += velocityStep.x
        desiredPosition.y += velocityStep.y
    }
    
}