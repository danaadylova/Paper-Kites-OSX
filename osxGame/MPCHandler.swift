//
//  MPCHandler.swift
//  osxGame
//
//  Created by Huang Ying-Kai on 1/28/16.
//  Copyright (c) 2016 Kai. All rights reserved.
//


import Foundation
import MultipeerConnectivity


class MPCHandler: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate{
    
    
    var peerID: MCPeerID!
    var session: MCSession!
    var browser: MCBrowserViewController!
    var advertiser: MCNearbyServiceAdvertiser!
    var invitationHandler: ((Bool, MCSession)->Void)!
    
    
    func setupPeerWithDisplayName(displayName: String){
        
        peerID = MCPeerID(displayName: displayName)
        
    }
    func setupSession(){
        
        
        session = MCSession(peer: peerID)
        session.delegate = self
        
    }
    func setupBrowser(){
        
        browser = MCBrowserViewController(serviceType: "game", session: session)
        
    }
    
    func advertiseSelf(advertise: Bool){
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "game")
        advertiser.delegate = self
        
        if advertise{
            advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "game")
            advertiser.delegate = self
            advertiser.startAdvertisingPeer()
        }else{
            advertiser.stopAdvertisingPeer()
        }
        
    }
    // MCNearbyServiceAdvertiserDelegate method implementation
    
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print(error.localizedDescription)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        
        print("received invitation")
        invitationHandler(true, self.session)
        
    }
    
    
    
    // MCSeesion delegate implimentation function
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        let userInfo = ["peerID": peerID, "state": state.rawValue]
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_Change_State", object: nil, userInfo: userInfo)
        }
    }
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
        let userInfo = ["peerID": peerID, "data": data]
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_Receive_Data", object: nil, userInfo: userInfo)
        }
    }
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {}
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {}
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    
}