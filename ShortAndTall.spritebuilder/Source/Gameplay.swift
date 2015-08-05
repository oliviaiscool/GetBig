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
    weak var obstacle: CCNode!
    
    //about the hero
    weak var hero: CCNode!
    weak var tallHero: CCNode!
    
    var didCollide = false
    
    // controlling movement
    var sinceTouch: CCTime = 0
    
    
    func didLoadFromCCB() {
        gamePhysicsBody.debugDraw = false
        
        // -------------------- ALLOW TOUCH RECOGNITION --------------------
        userInteractionEnabled = true
        multipleTouchEnabled = true
        
        
        // -------------------- CHANGE SIZE SET UP --------------------
        tallHero.visible = false
        tallHero.physicsBody.sensor = true
        
        gamePhysicsBody.collisionDelegate = self

    }
    
    func backToStart() {
        let mainScene = CCBReader.loadAsScene("Scenes/MainScene")
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
        } else {
            // ---------- IF SMALL, YOU CAN JUMP HIGH -----------
            if (tallHero.visible == true ) {
                hero.physicsBody.applyImpulse(ccp(0, 100))
                print("You're too heavy to jump!")
            } else {
                hero.physicsBody.applyImpulse(ccp(0, 200))
            }
        }
    }
    
    override func update(delta: CCTime) {
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))
        sinceTouch += delta
        
        tallHero.position.x = hero.position.x
        tallHero.physicsBody.sensor = true
        
        tallHero.position.y = hero.boundingBox().height
        
        // ---------- OBSTACLE SCROLLING, GAME OVER SOLUTION -----------
        if obstacle.position.x <= 0 {
//            var obstacle = CCBReader.load("Obstacle") as! Obstacle
            obstacle.position.x = CCDirector.sharedDirector().viewSize().width
        }
        
        if didCollide == true {
            gameOver()
        } else {
            obstacle.position.x = obstacle.position.x - 2
        }
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, obstacle: CCNode!) -> ObjCBool {
        didCollide = true
        println("detected collision")
        return true
    }

}