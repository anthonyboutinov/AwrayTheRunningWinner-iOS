//
//  DesignElements.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/16/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

let gameFont = "Helvetica-Nueue-Thin"

let blueButtonTexture = SKTexture(imageNamed: "blue_button")
let backButtonTexture = SKTexture(imageNamed: "back_button")

let buttonBottomMargin = CGFloat(5)

let margin = CGFloat(18.0)
let padding = margin / 3

class UIDesigner {
    
    class func insertTextIntoButton(button: SKSpriteNode, _ text: String) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: gameFont)
        label.text = text
        label.position.y -= label.frame.height / 2 - buttonBottomMargin
        button.addChild(label)
        return label
    }
    
    class func layoutButtonsWithText(#scene: SKScene, buttons: [SKSpriteNode], texts: [String], zPosition: CGFloat? = nil, hidden: Bool? = nil) -> [SKLabelNode] {
        assert(buttons.count == texts.count, "Number of buttons is not equal to number of texts")
        
        var labels: [SKLabelNode] = [SKLabelNode]()
        
        let midX = CGRectGetMidX(scene.frame)
        let midY = CGRectGetMidY(scene.frame)
        
        let elementHeight = blueButtonTexture.size().height
        for _i in 0..<buttons.count {
            let button = buttons[_i]
            let i = CGFloat(_i)
            
            button.position = CGPoint(x: midX, y: midY + (CGFloat(Int(buttons.count / 2)) - i) * elementHeight * 1.2)
            
            labels.append(UIDesigner.insertTextIntoButton(button, texts[_i]))
            
            if let zPosition = zPosition {
                button.zPosition = zPosition
            }
            
            if let hidden = hidden {
                button.hidden = hidden
            }
            
            scene.addChild(button)
        }
        return labels
    }
    
    class func addBackButton(scene: SKScene) -> SKSpriteNode {
        let button = SKSpriteNode(texture: backButtonTexture)
        button.position = CGPoint(x: CGRectGetMinX(scene.frame) + margin + button.size.width / 2, y: CGRectGetMaxY(scene.frame) - margin - button.size.height / 2)
        
        scene.addChild(button)
        return button
    }
    
    class func layoutTextTable(texts: [String], _ scene: SKScene, positionOffsetY: CGFloat, margin customMargin: CGFloat = margin, var fontSize: CGFloat? = nil) {
        let minX = CGRectGetMinX(scene.frame) + customMargin
        let midX = CGRectGetMidX(scene.frame)
        let midY = CGRectGetMidY(scene.frame)
        
        // Next line: Relative spacing between lines
        let paddingInPercent = CGFloat(0.05)
        let lowerCoeff = 1 - paddingInPercent
        let upperCoeff = 1 + paddingInPercent
        
        let fitIntoRectOfSize = CGSize(width: minX - CGRectGetMaxX(scene.frame) - customMargin, height: CGRectGetMaxY(scene.frame) - positionOffsetY - customMargin * 2)
        if fontSize == nil {
            fontSize = fitIntoRectOfSize.height / CGFloat(texts.count) * lowerCoeff
        }
        
        let sampleLabel = SKLabelNode(fontNamed: gameFont)
        sampleLabel.fontSize = fontSize!
        sampleLabel.text = "QW,$|`qpd"
        let elementHeight = sampleLabel.frame.height
        
        let coeff = CGFloat(Int(texts.count / 4))
        
        var column = CGFloat(0)
        var titleColumn = true // The first column is called Title Column
        for text in texts {
            
            if text.isEmpty {
                titleColumn = !titleColumn
                if titleColumn {
                    column++
                }
                continue
            }
            
            let label = SKLabelNode(fontNamed: gameFont)
            label.fontSize = fontSize!
            label.text = text
            
            if titleColumn {
                label.position.x = minX + label.frame.width / 2
            } else {
                label.position.x = midX + customMargin / 2 + label.frame.width / 2
            }
            
            label.position.y = midY + (coeff - column) * elementHeight * upperCoeff + positionOffsetY
            
            scene.addChild(label)
            
            titleColumn = !titleColumn
            if titleColumn {
                column++
            }
        }
    }
    
    class func addTitle(text: String, _ scene: SKScene) -> SKLabelNode {
        let title = SKLabelNode(fontNamed: gameFont)
        title.fontSize = 42
        title.text = text
        title.position = CGPoint(x: CGRectGetMidX(scene.frame), y: CGRectGetMaxY(scene.frame) - margin - title.frame.height)
        scene.addChild(title)
        return title
    }
    
}