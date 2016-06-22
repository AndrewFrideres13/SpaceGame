//
//  HUDNode.swift
//  SpaceRun
//
//  Created by Frideres, Andrew on 4/28/16.
//  Copyright © 2016 Frideres, Andrew. All rights reserved.
//

import SpriteKit

//
//Create a HUD that will hold all of our display areas
// Once its added to the scene we'll tell it to lay out its child nodes
//The child nodes will not contain labels as we will use the blank nodes
// as group containers and lay out the label nodes inside of them.
//Left align score and right align elapsed game time
//
class HUDNode: SKNode {
    //Build 2 parent nodes as groups to hold the core and elapsed time
    //Each group will have a title and value label
    
    //Class props
    private let ScoreGroupName = "scoreGroup"
    private let ScoreValueName = "scoreValue"
    private let HealthGroupName = "healthGroup"
    private let HealthValueName = "healthValue"
    
    private let ElapsedGroupName = "elapsedGroup"
    private let ElapsedValueName = "elapsedValue"
    private let TimerActionName = "elapsedGameTimer"
    
    private let PowerupGroupName = "powerupGroup"
    private let PowerupValueName = "powerupValue"
    private let PowerupTimerActionName = "powerupGameTimer"

    
    var elapsedTime: NSTimeInterval = 0.0
    var score: Int = 0
    var lives: Int = 2
    
    lazy private var scoreFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()
    
