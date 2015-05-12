//
//  CTModel.swift
//  CustomTable
//
//  Created by Hidetoshi Iida on 2014/06/05.
//
//

import UIKit

class PostModel: NSObject {
    
    var postContent:NSString      //タイトルネーム
    var postDate:NSString   //カテゴリネーム
    var idImg:NSString
    var postImg:NSString
    var postId:Int
    var poster:NSString
    var postOri:NSString
    var postDateReal:Int
    
    // initialize
    init(postContent: NSString, postDate: NSString, idImg: NSString, postImg: NSString,
        postId: Int, poster: NSString, postOri: NSString, postDateReal:Int) {
            self.postContent = postContent
            self.postDate = postDate
            self.idImg = idImg
            self.postImg = postImg
            self.postId = postId
            self.poster = poster
            self.postOri = postOri
            self.postDateReal = postDateReal
    }
}
