//
//  MainMenu.swift
//  Ninja2
//
//  Created by Serena Savarese on 11/12/23.
//

import SpriteKit

class MainMenu: SKScene {
    
    //MARK: - Properties
    var containerNode: SKSpriteNode!
    
    //MARK: - Systems
    
    override func didMove(to view: SKView) {
        setupBG()
        setupGrounds()
        setupNodes()
        setupContainer() //Suggerimento chatGPT
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        
        if node.name == "play" {
            let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.3))
        } else if node.name == "highscore" {
            setupPanel()
        } else if node.name == "setting" {
            setupSetting()
        } else if node.name == "container" {
            containerNode.removeFromParent()
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveGrounds()
    }
    
}

//MARK: - Configurations

extension MainMenu {
    
    func setupBG() {
        //Il backgound non è stato posizionato bene!!
        /*let bgNode = SKSpriteNode(imageNamed: "background")
        bgNode.zPosition = -1.0
        bgNode.anchorPoint = .zero
        bgNode.position = .zero
        addChild(bgNode)
        */
        
        for i in 0...2 {
            let bgNode = SKSpriteNode(imageNamed: "background")
            bgNode.name = "background"
            bgNode.anchorPoint = .zero
            bgNode.position = CGPoint(x: CGFloat(i)*bgNode.frame.width, y: 0.0)
            bgNode.zPosition = -1.0
            addChild(bgNode)
        }
    }
    
    func setupGrounds() {
        for i in 0...3 {
            let groundNode = SKSpriteNode(imageNamed: "ground")
            groundNode.name = "ground"
            groundNode.anchorPoint = .zero
            groundNode.zPosition = 1.0
            groundNode.position = CGPoint(x: CGFloat(i)*groundNode.frame.width, y: 0.0)
            addChild(groundNode)
        }
        
        /*for i in 0...2 {
            let groundNode = SKSpriteNode(imageNamed: "ground")
            groundNode.name = "ground"
            groundNode.anchorPoint = .zero
            groundNode.zPosition = 1.0
            groundNode.position = CGPoint(x: CGFloat(i)*groundNode.frame.width, y: 0.0)
            addChild(groundNode)
        }*/
        
        
    }
    func moveGrounds() {
        enumerateChildNodes(withName: "ground") { (node, _) in
            let node = node as! SKSpriteNode
            node.position.x -= 8.0
                    
            if node.position.x < -self.frame.width {
            node.position.x = node.frame.width*2.0
            }
        }
    }
    
    func setupNodes() {
        let play = SKSpriteNode(imageNamed: "play")
        play.name = "play"
        play.setScale(0.85)
        play.zPosition = 10.0
        play.position = CGPoint(x: size.width/1.4, y: size.height - play.size.height - 100.0) //Qui ci dovrebbe essere un meno qualcosa
        addChild(play)
        
        let highscore = SKSpriteNode(imageNamed: "highscore")
        highscore.name = "highscore"
        highscore.setScale(0.85)
        highscore.zPosition = 10.0
        highscore.position = CGPoint(x: size.width/1.8, y: size.height/1.5 - highscore.size.height) //Forse si deve aggiungere qualche altra cosa
        addChild(highscore)
        
        let setting = SKSpriteNode(imageNamed: "setting")
        setting.name = "setting"
        setting.setScale(0.85)
        setting.zPosition = 10.0
        setting.position = CGPoint(x: size.width/2.0, y: size.height/2.0 - setting.size.height - 50.0)
        addChild(setting)
    }

    func setupPanel() {
        setupContainer()
        
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        //Highscore
        let x = -panel.frame.width/2.0 + 250.0
        let highscoreLbl = SKLabelNode(fontNamed: "Krugthep")
        highscoreLbl.text = "Highscore: \(ScoreGenerator.sharedInstance.getHighscore())"
        highscoreLbl.horizontalAlignmentMode = .left
        highscoreLbl.fontSize = 80.0
        highscoreLbl.zPosition = 25.0
        highscoreLbl.position = CGPoint(x: x, y: highscoreLbl.frame.height/2.0 - 30.0)
        panel.addChild(highscoreLbl)
        
        let scoreLbl = SKLabelNode(fontNamed: "Krugthep")
        scoreLbl.text = "Score: \(ScoreGenerator.sharedInstance.getScore())"
        scoreLbl.fontSize = 80.0
        scoreLbl.zPosition = 25.0
        scoreLbl.position = CGPoint(x: x / 2.0 - 28, y: -scoreLbl.frame.height - 30.0)
        panel.addChild(scoreLbl)
    }
    
    func setupContainer() {
        containerNode = SKSpriteNode()
        containerNode.name = "container"
        containerNode.zPosition = 15.0
        containerNode.color = .clear //UIColor(white: 0.5, alpha 0.5)
        containerNode.size = size
        containerNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        addChild(containerNode)
    }
    
    func setupSetting() {
        //Panel
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        //Music
        let music = SKSpriteNode(imageNamed: "musicOn")
        music.name = "music"
        music.setScale(0.7)
        music.zPosition = 25.0
        music.position = CGPoint(x: -music.frame.width - 50.0, y: 0.0)
        panel.addChild(music)
        
        //Sound
        let effect = SKSpriteNode(imageNamed: "effectOn")
        effect.name = "effect"
        effect.setScale(0.7)
        effect.zPosition = 25.0
        effect.position = CGPoint(x: music.frame.width + 50.0, y: 0.0)
        panel.addChild(effect)
    }
}