    lazy private var timeFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    //Class initializer
    override init() {
        super.init()
        
        //Build an empty SKNode as our containing group and name it
        //scoreGroup so we can get a reference to itlater from
        //the scene graph using this name
        let scoreGroup = SKNode()
        scoreGroup.name = ScoreGroupName
        
        //Score Title setup
        //Create an SKLabelNode
        let scoreTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        scoreTitle.fontSize = 12.0
        scoreTitle.fontColor = SKColor.whiteColor()
        
        //Set the vertical and horizontal align modes in a way that will help lay out the labels in the group node
        scoreTitle.horizontalAlignmentMode = .Left
        scoreTitle.verticalAlignmentMode = .Bottom
        scoreTitle.text = "SCORE:"
        scoreTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        scoreGroup.addChild(scoreTitle)
        
        //Child nodes are positioned relative to the parent nodes origin
        
        //Score value setup
        let scoreValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreValue.fontSize = 20.0
        scoreValue.fontColor = SKColor.whiteColor()
        
        //Set the vertical and horizontal align modes in a way that will help lay out the labels in the group node
        scoreValue.horizontalAlignmentMode = .Left
        scoreValue.verticalAlignmentMode = .Top
        scoreValue.name = ScoreValueName
        scoreValue.text = "0"
        scoreValue.position = CGPoint(x: 0.0, y: -4.0)
        
        scoreGroup.addChild(scoreValue)
        
        //Add score group to scene
        addChild(scoreGroup)
        
        //Elapsed time group
        let elapsedGroup = SKNode()
        elapsedGroup.name = ElapsedGroupName
        
        let elapsedTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        elapsedTitle.fontSize = 12.0
        elapsedTitle.fontColor = SKColor.whiteColor()
        
        //Set the vertical and horizontal align modes in a way that will help lay out the labels in the group node
        elapsedTitle.horizontalAlignmentMode = .Right
        elapsedTitle.verticalAlignmentMode = .Bottom
        elapsedTitle.text = "TIME:"
        elapsedTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        elapsedGroup.addChild(elapsedTitle)
        
        //Child nodes are positioned relative to the parent nodes origin
        
        //Time value setup
        let elapsedValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        elapsedValue.fontSize = 20.0
        elapsedValue.fontColor = SKColor.whiteColor()
        
        //Set the vertical and horizontal align modes in a way that will help lay out the labels in the group node
        elapsedValue.horizontalAlignmentMode = .Right
        elapsedValue.verticalAlignmentMode = .Top
        elapsedValue.name = ElapsedValueName
        elapsedValue.text = "0.0s"
        elapsedValue.position = CGPoint(x: 0.0, y: -4.0)
        
        elapsedGroup.addChild(elapsedValue)
        
        //Add time group to scene
        addChild(elapsedGroup)

        
        //Elapsed time group
        let healthGroup = SKNode()
        healthGroup.name = HealthGroupName
        
        //Child nodes are positioned relative to the parent nodes origin
        let healthTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        healthTitle.fontSize = 14.0
        healthTitle.fontColor = SKColor.whiteColor()
        
        //Set the vertical align mode in a way that will help lay out the labels in the group node
        healthTitle.horizontalAlignmentMode = .Right
        healthTitle.verticalAlignmentMode = .Bottom
        healthTitle.text = "Lives Left"
        healthTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        healthGroup.addChild(healthTitle)
        
        //Time value setup
        let healthValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        healthValue.fontSize = 20.0
        healthValue.fontColor = SKColor.whiteColor()
        
        //Set the vertical and horizontal align modes in a way that will help lay out the labels in the group node
        healthValue.horizontalAlignmentMode = .Left
        healthValue.verticalAlignmentMode = .Bottom
        healthValue.name = HealthValueName
        healthValue.text = "2"
        healthValue.position = CGPoint(x: 2.0, y: 2.0)
        
        healthGroup.addChild(healthValue)
        
        //Add time group to scene
        addChild(healthGroup)

        
        //Weaps powerup group
        let powerupGroup = SKNode()
        powerupGroup.name = PowerupGroupName
        
        let powerupTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        powerupTitle.fontSize = 14.0
        powerupTitle.fontColor = SKColor.redColor()
        
        //Set the vertical align mode in a way that will help lay out the labels in the group node
        powerupTitle.verticalAlignmentMode = .Bottom
        powerupTitle.text = "Power-up!"
        powerupTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        //Setup actions to make our powerup timer pulse
        let scaleUp = SKAction.scaleTo(1.3, duration: 0.3)
        let scaleDown = SKAction.scaleTo(1.0, duration: 0.3)
        
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        
        powerupTitle.runAction(SKAction.repeatActionForever(pulse))
        
        powerupGroup.addChild(powerupTitle)
        
        //Child nodes are positioned relative to the parent nodes origin
        
        //Powerup value setup
        let powerupValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        powerupValue.fontSize = 20.0
        powerupValue.fontColor = SKColor.redColor()
        
        //Set the vertical and horizontal align modes in a way that will help lay out the labels in the group node
        powerupValue.verticalAlignmentMode = .Top
        powerupValue.name = PowerupValueName
        powerupValue.text = "0s left"
        powerupValue.position = CGPoint(x: 0.0, y: -4.0)
        
        powerupGroup.addChild(powerupValue)
        
        //Add time group to scene
        addChild(powerupGroup)

        powerupGroup.alpha = 0.0 //make it invisible to start
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Our labels are properly layed out within their parent group
    //but the group nodes are centered on the screen We need to create 
    //some layout method so that these group nodes are properly aligned
    
    func layoutForScene() {
        // Note: When a node exists in the scene graph, it can get access to the scene
        //via its scene property
        if let scene = scene {
            let sceneSize = scene.size
            //this will be used to calculate position of each group
            
            var groupSize = CGSizeZero
            
            if let scoreGroup = childNodeWithName(ScoreGroupName) {
                groupSize = scoreGroup.calculateAccumulatedFrame().size
                
                scoreGroup.position = CGPoint(x: 0.0 - sceneSize.width/2.0 + 20.0, y: sceneSize.height/2.0 - groupSize.height)
            } else {
                assert(false, "No score group node was found in the Scene Graph Tree")
            }
            
            if let healthGroup = childNodeWithName(HealthGroupName) {
                groupSize = healthGroup.calculateAccumulatedFrame().size
                
                healthGroup.position = CGPoint(x: 240.0 - sceneSize.width/2.0, y: sceneSize.height/2.0 - groupSize.height - 10.0)
            } else {
                assert(false, "No score group node was found in the Scene Graph Tree")
            }
        
        
            if let elapsedGroup = childNodeWithName(ElapsedGroupName) {
                groupSize = elapsedGroup.calculateAccumulatedFrame().size
                
                elapsedGroup.position = CGPoint(x: sceneSize.width/2.0 - 20.0, y: sceneSize.height/2.0 - groupSize.height)
            } else {
                assert(false, "No elapsed group node was found in the Scene Graph Tree")
            } //End elapsed time
            
            
            if let powerupGroup = childNodeWithName(PowerupGroupName) {
                groupSize = powerupGroup.calculateAccumulatedFrame().size
                
                powerupGroup.position = CGPoint(x: 0.0, y: sceneSize.height/2.0 - groupSize.height - 20)
            } else {
                assert(false, "No powerup group node was found in the Scene Graph Tree")
            } //End powerup
        }
    }
    
    //Show our weaps powerup timer
    func showPowerupTimer(time: NSTimeInterval) {
        //Lookup our PowerupGroup by name
        if let powerupGroup = childNodeWithName(PowerupGroupName) {
            
            //Remove any existing action w/ the following key
            //because we want to restart the timer
            powerupGroup.removeActionForKey(PowerupTimerActionName)
            
            //Lookup the power value by name
            if let powerupValue = powerupGroup.childNodeWithName(PowerupValueName) as! SKLabelNode? {
                //Run the countdown sequence te action will repeat itself every 0.05s in order to update text in the
                //powerupValue label
                //
                //Reuse the self.timeFormatter so we need to use a weak reference to self to ensure the block
                //does not retain self else MEMORY LEAK
                let start = NSDate.timeIntervalSinceReferenceDate()
                
                let block = SKAction.runBlock {
                    [weak self] in
                    
                    if let weakSelf = self {
                        let elapsedTime = NSDate.timeIntervalSinceReferenceDate() - start
                        let timeLeft = max(time - elapsedTime, 0)
                        
                        let timeLeftFormat = weakSelf.timeFormatter.stringFromNumber(timeLeft)!
                        powerupValue.text = "\(timeLeftFormat)"
                        
                    }
                } //End block
                let countDownSequence = SKAction.sequence([block, SKAction.waitForDuration(0.05)])
                let countDown = SKAction.repeatActionForever(countDownSequence)
                
                let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.1)
                let wait = SKAction.waitForDuration(time)
                let fadeOut = SKAction.fadeAlphaTo(0.0, duration: 1.0)
                
                let stopAction = SKAction.runBlock({ () -> Void in
                    powerupGroup.removeActionForKey(self.PowerupTimerActionName)
                
                })
                
                let visuals = SKAction.sequence([fadeIn, wait, fadeOut, stopAction])
                
                powerupGroup.runAction(SKAction.group([countDown, visuals]), withKey: self.PowerupTimerActionName)
                
            }
        }
    }
    
