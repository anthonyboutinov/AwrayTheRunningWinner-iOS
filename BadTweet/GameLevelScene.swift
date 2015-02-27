//
//  GameScene.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/6/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import SpriteKit

let gravity = CGPoint(x: 0.0, y: -450.0)

private var controlRectSizes = CGFloat(45.0)
private let indices: [Int] = [7, 1, 3, 5, 0, 2, 6, 8]

private let hurtSound = SKAction.playSoundFileNamed("hurt.wav", waitForCompletion: false)

class GameLevelScene: SKScene {
    
    // MARK: Enums
    
    // Tile Properties: preset and created during the game
    enum Properties: String {
        case isBouncy = "isBouncy" // The tile bounces when it's hit by the player's head
        case durability = "durability" // How many times the player has to hit this tile with his head in order for it to destroy. Each time tile's ducatility is decreased, it emits something (if it contains anything)
        case contains = "contains" // What the tile contains
        case hasBeenRemovedFromTheView = "r" // Marks that the tile has been removed from the view
        case willAutoRelease = "d" // Marks that the tile will be automatically removed when it finishes doing an action or an animation
    }
    
    enum GameOverState {
        case playerHasLost, playerHasWon
    }
    
    // MARK: Variables
    
    // MARK: Level counters
    
    var worldState: WorldStateWithUI!
    
    // MARK: Physics World
    
    private var previousUpdateTime = NSTimeInterval()
    // TODO: For 60fps must be 0.02, current value is for LOW FPS
    private let maxDelta = 0.03
    
    // MARK: UI elements
    
    private var upButton: SKShapeNode!
    private var leftButton: SKShapeNode!
    private var rightButton: SKShapeNode!
    
    private let pauseButton = SKSpriteNode(imageNamed: "pause")
    
    private var previouslyTouchedNodes = NSMutableSet()
    
    private let gameOverLabel = SKLabelNode(fontNamed: gameFont)
    private let replayButton = SKSpriteNode(texture: blueButtonTexture)
    private let mainMenuButtonNextToReplayButton = SKSpriteNode(texture: blueButtonTexture)
    
    // MARK: Game world entities
    private var player: Player!
    private var updatables: [Updatable] = [Updatable]()
    
    // MARK: Map of the level
    
    private var map: JSTileMap!
    private var walls: TMXLayer!
    private var hazards: TMXLayer!
    private var collidableItems: TMXLayer!
    private var noncollidableItems: TMXLayer!
    
    private var winLine = CGFloat(0)
    
    // MARK: Actions (Animations)
    
    private var bounce: SKAction!
    
    // MARK: Pause Scene
    
    private var dimmer: SKShapeNode!
    private let unpauseButton = SKSpriteNode(texture: blueButtonTexture)
    private let mainMenuButton = SKSpriteNode(texture: blueButtonTexture)
    private let settingsButton = SKSpriteNode(texture: blueButtonTexture)
    private var pauseMenuElements: [SKNode] = [SKNode]()
    
    private var gameIsPaused: Bool = false {
        didSet {
            hidePauseMenu(!self.gameIsPaused)
        }
    }
    
    private var gameOverState: GameOverState = .playerHasWon
    private var gameIsOver: Bool {
        set {
            worldState.gameOver = newValue
            if gameIsOver {
                showGameOverMenu()
            } else {
                hideGameOverMenu()
            }
        }
        get {
            return worldState.gameOver
        }
    }
    
    // MARK: - Methods
    
    // MARK: didMoveToView
    
    override func didMoveToView(view: SKView) {
        initMap()
        initAnimations()
        initPlayer()
        initUI()
        initPauseMenu()
        initGameOverStuff()
        worldState.parentScene = self
        worldState.addChildrenToScene()
    }
    
