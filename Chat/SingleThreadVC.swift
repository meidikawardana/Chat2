//
//  SingleThreadVC.swift
//  Chat
//
//  Created by Meidika Wardana on 5/6/15.
//  Copyright (c) 2015 BEI5000. All rights reserved.
//

import UIKit

class SingleThreadVC: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var bottomSpacingConstraint: NSLayoutConstraint!
    
    @IBOutlet var idImgView: UIImageView!
    
    @IBOutlet var posterLbl: UILabel!
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var postLbl: UILabel!
    @IBOutlet var postImgView: UIImageView!
    
    @IBOutlet var bottomSpacingConstraintImg: NSLayoutConstraint!
    
    
    @IBOutlet var bottomSpacingConstraintBtn: NSLayoutConstraint!
    
    @IBAction func backAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    var segueArgument:PostModel!
    
    
    let basicCellIdentifier = "BasicCell"
    let imageCellIdentifier = "ImageCell"
    
    
    @IBOutlet var stTableView: UITableView!
    
    var stThreadList : [ReplyModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillHideNotification, object: nil);
        
        self.idImgView.image = UIImage(named:  "bullsmile.png")
        
        if !segueArgument.idImg.isEqualToString("") {
            ImageLoader.sharedLoader.imageForUrl(GlobalFunction().getActualImg(segueArgument.idImg) as String, completionHandler:{(image: UIImage?, url: String) in
                
                if !(image == nil) {
                    self.idImgView.image = image!
                }
            })
        }
        
        let postImg: NSString = segueArgument.postImg
        if postImg.isEqualToString("") {
            self.postImgView.removeConstraint(NSLayoutConstraint(item: self.postImgView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 75))
            
            self.postImgView.addConstraint(NSLayoutConstraint(item: self.postImgView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0))
        }else{
            ImageLoader.sharedLoader.imageForUrl(GlobalFunction().getActualImg(postImg) as String, completionHandler:{(image: UIImage?, url: String) in
                self.postImgView.image = image!
            })
        }
        
        self.posterLbl.text = "@"+(segueArgument.poster as String)
        self.dateLbl.text = segueArgument.postDate as String
        self.postLbl.text = segueArgument.postOri as String
        
        self.postLbl.numberOfLines = 0
        self.postLbl.sizeToFit()
        
        stTableView.delegate = self
        stTableView.dataSource = self
        
        stTableView.rowHeight = UITableViewAutomaticDimension
        stTableView.estimatedRowHeight = 200
        
        self.appendFeeds()
        
    }
    
    // セクション数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // セクションの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stThreadList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if hasImageAtIndexPath(indexPath) {
            return imageCellAtIndexPath(indexPath)
        } else {
            return basicCellAtIndexPath(indexPath)
        }
    }
    
    func hasImageAtIndexPath(indexPath:NSIndexPath) -> Bool {
        let thread = stThreadList[indexPath.row]
        
        let replyImg: NSString = thread.replyImg
        if replyImg.isEqualToString("") {
            return false
        }
        return true
    }
    
    func imageCellAtIndexPath(indexPath:NSIndexPath) -> ImageCell {
        let cell = stTableView.dequeueReusableCellWithIdentifier(imageCellIdentifier) as! ImageCell
        setReplyContent(cell, indexPath: indexPath)
        setReplyDate(cell, indexPath: indexPath)
        setIdImg(cell, indexPath: indexPath)
        setReplyImg(cell, indexPath: indexPath)
        return cell
    }
    
    func setReplyImg(cell:ImageCell, indexPath:NSIndexPath) {
        let thread = stThreadList[indexPath.row] as ReplyModel
        ImageLoader.sharedLoader.imageForUrl(GlobalFunction().getActualImg(thread.replyImg) as String, completionHandler:{(image: UIImage?, url: String) in
            cell.postImageView.image = image!
        })
    }
    
    func basicCellAtIndexPath(indexPath:NSIndexPath) -> BasicCell {
        let cell = stTableView.dequeueReusableCellWithIdentifier(basicCellIdentifier) as! BasicCell
        setReplier(cell, indexPath: indexPath)
        setReplyContent(cell, indexPath: indexPath)
        setReplyDate(cell, indexPath: indexPath)
        setIdImg(cell, indexPath: indexPath)
        return cell
    }
    
    func setReplier(cell:BasicCell, indexPath:NSIndexPath) {
        let thread = stThreadList[indexPath.row] as ReplyModel
        cell.posterLabel.text = thread.replier as String
    }
    
    func setReplyContent(cell:BasicCell, indexPath:NSIndexPath) {
        let thread = stThreadList[indexPath.row] as ReplyModel
        cell.postLabel.text = thread.reply as String
    }
    
    func setReplyDate(cell:BasicCell, indexPath:NSIndexPath) {
        let thread = stThreadList[indexPath.row] as ReplyModel
        cell.dateLabel.text = thread.replyDate as String
    }
    
    func setIdImg(cell:BasicCell, indexPath:NSIndexPath) {
        let thread = stThreadList[indexPath.row] as ReplyModel
        cell.posterImageView.image = UIImage(named:  "bullsmile.png")
        
        if !thread.idImg.isEqualToString("") {
            ImageLoader.sharedLoader.imageForUrl(GlobalFunction().getActualImg(thread.idImg) as String, completionHandler:{(image: UIImage?, url: String) in
                
                if !(image == nil) {
                    cell.posterImageView.image = image!
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardNotification(notification: NSNotification) {
        
        let isShowing = notification.name == UIKeyboardWillShowNotification
        
        println("------1\(isShowing)")
        
        if let userInfo = notification.userInfo {
            
            println("------2")
            
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let endFrameHeight = endFrame?.size.height ?? 0.0
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.bottomSpacingConstraint?.constant = isShowing ? endFrameHeight+8.0 : 8.0
            self.bottomSpacingConstraintImg?.constant = isShowing ? endFrameHeight+12.0 : 8.0
            self.bottomSpacingConstraintBtn?.constant = isShowing ? endFrameHeight+8.0 : 8.0
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func appendFeeds(){
        let globalVariables = GlobalVariables()
        
        
        var post:NSString = "id=\(segueArgument.postId)&s=2"
        
//        NSLog("PostData: %@",post);
        
        let urlString : String = globalVariables.serverUrl+"/stock_tab6_op_json.php"
        
//        NSLog("URL: %@",urlString);
        
        var url:NSURL = NSURL(string:urlString)!
        
        var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        
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
            
//            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
//                NSLog("Response Replies ==> %@", responseData);
                
                var error: NSError?
                
                let jsonArr:NSArray = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSArray
                
                for jsonPiece : AnyObject in jsonArr {
                    var idx = 0
                    for jsonSubPiece : AnyObject in jsonPiece as! NSArray {
                        if(idx == 5){
//                            let json = JSON(jsonSubPiece as! NSArray)
                   
                            for replyPiece : AnyObject in jsonSubPiece as! NSArray {
                                let json = JSON(replyPiece as! NSArray)
                                
//                                println("reply array: \(json)")
                                self.generateFeedsReplyFinal(json,isAppend: true)
                            }
//                                                        for replyPiece : AnyObject in json {
//                                                            let json = JSON(jsonPiece as! NSArray)
//                            
//                                                            self.generateFeedsFinal(json,isAppend: true)
//                                                        }
                        }
                        idx++
                    }
                    
                    
                    //                    self.generateFeedsFinal(json,isAppend: true)
                }
                
            } else {
                GlobalFunction().showAlert("Failed to get reply list", message: "Connection Failed")
            }
        } else {
            if let error = reponseError {
                GlobalFunction().showAlert("Failed to get reply list", message: error.localizedDescription)
            }else{
                GlobalFunction().showAlert("Failed to get reply list", message: "Connection Failure")
            }
        }
    }
    
    func generateFeedsReplyFinal(contentJSON: JSON, isAppend : Bool){
        var replier : NSString = ""
        if let replierTemp : NSString? = contentJSON[0].string {
            replier = replierTemp!
        }
        
        var reply : NSString = ""
        if let replyTemp : NSString? = contentJSON[5].string {
            reply = replyTemp!
        }
        
        var replyImg : NSString = ""
        
        if(contentJSON[6].count > 0){
            if let replyImgTemp : NSString? = contentJSON[6][0].string {
                replyImg = replyImgTemp!
            }
        }
        
        var idImg : NSString = ""
        if let idImgTemp : NSString? = contentJSON[4].string {
            idImg = idImgTemp!
        }
        
        if !GlobalFunction().shouldUseDrawable(idImg) {
            idImg = GlobalVariables().serverUrlDesktop + "/uploaded_images/profpic/" + (idImg as String)
        }
        
        
        var actDateInt : Int = -1
        if let actDateIntTemp : Int = contentJSON[2].int {
            actDateInt = actDateIntTemp
        }
        
        //        println("-----idmg:\(idImg)")
        
        let threadNew : [ReplyModel] = [ReplyModel(reply: reply, replyDate: GlobalFunction().getTimeF(actDateInt), idImg: idImg, replyImg: replyImg, replier: replier)]
        
        if !isAppend {
            stThreadList = threadNew + stThreadList
        }else{
            stThreadList = stThreadList + threadNew
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.stTableView.reloadData()
        })
    }
}
