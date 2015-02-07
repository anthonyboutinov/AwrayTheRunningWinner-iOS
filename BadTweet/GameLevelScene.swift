//
//  GameScene.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/6/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import SpriteKit

private var controlRectSizes = CGFloat(45.0)

class GameLevelScene: SKScene {
    
    // MARK: - Variables
    
    // MARK Physics World
    
    private var previousUpdateTime = NSTimeInterval()
    private var gravity = CGPointMake(0.0, -60.0)
    
    // MARK: UI elements
    
    private var uiUp: SKShapeNode?
    private var uiLeft: SKShapeNode?
    private var uiRight: SKShapeNode?
    
    private let uiPause = SKSpriteNode(imageNamed: "Pause")
    
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
                    case uiUp!:
                        println("up")
                    case uiLeft!:
                        println("left")
                    case uiRight!:
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
        
        // Define some constants
        let edge = CGFloat(18)
        let uiZPosition = CGFloat(50)
        
        // Handle Pause Button
        uiPause.zPosition = uiZPosition
        uiPause.anchorPoint = CGPointMake(1, 1)
        uiPause.position = CGPointMake(CGRectGetMaxX(self.frame) - edge, CGRectGetMaxY(self.frame) - edge)
        addChild(uiPause)
        
        // Compute Sizes
        let controlWidth = self.frame.width * 0.35
        let halfConfrolWidth = controlWidth * 0.5
        let controlHeight = self.frame.height * 0.5
        let halfControlHeight = controlHeight * 0.5
        
        // Init variables
        uiUp = SKShapeNode(rectOfSize: CGSizeMake(controlWidth, self.frame.height - uiPause.size.height - edge * 2))
        uiLeft = SKShapeNode(rectOfSize: CGSizeMake(controlWidth, controlHeight))
        uiRight = SKShapeNode(rectOfSize: CGSizeMake(controlWidth, controlHeight))
        
        // Position them
        uiUp!.position = CGPointMake(self.frame.width - halfConfrolWidth, CGRectGetMidY(self.frame) - edge * 2.5)
        uiLeft!.position = CGPointMake(halfConfrolWidth, CGRectGetMaxY(self.frame) - controlHeight + halfControlHeight)
        uiRight!.position = CGPointMake(halfConfrolWidth, CGRectGetMinY(self.frame) + halfControlHeight)
        
        // Set some other properties and add them on screen
        for shapeNode in [uiUp, uiRight, uiLeft] {
            shapeNode!.zPosition = uiZPosition
            shapeNode!.alpha = 0.0
            addChild(shapeNode!)
        }
        
        

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
            // If gid is not black space
            if gid != 0 {
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
