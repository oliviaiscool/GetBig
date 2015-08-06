//
//  Gameplay.swift
//  ShortAndTall
//
//  Created by Olivia Ross on 7/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Gameplay: CCScene , CCPhysicsCollisionDelegate {
    
    //basic content nodes
    weak var gamePhysicsBody: CCPhysicsNode!
    weak var gameplayNode: CCNode!
    weak var obstaclesLayer: CCNode!
    
    //about the hero
    weak var hero: CCNode!
    weak var tallHero: CCNode!
    
    var didCollide = false
    
    //controlling score
    var obstaclesAvoided: Int = 0
    weak var scoreLabel: CCLabelTTF!
    
    //generating obstacles
    var obstacles: [CCNode] = []
    var randomInstance: UInt32!
    let firstObstaclePosition : CGFloat = 280
    let distanceBetweenObstacles : CGFloat = 250
    
    func didLoadFromCCB() {
        gamePhysicsBody.debugDraw = false
        
        // -------------------- ALLOW TOUCH RECOGNITION --------------------
        userInteractionEnabled = true
        multipleTouchEnabled = true
        
        
        // -------------------- CHANGE SIZE SET UP --------------------
        tallHero.visible = false
        tallHero.physicsBody.sensor = true
        
        gamePhysicsBody.collisionDelegate = self
        
        spawnRandomObstacle()
        spawnRandomObstacle()
        spawnRandomObstacle()

    }
    
    func backToStart() {
        let mainScene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(mainScene)
    }
    
    func gameOver() {
        //wait for a little bit
        var delay = CCActionDelay(duration: 4)
        
        //go back to the main screen
        var goBack = CCActionCallBlock(block: {self.backToStart()})
        runAction(CCActionSequence(array: [delay, goBack]))
    }
    
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        // -------------------- CHANGE SIZE --------------------
        if (touch.locationInNode(gameplayNode).x >= 250.00) {
            if (tallHero.visible == true) {
                tallHero.visible = false
            } else { // if false
                tallHero.visible = true
            }
        } else { // if you didn't tap the change size side of the screen
            // ---------- IF hero IS SMALL, IT CAN JUMP ON TOUCH -----------
            if (tallHero.visible == true ) {
                hero.physicsBody.applyImpulse(ccp(0, 10))
                print("You're too heavy to jump!")
            } else {
                hero.physicsBody.applyImpulse(ccp(0, 200))
            }
        }
    }
    
    // -----------  UPDATE FUNCTION ~ CALLED EVERY SINGLE FRAME -------------
    override func update(delta: CCTime) {
        
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))
        
        tallHero.position.x = hero.position.x
        tallHero.physicsBody.sensor = true
        
        tallHero.position.y = hero.boundingBox().height
        
        // ---------- OBSTACLE SCROLLING ---------- & ---------- GAME OVER SOLUTION -----------
        if didCollide == true {
            gameOver()
        } else {
            for obstacle in obstacles.reverse() {
                
                // obstacle moved past left side of screen?
                if obstacle.position.x < (obstacle.contentSize.width) {
                    obstacle.removeFromParent()
                    obstacles.removeAtIndex(find(obstacles, obstacle)!)
                    
                    // for each removed obstacle, add a new one
                    spawnRandomObstacle()
                }
                
                obstacle.position.x -= 4
            }
        }
    }

    
        // ---------- OBSTACLE COLLISION TESTING -----------
        func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, fire: CCNode!) -> ObjCBool {
            didCollide = true
            return true
        }
    
        func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, ice: CCNode!) -> ObjCBool {
            if tallHero.visible == true {
                println("SMASH! :) ")
                return false
            } else {
                didCollide = true
                return true
            }
        }
    
        // ---------- SCORE UPDATE -----------
        func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, sensor: CCNode!) -> ObjCBool {
            obstaclesAvoided += 1
            scoreLabel.string = String(obstaclesAvoided)
            return false
        }
    
    func spawnRandomObstacle(){
        var prevObstaclePos = firstObstaclePosition
        randomInstance = arc4random_uniform(100)
        
        if obstacles.count > 0 {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        if randomInstance >= 50 {
            let obstacle = CCBReader.load("Obstacle") as! Obstacle
            obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 0)
            obstaclesLayer.addChild(obstacle)
            obstacles.append(obstacle)
        } else {
            let obstacle = CCBReader.load("Smash") as! Smash
            obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 0)
            obstaclesLayer.addChild(obstacle)
            obstacles.append(obstacle)
        }
        
    }

}