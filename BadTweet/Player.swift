//
//  Player.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/7/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

// MARK: Physical properties and constraints
private let minMovement = CGPoint(x: -120.0, y: -350.0)
private let maxMovement = CGPoint(x: 120.0, y: 350.0)
private let jumpForce = CGPoint(x: 0.0, y: 350.0)
private let jumpCutoff = CGFloat(150.0)
private let slipperyCoefficient = CGFloat(0.6)

private let powerUpTime: NSTimeInterval = 30.0

// MARK: SKActions
private let jumpSound = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)


class Player: Updatable, HoldsItsSprite {
    
    // MARK: - Variables
    // MARK: Sprite
    
    let sprite: SKSpriteNode
    private let walkTextures: [SKTexture] = [
        SKTexture(imageNamed: "HeroRa1"),
        SKTexture(imageNamed: "HeroRa2")
    ]
    private let jumpTexture = SKTexture(imageNamed: "alienGreen_jump")
    private let hurtTexture = SKTexture(imageNamed: "alienGreen_hurt")
//    private var spriteWalkAnimationAction: SKAction?
    
    // MARK: Physical properties
    
    var velocity = CGPoint(x: 0.0, y: 0.0)
    
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
    
    required init(position: CGPoint) {
        
        sprite = SKSpriteNode(texture: walkTextures[0])
        sprite.zPosition = -21.0
        
        let animateWalkAction = SKAction.animateWithTextures(walkTextures, timePerFrame: 0.40);
        let spriteWalkAnimationAction = SKAction.repeatActionForever(animateWalkAction);
        sprite.runAction(spriteWalkAnimationAction)
        
        desiredPosition = position
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
            forwardMove = CGPoint(x: 1200.0, y: 0.0)
        }
        let forwardMoveStep = CGPointMultiplyScalar(forwardMove, delta)
        
        let gravityStep = CGPointMultiplyScalar(gravity, delta)
        velocity = CGPointAdd(velocity, gravityStep)
        
        velocity.x *= slipperyCoefficient
        
        // Jumping
        if mightAsWellJump && onGround {
            velocity = CGPointAdd(velocity, jumpForce)
            if Sound_soundEffects {
                sprite.runAction(jumpSound)
            }
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