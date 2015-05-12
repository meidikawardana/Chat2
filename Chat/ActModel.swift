//
//  ActModel.swift
//  Chat
//
//  Created by Meidika Wardana on 5/11/15.
//  Copyright (c) 2015 BEI5000. All rights reserved.
//

import Foundation

import UIKit

class ActModel: NSObject {
    
    var postContent:NSString      //タイトルネーム
    var postDate:NSString   //カテゴリネーム
    var idImg:NSString
    var postImg:NSString
    var postId:Int
    var poster:NSString
    var postOri:NSString
    
    var reply:NSString
    var replyDate:NSString
    var replyImg:NSString
    var replier:NSString
    
    // initialize
    init(postContent: NSString, postDate: NSString, idImg: NSString, postImg: NSString,
        postId: Int, poster: NSString, postOri: NSString
        
        ,reply: NSString,replyDate:NSString,replyImg:NSString,replier:NSString
        ) {
            self.postContent = postContent
            self.postDate = postDate
            self.idImg = idImg
            self.postImg = postImg
            self.postId = postId
            self.poster = poster
            self.postOri = postOri
            
            self.reply = reply
            self.replyDate = replyDate
            self.idImg = idImg
            self.replyImg = replyImg
            self.replier = replier
    }
}