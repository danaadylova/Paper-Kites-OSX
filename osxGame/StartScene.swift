//
//  StartScene.swift
//  osxGame
//
//  Created by Huang Ying-Kai on 1/28/16.
//  Copyright © 2016 Kai. All rights reserved.
//

import SpriteKit

enum choice{
    case single
    case multiple
}

class StartScene: SKScene {
    let singleLabel = SKLabelNode(fontNamed: "Chalkduster")
    let multiLabel = SKLabelNode(fontNamed: "Chalkduster")
    var frame1: SKSpriteNode! = SKSpriteNode(imageNamed: "frame")
    var frame2: SKSpriteNode! = SKSpriteNode(imageNamed: "frame")
    var mychoice = choice.single
    
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        let background = SKSpriteNode(imageNamed: "paperbackground.png") // becak ground size doesn't match
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        // background.size = CGSizeMake(self.frame.size.width, self.frame.size.height)
        background.zPosition = -5
        addChild(background)

        
        multiLabel.text = "Multi-player Game"
        multiLabel.fontSize = 40
        multiLabel.fontColor = SKColor.blackColor()
        multiLabel.position = CGPointMake(size.width * 0.5, size.height * 1/4)
        multiLabel.zPosition = 2
        addChild(multiLabel)
        
        singleLabel.text = "Single-player Game"
        singleLabel.fontSize = 40
        singleLabel.fontColor = SKColor.blackColor()
        singleLabel.position = CGPointMake(size.width * 0.5, size.height * 3/4)
        singleLabel.zPosition = 2
        addChild(singleLabel)
        
        frame2.position = CGPointMake(size.width * 0.5, size.height * 1/4+5)
        frame1.position = CGPointMake(size.width * 0.5, size.height * 3/4+5)
        frame2.alpha = 0
        addChild(frame1)
        addChild(frame2)
        
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor(red: 0.5, green:0.5, blue:0.5, alpha: 0.5)
        
    }
    
//    override func mouseDown(theEvent: NSEvent) {
//        let location = theEvent.locationInNode(self)
//
//        if self.nodeAtPoint(location) == self.singleLabel{
//            mychoice = .single
//            print("single")
//        }
//        if self.nodeAtPoint(location) == self.multiLabel{
//            mychoice = .multiple
//            print("multi")
//        }
//        
//    }
    func newGame(){
        
        let newGame = GameScene(size: self.size)
        let transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
        newGame.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(newGame, transition: transition)
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        if mychoice == .single{
            frame1.alpha = 1
            if frame2.alpha >= 0{
                frame2.alpha -= 0.02
            }
            
        }
        if mychoice == .multiple{
            frame2.alpha = 1
            if frame1.alpha >= 0{
                frame1.alpha -= 0.02
            }
        }
    }
}