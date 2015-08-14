//
//  Open.swift
//  ShortAndTall
//
//  Created by Olivia Ross on 8/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Open: CCNode {
    func tutorial() {
        let tutorial = CCBReader.loadAsScene("Tutorial")
        
        var scene = CCScene()
        scene.addChild(tutorial)
        
        var transition = CCTransition(fadeWithDuration: 0.5)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    func toggleMusic() {
        if OALSimpleAudio.sharedInstance().muted {
            OALSimpleAudio.sharedInstance().muted = false
        } else {
            OALSimpleAudio.sharedInstance().muted = true
        }
    }
}
