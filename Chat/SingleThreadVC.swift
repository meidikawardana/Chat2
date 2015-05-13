//
//  SingleThreadVC.swift
//  Chat
//
//  Created by Meidika Wardana on 5/6/15.
//  Copyright (c) 2015 BEI5000. All rights reserved.
//

import UIKit
import Alamofire

class SingleThreadVC: UIViewController,UITableViewDataSource, UITableViewDelegate
    ,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    @IBOutlet var actionReplyContainerB: NSLayoutConstraint!
    
    @IBOutlet var bottomViewB2: NSLayoutConstraint!
    
    @IBOutlet var mainPostImgH: NSLayoutConstraint!
    
    @IBOutlet var idImgView: UIImageView!
    
    @IBOutlet var posterLbl: UILabel!
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var postLbl: UILabel!
    @IBOutlet var postImgView: UIImageView!
    
    @IBAction func backAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    var segueArgument:PostModel!
    
    
    let basicCellIdentifier = "BasicCell"
    let imageCellIdentifier = "ImageCell"
    
    
    @IBOutlet var stTableView: UITableView!
    
    var stThreadList : [ReplyModel] = []
    
    //actionReply & bottomView begin
    @IBOutlet var actionReplyImgBtn: UIButton!
    
    @IBOutlet var actionReplyImg: UIImageView!
    
    @IBOutlet var replyCameraBtn: UIButton!
    
    @IBOutlet var replyTxt: UITextView!
    
    @IBOutlet var replyBtn: UIButton!
    
    @IBOutlet var actionReplyContainer: UIView!
    
    var imagePicker = UIImagePickerController()
    
    var shouldFocusOnReplyTxt : Bool = false

    //actionReply & bottomView end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addHandlers()
        
        actionReplyContainer.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardDidHideNotification, object: nil);
        
        actionReplyContainer.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardDidHideNotification, object: nil);
        
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
            //            self.postImgView.removeConstraint(NSLayoutConstraint(item: self.postImgView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 75))
            //
            //            self.postImgView.addConstraint(NSLayoutConstraint(item: self.postImgView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0))
            mainPostImgH.constant = 0
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
        
        shouldFocusOnReplyTxt = false
        
    }
    
    func keyboardNotification(notification: NSNotification) {
        
        let isShowing = notification.name == UIKeyboardDidShowNotification
        
        if let userInfo = notification.userInfo {
            
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let endFrameHeight = endFrame?.size.height ?? 0.0
            
//            println("values: \(self.bottomViewB2?.constant) \(endFrameHeight)")
            
            self.bottomViewB2?.constant = isShowing ? endFrameHeight : 0.0
            self.actionReplyContainerB?.constant = isShowing ? endFrameHeight + 40.0 : 40.0
            
//            println("values after: \(self.bottomViewB2?.constant) \(endFrameHeight)")
        }
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
    
    //    deinit {
    //        NSNotificationCenter.defaultCenter().removeObserver(self)
    //    }
    
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
                        }
                        idx++
                    }
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
        
        if !reply.isEqualToString("") {
            reply = (reply as String).replace("<[^>]+>",template:"")
        }
        
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
    
    
    @IBAction func actionReplyImgBtnTapped(sender: AnyObject) {
        clearUploadImg()
    }
    
    func clearUploadImg(){
        actionReplyImg.image = nil
        actionReplyContainer.hidden = true
    }
    
    @IBAction func replyCameraBtnTapped(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            if replyTxt.isFirstResponder() {
                self.shouldFocusOnReplyTxt = true
            }
            
            println("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        picker .dismissViewControllerAnimated(true, completion: nil)
        
        if let imageTemp : UIImage? = info[UIImagePickerControllerOriginalImage] as? UIImage {
            actionReplyImg.image = imageTemp
            actionReplyContainer.hidden = false
        }else{
            actionReplyContainer.hidden = true
        }
        
        if shouldFocusOnReplyTxt {
            replyTxt.becomeFirstResponder()
        }
    }
    
    
    @IBAction func replyBtnTapped(sender: AnyObject) {
        if(self.validateBeforeReply()){
            if actionReplyImg.image != nil {
                self.sendReplyImage()
            }else{
                self.sendReplyMessage("")
            }
        }
    }
    
    func validateBeforeReply() -> Bool {
        let reply:NSString = replyTxt.text
        if ( reply.isEqualToString("")) {
            GlobalFunction().showAlert("Reply Failed!", message: "Please write something")
            return false
        } else {
            return true
        }
    }
    
    func sendReplyImage() {
        // init paramters Dictionary
        var parameters = [
            "task": "task",
            "variable1": "var"
        ]
        
        // add addtionial parameters
        parameters["_xn"] = "\(GlobalFunction().getXN())"
        parameters["_from_ios"] = "1"
        
        // example image data
        //        let image = UIImage(named: "177143.jpg")
        let image = actionReplyImg.image
        let imageData = UIImagePNGRepresentation(image)
        
        // CREATE AND SEND REQUEST ----------
        
        let urlRequest = GlobalFunction().urlRequestWithComponents(GlobalVariables().serverUrlDesktop+"/upload_reply.php", parameters: parameters, imageData: imageData)
        
        Alamofire.upload(urlRequest.0, urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                println("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON { (request, response, jsonResponse, error) in
                println("REQUEST \(request)")
                //                println("RESPONSE \(response)")
                println("JSON \(jsonResponse)")
                println("ERROR \(error)")
                
                if error == nil {
                    let responseDict = JSON(jsonResponse as! NSDictionary)
                    
                    let statTemp = responseDict["stat"]
                    let stat : NSString = "\(statTemp)"
                    if stat.isEqualToString("0") {
                        let msg = responseDict["msg"]
                        GlobalFunction().showAlert("Upload Image Failed!", message: "\(msg)")
                    }else{
                        let id = responseDict["id"]
                        self.sendReplyMessage("\(id)")
                    }
                }else{
                    GlobalFunction().showAlert("Upload Image Failed!", message: error!.description)
                }
        }
    }
    
    func sendReplyMessage(imId : String){
        var reply:NSString = replyTxt.text
        let globalVariables = GlobalVariables()
        
        let uname:NSString = GlobalFunction().getXN()
        
        var replyData:NSString = "x=\(uname)&y=\(segueArgument.postId)&z=\(reply)&im=\(imId)&s=3"
        
        if let responseData:NSData? = GlobalFunction().askServer("Reply", url: globalVariables.serverUrl+"/stock_tab6_reply.php", postData: replyData){
            
            let responseNSStr:NSString  = NSString(data:responseData!, encoding:NSUTF8StringEncoding)!
            
            let responseStr :String = responseNSStr as String
            
            println(responseStr)
            
            let responseMsg: NSString = responseStr.substringFromIndex(advance(responseStr.startIndex,3))
            
            let responseStat: NSString = responseStr.substringToIndex(advance(responseStr.startIndex, 1))
            if(responseStat.isEqualToString("1")){
                
                var error: NSError?
                
                var dataFromNetwork:NSData! = responseMsg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                
                let jsonContent = JSON(data: dataFromNetwork)
                
//                println("1------------")
//                println(jsonContent)
                
                var replier : NSString = "null"
                if let replierTemp : NSString? = jsonContent[0][0].string {
                    replier = replierTemp!
                }
                
                var poster : NSString = "null"
                if let posterTemp : NSString? = jsonContent[0][1].string {
                    poster = posterTemp!
                }
                
                var post : NSString = "null"
                if let postTemp : NSString? = jsonContent[0][2].string {
                    post = postTemp!
                }
                
                var reply : NSString = "null"
                if let replyTemp : NSString? = jsonContent[0][3].string {
                    reply = replyTemp!
                }
                
                var cat_id : NSInteger = 0
                if let cat_idTemp : NSInteger? = jsonContent[0][4].int {
                    cat_id = cat_idTemp!
                }
                
                var act_date : NSInteger = 0
                if let act_dateTemp : NSInteger? = jsonContent[0][5].int {
                    act_date = act_dateTemp!
                }
                
                var post_id : NSInteger = 0
                if let post_idTemp : NSInteger? = jsonContent[0][6].int {
                    post_id = post_idTemp!
                }
                
                var cd : NSInteger = 0
                if let cdTemp : NSInteger? = jsonContent[0][7].int {
                    cd = cdTemp!
                }
                
                var pp : NSString = "bullsmile.png"
                if let ppTemp : NSString? = jsonContent[0][8].string {
                    pp = ppTemp!
                }
                
                var rep_id : NSInteger = 0
                if let rep_idTemp : NSInteger? = jsonContent[0][9].int {
                    rep_id = rep_idTemp!
                }
                
                var images_str : NSString = ""
                if jsonContent[0][10].count > 0 {
                    images_str = jsonContent[0][10][0].string!
                }
                
                var images_arr = []
                
                if(!images_str.isEqualToString("")){
                    images_arr = [images_str]
                }
                
                var creply : NSInteger = 0
                if let creplyTemp : NSInteger? = jsonContent[0][11].int {
                    creply = creplyTemp!
                }
                
                var hot_threaded : NSInteger = 0
                if let hot_threadedTemp : NSInteger? = jsonContent[0][12].int {
                    hot_threaded = hot_threadedTemp!
                }
                
                let shortlink : NSString = ""
                var pinned : NSInteger = 0
                if let pinnedTemp : NSInteger? = jsonContent[0][14].int {
                    pinned = pinnedTemp!
                }
                
                var sent_from : NSInteger = 0
                if let sent_fromTemp : NSInteger? = jsonContent[0][15].int {
                    sent_from = sent_fromTemp!
                }
                
                var act_date_before : NSInteger = 0
                if let act_date_beforeTemp : NSInteger? = jsonContent[0][16].int {//element index #16
                    act_date_before = act_date_beforeTemp!
                }
                
                let mention_arr = []
                let mention_arr_reply = []
                let collection_count : NSInteger = 0
                
                var nbed : NSInteger = 0
                if let nbedTemp : NSInteger? = jsonContent[0][20].int {
                    nbed = nbedTemp!
                }
                
                var post_date : NSString = "0"
                if let post_dateTemp : NSString? = jsonContent[0][21].string {
                    post_date = post_dateTemp!
                }
                
                var gender : NSInteger = 0
                if let genderTemp : NSInteger? = jsonContent[0][22].int {
                    gender = genderTemp!
                }
                
                let jsonDict = [
                        [
                            replier
                            ,poster
                            ,post
                            ,reply
                            ,cat_id
                            ,act_date
                            ,post_id
                            ,cd
                            ,pp
                            ,rep_id
                            ,images_arr
                            ,creply
                            ,hot_threaded
                            ,shortlink
                            ,pinned
                            ,sent_from
                            ,act_date_before
                            ,mention_arr
                            ,mention_arr_reply
                            ,collection_count
                            ,nbed
                            ,post_date
                            ,gender
                        ]
                    ]
                
                
                if !socketClient.socket.connected {
                    socketClient.socket.connect()
                }
                
                socketClient.socket.emit("message reply",jsonDict)
                
                replyTxt.text = "";
                replyTxt.resignFirstResponder()
                
                if actionReplyImg.image != nil {
                    self.clearUploadImg()
                }
            }else{
                println("failed2")
            }
        }
    }
    
    func addHandlers() {
        
        if !socketClient.socket.connected {
            socketClient.socket.connect()
        }
        
        socketClient.socket.on("message reply"){[weak self] dataReply, ack in
            var handled : Bool = false
            if let d = dataReply?[0] as? NSString {
                println("reply handled")
                self!.generateFeedsFinalMediator(GlobalFunction().generateFeeds(d, isPost: false),isAppend: true)
                handled = true
            }
            
            if(!handled){
                println("reply not handled: \(dataReply?[0])")
                self!.generateFeedsFinalMediator(GlobalFunction().generateFeedsFromArr(dataReply?[0] as! NSArray),isAppend: true)
            }
        }
    }
    
    func generateFeedsFinalMediator(contentJSON: JSON, isAppend : Bool){
        
        let threadNew : [ReplyModel] =  generateFeedsFinal(contentJSON, isAppend: isAppend)
        
        if !isAppend {
            stThreadList = threadNew + stThreadList
        }else{
            stThreadList = stThreadList + threadNew
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.stTableView.reloadData()
        })
    }
    
    func generateFeedsFinal(contentJSON: JSON, isAppend : Bool) -> [ReplyModel]{
        var replier : NSString = ""
        if let replierTemp : NSString? = contentJSON[0].string {
            replier = replierTemp!
        }
        
        var poster : NSString = ""
        if let posterTemp : NSString? = contentJSON[1].string {
            poster = posterTemp!
        }
        var post : NSString = ""
        if let postTemp : NSString? = contentJSON[2].string {
            post = postTemp!
        }
        
        var reply : NSString = ""
        if let replyTemp : NSString? = contentJSON[3].string {
            reply = replyTemp!
        }
        
        var displayMode : Int = 0 //POST_MODE
        if(!replier.isEqualToString("") && !replier.isEqualToString("null")){
            displayMode = 1 //REPLY_MODE
        }
        
        var rowText : NSString
        
        if(displayMode == 0){
            rowText =  "@\(poster) > \" \(post)\""
        }else{
            rowText =  "@\(replier) replied @\(poster) > \" \(reply)\""
        }
        
        var img : NSString = ""
        
        if(contentJSON[10].count > 0){
            if let imgTemp : NSString? = contentJSON[10][0].string {
                img = imgTemp!
            }
        }
        
        var idImg : NSString = ""
        if let idImgTemp : NSString? = contentJSON[8].string {
            idImg = idImgTemp!
        }
        
        if !GlobalFunction().shouldUseDrawable(idImg) {
            idImg = GlobalVariables().serverUrlDesktop + "/uploaded_images/profpic/" + (idImg as String)
        }
        
        
        var actDateInt : Int = -1
        if let actDateIntTemp : Int = contentJSON[5].int {
            actDateInt = actDateIntTemp
        }
        
        var postId : Int = 0
        if let postIdTemp : Int = contentJSON[6].int {
            postId = postIdTemp
        }
        
        if !post.isEqualToString("") {
            post = (post as String).replace("<[^>]+>",template:"")
        }
        
        let threadNew : [ReplyModel] = [ReplyModel(reply: reply, replyDate: GlobalFunction().getTimeF(actDateInt), idImg: idImg, replyImg: img, replier: replier)]
        
        return threadNew
    }
}