    func addHealth(health: Int) {
        if lives < 5 {
          lives +=  health
        }
        
        //Lookup score value label in scene graph by name
        if let healthValue = childNodeWithName("\(HealthGroupName)/\(HealthValueName)") as! SKLabelNode? {
            healthValue.text = scoreFormatter.stringFromNumber(lives)
            
            //Scale the node up for a brief period and scale it back down
            let scale = SKAction.scaleTo(1.5, duration: 0.02)
            let shrink = SKAction.scaleTo(1.0, duration: 0.07)
            
            healthValue.runAction(SKAction.sequence([scale, shrink]))
        }
    }
    
    func addPoints(points: Int) {
        score += points
        
        //Lookup score value label in scene graph by name
        if let scoreValue = childNodeWithName("\(ScoreGroupName)/\(ScoreValueName)") as! SKLabelNode? {
            //Format our score with the thousands seperator so here is where
            //we will use our cached self.scoreFormatter prop
            scoreValue.text = scoreFormatter.stringFromNumber(score)
            
            //Scale the node up for a brief period and scale it back down
            let scale = SKAction.scaleTo(1.1, duration: 0.02)
            let shrink = SKAction.scaleTo(1.0, duration: 0.07)
            
            scoreValue.runAction(SKAction.sequence([scale, shrink]))
            
        }
    }
    
    func startGame() {
        //Calculate time stamp when starting game
        let startTime = NSDate.timeIntervalSinceReferenceDate()
        
        if let elapsedValue = childNodeWithName("\(ElapsedGroupName)/\(ElapsedValueName)") as! SKLabelNode? {
            //use code block to update the elapsed time prop
            //set to be the difference between the start time and the current timestamp
            let update = SKAction.runBlock({
                [weak self] in
                
                if let weakSelf = self {
                    let currentTime = NSDate.timeIntervalSinceReferenceDate()
                    
                    let elapsedTime = currentTime - startTime
                    
                    weakSelf.elapsedTime = elapsedTime
                    
                    elapsedValue.text = weakSelf.timeFormatter.stringFromNumber(elapsedTime)
                }
                
            })
            
            let updateAndDelay = SKAction.sequence([update, SKAction.waitForDuration(0.05)])
            
            let timer = SKAction.repeatActionForever(updateAndDelay)
            
            runAction(timer, withKey:  TimerActionName)
            
        }
    }
    
    func endGame() {
        
        //Stop the timer sequence
        removeActionForKey(TimerActionName)
        
        //If the game ends remove weapons power up to to be sure
        if let powerupGroup = childNodeWithName(PowerupGroupName) {
            powerupGroup.removeActionForKey(PowerupTimerActionName)
            powerupGroup.runAction(SKAction.fadeAlphaTo(0.0, duration: 0.3))
        }
        
        
    }
}