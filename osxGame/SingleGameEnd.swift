//
//  singleGameEnd.swift
//  osxGame
//
//  Created by Huang Ying-Kai on 1/31/16.
//  Copyright © 2016 Kai. All rights reserved.
//

import SpriteKit

class SingleGameEnd: SKScene {
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    let congrats = SKLabelNode(fontNamed: "Chalkduster")
    let pressbutton = SKLabelNode(fontNamed: "Chalkduster")
    let pressbutton2 = SKLabelNode(fontNamed: "Chalkduster")
    
    init(size: CGSize, score:Int) {
        
        super.init(size: size)
        
        let background = SKSpriteNode(imageNamed: "paperbackground.png") // becak ground size doesn't match
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        // background.size = CGSizeMake(self.frame.size.width, self.frame.size.height)
        background.zPosition = -5
        addChild(background)
        
        
        congrats.text = "GOOD GAME  !!!"
        congrats.fontSize = 40
        congrats.fontColor = SKColor.blackColor()
        congrats.position = CGPoint(x: size.width/2, y: size.height*6/8)
        addChild(congrats)
        
        
        scoreLabel.text = "YOUR SCORE : \(score)"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height*4/8)
        addChild(scoreLabel)
        
        pressbutton.text = "PLEASE PRESS SQUARE BUTTON TO REPLAY "
        pressbutton.fontSize = 22
        pressbutton.fontColor = SKColor.blackColor()
        pressbutton.position = CGPoint(x: size.width/2, y: size.height*2/8)
        addChild(pressbutton)
        
        pressbutton2.text = "OR SQUARE BUTTON TO REPLAY ....."
        pressbutton2.fontSize = 22
        pressbutton2.fontColor = SKColor.blackColor()
        pressbutton2.position = CGPoint(x: size.width/2, y: size.height*1/8)
        addChild(pressbutton2)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor(red: 0.5, green:0.5, blue:0.5, alpha: 0.5)
    }
    
    override func update(currentTime: NSTimeInterval) {
        if pressbutton.alpha < 0.2{
            pressbutton.alpha = 1
        }else{
            pressbutton.alpha -= 0.01
        }
        if pressbutton2.alpha < 0.2{
            pressbutton2.alpha = 1
        }else{
            pressbutton2.alpha -= 0.01
        }
        
    }
    
}
