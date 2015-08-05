import Foundation

class MainScene: CCNode {
    
    func play() {
        let gameplay = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(gameplay)
    }
}
