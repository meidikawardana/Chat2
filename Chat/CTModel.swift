//
//  CTModel.swift
//  CustomTable
//
//  Created by Hidetoshi Iida on 2014/06/05.
//
//

import UIKit

class CTModel: NSObject {

    var titleName:NSString      //タイトルネーム
    var categoryName:NSString   //カテゴリネーム
    var idImg:NSString
    var postImg:NSString
    
    // initialize
    init(titleName: NSString, categoryName: NSString, idImg: NSString, postImg: NSString) {
        self.titleName = titleName
        self.categoryName = categoryName
        self.idImg = idImg
        self.postImg = postImg
    }
    

}
