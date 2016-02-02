//
//  Multi_GameScene.swift
//  osxGame
//
//  Created by Huang Ying-Kai on 1/30/16.
//  Copyright © 2016 Kai. All rights reserved.
//


import SpriteKit
import MultipeerConnectivity

class Multi_GameScene: SKScene, SKPhysicsContactDelegate {
    
    var kiteY: SKSpriteNode!
    var kiteYtail: [SKSpriteNode]!
    var kiteR: SKSpriteNode!
    var kiteRtail: [SKSpriteNode]!
    var player1: MCPeerID!
    var player2: MCPeerID!
    
    var rainstart = 0   //for raining
    var rainend = 0     //for raining
    var hailstart = 0   //for hailing
    var hailend = 0     //for hailing
    
    var time = 0
    
    var birdkiteYheadTouch = 0
    var headkiteYTouch = 0
    
    var birdkiteRheadTouch = 0
    var headkiteRTouch = 0
    
    var countRTailRemoval = 0
    var countYTailRemoval = 0
    var countEnemyTailRemove = 0 // For trying to kill enemy
    
    enum ColliderType:  UInt32 {
        case kiteYHead = 1
        case kiteYTail = 2
        case droplet = 4
        case hail = 8
        case bird = 16
        case kiteRHead = 32
        case kiteRTail = 64
        case baloon = 128
    }
    
    var backSound = SKAction()
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        backSound = SKAction .playSoundFileNamed("More-Monkey-Island-Band.mp3", waitForCompletion: true)
        runAction(backSound)
        let background = SKSpriteNode(imageNamed: "paperbackground.png") // becak ground size doesn't match
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.zPosition = -5
        addChild(background)
        
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "scorePlus", userInfo: nil, repeats: true)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(4), target: self, selector: "letTheBaloonFly", userInfo: nil, repeats: true) // Put a baloon

        kiteYtail = [SKSpriteNode]()
        kiteRtail = [SKSpriteNode]()

        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addBlueCloud),SKAction.waitForDuration(10.0)])))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addGrayCloud),SKAction.waitForDuration(4.0)])))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addrain),SKAction.waitForDuration(0.5)])))
        

        // new yellow kite
        kiteY = SKSpriteNode(imageNamed: "KiteY.png")
        kiteY.position = CGPointMake(size.width * 0.7, size.height * 0.5)
        kiteY.physicsBody = SKPhysicsBody(circleOfRadius:kiteY.frame.size.width/2)
        kiteY.physicsBody!.linearDamping = 1.0
        kiteY.physicsBody!.affectedByGravity = false            // only the head isn't affected by gravity
//        kiteY.physicsBody!.collisionBitMask = 0
        kiteY.physicsBody!.categoryBitMask = ColliderType.kiteYHead.rawValue // set collisionBitmask
        kiteY.physicsBody?.contactTestBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue | ColliderType.kiteRTail.rawValue | ColliderType.baloon.rawValue
        kiteY.physicsBody?.collisionBitMask = ColliderType.kiteYHead.rawValue
        
        let c = SKConstraint.positionX(SKRange(lowerLimit: 0, upperLimit: self.frame.size.width), y: SKRange(lowerLimit: 0, upperLimit: self.frame.size.height))
        kiteY.constraints = [c]

        self.addChild(kiteY)
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -1.0)  // put a little gravity in the world
        
        var constraint: SKConstraint!
        
        // new yellow kitetail
        for i in 0...125 {
            
            if i%21 == 0 && i != 0{
                kiteYtail.append(SKSpriteNode(imageNamed: "tailY.png"))
                
                kiteYtail[i].position = CGPointMake(kiteY.position.x, kiteY.position.y - 20 - 10*CGFloat(i))
                kiteYtail[i].physicsBody = SKPhysicsBody(rectangleOfSize: kiteYtail[i].frame.size)
                kiteYtail[i].physicsBody!.linearDamping = 1.0
                kiteYtail[i].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                kiteYtail[i].physicsBody!.collisionBitMask = 0
                constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteYtail[i-1])
                kiteYtail[i].constraints = [constraint]
                kiteYtail[i].zPosition = -1
                
            }else{
                kiteYtail.append(SKSpriteNode(imageNamed: "rope.png"))
                if i == 0{
                    kiteYtail[i].position = CGPointMake(kiteY.position.x, kiteY.position.y - 20)
                }else{
                    kiteYtail[i].position = CGPointMake(kiteY.position.x, kiteYtail[i-1].position.y - 2)
                }
                kiteYtail[i].physicsBody = SKPhysicsBody(rectangleOfSize: kiteYtail[i].frame.size)
                kiteYtail[i].physicsBody!.linearDamping = 1.0
                kiteYtail[i].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                kiteYtail[i].physicsBody!.collisionBitMask = 0
                if i > 0{       // the constraint for the tails except the first one
                    constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteYtail[i-1])
                    kiteYtail[i].constraints = [constraint]
                }else{          // the constraint of the first bow tie should derive from the kite head
                    constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 16), toNode: kiteY)
                    kiteYtail[i].constraints = [constraint]
                }
                kiteYtail[i].zPosition = -2
            }
            
            if i%7 == 0{
                kiteYtail[i].physicsBody!.contactTestBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue | ColliderType.kiteRHead.rawValue
            }
            kiteYtail[i].physicsBody?.collisionBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue
            kiteYtail[i].physicsBody?.categoryBitMask = ColliderType.kiteYTail.rawValue
            self.addChild(kiteYtail[i])
        }
        
        
        // new red kite
        kiteR = SKSpriteNode(imageNamed: "KiteR.png")
        kiteR.position = CGPointMake(size.width * 0.3, size.height * 0.5)
        kiteR.physicsBody = SKPhysicsBody(circleOfRadius:kiteR.frame.size.width/2)
        kiteR.physicsBody!.linearDamping = 1.0
        kiteR.physicsBody!.affectedByGravity = false            // only the head isn't affected by gravity
