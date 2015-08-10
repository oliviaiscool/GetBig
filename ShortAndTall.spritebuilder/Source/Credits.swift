//
//  Credits.swift
//  ShortAndTall
//
//  Created by Olivia Ross on 8/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Credits: CCScene {
    
    func backToStart() {
        let mainScene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(mainScene)
    }
}
