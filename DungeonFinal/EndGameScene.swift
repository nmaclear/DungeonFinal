//
//  EndGameScene.swift
//  DungeonFinal
//
//  Created by n maclear Dev on 5/25/21.
//

import Foundation
import GameKit
import SpriteKit

class EndGameScene: SKScene {

    override func didMove(to view: SKView) -> Void {
        backgroundColor = UIColor.orange
        let transition = SKTransition.fade(with: .blue, duration: 5)
        let endScene = GameScene()
        endScene.size = CGSize(width: 300, height: 400)
        self.view?.presentScene(endScene, transition: transition)
    }
    
    
}
