//
//  Player.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/7/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

let minMovement = CGPoint(x: -120.0, y: -450)
let maxMovement = CGPoint(x: 120.0, y: 350.0)
let jumpForce = CGPoint(x: 0.0, y: 360.0)
let jumpCutoff = CGFloat(150.0)
let slipperyCoefficient = CGFloat(0.6)

let powerUpTime: NSTimeInterval = 30.0


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
        let diff = CGPoint(x: desiredPosition.x - sprite.position.x, y: desiredPosition.y - sprite.position.y)
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
    
    var powerUpTimeLeft: NSTimeInterval = 0.0

    // MARK: - Methods
    
    init(gravity: CGPoint, position: CGPoint) {
        
        self.gravity = gravity
        
        sprite = SKSpriteNode(texture: walkTextures[0])
        sprite.zPosition = -21.0
        
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
        
        if powerUpTimeLeft > 0.0 {
            powerUpTimeLeft -= deltaTimeInterval
        }
        
        var forwardMove = CGPoint(x: 800.0, y: 0.0)
        if backwardsMarch {
            forwardMove = CGPoint(x: -800.0, y: 0.0)
        }
        if powerUpTimeLeft > 0.0 && forwardMarch {
            forwardMove = CGPoint(x: 1000.0, y: 0.0)
        }
        let forwardMoveStep = CGPointMultiplyScalar(forwardMove, delta)
        
        let gravityStep = CGPointMultiplyScalar(gravity, delta)
        velocity = CGPointAdd(velocity, gravityStep)
        
        velocity.x *= slipperyCoefficient
        
        // Jumping
        if mightAsWellJump && onGround {
            velocity = CGPointAdd(velocity, jumpForce)
            sprite.runAction(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
        } else if !mightAsWellJump && velocity.y > jumpCutoff {
            velocity = CGPoint(x: velocity.x, y: jumpCutoff)
        }
        
        if forwardMarch || backwardsMarch {
            velocity = CGPointAdd(velocity, forwardMoveStep)
        }

        velocity = CGPoint(x: Clamp(velocity.x, minMovement.x, maxMovement.x), y: Clamp(velocity.y, minMovement.y, maxMovement.y))
        
        let velocityStep = CGPointMultiplyScalar(velocity, delta)
        desiredPosition = CGPointAdd(desiredPosition, velocityStep)
    }
    
    func applyPowerUp() {
        powerUpTimeLeft = powerUpTime
    }
    
}