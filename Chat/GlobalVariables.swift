//
//  GlobalVariables.swift
//  Chat
//
//  Created by Meidika Wardana on 4/20/15.
//  Copyright (c) 2015 BEI5000. All rights reserved.
//

import Foundation

struct GlobalVariables {
    
    let serverIP : String
    let serverUrl : String
    let serverUrlDesktop : String
    let socketUrl : String
    
    init(){
        serverIP = "192.168.0.104"
        serverUrl = "http://"+serverIP+"/fsocialm"
        serverUrlDesktop = "http://"+serverIP+"/fsocial"
        socketUrl = serverIP+":3001"
    }
}