    // MARK: Touches
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            for node in self.nodesAtPoint(location) as [SKNode] {
                if gameIsPaused {
                    switch node {
                    case unpauseButton:
                        gameIsPaused = false
                    case mainMenuButton:
                        goToTheMainMenuScene()
                    case settingsButton:
                        // TODO: Setting button action
                        break
                    default: break
                    }
                } else if gameIsOver {
                    switch node {
                    case replayButton:
                        replay()
                    case mainMenuButtonNextToReplayButton:
                        goToTheMainMenuScene()
                    default: break
                    }
                } else {
                    switch node {
                    case upButton:
                        previouslyTouchedNodes.addObject(upButton)
                        player.mightAsWellJump = true
                    case leftButton:
                        previouslyTouchedNodes.addObject(leftButton)
                        player.backwardsMarch = true
                    case rightButton:
                        previouslyTouchedNodes.addObject(rightButton)
                        player.forwardMarch = true
                    case pauseButton:
                        gameIsPaused = true
                    default: break
                    }
                }
            }
        }
    }
    
    // FIXME: When moving out from uiUp, mightAsWellJump stays true
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if gameIsPaused || gameIsOver {
            return
        }
        
        // FIXME: Swift 1.2 will have simply Set instead of NSMutableSet
        let currentlyTouchedNodes = NSMutableSet()
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            var right = false
            var left = false
            
            for node in self.nodesAtPoint(location) as [SKNode] {
                if gameIsPaused {
                
                } else {
                    if node is SKShapeNode {
                        switch node {
                        case upButton:
                            currentlyTouchedNodes.addObject(upButton)
                            player.mightAsWellJump = true
                        case leftButton:
                            currentlyTouchedNodes.addObject(leftButton)
                            left = true
                        case rightButton:
                            currentlyTouchedNodes.addObject(rightButton)
                            right = true
                        default:
                            if previouslyTouchedNodes.containsObject(upButton) {
                                player.mightAsWellJump = false
                            }
                            if previouslyTouchedNodes.containsObject(leftButton) {
                                player.backwardsMarch = false
                            }
                            if previouslyTouchedNodes.containsObject(rightButton) {
                                player.forwardMarch = false
                            }
                            break
                        }
                        if right {
                            player.forwardMarch = true
                        }
                        if !right && left {
                            player.backwardsMarch = true
                        }
                    } else if node is SKSpriteNode {
                        //...
                    }
                }
            }
        }
        previouslyTouchedNodes = currentlyTouchedNodes
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if gameIsPaused || gameIsOver {
            return
        }
        
        let nodesToRemoveFromSet = NSMutableSet()
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            for node in self.nodesAtPoint(location) as [SKNode] {
                if node is SKShapeNode {
                    switch node {
                    case upButton:
                        nodesToRemoveFromSet.addObject(upButton)
                        player.mightAsWellJump = false
                    case leftButton:
                        nodesToRemoveFromSet.addObject(leftButton)
                        player.backwardsMarch = false
                    case rightButton:
                        nodesToRemoveFromSet.addObject(rightButton)
                        player.forwardMarch = false
                    default:
                        break
                    }
                } else if node is SKSpriteNode {
                    //...
                }
            }
            
        }
        
        for object in nodesToRemoveFromSet {
            previouslyTouchedNodes.removeObject(object)
        }
    }
    
    // MARK: Initializers
    
    private func initUI() {
        
        // Define some constants
        let edge = CGFloat(18)
        let uiZPosition = CGFloat(50)
        
        // Handle Pause Button
        pauseButton.zPosition = uiZPosition
        pauseButton.anchorPoint = CGPointMake(1, 1)
        pauseButton.position = CGPointMake(CGRectGetMaxX(self.frame) - edge, CGRectGetMaxY(self.frame) - edge)
        addChild(pauseButton)
        
        // Compute Sizes
        let controlWidth = self.frame.width * 0.35
        let halfConfrolWidth = controlWidth * 0.5
        let controlHeight = self.frame.height * 0.5
        let halfControlHeight = controlHeight * 0.5
        
        // Init variables
        upButton = SKShapeNode(rectOfSize: CGSizeMake(controlWidth, self.frame.height - pauseButton.size.height - edge * 2))
        leftButton = SKShapeNode(rectOfSize: CGSizeMake(controlWidth, controlHeight))
        rightButton = SKShapeNode(rectOfSize: CGSizeMake(controlWidth, controlHeight))
        
        // Position them
        upButton!.position = CGPointMake(self.frame.width - halfConfrolWidth, CGRectGetMidY(self.frame) - edge * 2.5)
        leftButton!.position = CGPointMake(halfConfrolWidth, CGRectGetMaxY(self.frame) - controlHeight + halfControlHeight)
        rightButton!.position = CGPointMake(halfConfrolWidth, CGRectGetMinY(self.frame) + halfControlHeight)
        
        // Set some other properties and add them on screen
        for shapeNode in [upButton, rightButton, leftButton] {
            shapeNode.zPosition = uiZPosition
            shapeNode.alpha = 0.0
            addChild(shapeNode)
        }
    }
    
    private func initMap() {
        // Initialize map and add on screen
        map = JSTileMap(named: worldState!.tmxFileName)
        addChild(map)
        
        // Store layers in local properties for faster access
        walls = map.layerNamed("Walls")
        hazards = map.layerNamed("Hazards")
        collidableItems = map.layerNamed("CollidableItems")
        noncollidableItems = map.layerNamed("NoncollidableItems")
        
        // Set rightmost position in pixels after crossing which player is 
        // declared a winner.
        winLine = (map.mapSize.width - 5) * map.tileSize.width
        
        // Set background color from map's property
        self.backgroundColor = SKColor(hex: map.backgroundColor)
    }
    
    private func initPlayer() {
        player = Player(position: CGPoint(x: map.tileSize.width * 5, y: map.tileSize.height * 4))
        map.addChild(player.sprite)
        updatables.append(player)
    }
    
    private func initAnimations() {
        
        // Bounce Action
        let bounceFactor = CGFloat(0.4)
        let dropHeight = CGFloat(10)
        let nDropHeight = CGFloat(-10)
        let dropActoin = SKAction.moveByX(0, y: nDropHeight, duration: 0.3)
        bounce = SKAction.sequence([
            SKAction.moveByX(0, y: dropHeight * bounceFactor, duration: 0.1),
            SKAction.moveByX(0, y: nDropHeight * bounceFactor, duration: 0.1)
            ])
        
    }
    
    private func initPauseMenu() {
        dimmer = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        dimmer.fillColor = SKColor(white: 0.1, alpha: 0.7)
        dimmer.zPosition = 50.0
        dimmer.hidden = true
        addChild(dimmer)
        
        UIDesigner.layoutButtonsWithText(
            scene: self,
            buttons: [unpauseButton, settingsButton, mainMenuButton],
            texts: ["Continue", "Settings", "Main Menu"],
            zPosition: 60.0,
            hidden: true
        )
        
        pauseMenuElements = [dimmer, unpauseButton, mainMenuButton, settingsButton]
    }
    
    private func initGameOverStuff() {
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: self.size.width / 2.0, y: self.size.height / 1.7)
        
        UIDesigner.layoutButtonsWithText(
            scene: self,
            buttons: [replayButton, mainMenuButtonNextToReplayButton],
            texts: ["Replay", "Main Menu"],
            zPosition: 60.0,
            hidden: true
        )
    }
    
    // MARK: Update
    
    override func update(currentTime: CFTimeInterval) {
        // Do not perform updates if game is over
        if worldState.gameOver {
            return
        }
        
        var delta = currentTime - previousUpdateTime
        if delta > maxDelta {
            delta = maxDelta
        }
        
        // FIXME: Delete this line when ready to test on real device (LOW FPS)
        delta *= 2.0
        
        previousUpdateTime = currentTime
        
        // Update player and présent enemies
        for updatable in updatables {
            updatable.update(delta: delta)
        }
        
        interactWithTheWorld()
        checkForWin()
        setViewPointCenter(player.position)
    }
    
    // MARK: Collisions
    
    private func interactWithTheWorld() {
        
        player.onGround = false
        
        for i in 0..<indices.count {
            
            // It is assumed that all layers have the same offset and size properties.
            // So here 'Walls' layer is used, since player's position is the same
            // with respect to all of the layers.
            let playerCoord: CGPoint = walls.coordForPoint(player.desiredPosition)
            // If the player starts to fall through the bottom of the map
            // then it's game over.
            if playerCoord.y >= map.mapSize.height - 1 {
//                gameOver(.playerHasLost)
                gameOverState = .playerHasLost
                gameIsOver = true
                return
            }
            let playerRect: CGRect = player.collisionBoundingBox
            
            let tileIndex = indices[i]
            let tileColumn = tileIndex % 3
            let tileRow = tileIndex / 3
            let tileCoord = CGPoint(
                x: playerCoord.x + CGFloat(tileColumn - 1),
                y: playerCoord.y + CGFloat(tileRow - 1))
            
            checkAndResolveCollisions(layer: walls, tileIndex, tileCoord, playerRect)
            
            if checkIfCollidedWithAHazard(tileCoord, playerRect) {
                return
            }
            
            checkAndResolveCollisions(layer: collidableItems, tileIndex, tileCoord, playerRect)
            
            handleNonCollidableItems(tileCoord, playerRect)
        
        }
        
        // Apply resolved position to the player's sprite
        player.position = player.desiredPosition
    }
    
    private func checkAndResolveCollisions(#layer: TMXLayer, _ tileIndex: Int, _ tileCoord: CGPoint, _ playerRect: CGRect) {
        
        let gid: Int = map.tileGID(atTileCoord: tileCoord, forLayer: layer)
        // If gid is not black space
        if gid != 0 {
            let tileRect = map.tileRect(fromTileCoord: tileCoord)
            
            // Collision resolution
            if CGRectIntersectsRect(playerRect, tileRect) {
                let intersection = CGRectIntersection(playerRect, tileRect)
                if (tileIndex == 7) {
                    
                    // Tile is directly below the player
                    player.desiredPosition.y += intersection.size.height
                    player.velocity.y = 0.0
                    player.onGround = true
                    
                } else if (tileIndex == 1) {
                    
                    // Tile is directly above the player
                    player.desiredPosition.y -= intersection.size.height
                    
                    if layer == collidableItems {
                        handleItemsCollisions(tileCoord, gid)
                    } else {
                         bounceTileIfItHasBouncingProperty(layer.tileAtCoord(tileCoord), gid)
                    }
                    
                } else if (tileIndex == 3) {
                    
                    // Tile is left of the player
                    player.desiredPosition.x += intersection.size.width
                    
                } else if (tileIndex == 5) {
                    
                    // Tile is right of the player
                    player.desiredPosition.x -= intersection.size.width
                    
                } else if (intersection.size.width > intersection.size.height) {
                    
                    // Tile is diagonal, but resolving collision vertically
                    player.velocity.y = 0.0
                    var intersectionHeight = CGFloat(0)
                    if (tileIndex > 4) {
                        intersectionHeight = intersection.size.height
                        player.onGround = true
                    } else {
                        intersectionHeight = -intersection.size.height
                    }
                    player.desiredPosition.y += intersection.size.height
                    
                } else {
                    
                    // Tile is diagonal, but resolving horizontally
                    var intersectionWidth = CGFloat(0)
                    if (tileIndex == 6 || tileIndex == 0) {
                        intersectionWidth = intersection.size.width
                    } else {
                        intersectionWidth = -intersection.size.width
                    }
                    player.desiredPosition.x += intersectionWidth
                }
            }
        }
    
    }

    private func checkIfCollidedWithAHazard(tileCoord: CGPoint, _ playerRect: CGRect) -> Bool {
        let gid = map.tileGID(atTileCoord: tileCoord, forLayer: hazards)
        if gid != 0 {
            let tileRect = map.tileRect(fromTileCoord: tileCoord)
            if CGRectIntersectsRect(playerRect, tileRect) {
//                gameOver(.playerHasLost)
                gameOverState = .playerHasLost
                gameIsOver = true
                return true
            }
        }
        return false
    }
    
    private func handleNonCollidableItems(tileCoord: CGPoint, _ playerRect: CGRect) {
        let gid = map.tileGID(atTileCoord: tileCoord, forLayer: noncollidableItems)
        if gid != 0 {
            let tile = noncollidableItems.tileAtCoord(tileCoord)
            
            // If tile has been removed from the view,
            if let _ = tile.userData?[Properties.hasBeenRemovedFromTheView.rawValue] {
                // Then skip it.
                return
            }
            
            let tileRect = map.tileRect(fromTileCoord: tileCoord)
            if CGRectIntersectsRect(playerRect, tileRect) {
                if let properties = map.properties(forGID: gid) {
                    checkContainsPropertyOfATile(properties)
                }
                
                // Add flag to the tile
                tile.userData = [Properties.hasBeenRemovedFromTheView.rawValue:true]
                tile.removeFromParent()
                
            }
        }
    }
    
    private func handleItemsCollisions(tileCoord: CGPoint, _ gid: Int) {
        let layer = collidableItems
        
        // Tile is directly above the player
        let tile = layer.tileAtCoord(tileCoord)
        
        if let properties = tile!.userData {
            // Optimized and personalized properties
            
            // WARNING: When editing this, remember to write an adoptation of it
            // for the non-optimized properties below
            
            // Return if the tile has 'willAutoRelease' property
            if let _ = properties[Properties.willAutoRelease.rawValue] {
                return
            }
            
            if var durability = properties[Properties.durability.rawValue] as? Int {
                handleDurability(durability, properties, layer, tileCoord, tile)
            }
            if checkContainsPropertyOfATile(properties) {
                return
            }
            
        } else if let properties: NSMutableDictionary = map.tileProperties[NSInteger(gid)] as? NSMutableDictionary {
            // Non-optimized and non-personalized properties
            
            // WARNING: When editing this, remember to write an adoptation of it
            // for the optimized properties above
            
            // Save a copy to tile's userData and edit it
            tile!.userData = properties
            
            if var durability = (properties[Properties.durability.rawValue] as? String)?.toInt()? {
                handleDurability(durability, properties, layer, tileCoord, tile)
            }
            if checkContainsPropertyOfATile(properties) {
                return
            }
        }
    }
    
    private func handleDurability(var durability: Int, _ properties: NSMutableDictionary, _ layer: TMXLayer, _ tileCoord: CGPoint, _ tile: SKSpriteNode) {
        durability--
        player.velocity.y = 0.0
        if durability < 1 {
            // Remove tile after optional bounce animation
            if let _ = properties[Properties.isBouncy.rawValue] {
                tile.runAction(bounce, completion: {layer.removeTileAtCoord(tileCoord)})
                properties[Properties.willAutoRelease.rawValue] = true
            } else {
                layer.removeTileAtCoord(tileCoord)
            }
            // Don't bother updating durability value if it's going to be removed anyway
        } else {
            // Here: update the value
            properties[Properties.durability.rawValue] = durability
            // Bounce
            if let _ = properties[Properties.isBouncy.rawValue] {
                tile.runAction(bounce)
            }
        }
    }
    
    private func checkContainsPropertyOfATile(properties: NSMutableDictionary) -> Bool {
        if let contains = properties["contains"] as? String {
            switch contains {
            case "coin":
                worldState!.numCoins++
            case "powerUp":
                player.applyPowerUp()
            default:
                break
            }
            return true
        }
        return false
    }
    
    private func setViewPointCenter(position: CGPoint) {
        var x = max(position.x, self.size.width / 2)
        var y = max(position.y, self.size.height / 2)
        x = min(x, (map.mapSize.width * map.tileSize.width) - self.size.width / 2)
        y = min(y, (map.mapSize.height * map.tileSize.height) - self.size.height / 2)
        let actualPosition = CGPoint(x: x, y: y)
        let centerOfView = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        let viewPoint = CGPointSubtract(centerOfView, actualPosition)
        map.position = viewPoint
    }
    
    private func bounceTileIfItHasBouncingProperty(tile: SKSpriteNode, _ gid: Int) {
        if let _ = map.properties(forGID: gid)?[Properties.isBouncy.rawValue] {
            tile.runAction(bounce)
        }
    }
    
    // MARK: Game over
    
    private func showGameOverMenu() {
        
        // FIXME: gameOverLabel does not show up
        for node in [gameOverLabel, replayButton, mainMenuButtonNextToReplayButton] {
            node.hidden = false
        }
        
        switch gameOverState {
            
        case .playerHasWon:
            gameOverLabel.text = "You Won!"
            
        case .playerHasLost:
            if Sound_soundEffects {
                runAction(hurtSound)
            }
            // Next line: this means "if numLives == 1 before subtracting one."
            // This construction is required because numLives never reaches 0.
            // Instead, worldState is reset at that point.
            if worldState.numLives-- == 1 {
                gameOverLabel.text = "GAME OVER"
            } else {
                gameOverLabel.text = "You've lost a life"
            }
            
        }
    }
    
    private func hideGameOverMenu() {
        
        for node in [gameOverLabel, replayButton, mainMenuButtonNextToReplayButton] {
            node.hidden = true
        }
    }
    
