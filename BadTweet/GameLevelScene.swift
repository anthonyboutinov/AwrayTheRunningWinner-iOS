//
//  GameScene.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/6/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import SpriteKit

private let controlRectSizes = CGFloat(45.0)

class GameLevelScene: SKScene {
    
    // MARK: - Variables
    
    // MARK Physics World
    
    private var previousUpdateTime = NSTimeInterval()
    private var gravity = CGPointMake(0.0, -45.0)
    
    // MARK: UI elements
    
    private let uiControllerImage = SKSpriteNode(imageNamed: "Controller")
    private let uiUp = SKShapeNode(rectOfSize: CGSizeMake(controlRectSizes, controlRectSizes))
    private let uiDown = SKShapeNode(rectOfSize: CGSizeMake(controlRectSizes, controlRectSizes))
    private let uiLeft = SKShapeNode(rectOfSize: CGSizeMake(controlRectSizes, controlRectSizes))
    private let uiRight = SKShapeNode(rectOfSize: CGSizeMake(controlRectSizes, controlRectSizes))
    
    private let uiPower = SKSpriteNode(imageNamed: "power")
    private let uiPause = SKSpriteNode(imageNamed: "pause")
    
    // MARK: Game world entities
    private var player: Player?
    
    // MARK: Map of the level
    
    private var map: JSTileMap?
    private var walls: TMXLayer?
    
    // MARK: - Methods
    // MARK: Overridden
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        //self.anchorPoint = CGPointMake(0, 1)
        
        //self.physicsWorld.gravity = CGVectorMake(0.0, -9.8)
        
        initMap()
        initPlayer()
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
        
        var delta = currentTime - previousUpdateTime
        if delta > 0.02 {
            delta = 0.02
        }
        
        previousUpdateTime = currentTime
        player!.update(delta: delta)
        
        checkForAndResolveCollisions(forPlayer: player!, forLayer: walls!)
        
    }
    
    // MARK: Initializers
    
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
    
    private func initMap() {
        map = JSTileMap(named: "Level1.tmx")
        map!.setScale(0.5)
        addChild(map!)
        
        walls = map!.layerNamed("Walls")
    }
    
    private func initPlayer() {
        player = Player(gravity: gravity, position: CGPointMake(map!.tileSize.width * 5, map!.tileSize.height * 4))
        map!.addChild(player!.sprite)
    }
    
    // MARK: Physics World methods
    
    private func tileRect(fromTileCoord tileCoord: CGPoint) -> CGRect {
        let levelHeightInPixels = map!.mapSize.height * map!.tileSize.height
        let origin = CGPointMake(tileCoord.x * map!.tileSize.width, levelHeightInPixels - ((tileCoord.y + 1) * map!.tileSize.height))
//        let origin = CGPointMake(tileCoord.x * map!.tileSize.width,  (tileCoord.y * map!.tileSize.height))

        return CGRectMake(origin.x, origin.y, map!.tileSize.width, map!.tileSize.height)
    }
    
    private func tileGID(atTileCoord coord: CGPoint, forLayer layer: TMXLayer) -> Int {
        return layer.layerInfo.tileGidAtCoord(coord)
    }
    
    private func checkForAndResolveCollisions(forPlayer player: Player, forLayer layer: TMXLayer) {
        let indices: [Int] = [7, 1, 3, 5, 0, 2, 6, 8]
        player.onGround = false
        for i in 0..<indices.count {
            let tileIndex = indices[i]
            
            let playerRect: CGRect = player.collisionBoundingBox
            let playerCoord: CGPoint = layer.coordForPoint(player.desiredPosition)
            
            let tileColumn = tileIndex % 3
            let tileRow = tileIndex / 3
            let tileCoord = CGPointMake(playerCoord.x + CGFloat(tileColumn - 1), playerCoord.y + CGFloat(tileRow - 1))
            
            let gid = tileGID(atTileCoord: tileCoord, forLayer: layer)
            if gid != 0 { // if gid is not black space
                let tileRect = self.tileRect(fromTileCoord: tileCoord)
//                println("GID \(gid), TileCoord \(tileCoord), TileRect \(tileRect), PlayerRect \(playerRect)")
                
                // Collision resolution goes here
                if CGRectIntersectsRect(playerRect, tileRect) {
                    let intersection = CGRectIntersection(playerRect, tileRect)
                    //2
                    if (tileIndex == 7) {
                        //tile is directly below the player
                        player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height)
                        player.velocity = CGPointMake(player.velocity.x, 0.0)
                        player.onGround = true
                    } else if (tileIndex == 1) {
                        //tile is directly above the player
                        player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y - intersection.size.height)
                    } else if (tileIndex == 3) {
                        //tile is left of the player
                        player.desiredPosition = CGPointMake(player.desiredPosition.x + intersection.size.width, player.desiredPosition.y)
                    } else if (tileIndex == 5) {
                        //tile is right of the player
                        player.desiredPosition = CGPointMake(player.desiredPosition.x - intersection.size.width, player.desiredPosition.y)
                        //3
                    } else {
                        if (intersection.size.width > intersection.size.height) {
                            //tile is diagonal, but resolving collision vertically
                            //4
                            player.velocity = CGPointMake(player.velocity.x, 0.0)
                            var intersectionHeight = CGFloat(0)
                            if (tileIndex > 4) {
                                intersectionHeight = intersection.size.height
                                player.onGround = true
                            } else {
                                intersectionHeight = -intersection.size.height
                            }
                            player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height )
                        } else {
                            //tile is diagonal, but resolving horizontally
                            var intersectionWidth = CGFloat(0)
                            if (tileIndex == 6 || tileIndex == 0) {
                                intersectionWidth = intersection.size.width
                            } else {
                                intersectionWidth = -intersection.size.width
                            }
                            player.desiredPosition = CGPointMake(player.desiredPosition.x  + intersectionWidth, player.desiredPosition.y)
                        }
                    }
                }
            }
        }
        //5
        player.position = player.desiredPosition
    }
}
