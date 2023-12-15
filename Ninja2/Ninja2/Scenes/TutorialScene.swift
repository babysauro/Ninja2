//
//  TutorialScene.swift
//  JurassicQuack
//
//  Created by Serena Savarese on 15/12/23.
//

import SpriteKit

class TutorialScene: SKScene {
    var tutorialText: SKLabelNode!
    var tapToJumpText: SKLabelNode!
    var avoidObstaclesText: SKLabelNode!
    var collectCoinsText: SKLabelNode!
    
    override func didMove(to view: SKView) {
        setupTutorial()
    }
    
    func setupTutorial() {
        tutorialText = SKLabelNode(fontNamed: "Arial") 
        tutorialText.text = "Benvenuto nel Tutorial!"
        tutorialText.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(tutorialText)
        
        tapToJumpText = SKLabelNode(fontNamed: "Arial")
        tapToJumpText.text = "Tocca lo schermo per saltare"
        tapToJumpText.position = CGPoint(x: size.width / 2, y: size.height - 200)
        addChild(tapToJumpText)
        
        avoidObstaclesText = SKLabelNode(fontNamed: "Arial")
        avoidObstaclesText.text = "Evita gli asteroidi per non perdere vite"
        avoidObstaclesText.position = CGPoint(x: size.width / 2, y: size.height - 300)
        addChild(avoidObstaclesText)
        
        collectCoinsText = SKLabelNode(fontNamed: "Arial")
        collectCoinsText.text = "Raccogli le monete per aumentare lo score"
        collectCoinsText.position = CGPoint(x: size.width / 2, y: size.height - 400)
        addChild(collectCoinsText)
    }
    
    // Codice per gestire il passaggio alla scena di gioco dopo il tutorial
    func goToGameScene() {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        goToGameScene() // Avvia il gioco alla pressione dello schermo nel tutorial
    }
}

