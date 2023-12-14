//
//  GameScene.swift
//  Ninja2
//
//  Created by Serena Savarese on 10/12/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK: - Properties
    var ground: SKSpriteNode!
    var player: SKSpriteNode!
    var cameraNode = SKCameraNode()
    
    var obstacles: [SKSpriteNode] = []
    var coin: SKSpriteNode!
    var redCoin: SKSpriteNode!
    
    //Move camera -> camera moves with speed 450pt per seconds
    var cameraMovePointPerSecond: CGFloat = 450.0
    
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    var isTime: CGFloat = 3.0
    var onGround = true
    var velocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.4
    var playerPosY: CGFloat = 0.0
    
    var numScore: Int = 0
    var gameOver = false
    var life: Int = 3
    
    var lifeNode: [SKSpriteNode] = []
    var scoreLbl = SKLabelNode(fontNamed: "Krungthep") //Font
    var coinIcon: SKSpriteNode!
    
    //Add pause node into Scene
    var pauseNode: SKSpriteNode!
    var containerNode = SKNode()
    
    //Music and Effect
    var soundcoin = SKAction.playSoundFileNamed("newCoin.wav")
    var soundJump = SKAction.playSoundFileNamed("jump.wav")
    var soundCollision = SKAction.playSoundFileNamed("collision.wav")
    
    //Add playable area for scene and camera playable area
    var playableRect: CGRect{
        let ratio: CGFloat
        
        switch UIScreen.main.nativeBounds.height{
        case 2532, 2778, 2436: //case iPhone 14
            ratio = 2.0
        default: //other cases
            ratio = 16/9
        }
        
        let playableHeight = size.width / ratio
        let playableMargin = (size.height - playableHeight )/2.0
        
        return CGRect(x: 0.0, y: playableMargin, width: size.height, height: playableHeight)
    }
    
    var cameraRect: CGRect{
        let width = playableRect.width
        let height = playableRect.height
        let x = cameraNode.position.x - size.width/2.0 + (size.width - width)/2.0
        let y = cameraNode.position.y - size.height/2.0 + (size.height - height)/2.0
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    
    //MARK: - Systems
    override func didMove(to view: SKView) {
        setupNodes()
        
        //BackGround Music
        //SKTAudio.sharedInstance().playBGMusic("quack-8bit.mp3") CANZONE SINGOLA!!!
        let songList = ["quack-8bit.mp3", "WhatIsLove-8Bit.mp3", "TakeOnMe-8Bit.mp3", "NeverGonnaGiveYouUp-8Bit.mp3",
                        "ShootingStars-8Bit.mp3", "BlueDaBaDee-8Bit.mp3", "SweetChildOnMe-8Bit.mp3", "LivinOnAPrayer-8Bit.mp3",
                        "SmellsLikeTeenSpirit-8Bit.mp3"]
        SKTAudio.sharedInstance().playBGMusic(songList)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))

        if node.name == "pause" {
            if isPaused { return }
            createPanel()
            lastUpdateTime = 0.0
            dt = 0.0
            isPaused = true
        } else if node.name == "resume" {
            containerNode.removeFromParent()
            isPaused = false
        } else if node.name == "quit" {
           let scene = MainMenu(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
        } else {
            //Player jump to height of 25pt
            if !isPaused {
                if onGround{
                       onGround = false
                       velocityY = -30.0
                    run(soundJump) //Sound Effect
                }
            }
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if velocityY < -12.5 {
            velocityY = 12.5
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        /*
         If last update time greater than 0 then current time subtract last update time
         */
        if lastUpdateTime > 0{
            dt = currentTime - lastUpdateTime
        }else{
            dt = 0
        }
        
        //This is the time the camera moves
        lastUpdateTime = currentTime
        moveCamera()
        movePlayer()
        
        velocityY += gravity
        player.position.y -= velocityY
        
        if player.position.y < playerPosY {
            player.position.y = playerPosY
            velocityY = 0.0
            onGround = true
        }
        
        if gameOver {
            let scene = GameOver(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
        }
        boundCheckPlayer()
    }
}

//MARK: - Configurations
extension GameScene {
    
    func setupNodes() {
        createBG()
        createGround()
        createPlayer()
        setupObstacles()
        spawnObstacles()
        setupCoin()
        spawnCoin()
        setupRedCoin()
        spawnRedCoin()
        setupPhysics()
        setupLife()
        setupScore()
        setupPause()
        setupCamera()
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func createBG() {
        for i in 0...3 {
            let bg = SKSpriteNode(imageNamed: "background")
            /*The default anchorPoint value of the scene is (0,0)
             and default anchorPoint value of node is (0.5, 0.5)
             */
            bg.name = "BG"
            bg.anchorPoint = .zero
            bg.position = CGPoint(x: CGFloat(i)*bg.frame.width, y: 0.0) //Scroll background
            bg.zPosition = -1.0 //position the background in the center of the screen
            addChild(bg)
        }
    }
    
    func createGround(){
        for i in 0...2 {
            ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 1.0
            ground.position = CGPoint(x: CGFloat(i)*ground.frame.width, y: 0.0)
            
            //Add physicsBody for Groud node
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody!.isDynamic = false
            ground.physicsBody!.affectedByGravity = false
            ground.physicsBody!.categoryBitMask = PhysicsCategory.Ground
            
            
            addChild(ground)
        }
    }
    
    func createPlayer(){
        
        player = SKSpriteNode(imageNamed: "duckSauro")
        player.name = "Player"
        player.zPosition = 5.0
        player.setScale(0.85)
        player.position = CGPoint(x: frame.width/2.0 - 100.0,
                                  y: ground.frame.height + player.frame.height/4.0) //Set Player node position on Ground node (changed 2 -> 4)
        
        //Add physicsBody for Player node
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2.0)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.restitution = 0.0
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        player.physicsBody!.contactTestBitMask = PhysicsCategory.Block | PhysicsCategory.Obstacle | PhysicsCategory.Coin
        
        self.view?.showsPhysics = false //TOLTO GREEN-BOX DI TUTTI
        
        
        playerPosY = player.position.y //Get current position of Player
        
        addChild(player)
        
    }
    
    func setupCamera(){
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func moveCamera(){
        let amountToMove = CGPoint(x: cameraMovePointPerSecond * CGFloat(dt), y: 0.0)
        cameraNode.position += amountToMove
        
        //Background
        enumerateChildNodes(withName: "BG") { node, _ in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width * 2.0 < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*4.0, y: node.position.y)
               
            }//End if
            
        }
        
        //Ground
        enumerateChildNodes(withName: "Ground") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width * 2.0 < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*3.0, y: node.position.y)
                //node.position.x += node.frame.width * 3
            }//End if
            
        }
        
    }
    
    //Move player
    func movePlayer() {
        let amountToMove = cameraMovePointPerSecond * CGFloat(dt)
        let rotate = CGFloat(1).degreesToRadiants() * amountToMove/2.5
        player.zRotation -= rotate
        player.position.x += amountToMove
    }
    
    func setupObstacles() {
        for i in 1...2 {
            let sprite = SKSpriteNode(imageNamed: "block-\(i)")
            sprite.name = "Block"
            obstacles.append(sprite)
        }
        
        for i in 1...2 {
            let sprite = SKSpriteNode(imageNamed: "obstacle-\(i)")
            sprite.name = "Obstacle"
            obstacles.append(sprite)
        }
        
        //Block node and Obstacle node will display randomly
        let index = Int(arc4random_uniform(UInt32(obstacles.count-1)))
        let sprite = obstacles[index].copy() as! SKSpriteNode
        sprite.zPosition = 5.0
        sprite.setScale(0.85)
        sprite.position = CGPoint(x: cameraRect.maxX + sprite.frame.width*6,
                                  y: ground.frame.height + sprite.frame.height/6.0) //Changed 2->6
        
        //Add physicsBody for Obstacles node
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody!.affectedByGravity = false
        sprite.physicsBody!.isDynamic = false
        
        if sprite.name == "Block" {
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Block
        }else {
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        }
        
        sprite.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        
        addChild(sprite)
        sprite.run(.sequence([.wait(forDuration: 10.0), .removeFromParent()]))
    }
    
    //Sawn nodes
    func spawnObstacles() {
        let random = Double(CGFloat.random(min: 1.5, max: isTime))
        run(.repeatForever(.sequence([.wait(forDuration: random),
                                      .run {[weak self] in
                                          self?.setupObstacles()
                                      }
                                     ])))
        run(.repeatForever(.sequence([
            .wait(forDuration: 5.0),
            .run{
                self.isTime -= 0.01
                
                if self.isTime <= 1.5 {
                    self.isTime = 1.5
                }
            }
        ])))
    }
    
    //COIN
    func setupCoin() {
        coin = SKSpriteNode(imageNamed: "coin-1")
        coin.name = "Coin"
        coin.zPosition = 20.0
        coin.setScale(0.85)
        let coinHeight = coin.frame.height
        let random = CGFloat.random(min: -coinHeight, max: coinHeight)
        coin.position = CGPoint(x: cameraRect.maxX + coin.frame.width*6.0, y: size.height/2.0 + random)
        
        //Add physicsBody for Coin node
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.0)
        coin.physicsBody!.affectedByGravity = false
        coin.physicsBody!.isDynamic = false
        coin.physicsBody!.categoryBitMask = PhysicsCategory.Coin
        coin.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        
        addChild(coin)
        coin.run(.sequence([.wait(forDuration: 15.0), .removeFromParent()]))
        
        //Add animation for Coin
        var textures: [SKTexture] = []
        for i in 1...6{
            textures.append(SKTexture(imageNamed: "coin-\(i)"))
        }
        
        coin.run(.repeatForever(.animate(with: textures, timePerFrame: 0.083)))
    }
    
    func spawnCoin() {
        let random = CGFloat.random(min: 2.5, max: 6.0)
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                self?.setupCoin()
            }
        ])))
    }
    
    //RED-COIN
    func setupRedCoin() {
        redCoin = SKSpriteNode(imageNamed: "redcoin-1")
        redCoin.name = "RedCoin"
        redCoin.zPosition = 20.0
        redCoin.setScale(0.85)
        let coinHeight = redCoin.frame.height
        let random = CGFloat.random(min: -coinHeight, max: coinHeight)
        redCoin.position = CGPoint(x: cameraRect.maxX + redCoin.frame.width*6.0, y: size.height/2.0 + random)
        
        //Add physicsBody for Coin node
        redCoin.physicsBody = SKPhysicsBody(circleOfRadius: redCoin.size.width / 2.0)
        redCoin.physicsBody!.affectedByGravity = false
        redCoin.physicsBody!.isDynamic = false
        redCoin.physicsBody!.categoryBitMask = PhysicsCategory.RedCoin
        redCoin.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        
        addChild(redCoin)
        redCoin.run(.sequence([.wait(forDuration: 15.0), .removeFromParent()]))
        
        //Add animation for Coin
        var textures: [SKTexture] = []
        for i in 1...6{
            textures.append(SKTexture(imageNamed: "redcoin-\(i)"))
        }
        
        redCoin.run(.repeatForever(.animate(with: textures, timePerFrame: 0.083)))
    }
    
    func spawnRedCoin() {
        let random = CGFloat.random(min: 2.5, max: 50.0)
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                self?.setupRedCoin()
            }
        ])))
    }
    
    func setupLife() {
        let node1 = SKSpriteNode(imageNamed: "life-on")
        let node2 = SKSpriteNode(imageNamed: "life-on")
        let node3 = SKSpriteNode(imageNamed: "life-on")
        
        setupLifePos(node1, i: 1.0, j: 0.0)
        setupLifePos(node2, i: 2.0, j: 8.0)
        setupLifePos(node3, i: 3.0, j: 16.0)
        
        lifeNode.append(node1)
        lifeNode.append(node2)
        lifeNode.append(node3)
    }
    
    func setupLifePos(_ node: SKSpriteNode, i: CGFloat, j:CGFloat) {
        let width = playableRect.width
        let height = playableRect.height
        
        node.setScale(0.5)
        node.zPosition = 50.0
        node.position = CGPoint(x: -width + node.frame.width*i + j - 15.0,
                                y: height/2.1 - node.frame.height)
        
        cameraNode.addChild(node)
    }
    
    func setupScore() {
        //Coin
        coinIcon = SKSpriteNode(imageNamed: "coin-1")
        coinIcon.setScale(0.5)
        coinIcon.zPosition = 50.0
        
        
        coinIcon.position = CGPoint(x: -playableRect.width + coinIcon.frame.width * 1.2,
                                    y: playableRect.height/2.0 - lifeNode[0].frame.height - coinIcon.frame.height*2.0)
        
        cameraNode.addChild(coinIcon)
        
        //Score Label
        scoreLbl.text = "\(numScore)"
        scoreLbl.fontSize = 60.0
        scoreLbl.horizontalAlignmentMode = .left
        scoreLbl.verticalAlignmentMode = .top
        scoreLbl.zPosition = 50.0
        scoreLbl.position = CGPoint(x: -playableRect.width + coinIcon.frame.width*2.5,
                                    y: coinIcon.position.y + coinIcon.frame.height/2.0 - 8.0)
        
        cameraNode.addChild(scoreLbl)
    }
    
    func setupPause() {
        
        pauseNode = SKSpriteNode(imageNamed: "pause")
        pauseNode.setScale(0.8)
        pauseNode.zPosition = 50.0
        pauseNode.name = "pause"
        pauseNode.position = CGPoint(x: playableRect.width - pauseNode.frame.width,
                                     y: playableRect.height/2.1 - pauseNode.frame.height/2.0 - 70.0)
        
        cameraNode.addChild(pauseNode)
        
    }
    
    func createPanel() {
        
        cameraNode.addChild(containerNode)
        
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.zPosition = 60.0
        panel.position = .zero
        
        containerNode.addChild(panel)
        
        let resume = SKSpriteNode(imageNamed: "resume")
        resume.zPosition = 70.0
        resume.name = "resume"
        resume.setScale(0.7)
        resume.position = CGPoint(x: -panel.frame.width/2.0 + resume.frame.width*1.5, y: 0.0)
        
        panel.addChild(resume)
        
        let quit = SKSpriteNode(imageNamed: "back")
        quit.zPosition = 70.0
        quit.name = "quit"
        quit.setScale(0.7)
        quit.position = CGPoint(x: panel.frame.width/2.0 - quit.frame.width*1.5, y: 0.0)
        
        panel.addChild(quit)
    }
    
    //Check that the player touches the screen border
    func boundCheckPlayer() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        if player.position.x <= bottomLeft.x {
            player.position.x = bottomLeft.x
            lifeNode.forEach ({ $0.texture = SKTexture(imageNamed: "life-off") })
            numScore = 0
            scoreLbl.text = "\(numScore)"
            gameOver = true
        }
    }
    
    func setupGameover() {
        life -= 1
        if life <= 0 { life = 0 }
        lifeNode[life].texture = SKTexture(imageNamed: "life-off")
        
        if life <= 0 && !gameOver {
            gameOver = true
        }
    }
    
    
}

//MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        
        //if Player collision with Block then print ("Block")
        switch other.categoryBitMask {
            
        case PhysicsCategory.Block:
            cameraMovePointPerSecond += 150.0 //Increasing the movement speed of Camera
            numScore -= 1
            if numScore <= 0 {numScore = 0}
            scoreLbl.text = "\(numScore)"
            run(soundCollision)
            
        case PhysicsCategory.Obstacle:
            setupGameover()
            
        case PhysicsCategory.Coin:
            if let node = other.node {
                node.removeFromParent() //Take the coin
                numScore += 1
                scoreLbl.text = "\(numScore)"
                if numScore % 5 == 0{
                    cameraMovePointPerSecond += 100.0
                }
                
                //Use UserDefaults to save and get scores
                let highscore = ScoreGenerator.sharedInstance.getHighscore()
                if numScore > highscore {
                    ScoreGenerator.sharedInstance.setHighscore(numScore)
                    ScoreGenerator.sharedInstance.setScore(highscore)
                } else {
                    ScoreGenerator.sharedInstance.setHighscore(highscore)
                    ScoreGenerator.sharedInstance.setScore(numScore)
                }
                
                run(soundcoin) //Sound Effect
                
            }
            
        case PhysicsCategory.RedCoin:
            print("Player collided with RedCoin")
            if let node = other.node {
                node.removeFromParent() //Take the coin
                numScore += 2
                print("Score incremented by 2: \(numScore)")
                scoreLbl.text = "\(numScore)"
                if numScore % 5 == 0{
                    cameraMovePointPerSecond += 100.0
                }
                
                //Use UserDefaults to save and get scores
                let highscore = ScoreGenerator.sharedInstance.getHighscore()
                if numScore > highscore {
                    ScoreGenerator.sharedInstance.setHighscore(numScore)
                    ScoreGenerator.sharedInstance.setScore(highscore)
                } else {
                    ScoreGenerator.sharedInstance.setHighscore(highscore)
                    ScoreGenerator.sharedInstance.setScore(numScore)
                }
                
                run(soundcoin) //Sound Effect
                
                
            }
        default: break
        }
        
    }
}
