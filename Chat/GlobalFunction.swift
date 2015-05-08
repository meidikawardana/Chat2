//
//  GlobalFunction.swift
//  Chat
//
//  Created by Meidika Wardana on 5/8/15.
//  Copyright (c) 2015 BEI5000. All rights reserved.
//

import Foundation
import UIKit

class GlobalFunction {
    func showAlert(title:String,message:String){
        var alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    func shouldUseDrawable(idImg: NSString) -> Bool {
        var useDrawable = idImg.isEqualToString("bullsmile.png")
        
        if idImg.isEqualToString("") {
            useDrawable = true
        }
        
        if idImg.isEqualToString("null") {
            useDrawable = true
        }
        
        if idImg.isEqualToString("bullsmile_profpic.png") {
            useDrawable = true
        }
        
        return useDrawable
    }
    
    func getTimeF(utParam: Int) -> String {
        let ut : NSTimeInterval = (String(utParam) as NSString).doubleValue
        let start = NSDate(timeIntervalSince1970: ut)
        let enddt = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let datecomponenets = calendar.components(NSCalendarUnit.CalendarUnitSecond, fromDate: start, toDate: enddt, options: nil)
        let diff = datecomponenets.second
        
        if (diff <= 1) {
            return "a second ago";
        } else if (diff < 60) {
            return String(diff) + " seconds ago"
        } else if (diff >= 60 && diff < 120) {
            return "1 min ago"
        } else if (diff >= 120 && diff < 3600) {
            return String(diff / 60) + " mins ago"
        } else if (diff >= 3600 && diff < 7200) {
            return "an hour ago"
        } else if (diff >= 7200 && diff < 86400) {
            return String(diff / 3600) + " hours ago"
        } else if (diff >= 86400 && diff < 172800) {
            return "Yesterday" + formatTime(String(utParam), version: 2)
        } else if (diff >= 172800) {
            return formatTime(String(utParam), version: 1)
        }
        return String(utParam)
    }
    
    func formatTime(unixTimestamp : NSString, version : Int) -> String {
        let dv : NSTimeInterval = (unixTimestamp).doubleValue * 1000;// its need to be in milisecond
        let dt = NSDate(timeIntervalSince1970: dv)
        
        var dateFormater : NSDateFormatter = NSDateFormatter()
        dateFormater.dateFormat = (version == 1) ? "MMM dd yyyy hh:mma" : "hh:mma"
        
        if (version == 1) {
            return dateFormater.stringFromDate(dt)
        } else {
            return " at " + dateFormater.stringFromDate(dt)
        }
    }
    
    func getActualImg(url:NSString) ->NSString{
        var img_post : NSString = url
        img_post = img_post.stringByReplacingOccurrencesOfString("http://localhost/fsocial", withString: GlobalVariables().serverUrlDesktop)
        img_post = img_post.stringByReplacingOccurrencesOfString("http://localhost/m", withString: GlobalVariables().serverUrl)
        return img_post
    }
    
}