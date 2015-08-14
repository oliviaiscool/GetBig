//
//  Gameplay.swift
//  ShortAndTall
//
//  Created by Olivia Ross on 7/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Gameplay: CCScene , CCPhysicsCollisionDelegate {
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var highScore: Int = NSUserDefaults.standardUserDefaults().integerForKey("getHighScore") ?? 0 {
        didSet {
            defaults.setInteger(highScore, forKey: "getHighScore")
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
    weak var highScoreLabel: CCLabelTTF!
    
    // MARK: Variables: generating obstacles
    var obstacles: [CCNode] = []
    var randomInstance: UInt32!
    let firstObstaclePosition : CGFloat = 280
    let distanceBetweenObstacles : CGFloat = 250
    var scrollSpeed: Double = 1
    
    weak var smashed: SmashParticles!
    
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
        
        
        // MARK: Prepare game over
        gameOverScene.visible = false
        
        // MARK: Spawn first three obstacles
        spawnRandomObstacle()
        spawnRandomObstacle()
        spawnRandomObstacle()
        
        smashed.visible = false
        
    }

    func backToStart() {
        let mainScene = CCBReader.loadAsScene("MainScene")
        
        var scene = CCScene()
        scene.addChild(mainScene)
        
        var transition = CCTransition(fadeWithDuration: 0.5)
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    func play() {
        let gameplay = CCBReader.loadAsScene("Gameplay")
        
        var scene = CCScene()
        scene.addChild(gameplay)
        
        var transition = CCTransition(fadeWithDuration: 0.5)
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    func showGameOverScene() {
        gameOverScene.visible = true
        currentScore.string = String(obstaclesAvoided)
        currentMultiplierLabel.string = String(scoreMultiplier)
        
        actualScore.string = String(obstaclesAvoided * scoreMultiplier)
        
        if obstaclesAvoided * scoreMultiplier > highScore {
            highScore = obstaclesAvoided * scoreMultiplier
        }
        
        highScoreLabel.string = String(highScore)
        
        self.animationManager.runAnimationsForSequenceNamed("Gameover")
    }
    
    func gameOver() {
        userInteractionEnabled = false
        scheduleOnce("showGameOverScene", delay: 0.1)
    }
    
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        // MARK: Changing the hero's size
        if (touch.locationInNode(self).x >= 250.00) {
            if (tallHero.visible == true) {
                tallHero.visible = false
            } else { // if false
                tallHero.visible = true
            }
        } else {
            // MARK: Telling the hero to jump
            if (tallHero.visible == true ) {
                hero.physicsBody.applyImpulse(ccp(0, 10))
                print("You're too heavy to jump!")
            } else {
                hero.physicsBody.applyImpulse(ccp(0, 2000))
            }
        }
    }
    
    override func update(delta: CCTime) {
        
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))
        
        tallHero.position.x = hero.position.x
        tallHero.physicsBody.sensor = true
        
        tallHero.position.y = hero.boundingBox().height

        if isGameOver == false {
        // MARK: Obstacle scrolling
            for obstacle in obstacles.reverse() {
                
                // obstacle moved past left side of screen?
                if obstacle.position.x < (obstacle.contentSize.width) {
                    obstacle.removeFromParent()
                    obstacles.removeAtIndex(find(obstacles, obstacle)!)
                    
                    // for each removed obstacle, add a new one
                    spawnRandomObstacle()
                }
                
                obstacle.position.x -= CGFloat(scrollSpeed)
                
                if scrollSpeed < 12 {
                    scrollSpeed += 0.0008
                }
            }
        } else {
            for obstacle in obstacles.reverse() {
                
                obstacle.physicsBody.sensor = true
                
                // obstacle moved past left side of screen?
                if obstacle.position.x < (obstacle.contentSize.width) {
                    obstacle.removeFromParent()
                    obstacles.removeAtIndex(find(obstacles, obstacle)!)
                    
                    // for each removed obstacle, add a new one
                    spawnRandomObstacle()
                }
                
                obstacle.position.x -= CGFloat(scrollSpeed)
                
                
            }
        }
    }

    
        // MARK: Colliding with an obstacle
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
    
        // MARK: Colliding with a collectable
    
        func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, collectable: CCParticleSystem!) -> ObjCBool {
            multiplierArea.visible = true
            
            if isGameOver == false {
                scoreMultiplier += 1
                collectable.removeFromParent()
            }
            
            return false
        }
    
        // MARK: Score update,  colliding with score sensor
        func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, sensor: CCNode!) -> ObjCBool {
            if isGameOver == false {
                obstaclesAvoided += 1
            }
            
            return false
        }
    
    
    func spawnRandomObstacle(){
        var prevObstaclePos = firstObstaclePosition
        randomInstance = arc4random_uniform(100)
        
        if obstacles.count > 0 {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        // MARK: Choosing random obstacle/collectable to spawn

        if randomInstance <= 49 {
            let obstacle = CCBReader.load("Obstacle") as! Obstacle
            obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 50)
            obstaclesLayer.addChild(obstacle)
            obstacles.append(obstacle)
        } else if randomInstance <= 98 {
            let obstacle = CCBReader.load("Smash") as! Smash
            obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 50)
            obstaclesLayer.addChild(obstacle)
            obstacles.append(obstacle)
        } else if obstaclesAvoided > 11 {
            let obstacle = CCBReader.load("collectable") as! CCParticleSystem
            obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 50)
            obstaclesLayer.addChild(obstacle)
            obstacles.append(obstacle)
        } else {
            let obstacle = CCBReader.load("Smash") as! Smash
            obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 50)
            obstaclesLayer.addChild(obstacle)
            obstacles.append(obstacle)
        }
    }
}
