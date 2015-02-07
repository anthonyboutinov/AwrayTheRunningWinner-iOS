//
//  GameScene.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/6/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import SpriteKit

private let controlRectSizes = CGFloat(45.0)

class GameScene: SKScene {
    
    private let uiControllerImage = SKSpriteNode(imageNamed: "Controller")
    private let uiUp = SKShapeNode(rectOfSize: CGSizeMake(controlRectSizes, controlRectSizes))
    private let uiDown = SKShapeNode(rectOfSize: CGSizeMake(controlRectSizes, controlRectSizes))
    private let uiLeft = SKShapeNode(rectOfSize: CGSizeMake(controlRectSizes, controlRectSizes))
    private let uiRight = SKShapeNode(rectOfSize: CGSizeMake(controlRectSizes, controlRectSizes))
    
    private let uiPower = SKSpriteNode(imageNamed: "power")
    private let uiPause = SKSpriteNode(imageNamed: "pause")
    
    private var hero: SKSpriteNode?
    private let heroWalkTextures: [SKTexture] = [
        SKTexture(imageNamed: "alienGreen_walk1"),
        SKTexture(imageNamed: "alienGreen_walk2")
    ]
    private let heroJumpTexture = SKTexture(imageNamed: "alienGreen_jump")
    private let heroHurtTexture = SKTexture(imageNamed: "alienGreen_hurt")
    private var heroWalkAnimationAction: SKAction?
    
    private let groundTexture = SKTexture(imageNamed: "grass")
    private var groundTiles: [SKSpriteNode] = [SKSpriteNode]()
    
    private var groundLine = CGFloat(60)
    private var movementSpeed = 0.4
    
    enum ColliderType: UInt32 {
        case Hero =     0x0000000F
        case Enemies =  0x000000F0
        case Ground =   0x00000F00
    }
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        
        //self.physicsWorld.gravity = CGVectorMake(0.0, -9.8)
        
        initGround()
        initHero()
        initUI()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            for node in self.nodesAtPoint(location) {
                if let shape = node as? SKShapeNode {
                    switch shape {
                    case uiUp:
                        println("up")
                    case uiDown:
                        println("down")
                    case uiLeft:
                        println("left")
                    case uiRight:
                        println("right")
                    default:
                        break
                    }
                } else if let sprite = node as? SKSpriteNode {
                    //...
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    private func initUI() {
        uiControllerImage.userInteractionEnabled = false
        uiControllerImage.zPosition = 1000
        uiControllerImage.anchorPoint = CGPointMake(0, 0)
        uiControllerImage.position = CGPointMake(20.0, 20.0)
        addChild(uiControllerImage)
        
        let uiZPosition = uiControllerImage.zPosition + 1
        let uiPosition = CGPointMake(uiControllerImage.position.x + 18, uiControllerImage.position.y  + 19)
        
        uiUp.zPosition = uiZPosition
        uiUp.position = CGPointMake(
            uiPosition.x + controlRectSizes,
            uiPosition.y + controlRectSizes * 2)
        addChild(uiUp)
        
        uiDown.zPosition = uiZPosition
        uiDown.position = CGPointMake(
            uiPosition.x + controlRectSizes,
            uiPosition.y)
        addChild(uiDown)
        
        uiLeft.zPosition = uiZPosition
        uiLeft.position = CGPointMake(
            uiPosition.x,
            uiPosition.y + controlRectSizes)
        addChild(uiLeft)
        
        uiRight.zPosition = uiZPosition
        uiRight.position = CGPointMake(
            uiPosition.x + controlRectSizes * 2,
            uiPosition.y + controlRectSizes)
        addChild(uiRight)
        
        uiUp.alpha = 0
        uiDown.alpha = 0
        uiLeft.alpha = 0
        uiRight.alpha = 0
        
        uiPower.zPosition = uiZPosition
        uiPower.anchorPoint = CGPointMake(1, 0.5)
        uiPower.position = CGPointMake(CGRectGetMaxX(self.frame) - 18,  uiLeft.position.y)
        addChild(uiPower)
        
        uiPause.zPosition = uiZPosition
        uiPause.anchorPoint = CGPointMake(0, 1)
        uiPause.position = CGPointMake(18, CGRectGetMaxY(self.frame) - 18)
        addChild(uiPause)

    }
    
    private func initHero() {
        hero = SKSpriteNode(texture: heroWalkTextures[0])
        hero!.anchorPoint = CGPointMake(0, 0)
        hero!.position = CGPointMake(200, groundLine + 40)
        hero!.zPosition = 900
        
        hero!.physicsBody = SKPhysicsBody(rectangleOfSize: hero!.size)
        hero!.physicsBody!.mass = 0.10
        hero!.physicsBody!.allowsRotation = false
        hero!.physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
        hero!.physicsBody!.collisionBitMask = ColliderType.Enemies.rawValue & ColliderType.Ground.rawValue
        hero!.physicsBody!.contactTestBitMask = ColliderType.Enemies.rawValue & ColliderType.Ground.rawValue
        
        let animateWalkAction = SKAction.animateWithTextures(heroWalkTextures, timePerFrame: 0.40);
//        let moveAction = SKAction.moveBy(CGVector(view.bounds.width,0), duration: 1.4);
//        let group = SKAction.group([ animateAction,moveAction]);
        heroWalkAnimationAction = SKAction.repeatActionForever(animateWalkAction);
        hero!.runAction(heroWalkAnimationAction)
        
        addChild(hero!)
        
    }
    
    private func initGround() {
        let groundTileWidth = groundTexture.size().width
        let count = (Int(self.frame.width) / Int(groundTileWidth) + 2)
        
        for i in 0..<count {
            groundTiles.append(SKSpriteNode(texture: groundTexture))
            let tile = groundTiles[i]
            
            // Setting position
            tile.anchorPoint = CGPointMake(0, 1)
            tile.zPosition = 200
            tile.position.x = groundTileWidth * CGFloat(i)
            tile.position.y = groundLine
            
            // Setting physicsBody
            tile.physicsBody = SKPhysicsBody(rectangleOfSize: tile.size)
            tile.physicsBody!.affectedByGravity = false
            tile.physicsBody!.dynamic = false
            tile.physicsBody!.categoryBitMask = ColliderType.Ground.rawValue
            tile.physicsBody!.collisionBitMask = ColliderType.Hero.rawValue & ColliderType.Enemies.rawValue
            tile.physicsBody!.contactTestBitMask = ColliderType.Hero.rawValue & ColliderType.Enemies.rawValue

            //var action = SKAction.moveByX(-groundTileWidth, y: 0, duration: movementSpeed)
            //action = SKAction.repeatAction(action, count: count)
            //tile.runAction(action)
            
            
            addChild(groundTiles[i])
        }
        

    }
    
}
