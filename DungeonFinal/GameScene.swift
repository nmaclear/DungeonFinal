//
//  GameScene.swift
//  DungeonFinal
//
//  Created by n maclear Dev on 5/4/21.
//

import SpriteKit
import GameplayKit
import FirebaseDatabase

struct Position {
    var x: Int
    var y: Int
}

class Monster {
    var evil: Bool
    var length: Int
    var pos: Position
    var heads: [Position]

    init(evil: Bool, length: Int, pos: Position, heads: [Position]) {
        self.evil = evil
        self.length = length
        self.pos = pos
        self.heads = heads
    }
}

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var lose : SKLabelNode?
    
    var map : SKTileMapNode?
    
    var gameStart = false
    
    let cur = SKShapeNode()
    
    var curTile = [50,50]
    
    private let database = Database.database().reference()
    
    func monsterTimer(monst: Monster, texture: Int) {
        var m = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] timer in
            if(!gameStart) {
                return;
            }
            var x = Int.random(in: -1...1)
            var y = Int.random(in: -1...1)
            
            var heads = monst.heads
            
            let firstHead: Position = heads[heads.startIndex]
            
            for m in 0...heads.count-1 {
                if((heads[m].x == firstHead.x + x) && (heads[m].y == firstHead.y + y)) {
                    if((curTile[0] - heads[m].x) <= 0) {
                        x = -1
                    } else {
                        x = 1
                    }
                    if((curTile[1] - heads[m].y) <= 0) {
                        y = -1
                    } else {
                        y = 1
                    }
                }
            }
            
            heads[heads.startIndex] = Position(x: firstHead.x + x, y: firstHead.y + y)
            // create a loop that makes last index, index before... make indnex before, index before before....
            map?.setTileGroup(map?.tileSet.tileGroups[4], forColumn: heads[heads.endIndex-1].x, row: heads[heads.endIndex-1].y)
            for i in stride(from: heads.count-1, to: 0, by:-1) {
                heads[i] = Position(x: heads[i-1].x, y:heads[i-1].y)
                map?.setTileGroup(map?.tileSet.tileGroups[texture], forColumn: heads[i].x, row: heads[i].y)
                if(heads[i].x == curTile[0] && heads[i].y == curTile[1]) {
                    if(cur.strokeColor == UIColor.green) {
                        cur.strokeColor = UIColor.yellow
                    } else if(cur.strokeColor == UIColor.yellow) {
                        cur.strokeColor = UIColor.red
                    } else if(cur.strokeColor == UIColor.red) {
                        print("You're dead!")
                        endGame()
                    }
                }
            }
            monst.heads = heads
        }
    }
    
    func endGame() {
        gameStart = false
        let transition = SKTransition.doorsCloseHorizontal(withDuration: 1)
        let endScene = GameScene(size: self.frame.size)
        self.view?.presentScene(endScene, transition: transition)
    }
    
    func endGameScene() {
        
    }
    
    override func didMove(to view: SKView) {
        var monst1 = Monster(evil: true, length: 5, pos: Position(x: 50, y: 50), heads: [Position(x: 50, y: 50-1),Position(x: 50, y: 50-2),Position(x: 50, y: 50-3),Position(x: 50, y: 50-4),Position(x: 50, y: 50-5)])
        
        for z in 0...monst1.heads.count-1 {
            map?.setTileGroup(map?.tileSet.tileGroups[5], forColumn: monst1.heads[z].x, row: monst1.heads[z].y)
        }
        
        monsterTimer(monst: monst1, texture: 5)
        
        var monst2 = Monster(evil: true, length: 5, pos: Position(x: 50, y: 50), heads: [Position(x: 50, y: 50-1),Position(x: 50, y: 50-2),Position(x: 50, y: 50-3),Position(x: 50, y: 50-4),Position(x: 50, y: 50-5)])
        
        for z in 0...monst2.heads.count-1 {
            map?.setTileGroup(map?.tileSet.tileGroups[6], forColumn: monst2.heads[z].x, row: monst2.heads[z].y)
        }
        
        monsterTimer(monst: monst2, texture: 6)

        
        cur.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 128, height: 128), cornerRadius: 32).cgPath
        cur.position = CGPoint(x: frame.midX, y: frame.midY)
        cur.fillColor = UIColor.clear
        cur.strokeColor = UIColor.green
        cur.lineWidth = 8
        addChild(cur)

        self.map = self.childNode(withName: "//map") as? SKTileMapNode
        
        if let map = self.map {
            let tileSet = map.tileSet
            
            //Setup map textures
            for x in 0...map.numberOfRows-1 {
                for y in 0...map.numberOfColumns-1 {
                    map.setTileGroup(tileSet.tileGroups[4], forColumn: x, row: y)
                }
            }
        }
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//joinGame") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
            label.drawBorder(color: UIColor.blue, width: 5)
        }
    }
    
    var canPlace = false
    
    func touchDown(atPoint pos : CGPoint) {
        if(!gameStart) {
            return
        }
        
        let col = map?.tileColumnIndex(fromPosition: pos)
        let row = map?.tileRowIndex(fromPosition: pos)
        
        for i in -1...1 {
            if((col! + i) == curTile[0]) {
                print("near col")
                for j in -1...1 {
                    if((row! + j) == curTile[1]) {
                        print(i,j)
                        print("near col/row")
                        canPlace = true
                        curTile = [col!,row!]
                        database.child("player").child("x").setValue(curTile[0])
                        database.child("player").child("y").setValue(curTile[1])
                    }
                }
            }
        }
        for j in -1...1 {
            if((curTile[1] + j) == row!) {
                print("Near row")
            }
        }
        
        //map?.setTileGroup(map?.tileSet.tileGroups[3], forColumn: col!, row: row!)
        if(canPlace) {
            let s:CGPoint = map!.centerOfTile(atColumn: col!, row: row!)
            let x = s.x - 64
            let y = s.y - 64
            cur.position = CGPoint(x: x, y: y)
            let action2 = SKAction.move(to: s, duration: 0.8)
            camera?.run(action2)
            print(curTile, "pre")
            print(curTile, "post")
            canPlace = false
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
            
            if let label = self.label {
                if(label.frame.contains(t.location(in: self))) {
                    gameStart = true
                    label.run(SKAction.fadeOut(withDuration: 1.0))
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
}
extension SKLabelNode {
    func drawBorder(color: UIColor, width: CGFloat) {
        let fram = self.frame
        let dist = fram.maxX - fram.minX
        let shapeNode = SKShapeNode(rect: CGRect(x:fram.minX, y: fram.minY-50, width: dist, height: 175))
        shapeNode.fillColor = .clear
        shapeNode.strokeColor = color
        shapeNode.lineWidth = width
        addChild(shapeNode)
    }
}
