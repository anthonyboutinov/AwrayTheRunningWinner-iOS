//
//  CGExtinsionFormulas.swift
//  BadTweet
//
//  Created by Anthony Boutinov on 2/8/15.
//  Copyright (c) 2015 Anthony Boutinov. All rights reserved.
//

import Foundation

// Extends CGPoint manipulations

// Multiplies CGPoint's values by CGFloat
func CGPointMultiplyScalar(var point: CGPoint, float: CGFloat) -> CGPoint {
    point.x *= float
    point.y *= float
    return point
}

// Adds two CGPoints
func CGPointAdd(var a: CGPoint, b: CGPoint) -> CGPoint {
    a.x += b.x
    a.y += b.y
    return a
}

// Subtracts two CGPoints
func CGPointSubtract(var a: CGPoint, b: CGPoint) -> CGPoint {
    a.x -= b.x
    a.y -= b.y
    return a
}

// Ensures that a scalar value stays with the range [min..max], inclusive
func Clamp(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    return value < min ? min : value > max ? max : value;
}