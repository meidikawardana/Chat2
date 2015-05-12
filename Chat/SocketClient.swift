//
//  SocketClient.swift
//  Chat
//
//  Created by Meidika Wardana on 5/9/15.
//  Copyright (c) 2015 BEI5000. All rights reserved.
//

import Foundation

class SocketClient {
    let socket = SocketIOClient(socketURL: GlobalVariables().socketUrl)
}

let socketClient = SocketClient()