//
//  GameScene.swift
//  SpaceRun
//
//  Created by Frideres, Andrew on 4/19/16.
//  Copyright (c) 2016 Frideres, Andrew. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    //Class Properties
    private let SpaceshipNodeName = "ship"
    private let HealthPowerUpNodeName = "healthPowerUp"
    private let PhotonTorpedoNodeName = "photon"
    private let ObstacleNodeName = "obstacle"
    private let PowerupNodeName = "powerup"
    private let HUDNodeName = "hud"
    
    //Properties for sound actions We will preload our sounds
    //into these properties
    private let shootSound: SKAction = SKAction.playSoundFileNamed("laserShot.wav", waitForCompletion: false)
    private let obstacleExplodeSound: SKAction = SKAction.playSoundFileNamed("darkExplosion.wav", waitForCompletion: false)
    private let shipExplodeSound: SKAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    private weak var shipTouch: UITouch?
    private var lastUpdateTime: NSTimeInterval = 0
    private var lastShotFireTime: NSTimeInterval = 0
    private let defaultFireRate: Double = 0.5
    private var shipFireRate: Double = 0.5
    private let powerUpDuration:NSTimeInterval = 5.0
    private var shipHealthRate: Int = 2
    private var score: Int = 0
    
    //Make copies of our explosions so we can use over and over
    //We dont want to load from the .sks so insteal we'll create class
    //properties and load (cache) them for use
    private let shipExplodeTemplate: SKEmitterNode = SKEmitterNode.pdc_nodeWithFile("shipExplode.sks")!
    private let obstacleExplodeTemplate: SKEmitterNode = SKEmitterNode.pdc_nodeWithFile("obstacleExplode.sks")!
    private var shipBarrierTemplate: SKEmitterNode = SKEmitterNode.pdc_nodeWithFile("forcefield.sks")!
    
    override init(size: CGSize) {
        super.init(size: size)
        setupGame(size)
    }

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setupGame(self.size)
    }
    
    func setupGame(size: CGSize) {
        let ship = SKSpriteNode(imageNamed: "Spaceship.png")
        
        ship.position = CGPoint(x: size.width/2, y: size.height/2)
        
        //Sprite Kits resize formula (transform) is efficient
        ship.size = CGSize(width: 40, height: 40)
        
        ship.name = SpaceshipNodeName
        
        self.addChild(ship)
        //Add our starfield parallax effect to the scene
        // by creating an instance of the StarField class
        addChild(StarField())
        
        //Add ship thruster particle to our ship
        if let shipThruster = SKEmitterNode.pdc_nodeWithFile("thrust.sks") {
            shipThruster.position = CGPoint(x: 0.0, y: -22.0)
            
            //Add thruster to the ship as child
            ship.addChild(shipThruster)

        }
        
        shipBarrierTemplate.position = CGPoint(x: 0.0, y: 42.0)
        ship.addChild(shipBarrierTemplate)
        
        let hudNode = HUDNode()
        hudNode.name = HUDNodeName
        //By default, nodes will stack according to the order they are added to
        //the scene If we want to change this order, we can use a node's zPosit
        hudNode.zPosition = 100.0
        
        //Set the position of the node to the center 
        //All of the child nodes will be positioned
        //relative to this parent node's origin point
        hudNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        
        addChild(hudNode)
        
        //Layout the score and time labels
        hudNode.layoutForScene()
        
        //Start the game already
        hudNode.startGame()
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        /*let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)*/
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        /*for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }*/
        
        //
        //Grab any touches noting that touches is a "set" of any 
        //touch event that has occurred
        //
        if let touch = touches.first {
            /*
            //Locate touch point 
            let touchPoint = touch.locationInNode(self)
            
            //Need to reacquire a reference to our ship node
            //in the Scene graph tree.
            //
            //Can think of scene tree like a DOM
            //You can look up a scene graph node by passing the node's
            //name string to the scene's childNodeWithName method
            if let ship = self.childNodeWithName(SpaceshipNodeName) {
                ship.position = touchPoint
            }
            */
            self.shipTouch = touch
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        //If the last update time property is 0 this is the first frame
        // rendered for this scene Set it to the current time
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Calculate the time change (delta) since the last frame
        let timeDelta = currentTime - lastUpdateTime
        
        //If the touch is still thar (since ship touch is weak reference), 
        //it will automatically be set to nil by the touch handling system
        //when it releases the touches after they are done), find the ship
        //node in the Scene graph by its name and update its position property
        //to the point on the screen that was touched
        //
        // This happens every frame so the ship will keep up with wherever the
        //user's finger moves to

        if let shipTouch = self.shipTouch {
            /*if let ship = self.childNodeWithName(SpaceshipNodeName) {
                ship.position = shipTouch.locationInNode(self)
            }*/
            moveShipTowardPoint(shipTouch.locationInNode(self), timeDelta: timeDelta)
            
            //We only want photon torpedos to launch from our ship when users finger is on screen
            //AND if the difference between current time and last time a torpedo was fired
            //is greater than 0.5 secs
            if currentTime - lastShotFireTime > shipFireRate {
                shoot()
                
                //Comment this out for fun
                lastShotFireTime = currentTime
            }
        }
        
        //We want to release the kraken! Er asteroids 1.5% of the time a frame is drawn
        if arc4random_uniform(1000) <= 15 {
            //dropAsteroid()
            dropThing()
        }
        
        //Check for any collision before each frame is rendered
        checkCollisions()
        
        //Update lastUpdateTime to current time
        lastUpdateTime = currentTime
    }
    //
    //Nudge ship toward touch point
    //by a decent distance amount based on elapsed time
    func moveShipTowardPoint(point: CGPoint, timeDelta: NSTimeInterval) {
        // Points per second te ship should travel
        let shipSpeed = CGFloat(300)
        
        if let ship = self.childNodeWithName(SpaceshipNodeName) {
            //Using the Pythagorean Theorem, determine the distance
            //between ships current position and the point passed in
            let distanceLeftToTravel = sqrt(pow(ship.position.x - point.x, 2) + pow(ship.position.y - point.y, 2))
            
            //If the distane left to travel is greater than 4 points, keep moving ship
            //Otherwise, stop moving the ship because we may experience
            //"jitter" around touch point (due to imprecision in float numbers)
            //if we get too close.
            if distanceLeftToTravel > 4 {
                //Calculate how far we hould move the ship during this frame
                let howFarToMove =  CGFloat(timeDelta) * shipSpeed
                
                //Convert the distance remaining back into x,y coordinates
                //using the atan2() function to determine the proper angle
                //based on ship's position and destination
                let angle = atan2(point.y - ship.position.y, point.x - ship.position.x)
                
                //Then, using the angle along with sine and cosine trig functions determine
                //the x and y offset values
                let xOffset = howFarToMove * cos(angle)
                let yOffset = howFarToMove * sin(angle)
                
                // Use this all to move the ship
                ship.position = CGPoint(x: ship.position.x + xOffset, y: ship.position.y + yOffset)
            }
        }
    }
    
    //Create a powerup sprite which spins and moves from top to bottom
    func dropWeaponsPowerUp() {
        let sideSize = 30.0
        
        //Set position for weapons powerup
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        
        let startY = Double(self.size.height) + sideSize
        
        //Create and config weaps powerup sprite
        let powerUp = SKSpriteNode(imageNamed: "powerup")
        
        powerUp.size = CGSize(width: sideSize, height: sideSize)
        powerUp.position = CGPoint(x: startX, y: startY)
        powerUp.name = PowerupNodeName
        
        self.addChild(powerUp)
        
        //Setup power ups movement
        let powerUpPath = buildEnemyShipMovementPath()
        
        let flightPath = SKAction.followPath(powerUpPath, asOffset: true, orientToPath: true, duration: 5.0)
        
        let remove = SKAction.removeFromParent()
        
        powerUp.runAction(SKAction.sequence([flightPath, remove]))
    }
    
    //Need the health power up to shrink as it gets lower
    func dropHealth() {
        let sideSize = 20.0
        
        //Set position for weapons powerup
        let startX = Double(arc4random_uniform(uint(self.size.width - 80)) + 30)
        
        let startY = Double(self.size.height) + sideSize
        
        //Create and config health powerup sprite
        let shipHealth = SKSpriteNode(imageNamed: "healthPowerUp")
        
        shipHealth.size = CGSize(width: sideSize, height: sideSize)
        shipHealth.position = CGPoint(x: startX, y: startY)
        shipHealth.name = HealthPowerUpNodeName
        
        self.addChild(shipHealth)
        
        let healthPowerUpPath = buildEnemyShipMovementPath()
        
        let healthFlightPath = SKAction.followPath(healthPowerUpPath, asOffset: true, orientToPath: true, duration: 5.0)
        
        let shrink = SKAction.scaleTo(0.5, duration: 5.0)
        
        let remove = SKAction.removeFromParent()
        
        //Chain healthFlightPath and shrink
        
        let flyThenRemove = SKAction.sequence([healthFlightPath, remove])
        
        shipHealth.runAction(SKAction.group([flyThenRemove, shrink]))
    }
    
    func shoot() {
        if let ship = self.childNodeWithName(SpaceshipNodeName) {
            //Create a photon torpedo sprite
            let photon = SKSpriteNode(imageNamed: "photon.png")
            photon.name = PhotonTorpedoNodeName
            photon.position = ship.position
            
            self.addChild(photon)
            
            //Move the torpedo from its original position past top edge of screen
            //over half a sec. y-axis in SK is flipped back to normal(0, 0) is the bottom
            //left corner OPPOSITE OF PHASER Scene height (self.size.height is the top edge)
            let fly = SKAction.moveByX(0, y: self.size.height + photon.size.height, duration: 0.5)
            
            //Run the action
            //photon.runAction(fly)
            
            //Remove the torpedo once it leaves the scene
            let remove = SKAction.removeFromParent()
            
            let fireAndRemove = SKAction.sequence([fly, remove])
            
            photon.runAction(fireAndRemove)
            
            self.runAction(self.shootSound)
        }
    }
    
    //Choose randomly when to drop an enemy ship, asteroid, powerup, or w.e
    func dropThing() {
        let dieRoll = arc4random_uniform(100) //die roll between 0 and 99
        
        if dieRoll < 19 {
            dropHealth()
        } else if dieRoll < 20 {
            dropWeaponsPowerUp()
        } else if dieRoll < 35 {
            dropEnemyShip()
        } else {
            dropAsteroid()
        }
    }// end drop thing
    
    func dropAsteroid() {
        
        //Define asteroid size, which will be a random number between 15 and 44
        let sideSize = Double(arc4random_uniform(30) + 15)
        
        //Max x-value for the scene
        let maxX = Double(self.size.width)
        let quarterX = maxX / 4.0
        
        let randRange = UInt32(maxX + (quarterX * 2))
        
        //arc4random_uniform requires a UInt32 paramter passed to it
        //Determine starting x-position for asteroid
        let startX = Double(arc4random_uniform(randRange)) - quarterX
        
        let startY = Double(self.size.height) + sideSize
        
        //random end x position
        let endX = Double(arc4random_uniform(UInt32(maxX)))
        let endY = 0.0 - sideSize
        
        //Create the asteroid sprite and set its properties
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.size = CGSize(width: sideSize, height: sideSize)
        
        asteroid.position = CGPoint(x: startX, y: startY)
        
        asteroid.name = ObstacleNodeName
        
        self.addChild(asteroid)
        
        // Run some actions to move the asteroid
        //Move asteroid to a random generated point, over a 
        //duration of 3-6 secs
        let move = SKAction.moveTo(CGPoint(x: endX, y: endY), duration: Double(arc4random_uniform(4) + 3))
        
        let remove = SKAction.removeFromParent()
        
        let travelAndRemove = SKAction.sequence([move, remove])
        
        //As it moves, rotate the asteroid by 3 radians (180 degrees)
        //over 1-3 secs
        let spin = SKAction.rotateByAngle(3, duration: Double(arc4random_uniform(3) + 1))
        
        let spinForever = SKAction.repeatActionForever(spin)
        
        let all = SKAction.group([spinForever, travelAndRemove])
        
        asteroid.runAction(all)
    }
    
    func dropEnemyShip() {
        let sideSize = 30.0
        
        //Set position for enemy ship
        let startX = Double(arc4random_uniform(uint(self.size.width - 40)) + 20)
        
        let startY = Double(self.size.height) + sideSize
        
        //Create and config enemy shipsprite
        let enemy = SKSpriteNode(imageNamed: "enemy")
        
        enemy.size = CGSize(width: sideSize, height: sideSize)
        enemy.position = CGPoint(x: startX, y: startY)
        enemy.name = ObstacleNodeName
        
        self.addChild(enemy)
        //Setup enemy movement We want the enemy ship
        //to follow a curved path(Bezier Curve) which uses control points
        //to define how the curve of the path is formed
        //The following method call will return the path
        let shipPath = buildEnemyShipMovementPath()
        
        //use the provided ship path to move our enemy ship
        //
        // asOffet parameter: if set to true, let's us treat the actual
        //point values of the path as offsets from the enemy ship's start point
        //A false value would treat the paths points as absolute positions on screen
        //
        //OrientToPath if true causes the enemy ship to turn and face the
        //direction of the path automatically
        //
        let followPath = SKAction.followPath(shipPath, asOffset: true, orientToPath: true, duration: 6.0)
        
        let remove = SKAction.removeFromParent()
        
        enemy.runAction(SKAction.sequence([followPath, remove]))
    }
    
    func buildEnemyShipMovementPath() -> CGPathRef {
        let yMax = -1.0 * self.size.height
        //Bezier path was produced using PaintCode app
        //
        //Use the UIBezierPath class to build an object that adds points w 2 
        //control points per point to construct a curved path
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(CGPointMake(0.5, -0.5))
        
        bezierPath.addCurveToPoint(CGPointMake(-2.5, -59.5), controlPoint1: CGPointMake(0.5, -0.5), controlPoint2: CGPointMake(4.55, -29.48))
        
        bezierPath.addCurveToPoint(CGPointMake(-27.5, -154.5), controlPoint1: CGPointMake(-9.55, -89.52), controlPoint2: CGPointMake(-43.32, -115.43))
        
        bezierPath.addCurveToPoint(CGPointMake(30.5, -243.5), controlPoint1: CGPointMake(-11.68, -193.57), controlPoint2: CGPointMake(17.28, -186.95))
        
        bezierPath.addCurveToPoint(CGPointMake(-52.5, -379.5), controlPoint1: CGPointMake(43.72, -300.05), controlPoint2: CGPointMake(-47.71, -335.76))
        
        bezierPath.addCurveToPoint(CGPointMake(54.5, -449.5), controlPoint1: CGPointMake(-57.29, -423.24), controlPoint2: CGPointMake(-8.14, -482.45))
        
        bezierPath.addCurveToPoint(CGPointMake(-5.5, -348.5), controlPoint1: CGPointMake(117.14, -416.55), controlPoint2: CGPointMake(52.25, -308.62))
        
        bezierPath.addCurveToPoint(CGPointMake(10.5, -494.5), controlPoint1: CGPointMake(-63.25, -388.38), controlPoint2: CGPointMake(-14.48, -457.43))
        
        bezierPath.addCurveToPoint(CGPointMake(0.5, -559.5), controlPoint1: CGPointMake(23.74, -514.16), controlPoint2: CGPointMake(6.93, -537.57))
        
        bezierPath.addCurveToPoint(CGPointMake(-2.5, yMax), controlPoint1: CGPointMake(-5.2, yMax), controlPoint2: CGPointMake(-2.5, yMax))
        
        return bezierPath.CGPath
    }
    
    func checkCollisions() {
        //Effects for space ship!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if let ship = self.childNodeWithName(SpaceshipNodeName) {
            if self.shipHealthRate == 4 {
                self.shipBarrierTemplate.particleColorSequence = nil;
                self.shipBarrierTemplate.particleColorBlendFactor = 1.0;
                self.shipBarrierTemplate.particleColor = SKColor.yellowColor()
                
            } else if self.shipHealthRate == 3 {
                self.shipBarrierTemplate.particleColorSequence = nil;
                self.shipBarrierTemplate.particleColorBlendFactor = 1.0;
                self.shipBarrierTemplate.particleColor = SKColor.orangeColor()

            } else if self.shipHealthRate == 2 {
                self.shipBarrierTemplate.particleColorSequence = nil;
                self.shipBarrierTemplate.particleColorBlendFactor = 1.0;
                self.shipBarrierTemplate.particleColor = SKColor.redColor()
                self.shipBarrierTemplate.particleBirthRate = 15
                self.shipBarrierTemplate.particleAlpha = 0.1
                
            } else if self.shipHealthRate == 1 {
                self.shipBarrierTemplate.particleColorSequence = nil;
                self.shipBarrierTemplate.particleColorBlendFactor = 1.0;
                self.shipBarrierTemplate.particleAlpha = -1
                self.shipBarrierTemplate.particleBirthRate = 0
            }

            enumerateChildNodesWithName(PowerupNodeName) {
                myPowerUp, _ in
                
                if ship.intersectsNode(myPowerUp) {
                    //Show powerup HUD info
                    if let hud = self.childNodeWithName(self.HUDNodeName) as! HUDNode? {
                       
                        hud.showPowerupTimer(self.powerUpDuration)
                    }

                    myPowerUp.removeFromParent()
                    
                    //Increase ships rate of fire for a period of 5 secs
                    self.shipFireRate = 0.1
                    
                    //But, we need to power down after collecting the power up
                    let powerDown = SKAction.runBlock {
                        self.shipFireRate = self.defaultFireRate
                    }
                    
                    //Now let's set up our delay
                    let wait = SKAction.waitForDuration(self.powerUpDuration)
                    
                    let waitAndPowerDown = SKAction.sequence([wait, powerDown])
                    
                    //ship.runAction(waitAndPowerDown)
                    //If we collect an additional power up while one is in progress
                    //we need to stop the previous timer, and start a new one
                    //SK lets us run actions with a key that we can use to identify and 
                    //remove the action before it has had a chance to run or finish
                    let powerDownActionKey = "waitAndPowerDown"
                    ship.removeActionForKey(powerDownActionKey)
                    
                    ship.runAction(waitAndPowerDown, withKey: powerDownActionKey)
                }
            }
            
            enumerateChildNodesWithName(HealthPowerUpNodeName) {
                healthPowerUp, _ in
                
                if ship.intersectsNode(healthPowerUp) {
                    if let hud = self.childNodeWithName(self.HUDNodeName) as! HUDNode? {
                        let live = 1
                        
                        if self.shipHealthRate < 4 {
                            hud.addHealth(live)
                        }
                    }

                    healthPowerUp.removeFromParent()
                    
                    if self.shipHealthRate <= 4 {
                        self.shipHealthRate++
                    } else {
                        if let hud = self.childNodeWithName(self.HUDNodeName) as! HUDNode? {
                            let score = 100
                         
                            hud.addPoints(score)
                        }
                    }
                }
            }
            //This method will execute the given code block for every node
            //that is an obstacle node this will iterate thru all  of our obstacle
            //nodes in the scene graph tree
            //
            //enumerateChildNodesWithName will automagically populate
            //the local identifier obstacle w a reference to the next "obstacle"
            //node it found as it is looping thru the Scene graph tree
            //
            enumerateChildNodesWithName(ObstacleNodeName) {
                obstacle, _ in
                
                //check for collision with our ship
                if ship.intersectsNode(obstacle) {
                    //our ship collided with an obstacle
                    //
                    //Set shipTouch property to nil so it will not be used by
                    //our shooting logic in the update() func to continue tracking
                    //touch and shoot torpedos. If this doesn't work the torpedo
                    //will be shot from 0,0 since the ships gone
                    if let hud = self.childNodeWithName(self.HUDNodeName) as! HUDNode? {
                        let live = -1
                        
                        if self.shipHealthRate > 0 {
                            hud.addHealth(live)
                        }
                    }

                    self.shipTouch = nil
                    
                    //Remove the ship and the obstacle that hit it
                    self.shipHealthRate--
                    if let hud = self.childNodeWithName(self.HUDNodeName) as! HUDNode? {
                        if self.score > 0 {
                            let score = -10
                            hud.addPoints(score)
                        }
                    }

                    obstacle.removeFromParent()
                    self.runAction(self.obstacleExplodeSound)
                    
                    if self.shipHealthRate == 0 {
                        ship.removeFromParent()
                        self.runAction(self.shipExplodeSound)
                        let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        explosion.position = obstacle.position
                        explosion.pdc_dieOutInDuration(0.1)
                        self.addChild(explosion)
                        
                        //Call a copy() on the node in the shipExplodeTemplate
                        //property cus nodes can only be added to a scene once
                        //If we try to add a node again that already exists
                        // the game will crash w/ an error. WE must add copies
                        let explosionParticle = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        explosionParticle.position = obstacle.position
                        explosionParticle.pdc_dieOutInDuration(0.3)
                        self.addChild(explosionParticle)
                        if let hud = self.childNodeWithName(self.HUDNodeName) as! HUDNode? {
                            hud.endGame()
                        }
                    }
                }
                
                //Now, check if the obstacle collided w/ a torpedo
                //Add an inner loop/enumeration to check if any of our torpedos
                //
                self.enumerateChildNodesWithName(self.PhotonTorpedoNodeName) {
                    myPhoton, stop in
                    
                    if myPhoton.intersectsNode(obstacle) {
                        //Remove torpedo and obstacle and health from scene
                        myPhoton.removeFromParent()
                        obstacle.removeFromParent()
                        
                        //Set stop.memory = true to end inner loop
                        //Kind of like a break in other languages
                        self.runAction(self.obstacleExplodeSound)
                        
                        let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        explosion.position = obstacle.position
                        explosion.pdc_dieOutInDuration(0.1)
                        self.addChild(explosion)
                        
                        //Update our score
                        if let hud = self.childNodeWithName(self.HUDNodeName) as! HUDNode? {
                            let score = 10
                            hud.addPoints(score)
                        }
                        stop.memory = true
                    }
                }
            } //end enumerateChildNodesWithName(ObstacleNodeName)
        }
    } // End of checkCollisions()
} // End of game scene