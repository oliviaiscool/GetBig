//
//  Tutorial.swift
//  ShortAndTall
//
//  Created by Olivia Ross on 8/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

enum Section {
    case Jump, Morph, Morph2, Practice
}

class Tutorial: CCNode, CCPhysicsCollisionDelegate {
    
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var didTutorial: Bool = NSUserDefaults.standardUserDefaults().boolForKey("didTutorial") ?? false {
        didSet {
            defaults.setBool(didTutorial, forKey:"didTutorial")
            defaults.synchronize()
        }
    }
    
    // MARK: Variables: basic content nodes
    weak var gamePhysicsBody: CCPhysicsNode!
    weak var obstaclesLayer: CCNode!
    weak var gameOverScene: CCNode!
    
    var isGameOver: Bool = false
    
    // MARK: Variables: about the hero
    weak var hero: CCNode!
    weak var tallHero: CCNode!
    
    // MARK: Variables: controlling score
    var obstaclesAvoided: Int = 0 {
        didSet{
            if isGameOver == false {
                scoreLabel.string = "\(obstaclesAvoided)"
            }
        }
    }
    var scoreMultiplier: Int = 1 {
        didSet{
            multiplierLabel.string = "\(scoreMultiplier)"
        }
    }
    weak var multiplierLabel: CCLabelTTF!
    weak var multiplierArea: CCNode!
    weak var scoreLabel: CCLabelTTF!
    weak var currentScore: CCLabelTTF!
    weak var currentMultiplierLabel: CCLabelTTF!
    weak var actualScore: CCLabelTTF!
    
    // MARK: Variables: generating obstacles
    var obstacles: [CCNode] = []
    var randomInstance: UInt32!
    let firstObstaclePosition : CGFloat = 280
    let distanceBetweenObstacles : CGFloat = 250
    
    weak var smashed: SmashParticles!
    
    // MARK: Tutorial specific variables
    weak var jump_instruct1: CCLabelTTF!
    weak var jump_instruct2: CCLabelTTF!
    weak var morph_instruct1: CCLabelTTF!
    weak var morph_instruct2: CCLabelTTF!
    
    var objectiveMet: Bool = false
    var morphAllowed: Bool = false
    var currentSection = Section.Jump
    
    
    
