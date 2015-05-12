//
//  GlobalFunction.swift
//  Chat
//
//  Created by Meidika Wardana on 5/8/15.
//  Copyright (c) 2015 BEI5000. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

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
        let dv : NSTimeInterval = (unixTimestamp).doubleValue // its need to be in milisecond
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
        
        if !(substring(img_post as String, from: 0, to: 7) as NSString).isEqualToString("http://") {
            img_post = "http://" + (img_post as String)
        }
        
        img_post = img_post.stringByReplacingOccurrencesOfString("http://localhost/fsocial", withString: GlobalVariables().serverUrlDesktop)
        img_post = img_post.stringByReplacingOccurrencesOfString("http://localhost/m", withString: GlobalVariables().serverUrl)
        return img_post
    }
    
    func getXN() ->String{
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        return prefs.valueForKey("XN") as! NSString as String
    }
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    func askServer(requestName : String, url : String, postData : NSString) -> NSData?{
        
        var url:NSURL = NSURL(string:url)!
        
        var postData:NSData = postData.dataUsingEncoding(NSASCIIStringEncoding)!
        
        var postLength:NSString = String( postData.length )
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                return urlData
            } else {
                GlobalFunction().showAlert(requestName+" Failed!", message: "Connection Failed")
            }
        } else {
            
            var msg : String = "Connection Failure"
            
            if let error = reponseError {
                msg = (error.localizedDescription)
            }
            
            GlobalFunction().showAlert(requestName+" Failed!", message: msg)
        }
        
        return nil
    }
    
    func generateFeedsFromDict(jsonData : NSDictionary) -> JSON{
        let json = JSON(jsonData)
        
        let contentJSON = json["content"][0]
        return contentJSON
    }
    
    func generateFeedsFromArr(jsonData : NSArray) -> JSON{
        let json = JSON(jsonData)
        
        let contentJSON = json[0]
        return contentJSON
    }
    
    func generateFeeds(jsonData : NSString, isPost: Bool) -> JSON{
        
        var error: NSError?
        
        var dataFromNetwork:NSData! = jsonData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let jsonDict : NSDictionary? = NSJSONSerialization.JSONObjectWithData(dataFromNetwork, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
        
        
        let json = ( isPost ? JSON(jsonDict!) : JSON(data: dataFromNetwork))
        
//        if !isPost {
//            println("reply............ \(json[0])")
//        }
        
        let contentJSON = ( isPost ? json["content"][0] : json[0] )
        
        return contentJSON
    }
    
    func substring(str : String, from: Int, to: Int) -> String{
//        if(from == 0)
        
        var result = str
        
        if from == 0 {
            result = str.substringToIndex(advance(str.startIndex, to))
        }
        if to == 0 {
            result = str.substringFromIndex(advance(str.startIndex, from))
        }
        
        return result
    }
}