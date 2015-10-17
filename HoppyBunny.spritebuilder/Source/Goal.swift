//
//  Goal.swift
//  HoppyBunny
//
//  Created by Daniele Scochet on 13/10/15.
//  Copyright © 2015 Masca Labs di Daniele Scochet. All rights reserved.
//

import Foundation

class Goal: CCNode {
    func didLoadFromCCB() {
        physicsBody.sensor = true
    }
}