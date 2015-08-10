import Foundation

class MainScene: CCNode {
    
    func play() {
        let gameplay = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(gameplay)
    }
    
    func credits() {
        let credits = CCBReader.loadAsScene("Credits")
        CCDirector.sharedDirector().presentScene(credits)
    }
}
