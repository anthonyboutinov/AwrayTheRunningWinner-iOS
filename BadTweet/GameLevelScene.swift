//
//  GameScene.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/6/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import SpriteKit

private var controlRectSizes = CGFloat(45.0)
private let indices: [Int] = [7, 1, 3, 5, 0, 2, 6, 8]

enum GameOverState {
    case playerHasLost, playerHasWon
}

class GameLevelScene: SKScene {
    
    // MARK: - Variables
    
    // MARK: Level counters
    
    var worldState: WorldStateWithUI?
    
    // MARK: Physics World
    
    private var previousUpdateTime = NSTimeInterval()
    private var gravity = CGPointMake(0.0, -450.0)
    // TODO: For 60fps must be 0.02, current value is for LOW FPS
    private let maxDelta = 0.08
    
    // MARK: UI elements
    
    private var uiUp: SKShapeNode?
    private var uiLeft: SKShapeNode?
    private var uiRight: SKShapeNode?
    
    private let uiPause = SKSpriteNode(imageNamed: "Pause")
    
    private var previouslyTouchedNodes = NSMutableSet()
    
    private let replayTag = 321
    
    
    
    // MARK: Game world entities
    private var player: Player?
    
    // MARK: Map of the level
    
    private var map: JSTileMap?
    private var walls: TMXLayer?
    private var hazards: TMXLayer?
    
    // MARK: - Methods
    
    // MARK: Overridden
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        
        initMap()
        initPlayer()
        initUI()
        worldState!.addChildrenToScene(self)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            for node in self.nodesAtPoint(location) {
                if let shape = node as? SKShapeNode {
                    switch shape {
                    case uiUp!:
                        previouslyTouchedNodes.addObject(uiUp!)
                        player!.mightAsWellJump = true
                    case uiLeft!:
                        previouslyTouchedNodes.addObject(uiLeft!)
                        player!.backwardsMarch = true
                    case uiRight!:
                        previouslyTouchedNodes.addObject(uiRight!)
                        player!.forwardMarch = true
                    default:
                        break
                    }
                } else if let sprite = node as? SKSpriteNode {
                    //...
                }
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        // FIXME: When moving out from uiUp, mightAsWellJump stays true
        
        let currentlyTouchedNodes = NSMutableSet()
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            var right = false
            var left = false
            
            for node in self.nodesAtPoint(location) {
                if let shape = node as? SKShapeNode {
                    switch shape {
                    case uiUp!:
                        currentlyTouchedNodes.addObject(uiUp!)
                        player!.mightAsWellJump = true
                    case uiLeft!:
                        currentlyTouchedNodes.addObject(uiLeft!)
                        left = true
                    case uiRight!:
                        currentlyTouchedNodes.addObject(uiRight!)
                        right = true
                    default:
                        if previouslyTouchedNodes.containsObject(uiUp!) {
                            player!.mightAsWellJump = false
                        }
                        if previouslyTouchedNodes.containsObject(uiLeft!) {
                            player!.backwardsMarch = false
                        }
                        if previouslyTouchedNodes.containsObject(uiRight!) {
                            player!.forwardMarch = false
                        }
                        break
                    }
                    if right {
//                        player!.backwardsMarch = false
                        player!.forwardMarch = true
                    }
                    if !right && left {
                        player!.backwardsMarch = true
//                        player!.forwardMarch = false
                    }
                } else if let sprite = node as? SKSpriteNode {
                    //...
                }
            }
        }
        
