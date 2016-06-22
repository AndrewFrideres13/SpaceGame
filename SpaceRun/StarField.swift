//
//  StarField.swift
//  SpaceRun
//
//  Created by Frideres, Andrew on 4/26/16.
//  Copyright © 2016 Frideres, Andrew. All rights reserved.
//

import SpriteKit

class StarField: SKNode {
    
    override init() {
        super.init()
        initSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        initSetup()
    }
    
    func initSetup() {
        //Cus we need to call a method on self from inside a code block
        //we must create a weak reference to it. This is what we are doing
        //with our weakSelf constant.
        //
        //Why? The action holds a strong reference to the block and the node
        //holds a strong reference to the action If the block held a strong reference
        //to the node (self), then the action, the block, and the node would
        //form a retain cycle and never get deallocated
        //Memory leak
        let update = SKAction.runBlock {
            [weak self] in
            
            if arc4random_uniform(10) < 6 {
                if let weakSelf = self {
                    weakSelf.launchStar()
                }
            }
        } //End of update
        
        let delay = SKAction.waitForDuration(0.01)
        
        let updateLoop = SKAction.sequence([delay, update])
        
        runAction(SKAction.repeatActionForever(updateLoop))
    }
    
    func launchStar() {
        //Make sure we have a reference to our scene
        if let scene = self.scene {
            
            //Calculate a random start point at top of screen
            let randX = Double(arc4random_uniform(uint(scene.size.width)))
            
            let maxY = Double(scene.size.height)
            
            let randomStart = CGPoint(x: randX, y: maxY)
            
            let star = SKSpriteNode(imageNamed: "shootingStar")
            
            star.position = randomStart
            
            star.alpha = 0.1 + (CGFloat(arc4random_uniform(10)) / 10.0)
            star.size = CGSize(width: 3.0 - star.alpha, height: 8.0 - star.alpha)
            
            //Stack from dimmest to brightest in zAxis
            star.zPosition = -100 + star.alpha * 10
            
            addChild(star)
            
            //Move the star toward bottom of screen using a random duration between 0.1 
            //and 1 sec and removing the star when it passes bottom edge
            
            let destY =  0.0 - scene.size.height - star.size.height
            let duration = Double(-star.alpha + 1.8)
            let move = SKAction.moveByX(0.0, y: destY, duration: duration)
            
            let remove = SKAction.removeFromParent()
            
            star.runAction(SKAction.sequence([move, remove]))
        }
    }
}