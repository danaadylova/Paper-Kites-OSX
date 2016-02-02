//
//  AppDelegate.swift
//  osxGame
//
//  Created by Huang Ying-Kai on 1/28/16.
//  Copyright (c) 2016 Kai. All rights reserved.
//

import Cocoa
import SpriteKit
import MultipeerConnectivity

enum state {
    case connectingS
    case secondconnectingS
    case startS
    case single_gameS
    case multi_gameS
    case singleEnd
    case multiEnd
}


@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    var mpcHandler: MPCHandler = MPCHandler()
    var connected = false
    var currentState: state!
    var connectS: ConnectingScene!
    var startS: StartScene!
    var gameS: GameScene!
    var secconnectS: SecondConnectingScene!
    var multigameS: Multi_GameScene!
    var singend: SingleGameEnd!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /* Pick a size for the scene */
        
        self.mpcHandler.setupPeerWithDisplayName(NSHost.currentHost().name!)
        self.mpcHandler.setupSession()
        self.mpcHandler.advertiseSelf(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showState:", name: "MPC_Change_State", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveData:", name: "MPC_Receive_Data", object: nil)
        
        connectS = ConnectingScene(size: self.window.frame.size)
        gameS = GameScene(size: self.window.frame.size)
        startS = StartScene(size: self.window.frame.size)
        secconnectS = SecondConnectingScene(size: self.window.frame.size)
        multigameS = Multi_GameScene(size: self.window.frame.size)
        singend = SingleGameEnd(size: self.window.frame.size,score: 1000)
        
        
        connectS.scaleMode = .AspectFill
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(gameS)
        currentState = state.connectingS
        
    }
    func showState(notification: NSNotification){
        
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.objectForKey("state") as! Int
        let peerID = userInfo.objectForKey("peerID") as! MCPeerID
        
        
        if state == MCSessionState.Connected.rawValue{
            print("connected")
            
            print(self.mpcHandler.session.connectedPeers.count)
            
            connected = true
            if connected {
                if self.currentState == .secondconnectingS{
                    multigameS = Multi_GameScene(size: self.window.frame.size)
                    multigameS.player1 = self.mpcHandler.session.connectedPeers[0]
                    multigameS.player2 = self.mpcHandler.session.connectedPeers[1]
                    let transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
                    multigameS.scaleMode = .AspectFill
                    skView.presentScene(multigameS, transition: transition)
                    self.mpcHandler.advertiseSelf(false)
                    self.currentState = .multi_gameS
                    
                }else{
                    let transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
                    skView.showsFPS = true
                    skView.showsNodeCount = true
                    //skView.ignoresSiblingOrder = true
                    startS.scaleMode = .AspectFill
                    skView.presentScene(startS, transition: transition)
                    self.mpcHandler.advertiseSelf(false)
                    self.currentState = .startS
                }
            }
        }else if state == MCSessionState.Connecting.rawValue{
            print("connecting")
            connected = false
        }else{
            print("not connected")
            connected = false
            
            if self.mpcHandler.session.connectedPeers.count == 1{
                let transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
                skView.showsFPS = true
                skView.showsNodeCount = true
                //skView.ignoresSiblingOrder = true
                secconnectS.scaleMode = .AspectFill
                skView.presentScene(secconnectS, transition: transition)
                self.mpcHandler.advertiseSelf(true)
                self.currentState = .secondconnectingS
                
            }else{
                let transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
                skView.showsFPS = true
                skView.showsNodeCount = true
                //skView.ignoresSiblingOrder = true
                connectS.scaleMode = .AspectFill
                skView.presentScene(connectS, transition: transition)
                self.mpcHandler.advertiseSelf(true)
                self.currentState = .connectingS
            }
        }
    }
    
    func receiveData(notification: NSNotification) {
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.userInfo as! Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["peerID"] as! MCPeerID
        
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, AnyObject>
        
        if self.mpcHandler.session.connectedPeers.count == 2{
            // Check if there's an entry with the "message" key.
            if let type = dataDictionary["type"] {
                // Make sure that the message is other than "_end_chat_".
                if type as! String == "button"{
                    
                    if let info = dataDictionary["info"] {
                        
                        if info as! String == "rec" && self.currentState == .multiEnd {
                           
                            multigameS = Multi_GameScene(size: self.window.frame.size)
                            multigameS.player1 = self.mpcHandler.session.connectedPeers[0]
                            multigameS.player2 = self.mpcHandler.session.connectedPeers[1]
                            let transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
                            multigameS.scaleMode = .AspectFill
                            skView.presentScene(multigameS, transition: transition)
                            self.currentState = .multi_gameS
                            
                            
                        }else if info as! String == "cross" {
                            let transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
                            skView.showsFPS = true
                            skView.showsNodeCount = true
                            startS.scaleMode = .AspectFill
                            skView.presentScene(secconnectS, transition: transition)
                            self.mpcHandler.session.cancelConnectPeer(self.mpcHandler.session.connectedPeers[1])
 //                           self.currentState = .secondconnectingS
 // need to test if it's instant !!                           self.mpcHandler.advertiseSelf(true)
                            
                        }else{
                            print("something's wrong!!")
                        }
                    }
                    
                }else if type as! String == "joystick" && self.currentState == .multi_gameS{
                    if let vectdic = dataDictionary["info"] as! [String: Float]?{
                        
                        let vec = CGVectorMake(CGFloat(vectdic["x"]!), CGFloat(vectdic["y"]!))
                        if fromPeer == multigameS.player1{
                            let point = CGPoint(x:multigameS.kiteY.position.x + vec.dx,y:multigameS.kiteY.position.y + vec.dy)
                            multigameS.moveKiteY(location: point)
                            multigameS.rotateKiteY(location: point)
                        }
                        if fromPeer == multigameS.player2 {
                            let point = CGPoint(x:multigameS.kiteR.position.x + vec.dx,y:multigameS.kiteR.position.y + vec.dy)
                            multigameS.moveKiteR(location: point)
                            multigameS.rotateKiteR(location: point)
                        }
                    }
                }
            }
        }else if self.mpcHandler.session.connectedPeers.count == 1{
            
            if let type = dataDictionary["type"] {
                
                if type as! String == "button"{
                    if let info = dataDictionary["info"] {
                        
                        if info as! String == "rec" && self.currentState == .startS {
                            
                            if  startS.mychoice == .single{
                                self.gameS = GameScene(size: self.window.frame.size)
                                let transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
                                gameS.scaleMode = .AspectFill
                                skView.presentScene(gameS, transition: transition)
                                self.currentState = .single_gameS

                            }else{
                                let transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
                                gameS.scaleMode = .AspectFill
                                skView.presentScene(secconnectS, transition: transition)
                                self.mpcHandler.advertiseSelf(true)
                                self.currentState = .secondconnectingS
                            }
                            
                        }else if info as! String == "rec" && self.currentState == .singleEnd {
                            
                            self.gameS = GameScene(size: self.window.frame.size)
                            let transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
                            gameS.scaleMode = .AspectFill
                            skView.presentScene(gameS, transition: transition)
                            self.currentState = .single_gameS
                            
                        }else if info as! String == "cross" {
                            
                            if self.currentState == .startS{
                                let transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
                                skView.showsFPS = true
                                skView.showsNodeCount = true
                                //skView.ignoresSiblingOrder = true
                                connectS.scaleMode = .AspectFill
                                skView.presentScene(connectS, transition: transition)
                                self.mpcHandler.session.cancelConnectPeer(fromPeer)
                                self.mpcHandler.advertiseSelf(true)
//need to test                                self.currentState = .connectingS
                                
                            }else{
                                
                                let transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
                                skView.showsFPS = true
                                skView.showsNodeCount = true
                                //skView.ignoresSiblingOrder = true
                                startS.scaleMode = .AspectFill
                                skView.presentScene(startS, transition: transition)
                                self.mpcHandler.advertiseSelf(false)
                                self.currentState = .startS
                            }
                        }else{
                            print("something's wrong!!")
                        }
                    }
                    
                }else if type as! String == "joystick"{
                
                    if let vectdic = dataDictionary["info"] as! [String: Float]?{
    
                        let vec = CGVectorMake(CGFloat(vectdic["x"]!), CGFloat(vectdic["y"]!))
    
                        if self.currentState == .startS{
                            if vec.dy > 0{
                                startS.mychoice = .single
                            }
                            if vec.dy < 0{
                                startS.mychoice = .multiple
                            }
                        }else if self.currentState == .single_gameS{
    
                            let point = CGPoint(x:gameS.kite.position.x + vec.dx,y:gameS.kite.position.y + vec.dy)
                            gameS.moveKite(location: point)
                            gameS.rotateKite(location: point)
                        }
                    }
                }
            }
        }
    }
    
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
