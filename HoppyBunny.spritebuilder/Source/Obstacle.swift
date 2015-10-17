//
//  Obstacle.swift
//  HoppyBunny
//
//  Created by Daniele Scochet on 13/10/15.
//  Copyright © 2015 Masca Labs di Daniele Scochet. All rights reserved.
//

import Foundation

class Obstacle : CCNode {
    // definiamo prima le code connections per la carrot
    weak var topCarrot : CCNode!
    weak var bottomCarrot : CCNode!
    
    // costanti
    let topCarrotMinimumPositionY : CGFloat = 128
    let bottomCarrotMaximumPositionY : CGFloat = 440
    let carrotDistance : CGFloat = 142                  // spazio verticale tra le carote top e bottom
    
    func setupRandomPosition() {
        let randomPrecision : UInt32 = 100
        let random = CGFloat(arc4random_uniform(randomPrecision)) / CGFloat(randomPrecision)
        let range = bottomCarrotMaximumPositionY - carrotDistance - topCarrotMinimumPositionY
        topCarrot.position = ccp(topCarrot.position.x, topCarrotMinimumPositionY + (random * range))
        bottomCarrot.position = ccp(bottomCarrot.position.x, topCarrot.position.y + carrotDistance)
    }
    
    func didLoadFromCCB() {
        topCarrot.physicsBody.sensor = true
        bottomCarrot.physicsBody.sensor = true
        /*
            This changes the carrot's physics bodies to sensors. Setting the sensor value to true tells Chipmunk no actual collision feedback should be calculated, meaning the collision callback method does run but sensors will always allow the colliding objects to pass through the collision.
            You don't need an actual collision here because just touching an obstacle means instant death.
*/
    }
}
