//
//  RainFall.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/17/23.
//

import SwiftUI
import SpriteKit

class RainFall: SKScene {
    override func sceneDidLoad() {
        anchorPoint = CGPoint(x: 0.5, y: 1)
        size = UIScreen.main.bounds.size
        scaleMode = .resizeFill
        backgroundColor = .clear
        let node = SKEmitterNode(fileNamed: "RainSprite.sks")!
        addChild(node)
    }
}

class RainFallLanding: SKScene {
    override func sceneDidLoad() {
        anchorPoint = CGPoint(x: 0.5, y: 1)
        size = UIScreen.main.bounds.size
        scaleMode = .resizeFill
        backgroundColor = .clear
        let node = SKEmitterNode(fileNamed: "RainFallingSprite.sks")!
        addChild(node)
        node.particlePositionRange.dy = 50
    }
}
