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
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        
        let lowerLeftPoint = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame))
        
        uiControllerImage.userInteractionEnabled = false
        uiControllerImage.zPosition = 1000
        uiControllerImage.anchorPoint = CGPointMake(0, 0)
        uiControllerImage.position = CGPointMake(lowerLeftPoint.x + 20, lowerLeftPoint.y + 20)
        addChild(uiControllerImage)
        
        let UDLR_zPosition = uiControllerImage.zPosition + 1
        let UDLR_position = CGPointMake(uiControllerImage.position.x + 18, uiControllerImage.position.y  + 19)
        
//        uiUp.strokeColor = SKColor.blueColor()
        uiUp.name = "up"
        uiUp.zPosition = UDLR_zPosition
        uiUp.position = CGPointMake(
            UDLR_position.x + controlRectSizes,
            UDLR_position.y + controlRectSizes * 2)
        addChild(uiUp)
        
//        uiDown.strokeColor = SKColor.blueColor()
        uiDown.zPosition = UDLR_zPosition
        uiDown.position = CGPointMake(
            UDLR_position.x + controlRectSizes,
            UDLR_position.y)
        addChild(uiDown)
        
//        uiLeft.strokeColor = SKColor.blueColor()
        uiLeft.zPosition = UDLR_zPosition
        uiLeft.position = CGPointMake(
            UDLR_position.x,
            UDLR_position.y + controlRectSizes)
        addChild(uiLeft)
        
//        uiRight.strokeColor = SKColor.blueColor()
        uiRight.zPosition = UDLR_zPosition
        uiRight.position = CGPointMake(
            UDLR_position.x + controlRectSizes * 2,
            UDLR_position.y + controlRectSizes)
        addChild(uiRight)
        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            for node in self.nodesAtPoint(location) {
                if let sprite = node as? SKSpriteNode {
                    if sprite == uiUp {
                        println("up")
                    }
                    
                    if sprite.name == uiUp.name {
                        println("up name")
                    }
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
}