//    private func gameOver(state: GameOverState) {
//        worldState.gameOver = true
//        
//        var gameOverText: String!
//        var startReplayButtonText: String!
//        
//        switch state {
//        case .playerHasWon:
//            gameOverText = "WIN!"
//            startReplayButtonText = "Continue"
//            
//            // Advance to the next level
//            worldState.advanceToTheNextLevel()
//            
//        case .playerHasLost:
//            if Sound_soundEffects {
//                runAction(hurtSound)
//            }
//            
//            // Next line: this means "if numLives == 1 before subtracting one."
//            // This construction is required because numLives never reaches 0.
//            // Instead, worldState is reset at that point.
//            if worldState.numLives-- == 1 {
//                gameOverText = "GAME OVER"
//            } else {
//                gameOverText = "You've lost a life"
//            }
//            startReplayButtonText = "Replay"
//
//        }
//        println(gameOverText)
//        
//        gameOverLabel.text = gameOverText
//        addChild(gameOverLabel)
//    }
    
    private func checkForWin() {
        if player.position.x > winLine {
//            gameOver(.playerHasWon)
            gameOverState = .playerHasWon
            gameIsOver = true
        }
    }
    
    private func replay() {
        worldState!.gameOver = false
        
        // Configure scene
        let scene = GameLevelScene()
        scene.worldState = worldState
        scene.worldState.parentScene = scene
        
        presentScene(scene, view!)
    }
    
    // MARK: - Pause Menu
    
    private func hidePauseMenu(hidden: Bool) {
        paused = !hidden
        for element in pauseMenuElements {
            element.hidden = hidden
        }
        pauseButton.hidden = !hidden
    }
    
    private func goToTheMainMenuScene() {
        presentScene(MainMenuScene(), view!)
    }
    
}
