import Foundation

class MainScene: CCNode {
    
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
}