//        kiteR.physicsBody!.collisionBitMask = 0
        kiteR.physicsBody!.categoryBitMask = ColliderType.kiteRHead.rawValue // set collisionBitmask
        kiteR.physicsBody?.contactTestBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue | ColliderType.kiteYTail.rawValue | ColliderType.baloon.rawValue
        kiteR.physicsBody?.collisionBitMask = ColliderType.kiteRHead.rawValue
        kiteR.constraints = [c]

        self.addChild(kiteR)
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -3.0)  // put a little gravity in the world
        
        
        // new red kitetail
        for i in 0...125 {
            
            if i%21 == 0 && i != 0{
                kiteRtail.append(SKSpriteNode(imageNamed: "tailR.png"))
                
                kiteRtail[i].position = CGPointMake(kiteR.position.x, kiteR.position.y - 20 - 10*CGFloat(i))
                kiteRtail[i].physicsBody = SKPhysicsBody(rectangleOfSize: kiteRtail[i].frame.size)
                kiteRtail[i].physicsBody!.linearDamping = 1.0
                kiteRtail[i].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                kiteRtail[i].physicsBody!.collisionBitMask = 0
                constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteRtail[i-1])
                kiteRtail[i].constraints = [constraint]
                kiteRtail[i].zPosition = -1
                
            }else{
                kiteRtail.append(SKSpriteNode(imageNamed: "rope.png"))
                if i == 0{
                    kiteRtail[i].position = CGPointMake(kiteR.position.x, kiteR.position.y - 20)
                }else{
                    kiteRtail[i].position = CGPointMake(kiteR.position.x, kiteRtail[i-1].position.y - 2)
                }
                kiteRtail[i].physicsBody = SKPhysicsBody(rectangleOfSize: kiteRtail[i].frame.size)
                kiteRtail[i].physicsBody!.linearDamping = 1.0
                kiteRtail[i].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                kiteRtail[i].physicsBody!.collisionBitMask = 0
                if i > 0{       // the constraint for the tails except the first one
                    constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteRtail[i-1])
                    kiteRtail[i].constraints = [constraint]
                }else{          // the constraint of the first bow tie should derive from the kite head
                    constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 16), toNode: kiteR)
                    kiteRtail[i].constraints = [constraint]
                }
                kiteRtail[i].zPosition = -2
            }
            if i%7 == 0{
                kiteRtail[i].physicsBody!.contactTestBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue | ColliderType.kiteYHead.rawValue
            }
            kiteRtail[i].physicsBody?.collisionBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue
            kiteRtail[i].physicsBody?.categoryBitMask = ColliderType.kiteRTail.rawValue

            self.addChild(kiteRtail[i])
        }
        
    }
    
     
    func end(location location: CGPoint){
        
        var dx = location.x - kiteY.position.x
        var dy = location.y - kiteY.position.y
        
        adjustImpulse(dx: &dx , dy: &dy)
        
        let kiteimpulse = CGVectorMake(dx, dy)
        
        kiteY.physicsBody?.applyImpulse(kiteimpulse)
        
        
        dx = kiteY.position.x - kiteYtail[0].position.x
        dy = kiteY.position.y - kiteYtail[0].position.y
        
        adjustImpulse(dx: &dx , dy: &dy)
        
        var impulse = CGVectorMake(dx+kiteimpulse.dx, dy+kiteimpulse.dy)
        kiteYtail[0].physicsBody?.applyImpulse(impulse)
        
        for i in 1...kiteYtail.count-1{
            dx = kiteYtail[i-1].position.x - kiteYtail[i].position.x
            dy = kiteYtail[i-1].position.y - kiteYtail[i].position.y
            
            adjustImpulse(dx: &dx , dy: &dy)
            
            impulse = CGVectorMake(dx+kiteimpulse.dx, dy+kiteimpulse.dy)
            kiteYtail[i].physicsBody?.applyImpulse(impulse)
            
        }
        
        // kite head rotates back to 0 angle
        let rotateAction = SKAction.rotateToAngle(0, duration: 4.0)
        kiteY.runAction(rotateAction, withKey: "kiteRotata")
        
        for i in 0...kiteYtail.count-1{
            kiteYtail[i].physicsBody!.affectedByGravity = true
        }
        
        
    }
    
    func moveKiteY(location location: CGPoint){
        
        // rotation and move for the kite
        // get ready for moving the tail
        var tail2move = [CGPoint]()
        tail2move.append(kiteY.position)
        
        var move = SKAction.moveTo(location,duration:0.5)
        if(CGRectContainsPoint(self.frame, location)){
            kiteY.runAction(move)       // move the kite
        }
    }
    func rotateKiteY(location location: CGPoint){
        // the following 3 lines are for calculating the angle between the current location and new location
        var dx = location.x - kiteY.position.x
        var dy = location.y - kiteY.position.y
        var angle = atan2(dy, dx)
        
        
        if angle - kiteY.zRotation > CGFloat(M_PI) {    // this one is fucking insane
            angle += CGFloat(2*M_PI)
        } else if kiteY.zRotation - angle > CGFloat(M_PI) { // it's about nothing but math
            angle -= CGFloat(2*M_PI)
        }
        angle -= CGFloat(M_PI/2)    // adjust the direction
        
        kiteY.removeActionForKey("kiteRotata") // when the kite stop, it will rotate back to 0 angle gradually, disable it in order to change assign a angle to kiteG
        
        kiteY.zRotation = angle
        
        // get the angle between kiteG and the first bow tie
        // roataion of the first bow tie
        dx = kiteY.position.x - kiteYtail[0].position.x
        dy = kiteY.position.y - kiteYtail[0].position.y
        angle = atan2(dy, dx) - CGFloat(M_PI/2)   // adjust the angle like above
        
        
        var rotateAction = SKAction.rotateToAngle(angle, duration: 0.4)
        kiteYtail[0].runAction(rotateAction)
        
        
        // rotation for the rest of the bow ties using for looop
        var taildx = [CGFloat]()
        var taildy = [CGFloat]()
        var tailangle = [CGFloat]()
        
        for i in 0...kiteYtail.count - 2 {
            taildx.append(kiteYtail[i].position.x - kiteYtail[i+1].position.x)
            taildy.append(kiteYtail[i].position.y - kiteYtail[i+1].position.y)
            tailangle.append(atan2(taildy[i], taildx[i])-1.507)
            rotateAction = SKAction.rotateToAngle(tailangle[i], duration: 0.4)
            kiteYtail[i+1].runAction(rotateAction)
        }
    }
    
    
    func moveKiteR(location location: CGPoint){
        
        // rotation and move for the kite
        // get ready for moving the tail
        var tail2move = [CGPoint]()
        tail2move.append(kiteR.position)
        
        var move = SKAction.moveTo(location,duration:0.5)
        if(CGRectContainsPoint(self.frame, location)){
            kiteR.runAction(move)       // move the kite
        }
    }

    
    func rotateKiteR(location location: CGPoint){
        // the following 3 lines are for calculating the angle between the current location and new location
        var dx = location.x - kiteR.position.x
        var dy = location.y - kiteR.position.y
        var angle = atan2(dy, dx)
        
        
        if angle - kiteR.zRotation > CGFloat(M_PI) {    // this one is fucking insane
            angle += CGFloat(2*M_PI)
        } else if kiteR.zRotation - angle > CGFloat(M_PI) { // it's about nothing but math
            angle -= CGFloat(2*M_PI)
        }
        angle -= CGFloat(M_PI/2)    // adjust the direction
        
        kiteR.removeActionForKey("kiteRotata") // when the kite stop, it will rotate back to 0 angle gradually, disable it in order to change assign a angle to kiteG
        
        kiteR.zRotation = angle
        
        // get the angle between kiteG and the first bow tie
        // roataion of the first bow tie
        dx = kiteR.position.x - kiteRtail[0].position.x
        dy = kiteR.position.y - kiteRtail[0].position.y
        angle = atan2(dy, dx) - CGFloat(M_PI/2)   // adjust the angle like above
        
        
        var rotateAction = SKAction.rotateToAngle(angle, duration: 0.4)
        kiteRtail[0].runAction(rotateAction)
    
        // rotation for the rest of the bow ties using for looop
        var taildx = [CGFloat]()
        var taildy = [CGFloat]()
        var tailangle = [CGFloat]()
        
        for i in 0...kiteRtail.count - 2 {
            taildx.append(kiteRtail[i].position.x - kiteRtail[i+1].position.x)
            taildy.append(kiteRtail[i].position.y - kiteRtail[i+1].position.y)
            tailangle.append(atan2(taildy[i], taildx[i])-1.507)
            rotateAction = SKAction.rotateToAngle(tailangle[i], duration: 0.4)
            kiteRtail[i+1].runAction(rotateAction)
        }
    }

    
    func adjustImpulse(inout dx dx: CGFloat, inout dy: CGFloat){
        // to prevent the impulse from being too large
        
        let threshold: CGFloat = 2.1
        if dx > threshold{
            dx = threshold
        }else if dx < -threshold{
            dx = -threshold
        }
        if dy > threshold{
            dy = threshold
        }else if dy < -threshold{
            dy = -threshold
        }
        
    }
    func addBlueCloud(){
        
        let cloud = SKSpriteNode(imageNamed: "bluecloud\(randomNumber(1...4)).png")
        let actualY = random(min: cloud.size.height/2, max: size.height - cloud.size.height/2)
        let actionMove: SKAction!
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        if randomNumber(0...1) == 1{
            cloud.position = CGPoint(x: size.width + cloud.size.width/2, y: actualY)
            actionMove = SKAction.moveTo(CGPoint(x: -cloud.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration*2.5))
            
        }else{
            cloud.position = CGPoint(x: -cloud.size.width/2, y: actualY)
            actionMove = SKAction.moveTo(CGPoint(x: size.width + cloud.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration*2.5))
            
        }
        addChild(cloud)
        
        // Create the actions
        let actionMoveDone = SKAction.removeFromParent()
        cloud.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addGrayCloud(){
        
        let cloud = SKSpriteNode(imageNamed: "graycloud\(randomNumber(1...4)).png")
        let actualY = random(min: cloud.size.height/2, max: size.height - cloud.size.height/2)
        let actionMove: SKAction!
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        if randomNumber(0...1) == 1{
            cloud.position = CGPoint(x: size.width + cloud.size.width/2, y: actualY)
            actionMove = SKAction.moveTo(CGPoint(x: -cloud.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration*2.5))
            
        }else{
            cloud.position = CGPoint(x: -cloud.size.width/2, y: actualY)
            actionMove = SKAction.moveTo(CGPoint(x: size.width + cloud.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration*2.5))
        }
        addChild(cloud)
        rainstart++
        cloud.name = "rain\(self.rainstart)"
        // Determine speed of the cloud
        
        // Create the actions
        let actionMoveDone = SKAction.removeFromParent()
        cloud.runAction(SKAction.sequence([actionMove,SKAction.runBlock({self.rainend++}), actionMoveDone]))
    }
    
    func addrain(){
        var position = [CGPoint]()
        for i in self.rainend...self.rainstart {
            if let temp =  self.childNodeWithName("rain\(i)")?.position{
                position.append(temp)
            }
        }
        if position.count > 0{
            for i in 0...position.count-1{
                let dropPerCloud = 4
                for _ in 1...dropPerCloud {
                    let drop = SKSpriteNode(imageNamed: "drop.png")
                    let cd = SKSpriteNode(imageNamed: "graycloud1.png")
                    let randomX = random(min: -cd.size.width/2 , max: cd.size.width/2 )
                    let randomY = random(min: -cd.size.height/2 , max: cd.size.height/2 )
                    drop.position = CGPoint(x: position[i].x+randomX, y: position[i].y-cd.size.height/2-randomY)
                    drop.physicsBody = SKPhysicsBody(circleOfRadius: drop.size.width/2)
                    drop.physicsBody!.linearDamping = 1.0
                    drop.physicsBody!.affectedByGravity = true
                    drop.zPosition = -1
                    drop.physicsBody?.categoryBitMask = ColliderType.droplet.rawValue
                    //       drop.physicsBody!.contactTestBitMask = ColliderType.kiteHead.rawValue
                    //                drop.physicsBody!.collisionBitMask = 0
                    self.addChild(drop)
                    
                    let actionMoveDone = SKAction.removeFromParent()
                    drop.runAction(SKAction.sequence([SKAction.waitForDuration(5), actionMoveDone]))
                }
            }
        }
    }
    
    func addDarkCloud(){
        
        let cloud = SKSpriteNode(imageNamed: "darkcloud\(randomNumber(1...4)).png")
        let actualY = random(min: cloud.size.height/2, max: size.height - cloud.size.height/2)
        let actionMove: SKAction!
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        if randomNumber(0...1) == 1{
            cloud.position = CGPoint(x: size.width + cloud.size.width/2, y: actualY)
            actionMove = SKAction.moveTo(CGPoint(x: -cloud.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration*2.5))
            
        }else{
            cloud.position = CGPoint(x: -cloud.size.width/2, y: actualY)
            actionMove = SKAction.moveTo(CGPoint(x: size.width + cloud.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration*2.5))
        }
        addChild(cloud)
        hailstart++
        cloud.name = "hail\(self.hailstart)"
        // Determine speed of the cloud
        
        // Create the actions
        let actionMoveDone = SKAction.removeFromParent()
        
        cloud.runAction(SKAction.sequence([actionMove,SKAction.runBlock({self.hailend++}), actionMoveDone]))
    }
    
    
    func addhail(){
        
        var position = [CGPoint]()
        for i in self.hailend...self.hailstart {
            if let temp =  self.childNodeWithName("hail\(i)")?.position{
                position.append(temp)
            }
        }
        if position.count > 0{
            for i in 0...position.count-1{
                let hailPerCloud = 4
                for _ in 1...hailPerCloud {
                    let hail = SKSpriteNode(imageNamed: "spark.png")
                    hail.setScale(random(min:1, max:10)/10)
                    let cd = SKSpriteNode(imageNamed: "darkcloud1.png")
                    let randomX = random(min: -cd.size.width/2 , max: cd.size.width/2 )
                    let randomY = random(min: -cd.size.height/2 , max: cd.size.height/2 )
                    hail.position = CGPoint(x: position[i].x+randomX, y: position[i].y-cd.size.height/2-randomY)
                    hail.physicsBody = SKPhysicsBody(circleOfRadius: hail.size.width/2)
                    hail.physicsBody!.linearDamping = 1.0
                    hail.physicsBody!.affectedByGravity = true
                    hail.zPosition = -1
                    hail.physicsBody?.categoryBitMask = ColliderType.hail.rawValue
                    let fadeOut = SKAction .fadeOutWithDuration(0.5)
                    let fadeIn = SKAction .fadeInWithDuration(0.5)
                    let sequence = SKAction .sequence([fadeOut, fadeIn])
                    hail .runAction(sequence)
                    self.addChild(hail)
                    let actionMoveDone = SKAction.removeFromParent()
                    hail.runAction(SKAction.sequence([SKAction.waitForDuration(5), actionMoveDone]))
                }
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.categoryBitMask == ColliderType.kiteYHead.rawValue || bodyB.categoryBitMask == ColliderType.kiteYHead.rawValue {
            
            if bodyA.categoryBitMask == ColliderType.droplet.rawValue || bodyB.categoryBitMask == ColliderType.droplet.rawValue { // Collision with a droplet
                if (bodyA.categoryBitMask == ColliderType.droplet.rawValue) {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyA.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }else{
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyB.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }
                self.headkiteYTouch += 5
            } else if bodyA.categoryBitMask == ColliderType.hail.rawValue || bodyB.categoryBitMask == ColliderType.hail.rawValue { // Collision with a hail piece
                if (bodyA.categoryBitMask == ColliderType.hail.rawValue) {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyA.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }else{
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyB.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }
                self.headkiteYTouch += 10
            }else if bodyA.categoryBitMask == ColliderType.bird.rawValue || bodyB.categoryBitMask == ColliderType.bird.rawValue { // Collision with a bird piece
                //                debugLabel.text = "BIRDDDD and head"
                dispatch_async(dispatch_get_main_queue()) { // 2
                    self.birdkiteYheadTouch = self.birdkiteYheadTouch + 10
                }
            } else if (bodyA.categoryBitMask == ColliderType.kiteRTail.rawValue || bodyB.categoryBitMask == ColliderType.kiteRTail.rawValue) {
                ////////////////////////////////// DANA
                if countEnemyTailRemove == 4 {
                    kiteRtail[kiteRtail.count - 1].constraints = nil
                    kiteRtail.removeLast()
                    countEnemyTailRemove = 0
                } else {
                    countEnemyTailRemove += 1
                }
            } else if bodyA.categoryBitMask == ColliderType.baloon.rawValue || bodyB.categoryBitMask == ColliderType.baloon.rawValue { // Collision with a bird piece
                var didGetLife = false
                if randomNumber(1...10) < 4 { // Add a life
                    didGetLife = true
                    var constraint = SKConstraint()
                    for _ in 0...10 {
                        if kiteYtail.count%21 == 0 {
                            kiteYtail.append(SKSpriteNode(imageNamed: "tailY.png"))
                            kiteYtail[kiteYtail.count-1].position = CGPointMake(kiteY.position.x, kiteY.position.y - 20 - 10*CGFloat(kiteYtail.count-1))
                            kiteYtail[kiteYtail.count-1].physicsBody = SKPhysicsBody(rectangleOfSize: kiteYtail[kiteYtail.count-1].frame.size)
                            kiteYtail[kiteYtail.count-1].physicsBody!.linearDamping = 1.0
                            kiteYtail[kiteYtail.count-1].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                            constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteYtail[kiteYtail.count-2])
                            kiteYtail[kiteYtail.count-1].constraints = [constraint]
                            kiteYtail[kiteYtail.count-1].zPosition = -1
                            self.addChild(kiteYtail[kiteYtail.count-1])
                        }else {
                            kiteYtail.append(SKSpriteNode(imageNamed: "rope.png"))
                            if kiteYtail.count - 1 == 0{
                                kiteYtail[0].position = CGPointMake(kiteY.position.x, kiteY.position.y - 20)
                            }else{
                                kiteYtail[kiteYtail.count - 1].position = CGPointMake(kiteY.position.x, kiteYtail[kiteYtail.count-2].position.y - 2)
                            }
                            kiteYtail[kiteYtail.count - 1].physicsBody = SKPhysicsBody(rectangleOfSize: kiteYtail[kiteYtail.count - 1].frame.size)
                            kiteYtail[kiteYtail.count - 1].physicsBody!.linearDamping = 1.0
                            kiteYtail[kiteYtail.count - 1].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                            if kiteYtail.count - 1 > 0{       // the constraint for the tails except the first one
                                constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteYtail[kiteYtail.count-2])
                                kiteYtail[kiteYtail.count - 1].constraints = [constraint]
                            }else{          // the constraint of the first bow tie should derive from the kite head
                                constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 16), toNode: kiteY)
                                kiteYtail[kiteYtail.count - 1].constraints = [constraint]
                            }
                            kiteYtail[kiteYtail.count - 1].zPosition = -2
                            self.addChild(kiteYtail[kiteYtail.count-1])
                        }
                        if (kiteYtail.count - 1)%7 == 0{
                            kiteYtail[kiteYtail.count - 1].physicsBody!.contactTestBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue | ColliderType.bird.rawValue
                        }
                        kiteYtail[kiteYtail.count - 1].physicsBody!.collisionBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue
                        kiteYtail[kiteYtail.count - 1].physicsBody?.categoryBitMask = ColliderType.kiteYTail.rawValue
                    }
                }
                var pos = CGPoint()
                var oblachko = SKSpriteNode()
                if bodyA.categoryBitMask == ColliderType.baloon.rawValue {
                    pos = CGPoint(x: CGFloat((bodyA.node?.position.x)!), y: CGFloat((bodyA.node?.position.y)! + (bodyA.node?.frame.height)!*0.2))
                    bodyA.node?.removeFromParent()
                    if didGetLife { // Explosion animation with life
                        oblachko = SKSpriteNode(imageNamed: "baloon_life.png")
                    } else { // Explosion animation without  life
                        oblachko = SKSpriteNode(imageNamed: "baloon_nolife.png")
                    }
                } else {
                    pos = CGPoint(x: CGFloat((bodyB.node?.position.x)!), y: CGFloat((bodyB.node?.position.y)! + (bodyB.node?.frame.height)!*0.2))
                    bodyB.node?.removeFromParent()
                    if didGetLife { // Explosion animation with life
                        oblachko = SKSpriteNode(imageNamed: "baloon_life.png")
                    } else { // Explosion animation without  life
                        oblachko = SKSpriteNode(imageNamed: "baloon_nolife.png")
                    }
                }
                oblachko.position = CGPoint(x:pos.x, y: pos.y*1.5)
                oblachko.alpha = 0
                self.addChild(oblachko)
                runAction(SKAction .playSoundFileNamed("Pop.mp3", waitForCompletion: false))
                oblachko.runAction(SKAction.sequence([SKAction .fadeInWithDuration(1), SKAction .fadeOutWithDuration(1), SKAction .removeFromParent()]))
            }
            // red from below
        }else if bodyA.categoryBitMask == ColliderType.kiteRHead.rawValue || bodyB.categoryBitMask == ColliderType.kiteRHead.rawValue {
            
            if bodyA.categoryBitMask == ColliderType.droplet.rawValue || bodyB.categoryBitMask == ColliderType.droplet.rawValue { // Collision with a droplet
                if (bodyA.categoryBitMask == ColliderType.droplet.rawValue) {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyA.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }else{
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyB.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }
                self.headkiteRTouch += 5
                
            } else if bodyA.categoryBitMask == ColliderType.hail.rawValue || bodyB.categoryBitMask == ColliderType.hail.rawValue { // Collision with a hail piece
                if (bodyA.categoryBitMask == ColliderType.hail.rawValue) {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyA.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }else{
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyB.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }
                self.headkiteRTouch += 10
            }else if bodyA.categoryBitMask == ColliderType.bird.rawValue || bodyB.categoryBitMask == ColliderType.bird.rawValue { // Collision with a bird piece
                //                debugLabel.text = "BIRDDDD and head"
                dispatch_async(dispatch_get_main_queue()) { // 2
                    self.birdkiteRheadTouch = self.birdkiteRheadTouch + 10
                }
            } else if (bodyA.categoryBitMask == ColliderType.kiteYTail.rawValue || bodyB.categoryBitMask == ColliderType.kiteYTail.rawValue) {
                ////////////////////////////////// DANA
                if countEnemyTailRemove == 4 {
                    kiteYtail[kiteYtail.count - 1].constraints = nil
                    kiteYtail.removeLast()
                    countEnemyTailRemove = 0
                } else {
                    countEnemyTailRemove += 1
                }
            } else if bodyA.categoryBitMask == ColliderType.baloon.rawValue || bodyB.categoryBitMask == ColliderType.baloon.rawValue { // Collision with a bird piece
                var didGetLife = false
                if randomNumber(1...10) < 4 { // Add a life
                    didGetLife = true
                    var constraint = SKConstraint()
                    for _ in 0...10 {
                        if kiteRtail.count%21 == 0 {
                            kiteRtail.append(SKSpriteNode(imageNamed: "tailY.png"))
                            kiteRtail[kiteRtail.count-1].position = CGPointMake(kiteR.position.x, kiteR.position.y - 20 - 10*CGFloat(kiteRtail.count-1))
                            kiteRtail[kiteRtail.count-1].physicsBody = SKPhysicsBody(rectangleOfSize: kiteRtail[kiteRtail.count-1].frame.size)
                            kiteRtail[kiteRtail.count-1].physicsBody!.linearDamping = 1.0
                            kiteRtail[kiteRtail.count-1].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                            constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteRtail[kiteRtail.count-2])
                            kiteRtail[kiteRtail.count-1].constraints = [constraint]
                            kiteRtail[kiteRtail.count-1].zPosition = -1
                            self.addChild(kiteRtail[kiteRtail.count-1])
                        }else {
                            kiteRtail.append(SKSpriteNode(imageNamed: "rope.png"))
                            if kiteRtail.count - 1 == 0{
                                kiteRtail[0].position = CGPointMake(kiteR.position.x, kiteR.position.y - 20)
                            }else{
                                kiteRtail[kiteRtail.count - 1].position = CGPointMake(kiteR.position.x, kiteRtail[kiteRtail.count-2].position.y - 2)
                            }
                            kiteRtail[kiteRtail.count - 1].physicsBody = SKPhysicsBody(rectangleOfSize: kiteRtail[kiteRtail.count - 1].frame.size)
                            kiteRtail[kiteRtail.count - 1].physicsBody!.linearDamping = 1.0
                            kiteRtail[kiteRtail.count - 1].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                            if kiteRtail.count - 1 > 0{       // the constraint for the tails except the first one
                                constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteRtail[kiteRtail.count-2])
                                kiteRtail[kiteRtail.count - 1].constraints = [constraint]
                            }else{          // the constraint of the first bow tie should derive from the kite head
                                constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 16), toNode: kiteR)
                                kiteRtail[kiteRtail.count - 1].constraints = [constraint]
                            }
                            kiteRtail[kiteRtail.count - 1].zPosition = -2
                            self.addChild(kiteRtail[kiteRtail.count-1])
                        }
                        if (kiteRtail.count - 1)%7 == 0{
                            kiteRtail[kiteRtail.count - 1].physicsBody!.contactTestBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue | ColliderType.bird.rawValue
                        }
                        kiteRtail[kiteRtail.count - 1].physicsBody!.collisionBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue
                        kiteRtail[kiteRtail.count - 1].physicsBody?.categoryBitMask = ColliderType.kiteRTail.rawValue
                    }
                }
                var pos = CGPoint()
                var oblachko = SKSpriteNode()
                if bodyA.categoryBitMask == ColliderType.baloon.rawValue {
                    pos = CGPoint(x: CGFloat((bodyA.node?.position.x)!), y: CGFloat((bodyA.node?.position.y)! + (bodyA.node?.frame.height)!*0.2))
                    bodyA.node?.removeFromParent()
                    if didGetLife { // Explosion animation with life
                        oblachko = SKSpriteNode(imageNamed: "baloon_life.png")
                    } else { // Explosion animation without  life
                        oblachko = SKSpriteNode(imageNamed: "baloon_nolife.png")
                    }
                } else {
                    pos = CGPoint(x: CGFloat((bodyB.node?.position.x)!), y: CGFloat((bodyB.node?.position.y)! + (bodyB.node?.frame.height)!*0.2))
                    bodyB.node?.removeFromParent()
                    if didGetLife { // Explosion animation with life
                        oblachko = SKSpriteNode(imageNamed: "baloon_life.png")
                    } else { // Explosion animation without  life
                        oblachko = SKSpriteNode(imageNamed: "baloon_nolife.png")
                    }
                }
                oblachko.position = CGPoint(x:pos.x, y: pos.y*1.5)
                oblachko.alpha = 0
                self.addChild(oblachko)
                runAction(SKAction .playSoundFileNamed("Pop.mp3", waitForCompletion: false))
                oblachko.runAction(SKAction.sequence([SKAction .fadeInWithDuration(1), SKAction .fadeOutWithDuration(1), SKAction .removeFromParent()]))
            }
        } else if bodyA.categoryBitMask == ColliderType.kiteYTail.rawValue || bodyB.categoryBitMask == ColliderType.kiteYTail.rawValue { // Its a kite tail
            if bodyA.categoryBitMask == ColliderType.droplet.rawValue || bodyB.categoryBitMask == ColliderType.droplet.rawValue { // Collision with a droplet
                kiteYtail[kiteYtail.count - 1].constraints = nil
                kiteYtail.removeLast()
                kiteYtail[kiteYtail.count - 1].constraints = nil
                kiteYtail.removeLast()
                if (bodyA.categoryBitMask == ColliderType.droplet.rawValue) {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyA.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }else {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyB.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }
                
            } else if bodyA.categoryBitMask == ColliderType.hail.rawValue || bodyB.categoryBitMask == ColliderType.hail.rawValue { // Collision with a hail piece
                kiteYtail[kiteYtail.count - 1].constraints = nil
                kiteYtail.removeLast()
                kiteYtail[kiteYtail.count - 1].constraints = nil
                kiteYtail.removeLast()
                kiteYtail[kiteYtail.count - 1].constraints = nil
                kiteYtail.removeLast()
                kiteYtail[kiteYtail.count - 1].constraints = nil
                kiteYtail.removeLast()
                kiteYtail[kiteYtail.count - 1].constraints = nil
                kiteYtail.removeLast()
                if (bodyA.categoryBitMask == ColliderType.hail.rawValue) {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyA.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }else {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyB.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }
            }else if bodyA.categoryBitMask == ColliderType.bird.rawValue || bodyB.categoryBitMask == ColliderType.bird.rawValue { // Collision with a bird
                //                debugLabel.text = "BIRDDDD and tail"
                dispatch_async(dispatch_get_main_queue()) { // 2
                    self.birdkiteYheadTouch = self.birdkiteYheadTouch + 1
                }
            }
            
        } else if bodyA.categoryBitMask == ColliderType.kiteRTail.rawValue || bodyB.categoryBitMask == ColliderType.kiteRTail.rawValue { // Its a kite tail
            if bodyA.categoryBitMask == ColliderType.droplet.rawValue || bodyB.categoryBitMask == ColliderType.droplet.rawValue { // Collision with a droplet
                kiteRtail[kiteRtail.count - 1].constraints = nil
                kiteRtail.removeLast()
                kiteRtail[kiteRtail.count - 1].constraints = nil
                kiteRtail.removeLast()
                //                debugLabel.text = "Collision"
                if (bodyA.categoryBitMask == ColliderType.droplet.rawValue) {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyA.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }else {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyB.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }
                
            } else if bodyA.categoryBitMask == ColliderType.hail.rawValue || bodyB.categoryBitMask == ColliderType.hail.rawValue { // Collision with a hail piece
                kiteRtail[kiteRtail.count - 1].constraints = nil
                kiteRtail.removeLast()
                kiteRtail[kiteRtail.count - 1].constraints = nil
                kiteRtail.removeLast()
                kiteRtail[kiteRtail.count - 1].constraints = nil
                kiteRtail.removeLast()
                kiteRtail[kiteRtail.count - 1].constraints = nil
                kiteRtail.removeLast()
                kiteRtail[kiteRtail.count - 1].constraints = nil
                kiteRtail.removeLast()
                
                if (bodyA.categoryBitMask == ColliderType.hail.rawValue) {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyA.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }else {
                    let actionMoveDone = SKAction.removeFromParent()
                    let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                    bodyB.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                }
            } else if bodyA.categoryBitMask == ColliderType.bird.rawValue || bodyB.categoryBitMask == ColliderType.bird.rawValue { // Collision with a bird
                //                debugLabel.text = "BIRDDDD and tail"
                dispatch_async(dispatch_get_main_queue()) { // 2
                    self.birdkiteRheadTouch = self.birdkiteRheadTouch + 1
                }
            }
        }
    }

    func applyWind () {
        self.physicsWorld.gravity = CGVector(dx: 10 - Int(arc4random_uniform(20)) , dy: 0 - Int(arc4random_uniform(10)))
        kiteR.physicsBody?.mass = 1
        kiteR.physicsBody?.affectedByGravity = false
        kiteY.physicsBody!.mass = 1
        kiteY.physicsBody?.affectedByGravity = false
        runAction(SKAction .playSoundFileNamed("Wind.mp3", waitForCompletion: false))
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "windTimerEnds", userInfo: nil, repeats: false)
    }
    
    func windTimerEnds () {
        self.physicsWorld.gravity = CGVectorMake(0, -1.0)
        kiteY.physicsBody?.affectedByGravity = false
        kiteR.physicsBody?.affectedByGravity = false
    }
    
    func scorePlus(){
        time += 10
        if time%60 == 0{
            updatedifficulty()
        }
    }

    func letTheBirdFly() {
        
        var position: CGPoint
        var unitVectorWhere: Int
        if random(min:1, max:4) <= 2 { // To left from right <-
            position = CGPoint(x: self.frame.width+20, y: self.frame.height*random(min: 1, max: 9)/10.0)
            unitVectorWhere = -1
        } else { // To right from left ->
            position = CGPoint(x: -20, y: self.frame.height*random(min: 1, max: 9)/10.0)
            unitVectorWhere = 1
        }
        let Bird = SKSpriteNode(imageNamed: "Bird2.png")
        Bird.position = position
        Bird.physicsBody = SKPhysicsBody(circleOfRadius: Bird.frame.height/2)
        Bird.physicsBody?.affectedByGravity = false
        Bird.physicsBody?.categoryBitMask = ColliderType.bird.rawValue
        Bird.physicsBody?.collisionBitMask = ColliderType.bird.rawValue
        
        let up = SKAction .moveBy(CGVector(dx: unitVectorWhere*200, dy: 100), duration: 1)
        let changeWingsUp = SKAction .setTexture(SKTexture(imageNamed: "Bird1.png"))
        let down = SKAction .moveBy(CGVector(dx: unitVectorWhere*200, dy: -100), duration: 1)
        let changeWingsDown = SKAction .setTexture(SKTexture(imageNamed: "Bird2.png"))
        let sequence = SKAction .repeatActionForever(SKAction.sequence([up, changeWingsUp, down, changeWingsDown]))
        Bird .runAction(sequence)
        self.addChild(Bird)
        // To delete bird eventually
        let actionMoveDone = SKAction.removeFromParent()
        Bird.runAction(SKAction.sequence([SKAction.waitForDuration(120), actionMoveDone]))
        
    }

    func updatedifficulty(){
        
        if time >= 600 {
            NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(14), target: self, selector: "letTheBirdFly", userInfo: nil, repeats: true) // Put a bird
            
        }else if time >= 300 {
            _ = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "applyWind", userInfo: nil, repeats: true)
            
        }else if time >= 200 {
            runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addDarkCloud),SKAction.waitForDuration(4.0)])),withKey: "darkcloud")
            runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addhail),SKAction.waitForDuration(0.5)])),withKey: "addhail")
        }
        
        
    }
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    func randomNumber(range: Range<Int> = 1...6) -> Int {
        let min = range.startIndex
        let max = range.endIndex
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }
    
    func endGame(winner: String){
        removeAllActions()
        self.speed = 0.0
        let appdele = NSApplication.sharedApplication().delegate as! AppDelegate
        appdele.currentState = .multiEnd
        let endS = MultiGameScene(size: self.size, winner: winner)
        
        let transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
        endS.scaleMode = SKSceneScaleMode.AspectFill
        self.view!.presentScene(endS, transition: transition)
        
    }
    
    func letTheBaloonFly() {
        if random(min:1, max: 10)<4 {
            let whichPic = randomNumber(1...5)
            let PrettyBaloon = SKSpriteNode(imageNamed: "Baloon\(whichPic).1.png")
            PrettyBaloon.position = CGPoint(x: self.frame.width*random(min:1, max: 100)/100.0, y: 0 - PrettyBaloon.frame.height)
            PrettyBaloon.physicsBody = SKPhysicsBody(circleOfRadius: PrettyBaloon.frame.width/3, center: CGPoint(x: 0, y: PrettyBaloon.frame.height*0.3))
            PrettyBaloon.physicsBody?.affectedByGravity = false
            PrettyBaloon.physicsBody?.categoryBitMask = ColliderType.baloon.rawValue
            PrettyBaloon.physicsBody?.collisionBitMask = ColliderType.baloon.rawValue
            
            let up = SKAction .moveBy(CGVector(dx: 0, dy: 20), duration: 0.4)
            let changeTail = SKAction .setTexture(SKTexture(imageNamed: "Baloon\(whichPic).2.png"))
            let changeTailOneMoreTime = SKAction .setTexture(SKTexture(imageNamed: "Baloon\(whichPic).1.png"))
            let sequence = SKAction .repeatActionForever(SKAction.sequence([up, changeTail, up, changeTailOneMoreTime]))
            PrettyBaloon .runAction(sequence)
            self.addChild(PrettyBaloon)
            // To delete baloon eventually
            let actionMoveDone = SKAction.removeFromParent()
            PrettyBaloon.runAction(SKAction.sequence([SKAction.waitForDuration(120), actionMoveDone]))
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if kiteRtail.count < 22{
            endGame("YELLOW KITE")
        }else if kiteYtail.count < 22{
            endGame("RED KITE")
        }
        
        if kiteY.zRotation > CGFloat(2*M_PI){           // this one is because the insane math problem above
            kiteY.zRotation = kiteY.zRotation%CGFloat(2*M_PI)
        } else if kiteY.zRotation < CGFloat(-2*M_PI){
            let temp = -kiteY.zRotation%CGFloat(2*M_PI)
            kiteY.zRotation = -temp
        }
        if headkiteRTouch > 10{
            headkiteRTouch = 0
            if !kiteRtail.isEmpty {
                kiteRtail[kiteRtail.count - 1].constraints = nil
                kiteRtail.removeLast()
            }
        }
        if headkiteYTouch > 10{
            headkiteYTouch = 0
            if !kiteYtail.isEmpty {
                kiteYtail[kiteYtail.count - 1].constraints = nil
                kiteYtail.removeLast()
            }
        }
        if birdkiteRheadTouch >= 10 {
            birdkiteRheadTouch = 0
            for _ in 0...10 {
                if !kiteRtail.isEmpty {
                    kiteRtail[kiteRtail.count - 1].constraints = nil
                    kiteRtail.removeLast()
                }
            }
        }
        if birdkiteYheadTouch >= 10 {
            birdkiteYheadTouch = 0
            for _ in 0...10 {
                if !kiteYtail.isEmpty {
                    kiteYtail[kiteYtail.count - 1].constraints = nil
                    kiteYtail.removeLast()
                }
            }
        }
    }
    
}
