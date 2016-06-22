//
//  SKEmitterNodeExtension.swift
//  SpaceRun
//
//  Created by Frideres, Andrew on 4/26/16.
//  Copyright © 2016 Frideres, Andrew. All rights reserved.
//

import SpriteKit

//Use a Swift extension to extend the string class
//to have a length property
extension String {
    var length: Int {
        return self.characters.count
    }
}

extension SKEmitterNode {
    //Helper method to fetch the passed-in particle effect file
    class func pdc_nodeWithFile(filename: String) -> SKEmitterNode? {
        //We'll check the file basename and extension. If there is no
        //extension for the filename set it to "sks"
        let basename = (filename as NSString).stringByDeletingPathExtension
        //Get filename's extension
        var fileExt = (filename as NSString).pathExtension
        
        if fileExt.length == 0 {
            fileExt = "sks"
        }
        
        //We will grab the main bundle of our project and ask for the
        //path to a resource that has the previously calculated basename
        //and file extension
        if let path = NSBundle.mainBundle().pathForResource(basename, ofType: fileExt) {
            // Particle effects in SK are archived when created and we must unarchive 
            //the effect file so it can be treated as an SKEmitterNode object
            let node = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! SKEmitterNode
            
            return node
        }
        return nil
    }
    
    //We want to add explosions to the two collisions that occur
    //
    //We don't want the explosion emitters to keep running forever for these, have them die
    //aftera short duration
    func pdc_dieOutInDuration(duration:NSTimeInterval) {
        //Define two waiting periods because once we set the birthrate 0 
        //we will still need to wait before the particles die out Otherwise
        //the particles will vanish immediately
        let firstWait = SKAction.waitForDuration(duration)
        //Set birthRate to 0 in order to make particle effect dissapear
        //using SKAction code block
        let stop = SKAction.runBlock {
            [weak self] in
            
            if let weakSelf = self {
                weakSelf.particleBirthRate = 0
            }
        }
        //Setup second wait time
        let secondWeight = SKAction.waitForDuration(NSTimeInterval(self.particleLifetime))
        
        let remove = SKAction.removeFromParent()
        
        runAction(SKAction.sequence([firstWait, stop, secondWeight, remove]))
    }
    
}