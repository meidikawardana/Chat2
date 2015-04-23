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
    
    // initialize
    init(titleName: String, categoryName: String, idImg: String) {
        self.titleName = titleName
        self.categoryName = categoryName
        self.idImg = idImg
    }
    

}
