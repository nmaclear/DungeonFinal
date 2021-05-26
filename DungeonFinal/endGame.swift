//
//  endGame.swift
//  DungeonFinal
//
//  Created by n maclear Dev on 5/22/21.
//

import Foundation
import SpriteKit
import GameplayKit

class endGame: SKScene {
    
    
    var title: SKLabelNode = {
        var label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.zPosition = 2
        label.color = SKColor.gray
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = "Game Over"
        return label
    }()
    
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addNodes()
        setupNodes()
    }
    
    
    func addNodes() {
        self.addChild(title)
    }
    
    
    //MARK: - Constraints
    func setupNodes() {
        var game = GameScene()
        title.position = CGPoint(x: 0, y: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: view!.bounds.size)
        view?.presentScene(gameScene)
    }
    
}
