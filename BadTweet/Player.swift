//
//  Player.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/7/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

let minMovement = CGPointMake(0.0, -450)
let maxMovement = CGPointMake(120.0, 250.0)
let jumpForce = CGPointMake(0.0, 310.0)
let jumpCutoff = CGFloat(150.0)

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
    
    var forwardMarch: Bool = false {
        didSet {
            if forwardMarch && backwardsMarch {
                backwardsMarch = false
            }
        }
    }
    var backwardsMarch: Bool = false {
        didSet {
            if backwardsMarch && forwardMarch {
                forwardMarch = false
            }
        }
    }
    
    var mightAsWellJump = false
    var onGround = false
    
    var desiredPosition: CGPoint

    // MARK: - Methods
    
    init(gravity: CGPoint, position: CGPoint) {
        
        self.gravity = gravity
        
        sprite = SKSpriteNode(texture: walkTextures[0])
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
        
        let forwardMove = CGPointMake(800.0, 0.0)
        let forwardMoveStep = CGPointMultiplyScalar(forwardMove, delta)
        
        let gravityStep = CGPointMultiplyScalar(gravity, delta)
        velocity = CGPointAdd(velocity, gravityStep)
        
        velocity = CGPointMake(velocity.x * 0.9, velocity.y)
        
        // Jumping
        if mightAsWellJump && onGround {
            velocity = CGPointAdd(velocity, jumpForce)
            sprite.runAction(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
        } else if !mightAsWellJump && velocity.y > jumpCutoff {
            velocity = CGPointMake(velocity.x, jumpCutoff)
        }

        velocity = CGPointMake(Clamp(velocity.x, minMovement.x, maxMovement.x), Clamp(velocity.y, minMovement.y, maxMovement.y))
        
        let velocityStep = CGPointMultiplyScalar(velocity, delta)
        desiredPosition = CGPointAdd(desiredPosition, velocityStep)
    }
    
}