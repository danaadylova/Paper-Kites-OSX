//
//  ConnectingScene.swift
//  osxGame
//
//  Created by Huang Ying-Kai on 1/29/16.
//  Copyright © 2016 Kai. All rights reserved.
//

import SpriteKit

class ConnectingScene: SKScene {
    let connectingLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        let background = SKSpriteNode(imageNamed: "paperbackground.png") // becak ground size doesn't match
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        // background.size = CGSizeMake(self.frame.size.width, self.frame.size.height)
        background.zPosition = -5
        addChild(background)

        
        connectingLabel.text = "Please Connect To Your Controller ..."
        connectingLabel.fontSize = 30
        connectingLabel.fontColor = SKColor.blackColor()
        connectingLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(connectingLabel)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor(red: 0.5, green:0.5, blue:0.5, alpha: 0.5)
    }
    
    override func update(currentTime: NSTimeInterval) {
        if connectingLabel.alpha < 0.2{
            connectingLabel.alpha = 1
        }else{
            connectingLabel.alpha -= 0.01
        }
        
    }
    
}
