//
//  CTModel.swift
//  CustomTable
//
//  Created by Hidetoshi Iida on 2014/06/05.
//
//

import UIKit

class ReplyModel: NSObject {
    
    var reply:NSString
    var replyDate:NSString
    var idImg:NSString
    var replyImg:NSString
    var replier:NSString
    
    
    // initialize
    init(reply: NSString,replyDate:NSString,idImg:NSString,replyImg:NSString,replier:NSString) {
        self.reply = reply
        self.replyDate = replyDate
        self.idImg = idImg
        self.replyImg = replyImg
        self.replier = replier
    }
}