    func backToStart() {
        let mainScene = CCBReader.loadAsScene("MainScene")
        
        var scene = CCScene()
        scene.addChild(mainScene)
        
        var transition = CCTransition(fadeWithDuration: 0.5)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    func play() {
        let tutorial = CCBReader.loadAsScene("Tutorial")
        
        var scene = CCScene()
        scene.addChild(tutorial)
        
        var transition = CCTransition(fadeWithDuration: 0.5)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    func showGameOverScene() {
        gameOverScene.visible = true
        actualScore.string = String(obstaclesAvoided * scoreMultiplier)
        
        self.animationManager.runAnimationsForSequenceNamed("Gameover")
    }
    
    func gameOver() {
        isGameOver = true
        userInteractionEnabled = false
        scheduleOnce("showGameOverScene", delay: 0.1)
    }
    
    
    func didLoadFromCCB() {
        gamePhysicsBody.debugDraw = false
        gamePhysicsBody.collisionDelegate = self
        
        // MARK: Allow touch recognition
        userInteractionEnabled = true
        multipleTouchEnabled = true
        
        // MARK: Score calculating setup
        multiplierArea.visible = false
        
        // MARK: Morphing setup
        tallHero.visible = false
        tallHero.physicsBody.sensor = true
        
        tallHero.position.x = hero.position.x
        tallHero.position.x = hero.boundingBox().height
        
        //MARK: Tutorial setup
        jump_instruct2.visible = false
        morph_instruct1.visible = false
        morph_instruct2.visible = false
        
        spawnRedObstacle()
        jump_instruct1.visible = true
        
    }
    
    override func update (delta: CCTime) {
        
        
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))
        
        tallHero.physicsBody.sensor = true
        tallHero.position.x = hero.position.x
        tallHero.position.y = hero.boundingBox().height
        
        for obstacle in obstacles.reverse() {
            
            obstacle.physicsBody.sensor = true
            
            // obstacle moved past left side of screen?
            if obstacle.position.x < (self.contentSize.width) {
                obstacle.removeFromParent()
                obstacles.removeAtIndex(find(obstacles, obstacle)!)
                
            }
            if isGameOver == false {
            if objectiveMet == false {
                obstacle.position.x -= CGFloat(0.75)
            } else if objectiveMet {
                
                if currentSection == .Jump {
                    objectiveMet = false
                    spawnRedObstacle()
                    jump_instruct1.visible = false
                    jump_instruct2.visible = true
                    morphAllowed = true
                    currentSection = .Morph
                } else if currentSection == .Morph {
                    objectiveMet = false
                    spawnBlueObstacle()
                    jump_instruct2.visible = false
                    morph_instruct1.visible = true
                    currentSection = .Morph2
                } else if currentSection == .Morph2 {
                    objectiveMet = false
                    spawnRedObstacle()
                    morph_instruct1.visible = false
                    morph_instruct2.visible = true
                    currentSection = .Practice
                } else {
                    morph_instruct2.visible = false
                    if obstaclesAvoided < 6 {
                        spawnRandomObstacle()
                        objectiveMet = false
                    } else {
                        obstacle.position.x -= CGFloat(20)
                        let delay = CCActionDelay(duration: 1)
                        runAction(delay)
                        
                        if isGameOver == false {
                            gameOver()
                            youDidTutorial()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func spawnRedObstacle() {
        let obstacle = CCBReader.load("Obstacle") as! Obstacle
        obstacle.position = ccp(568, 50)
        obstaclesLayer.addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    func spawnBlueObstacle() {
        let obstacle = CCBReader.load("Smash") as! Smash
        obstacle.position = ccp(568, 50)
        obstaclesLayer.addChild(obstacle)
        obstacles.append(obstacle)
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, fire: Obstacle!) -> ObjCBool {
        if isGameOver == false {
            isGameOver = true
            gameOver()
        }
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, ice: Smash!) -> ObjCBool {
        if isGameOver == false {
            
            if tallHero.visible == true {
                
                ice.physicsBody.sensor = true
                ice.visible = false
                smashed.visible = true
                smashed.resetSystem()
                return false
            } else {
                isGameOver = true
                gameOver()
                return true
            }
        }
        return true
    }
    // MARK: Score update,  colliding with score sensor
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, sensor: CCNode!) -> ObjCBool {
        objectiveMet = true
        obstaclesAvoided++
        return false
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        // MARK: Changing the hero's size
        if (touch.locationInNode(self).x >= 250.00) {
            if (tallHero.visible == true) {
                tallHero.visible = false
            } else if morphAllowed { // if false
                tallHero.visible = true
            }
        } else {
            // MARK: Telling the hero to jump
            if (tallHero.visible == true && morphAllowed) {
                hero.physicsBody.applyImpulse(ccp(0, 100))
                print("You're too heavy to jump!")
            } else {
                hero.physicsBody.applyImpulse(ccp(0, 700))
            }
        }
    }
    
    func spawnRandomObstacle(){
        var prevObstaclePos = firstObstaclePosition
        randomInstance = arc4random_uniform(100)
        
        if obstacles.count > 0 {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        // MARK: Choosing random obstacle/collectable to spawn
        
        if randomInstance <= 50 {
            let obstacle = CCBReader.load("Obstacle") as! Obstacle
            obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 50)
            obstaclesLayer.addChild(obstacle)
            obstacles.append(obstacle)
        } else if randomInstance <= 100 {
            let obstacle = CCBReader.load("Smash") as! Smash
            obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 50)
            obstaclesLayer.addChild(obstacle)
            obstacles.append(obstacle)
        }
    }
    
    func youDidTutorial() {
        
        defaults.setBool(true, forKey: "didTutorial")
    }
    

}