        previouslyTouchedNodes = currentlyTouchedNodes
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        let nodesToRemoveFromSet = NSMutableSet()
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            for node in self.nodesAtPoint(location) {
                if let shape = node as? SKShapeNode {
                    switch shape {
                    case uiUp!:
                        nodesToRemoveFromSet.addObject(uiUp!)
                        player!.mightAsWellJump = false
                    case uiLeft!:
                        nodesToRemoveFromSet.addObject(uiLeft!)
                        player!.backwardsMarch = false
                    case uiRight!:
                        nodesToRemoveFromSet.addObject(uiRight!)
                        player!.forwardMarch = false
                    default:
                        break
                    }
                } else if let sprite = node as? SKSpriteNode {
                    //...
                }
            }
            
        }
        
        for object in nodesToRemoveFromSet {
            previouslyTouchedNodes.removeObject(object)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        // Do not perform updates if game is over
        if worldState!.gameOver {
            return
        }
        
        var delta = currentTime - previousUpdateTime
        if delta > maxDelta {
            delta = maxDelta
        }
        
        // TODO: Delete this line when ready to test on real device (LOW FPS)
        delta *= 2.0
        
        previousUpdateTime = currentTime
        player!.update(delta: delta)
        
        checkForAndResolveCollisions(forPlayer: player!, forLayer: walls!)
        handleHazarCollisions(forPlayer: player!)
        checkForWin()
        
        setViewPointCenter(player!.position)
        
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
        map = JSTileMap(named: worldState!.tmxFileName)
        map!.setScale(0.5)
        addChild(map!)
        
        walls = map!.layerNamed("Walls")
        hazards = map!.layerNamed("Hazards")
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
        player.onGround = false
        for i in 0..<indices.count {
            let tileIndex = indices[i]
            
            let playerRect: CGRect = player.collisionBoundingBox
            let playerCoord: CGPoint = layer.coordForPoint(player.desiredPosition)
            
            if playerCoord.y >= map!.mapSize.height - 1 {
                gameOver(.playerHasLost)
                return
            }
            
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
    
    private func handleHazarCollisions(forPlayer player: Player) {
        if worldState!.gameOver {
            return
        }
        
        
        for i in 0..<indices.count {
            let tileIndex = indices[i];
            
            let playerRect = player.collisionBoundingBox
            let playerCoord = hazards!.coordForPoint(player.desiredPosition)
            
            let tileColumn = tileIndex % 3;
            let tileRow = tileIndex / 3;
            let tileCoord = CGPointMake(playerCoord.x + CGFloat(tileColumn - 1), playerCoord.y + CGFloat(tileRow - 1))
            
            let gid = tileGID(atTileCoord: tileCoord, forLayer: hazards!)
            if gid != 0 {
                let tileRect = self.tileRect(fromTileCoord: tileCoord)
                if CGRectIntersectsRect(playerRect, tileRect) {
                    gameOver(.playerHasLost)
                    return
                }
            }
        }
    }
    
    private func setViewPointCenter(position: CGPoint) {
        var x = max(position.x, self.size.width / 2)
        var y = max(position.y, self.size.height / 2)
        x = min(x, (map!.mapSize.width * map!.tileSize.width) - self.size.width / 2)
        y = min(y, (map!.mapSize.height * map!.tileSize.height) - self.size.height / 2)
        // FIXME: Try dividing by map scale
        let actualPosition = CGPointMake(x / 2, y)
        let centerOfView = CGPointMake(self.size.width / 2, self.size.height / 2)
        let viewPoint = CGPointSubtract(centerOfView, actualPosition)
        map!.position = viewPoint
    }
    
    // MARK: Game over
    

    private func gameOver(state: GameOverState) {
        worldState!.gameOver = true
        
        var gameOverText: String?
        var startReplayButtonText: String?
        
        switch state {
        case .playerHasWon:
            gameOverText = "WIN!"
            startReplayButtonText = "Continue"
            
            // Next level
            worldState!.nextLevel()
            
        case .playerHasLost:
            runAction(SKAction.playSoundFileNamed("hurt.wav", waitForCompletion: false))
            
            let numLives = worldState!.numLives - 1
            worldState!.removeChildrenFromScene(scene!)
            worldState!.numLives = numLives
            if numLives == 0 {
                gameOverText = "GAME OVER"
                startReplayButtonText = "Replay"
            } else {
                gameOverText = "You've lost a life"
                startReplayButtonText = "Replay"
            }
            

        }
        println(gameOverText)
        
        // FIXME: The following code is very slow
        
        let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Nueue-Thin")
        gameOverLabel.text = gameOverText!
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPointMake(self.size.width / 2.0, self.size.height / 1.7)
        addChild(gameOverLabel)
        
        let replay = UIButton()
        replay.tag = replayTag;
        replay.setTitle(startReplayButtonText, forState: UIControlState.allZeros)
        replay.addTarget(self, action: Selector("replay"), forControlEvents: UIControlEvents.TouchUpInside)
        replay.frame = CGRectMake(CGRectGetMidX(frame) - 100, CGRectGetMidY(frame) - 24, 200, 48)
        replay.backgroundColor = SKColor(white: 0.4, alpha: 0.6)
        view!.addSubview(replay)
    }
    
    private func checkForWin() {
        if player!.position.x > 20 * 70 {//map!.mapSize.width - 20 {
            gameOver(.playerHasWon)
        }
    }
    
    func replay() {
        view!.viewWithTag(replayTag)!.removeFromSuperview()
        
        // Configure scene
        let scene = GameLevelScene()
        scene.worldState = worldState
        
        presentScene(scene, view!)
        
    }
    
    
}
