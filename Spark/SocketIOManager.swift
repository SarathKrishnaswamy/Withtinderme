//
//  SocketIOManager.swift
//  Love Pulse
//
//  Created by Gopimanojkumar on 25/09/19.
//  Copyright © 2019 Adhashtechnolab. All rights reserved.
//

import UIKit
import SocketIO
import RSLoadingView

protocol sendAfterSocketConnect: AnyObject {
    func sendAfterSocketConnectMethod()
}

class SocketIOManager: NSObject {
    
    ///Socket io manager
    static let sharedSocketInstance = SocketIOManager()
    ///Configure socket manager
    let socketManager = SocketManager(socketURL: URL(string:Endpoints.socket_base.rawValue)!, config: [.reconnects(true),.compress,.reconnectAttempts(20)])
    var socket:SocketIOClient!
    var options:SocketIOClientConfiguration!
    var newsocket: SocketIOClient!
    var newmanager : SocketManager!
    var SocketIoStatus : SocketIOStatus?
    var isConnected = false
    
    weak var delegate : sendAfterSocketConnect?
    
    ///Initialize the socket
    override init() {
        super.init()
        self.socket = self.socketManager.defaultSocket
    }
    
    ///This method is used to connect the socket
    func ConnectsToSocket() {
        
        newmanager = SocketManager(socketURL: URL(string: Endpoints.socket_base.rawValue)!, config: [.reconnects(true),.compress,.reconnectAttempts(5), .forceNew(true)])
        newsocket = newmanager.defaultSocket
        
        self.newsocket.onAny({ data in
            
        })
        
        self.newsocket.on(clientEvent: .connect) {data, ack in
            print(data)
            print("Socket connected")
            self.isConnected = true
            //self.emitLoggedInUserIDToSocket()
            
            if !SessionManager.sharedInstance.getUserId.isEmpty {
                self.delegate?.sendAfterSocketConnectMethod()
            }
            
        }
        self.newsocket.on(clientEvent: .error) { (data, eck) in
            print(data.debugDescription)
            print("socket error")
            //RSLoadingView().showOnKeyWindow()
            
            if !SocketIOManager.sharedSocketInstance.isConnected {
                SocketIOManager.sharedSocketInstance.ConnectsToSocket()
            }
            //self.isConnected = false
        }
        self.newsocket.on(clientEvent: .disconnect) { (data, eck) in
            print(data)
            print("socket disconnect")
            self.isConnected = false
        }
        self.newsocket.on(clientEvent: SocketClientEvent.reconnect) { (data, eck) in
            print(data)
            print("socket reconnect")
        }
        
        //        self.newsocket.on("online_status") { data, ack in
        //           print("Received Socket Online Status ! \(data)")
        //        }
        
        self.newsocket.on("leaveRoom") { data, ack in
            print("Received leaveRoom Status ! \(data)")
        }
        
        self.newsocket.connect()
    }
    
    ///Called when user logged In
    func emitLoggedInUserIDToSocket() {
        let newDict = ["user_id":SessionManager.sharedInstance.getUserId]
        SocketIOManager.sharedSocketInstance.newsocket.emit("connect_client", newDict)
        print("User ID Emitted To Server")
        
    }
    
    ///Called when user send message to opponent
    func emitMessageToOpponent(param:[String : Any]) {
        SocketIOManager.sharedSocketInstance.newsocket.emit("send_message", param)
        print("Message Emitted To Server")
    }
    
    ///Called when user send message to opponent
    func emitThreadRoomID(param:[String : Any]) {
        SocketIOManager.sharedSocketInstance.newsocket.emit("threadRoom", param)
        print("Thread ID Enitted")
        RSLoadingView.hideFromKeyWindow()
    }
    
    ///Called when user logged In
    func disconnectSocket() {
        if newsocket != nil {
            let newDict = ["user_id":SessionManager.sharedInstance.getUserId]
            SocketIOManager.sharedSocketInstance.newsocket.emit("disconnect_client", newDict)
            print("Socket Disconnect Emitted")
            newsocket.disconnect()
        }
        
    }
    
    ///Leave Room
    func leaveFromRoom(param:[String : Any]) {
        SocketIOManager.sharedSocketInstance.newsocket.emit("leaveRoom", param)
        print("Leave From Room Emitted")
        
    }
    
    ///Close Thread
    func closeThreadEmit(param:[String : Any]) {
        SocketIOManager.sharedSocketInstance.newsocket.emit("closeThread", param)
        print("Close Thread Emitted")
        
    }
}

