//
//  GameScene.swift
//  osxGame
//
//  Created by Huang Ying-Kai on 1/28/16.
//  Copyright (c) 2016 Kai. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var kite: SKSpriteNode!
    var kiteTail: [SKSpriteNode]!
    
    var scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    var rainstart = 0   //for raining
    var rainend = 0     //for raining

    var hailstart = 0   //for hailing
    var hailend = 0     // for hailing
    
    var score = 0
    var headtouch = 0
    var birdHeadTouch = 0
    
    // Bitmasks for collisions
    enum ColliderType:  UInt32 {
        case kiteHead = 1
        case kiteTail = 2
        case droplet = 4
        case hail = 8
        case bird = 16
        case baloon = 32

    }
    
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self // I change the behavor of physical interactions of the world
        runAction(SKAction .playSoundFileNamed("More-Monkey-Island-Band.mp3", waitForCompletion: true)) // Play background music for the game
        
        scoreLabel.text = "YOUR SCORE : \(score)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.position = CGPoint(x: size.width/4, y: size.height*8/9)
        addChild(scoreLabel)
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "scorePlus", userInfo: nil, repeats: true) // Up score every second

        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(4), target: self, selector: "letTheBaloonFly", userInfo: nil, repeats: true) // Put a baloon

        let background = SKSpriteNode(imageNamed: "paperbackground.png") // becak ground size doesn't match
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.zPosition = -5
        addChild(background)

        kiteTail = [SKSpriteNode]()
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addDarkCloud),SKAction.waitForDuration(4.0)])))
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addhail),SKAction.waitForDuration(0.5)])))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addBlueCloud),SKAction.waitForDuration(10.0)])),withKey: "bluecloud") // Start showing blue clouds

        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addGrayCloud),SKAction.waitForDuration(4.0)])),withKey: "graycloud") // Start showing dark clouds - rain
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addrain),SKAction.waitForDuration(0.5)])),withKey: "addrain")// Start showing dark grey clouds - hail/snow

        // KITE
        kite = SKSpriteNode(imageNamed: "KiteY.png")
        kite.position = CGPointMake(size.width * 0.5, size.height * 0.5)
        kite.zPosition = -1
        kite.physicsBody = SKPhysicsBody(circleOfRadius:kite.frame.size.width/2)
        kite.physicsBody!.linearDamping = 1.0
        kite.physicsBody!.affectedByGravity = false            // only the head isn't affected by gravity
        kite.physicsBody!.categoryBitMask = ColliderType.kiteHead.rawValue // set collisionBitmask
        kite.physicsBody?.contactTestBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue | ColliderType.bird.rawValue | ColliderType.baloon.rawValue
        let c = SKConstraint.positionX(SKRange(lowerLimit: 0, upperLimit: self.frame.size.width), y: SKRange(lowerLimit: 0, upperLimit: self.frame.size.height)) // To stop the kite from going off the screen
        kite.constraints = [c]
        self.addChild(kite)
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -1.0)  // put a little gravity in the world
        
        var constraint: SKConstraint!

        // KITE TAIL: create kite tail with rope effect
        for i in 0...160 {
            if i%21 == 0 && i != 0{
                kiteTail.append(SKSpriteNode(imageNamed: "tailY.png"))
                kiteTail[i].position = CGPointMake(kite.position.x, kite.position.y - 20 - 10*CGFloat(i))
                kiteTail[i].physicsBody = SKPhysicsBody(rectangleOfSize: kiteTail[i].frame.size)
                kiteTail[i].physicsBody!.linearDamping = 1.0
                kiteTail[i].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteTail[i-1])
                kiteTail[i].constraints = [constraint]
                kiteTail[i].zPosition = -1
            } else {
                kiteTail.append(SKSpriteNode(imageNamed: "rope.png"))
                if i == 0{
                    kiteTail[i].position = CGPointMake(kite.position.x, kite.position.y - 20)
                }else{
                    kiteTail[i].position = CGPointMake(kite.position.x, kiteTail[i-1].position.y - 2)
                }
                kiteTail[i].physicsBody = SKPhysicsBody(rectangleOfSize: kiteTail[i].frame.size)
                kiteTail[i].physicsBody!.linearDamping = 1.0
                kiteTail[i].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                if i > 0{       // the constraint for the tails except the first one
                    constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteTail[i-1])
                    kiteTail[i].constraints = [constraint]
                }else{          // the constraint of the first bow tie should derive from the kite head
                    constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 16), toNode: kite)
                    kiteTail[i].constraints = [constraint]
                }
                kiteTail[i].zPosition = -2
            }
            if i%7 == 0{
                kiteTail[i].physicsBody!.contactTestBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue | ColliderType.bird.rawValue
            }
            kiteTail[i].physicsBody!.collisionBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue
            kiteTail[i].physicsBody?.categoryBitMask = ColliderType.kiteTail.rawValue
            self.addChild(kiteTail[i])
        }
    }
    
    // Did the contact begin?
    func didBeginContact(contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.categoryBitMask == ColliderType.kiteTail.rawValue || bodyB.categoryBitMask == ColliderType.kiteTail.rawValue { // Its a kite tail
            if bodyA.categoryBitMask == ColliderType.droplet.rawValue || bodyB.categoryBitMask == ColliderType.droplet.rawValue { // Collision with a droplet
                kiteTail[kiteTail.count - 1].constraints = nil
                kiteTail.removeLast()
                kiteTail[kiteTail.count - 1].constraints = nil
                kiteTail.removeLast()
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
                kiteTail[kiteTail.count - 1].constraints = nil
                kiteTail.removeLast()
                kiteTail[kiteTail.count - 1].constraints = nil
                kiteTail.removeLast()
                kiteTail[kiteTail.count - 1].constraints = nil
                kiteTail.removeLast()
                kiteTail[kiteTail.count - 1].constraints = nil
                kiteTail.removeLast()
                kiteTail[kiteTail.count - 1].constraints = nil
                kiteTail.removeLast()
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
                    self.birdHeadTouch = self.birdHeadTouch + 1
                }
            }
        }else if bodyA.categoryBitMask == ColliderType.kiteHead.rawValue || bodyB.categoryBitMask == ColliderType.kiteHead.rawValue {
            
            if bodyA.categoryBitMask == ColliderType.droplet.rawValue || bodyB.categoryBitMask == ColliderType.droplet.rawValue { // Collision with a droplet
                dispatch_async(dispatch_get_main_queue()) { // 2
                    if (bodyA.categoryBitMask == ColliderType.droplet.rawValue) {
                        let actionMoveDone = SKAction.removeFromParent()
                        let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                        bodyA.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                    }else{
                        let actionMoveDone = SKAction.removeFromParent()
                        let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                        bodyB.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                    }
                    self.headtouch += 5
                }
                
            } else if bodyA.categoryBitMask == ColliderType.hail.rawValue || bodyB.categoryBitMask == ColliderType.hail.rawValue { // Collision with a hail piece
                dispatch_async(dispatch_get_main_queue()) { // 2
                    if (bodyA.categoryBitMask == ColliderType.hail.rawValue) {
                        let actionMoveDone = SKAction.removeFromParent()
                        let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                        bodyA.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                    }else{
                        let actionMoveDone = SKAction.removeFromParent()
                        let actionShrink = SKAction.scaleTo(0.1, duration: 0.2)
                        bodyB.node?.runAction(SKAction.sequence([actionShrink, actionMoveDone]))
                    }
                    self.headtouch += 10
                }
            }else if bodyA.categoryBitMask == ColliderType.bird.rawValue || bodyB.categoryBitMask == ColliderType.bird.rawValue { // Collision with a bird piece
                //                debugLabel.text = "BIRDDDD and head"
                dispatch_async(dispatch_get_main_queue()) { // 2
                    self.birdHeadTouch = self.birdHeadTouch + 10
                }
            }else if bodyA.categoryBitMask == ColliderType.baloon.rawValue || bodyB.categoryBitMask == ColliderType.baloon.rawValue { // Collision with a bird piece
                var didGetLife = false
                if randomNumber(1...10) < 4 { // Add a life
                    didGetLife = true
                    var constraint = SKConstraint()
                    for _ in 0...10 {
                        if kiteTail.count%21 == 0 {
                            kiteTail.append(SKSpriteNode(imageNamed: "tailY.png"))
                            kiteTail[kiteTail.count-1].position = CGPointMake(kite.position.x, kite.position.y - 20 - 10*CGFloat(kiteTail.count-1))
                            kiteTail[kiteTail.count-1].physicsBody = SKPhysicsBody(rectangleOfSize: kiteTail[kiteTail.count-1].frame.size)
                            kiteTail[kiteTail.count-1].physicsBody!.linearDamping = 1.0
                            kiteTail[kiteTail.count-1].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                            constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteTail[kiteTail.count-2])
                            kiteTail[kiteTail.count-1].constraints = [constraint]
                            kiteTail[kiteTail.count-1].zPosition = -1
                            self.addChild(kiteTail[kiteTail.count-1])
                        }else {
                            kiteTail.append(SKSpriteNode(imageNamed: "rope.png"))
                            if kiteTail.count - 1 == 0{
                                kiteTail[0].position = CGPointMake(kite.position.x, kite.position.y - 20)
                            }else{
                                kiteTail[kiteTail.count - 1].position = CGPointMake(kite.position.x, kiteTail[kiteTail.count-2].position.y - 2)
                            }
                            kiteTail[kiteTail.count - 1].physicsBody = SKPhysicsBody(rectangleOfSize: kiteTail[kiteTail.count - 1].frame.size)
                            kiteTail[kiteTail.count - 1].physicsBody!.linearDamping = 1.0
                            kiteTail[kiteTail.count - 1].physicsBody!.affectedByGravity = true      // all the bow ties are affected by gravity
                            if kiteTail.count - 1 > 0{       // the constraint for the tails except the first one
                                constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 1), toNode: kiteTail[kiteTail.count-2])
                                kiteTail[kiteTail.count - 1].constraints = [constraint]
                            }else{          // the constraint of the first bow tie should derive from the kite head
                                constraint = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 16), toNode: kite)
                                kiteTail[kiteTail.count - 1].constraints = [constraint]
                            }
                            kiteTail[kiteTail.count - 1].zPosition = -2
                            self.addChild(kiteTail[kiteTail.count-1])
                        }
                        if (kiteTail.count - 1)%7 == 0{
                            kiteTail[kiteTail.count - 1].physicsBody!.contactTestBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue | ColliderType.bird.rawValue
                        }
                        kiteTail[kiteTail.count - 1].physicsBody!.collisionBitMask = ColliderType.droplet.rawValue | ColliderType.hail.rawValue
                        kiteTail[kiteTail.count - 1].physicsBody?.categoryBitMask = ColliderType.kiteTail.rawValue
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
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        for i in 0...kiteTail.count-1{
            kiteTail[i].physicsBody!.affectedByGravity = true
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        moveKite(location: location)
        rotateKite(location: location)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        for i in 0...kiteTail.count-1{
            kiteTail[i].physicsBody!.affectedByGravity = true
        }
    }
    
    func moveKite(location location: CGPoint){
        // rotation and move for the kite
        // get ready for moving the tail
        var tail2move = [CGPoint]()
        tail2move.append(kite.position)
        
        let move = SKAction.moveTo(location,duration:0.5)
        if(CGRectContainsPoint(self.frame, location)){
            kite.runAction(move)       // move the kite
        }
    }
    
    func rotateKite(location location: CGPoint){
        // the following 3 lines are for calculating the angle between the current location and new location
        var dx = location.x - kite.position.x
        var dy = location.y - kite.position.y
        var angle = atan2(dy, dx)
        
        
        if angle - kite.zRotation > CGFloat(M_PI) {    // this one is fucking insane
            angle += CGFloat(2*M_PI)
        } else if kite.zRotation - angle > CGFloat(M_PI) { // it's about nothing but math
            angle -= CGFloat(2*M_PI)
        }
        angle -= CGFloat(M_PI/2)    // adjust the direction
        
        kite.removeActionForKey("kiteRotata") // when the kite stop, it will rotate back to 0 angle gradually, disable it in order to change assign a angle to kiteG
        
        kite.zRotation = angle
        
        // get the angle between kiteG and the first bow tie
        // roataion of the first bow tie
        dx = kite.position.x - kiteTail[0].position.x
        dy = kite.position.y - kiteTail[0].position.y
        angle = atan2(dy, dx) - CGFloat(M_PI/2)   // adjust the angle like above
        
        var rotateAction = SKAction.rotateToAngle(angle, duration: 0.4)
        kiteTail[0].runAction(rotateAction)
        
        
        // rotation for the rest of the bow ties using for looop
        var taildx = [CGFloat]()
        var taildy = [CGFloat]()
        var tailangle = [CGFloat]()
        
        for i in 0...kiteTail.count - 2 {
            taildx.append(kiteTail[i].position.x - kiteTail[i+1].position.x)
            taildy.append(kiteTail[i].position.y - kiteTail[i+1].position.y)
            tailangle.append(atan2(taildy[i], taildx[i])-1.507)
            rotateAction = SKAction.rotateToAngle(tailangle[i], duration: 0.4)
            kiteTail[i+1].runAction(rotateAction)
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
    
    func addrain(){
        
        var position = [CGPoint]()
        for i in self.rainend...self.rainstart {
            if let temp =  self.childNodeWithName("rain\(i)")?.position{
                position.append(temp)
            }
        }
        if position.count>0{
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
                    self.addChild(drop)
                    
                    let actionMoveDone = SKAction.removeFromParent()
                    drop.runAction(SKAction.sequence([SKAction.waitForDuration(5), actionMoveDone]))
                }
            }
        }
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
    
    func applyWind () {
        self.physicsWorld.gravity = CGVector(dx: 10 - Int(arc4random_uniform(20)) , dy: 0 - Int(arc4random_uniform(10)))
        kite.physicsBody?.mass = 1
        kite.physicsBody?.affectedByGravity = false
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "windTimerEnds", userInfo: nil, repeats: false)
    }
    
    func windTimerEnds () {
        self.physicsWorld.gravity = CGVectorMake(0, -1.0)
        kite.physicsBody?.affectedByGravity = false
    }

    func endGame(){
    
        self.speed = 0.0
        let appdele = NSApplication.sharedApplication().delegate as! AppDelegate
        appdele.currentState = .singleEnd
        let endS = SingleGameEnd(size: self.size, score: self.score)

        let transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
        endS.scaleMode = SKSceneScaleMode.AspectFill
        self.view!.presentScene(endS, transition: transition)
    
    }
    
    
    func scorePlus(){
        score += 10
        scoreLabel.text = "YOUR SCORE : \(score)"
        
        if score%60 == 0{
            updatedifficulty()
        }
    }
    
    
    func letTheBirdFly() {
        if randomNumber(1...10) <= 5 {
            runAction(SKAction .playSoundFileNamed("Chic.mp3", waitForCompletion: false)) // Play chick sound
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

    func updatedifficulty(){
        
        if score == 600 {
            NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(15), target: self, selector: "letTheBirdFly", userInfo: nil, repeats: true) // Put a bird

        }else if score == 300 {
            _ = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "applyWind", userInfo: nil, repeats: true)

        }else if score == 100 {
            runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addDarkCloud),SKAction.waitForDuration(4.0)])))
            runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addhail),SKAction.waitForDuration(0.5)])))
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if kiteTail.count < 22{
            endGame()
        }
        if kite.zRotation > CGFloat(2*M_PI){           // this one is because the insane math problem above
            kite.zRotation = kite.zRotation%CGFloat(2*M_PI)
        } else if kite.zRotation < CGFloat(-2*M_PI){
            let temp = -kite.zRotation%CGFloat(2*M_PI)
            kite.zRotation = -temp
        }
        if headtouch > 10{
            headtouch = 0
            if !kiteTail.isEmpty {
                kiteTail[kiteTail.count - 1].constraints = nil
                kiteTail.removeLast()
            }
        }
        if birdHeadTouch >= 10 {
            birdHeadTouch = 0
            for _ in 0...10 {
                if !kiteTail.isEmpty {
                    kiteTail[kiteTail.count - 1].constraints = nil
                    kiteTail.removeLast()
                }
            }
        }
    }
}
