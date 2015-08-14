import Foundation

class MainScene: CCNode {
    
    let defaults = NSUserDefaults.standardUserDefaults()

    func didLoadFromCCB() {
        
        OALSimpleAudio.sharedInstance().playBg("PROTODOME - CHIPFUNK - 04 Interstellar Good Times..mp3", loop: true)
        OALSimpleAudio.sharedInstance().muted = false
        
    }
    
    func toggleMusic() {
        if OALSimpleAudio.sharedInstance().muted {  
            OALSimpleAudio.sharedInstance().muted = false
        } else {
            OALSimpleAudio.sharedInstance().muted = true
        }
    }
    
    func play() {
        let gameplay = CCBReader.loadAsScene("Gameplay")
        
        var scene = CCScene()
        scene.addChild(gameplay)
        
        var transition = CCTransition(fadeWithDuration: 0.5)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    func credits() {
        let credits = CCBReader.loadAsScene("Credits")
        
        var scene = CCScene()
        scene.addChild(credits)
        
        var transition = CCTransition(fadeWithDuration: 0.5)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    func tutorial() {
        let tutorial = CCBReader.loadAsScene("Tutorial")
        
        var scene = CCScene()
        scene.addChild(tutorial)
        
        var transition = CCTransition(fadeWithDuration: 0.5)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    override func update(delta: CCTime) {
        if defaults.boolForKey("didTutorial") == false {
            println("Sucess")
            let mainScene = CCBReader.loadAsScene("Open")
            
            var scene = CCScene()
            scene.addChild(mainScene)
            
            var transition = CCTransition(fadeWithDuration: 0.5)
            CCDirector.sharedDirector().replaceScene(scene, withTransition: transition)
        }

    }
}
