//
//  GameViewController.swift
//  Ninja2
//
//  Created by Serena Savarese on 10/12/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = MainMenu(size: CGSize(width: 2556, height: 1179)) //iPhone 15
        scene.scaleMode = .aspectFill
        
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        skView.presentScene(scene)
    }
    
    

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
