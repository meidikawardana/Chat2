//
//  HomeVC.swift
//  SwiftLoginScreen
//
//  Created by Dipin Krishna on 31/07/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.

import UIKit
import Alamofire

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate,
UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    @IBOutlet var usernameLabel : UILabel!
    
    @IBOutlet weak var sendTextview: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var uploadImgView: UIImageView!
    
    @IBOutlet var btnUploadImg: UIButton!
    
    
    @IBOutlet var btnRemoveImg: UIButton!
    
    
    var imagePicker = UIImagePickerController()
    
    let basicCellIdentifier = "BasicCell"
    let imageCellIdentifier = "ImageCell"
    
    @IBAction func uploadImgTapped(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            println("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnRemoveImgTapped(sender: AnyObject) {
        self.clearUploadImg()
    }
    
    
    func clearUploadImg(){
        uploadImgView.image = nil
        btnRemoveImg.hidden = true
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        picker .dismissViewControllerAnimated(true, completion: nil)
        
        if let imageTemp : UIImage? = info[UIImagePickerControllerOriginalImage] as? UIImage {
            uploadImgView.image = imageTemp
            btnRemoveImg.hidden = false
        }else{
            btnRemoveImg.hidden = true
        }
    }
    
    
    //    let socket = SocketIOClient(socketURL: "192.168.1.100:8080")
    let socket = SocketIOClient(socketURL: GlobalVariables().socketUrl)
    
    var threadList : [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRemoveImg.hidden = true
        
        // Do any additional setup after loading the view.
        self.addHandlers()
        self.socket.connect()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
    }
    
    // セクション数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // セクションの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threadList.count
    }
    
    // セクション高さ
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return 100
    //    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if hasImageAtIndexPath(indexPath) {
            return imageCellAtIndexPath(indexPath)
        } else {
            return basicCellAtIndexPath(indexPath)
        }
    }
    
    func hasImageAtIndexPath(indexPath:NSIndexPath) -> Bool {
        let thread = threadList[indexPath.row]
        
        let postImg: NSString = thread.postImg
        if postImg.isEqualToString("") {
            return false
        }
        return true
    }
    
    func imageCellAtIndexPath(indexPath:NSIndexPath) -> ImageCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(imageCellIdentifier) as! ImageCell
        setPostContent(cell, indexPath: indexPath)
        setPostDate(cell, indexPath: indexPath)
        setIdImg(cell, indexPath: indexPath)
        setPostImg(cell, indexPath: indexPath)
        return cell
    }
    
    func setPostImg(cell:ImageCell, indexPath:NSIndexPath) {
        let thread = threadList[indexPath.row] as PostModel
        ImageLoader.sharedLoader.imageForUrl(GlobalFunction().getActualImg(thread.postImg) as String, completionHandler:{(image: UIImage?, url: String) in
//            cell.postImageView.contentMode = .ScaleAspectFit
//            cell.postImageView.clipsToBounds = true
            cell.postImageView.image = image!
        })
    }
    
    func basicCellAtIndexPath(indexPath:NSIndexPath) -> BasicCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(basicCellIdentifier) as! BasicCell
        setPostContent(cell, indexPath: indexPath)
        setPostDate(cell, indexPath: indexPath)
        setIdImg(cell, indexPath: indexPath)
        return cell
    }
    
    func setPostContent(cell:BasicCell, indexPath:NSIndexPath) {
        let thread = threadList[indexPath.row] as PostModel
        cell.postLabel.text = thread.postContent as String
    }
    
    func setPostDate(cell:BasicCell, indexPath:NSIndexPath) {
        let thread = threadList[indexPath.row] as PostModel
        cell.dateLabel.text = thread.postDate as String
    }
    
    func setIdImg(cell:BasicCell, indexPath:NSIndexPath) {
        let thread = threadList[indexPath.row] as PostModel
        cell.posterImageView.image = UIImage(named:  "bullsmile.png")
        
        if !thread.idImg.isEqualToString("") {
            ImageLoader.sharedLoader.imageForUrl(GlobalFunction().getActualImg(thread.idImg) as String, completionHandler:{(image: UIImage?, url: String) in
                
                if !(image == nil) {
                    cell.posterImageView.image = image!
                }
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if (!self.isLoggedIn()) {
            self.gotoLogin()
        } else {
            let xn = self.getXN()
            self.usernameLabel.text = xn
            let jsonLogin = ["username" : xn
                ,"ismobile": 0
            ]
            
            self.socket.emit("add user", jsonLogin)
            
            self.appendFeeds()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // #pragma mark - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toSingleThread" || segue.identifier == "toSingleThread2" ) {
            
            //            let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)
            
            var indexPath = self.tableView.indexPathForSelectedRow() //get index of data for selected row
            
            let r:PostModel = self.threadList[indexPath!.row] as PostModel
            
//            println("1.---\(r.postContent)")
//            println("2.---\(r.postDate)")
//            println("3.---\(r.idImg)")
//            println("4.---\(r.postImg)")
            
            var svc = segue.destinationViewController as! SingleThreadVC
            
            svc.segueArgument = r
            
        }
    }
    
    @IBAction func logoutTapped(sender : UIButton) {
        
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        
        self.performSegueWithIdentifier("goto_login", sender: self)
    }
    
    
    @IBAction func sendTapped(sender: AnyObject) {
        
        if (!self.isLoggedIn()) {
            self.gotoLogin()
        } else {
            if(self.validateBeforePost()){
                if uploadImgView.image != nil {
                    self.sendPostImage()
                }else{
                    self.sendPostMessage("")
                }
                
            }
        }
    }
    
    func sendPostImage(){
        // init paramters Dictionary
        var parameters = [
            "task": "task",
            "variable1": "var"
        ]
        
        // add addtionial parameters
        parameters["_xn"] = "\(self.getXN())"
        parameters["_iim"] = "1"
        parameters["_from_ios"] = "1"
        
        // example image data
        //        let image = UIImage(named: "177143.jpg")
        let image = uploadImgView.image
        let imageData = UIImagePNGRepresentation(image)
        
        // CREATE AND SEND REQUEST ----------
        
        let urlRequest = urlRequestWithComponents(GlobalVariables().serverUrl+"/upload.php", parameters: parameters, imageData: imageData)
        
        Alamofire.upload(urlRequest.0, urlRequest.1)
//        Alamofire.upload(.GET, GlobalVariables().serverUrl+"/upload_alamofire.php?_xn=\(self.getXN())&_iim=1", imageData)
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
                        self.sendPostMessage("\(id)")
                    }
                    
//                    let stat: NSString = responseDict["stat"].string!
//                    let id: NSString = responseDict["id"].string!
//                    
//                    println("\(stat)")
//                    println("\(id)")
                    
//                    let responseJSON = JSON(jsonResponse as! NSDictionary)
//                    
//                    if let stat : NSString = responseDict["stat"]!.string {
//                        if stat.isEqualToString("0") {
//                            let msg : NSString = responseDict["msg"]!.string!
//                            GlobalFunction().showAlert("Upload Image Failed!", message: "\(msg)")
//                        }else{
//                            let imId : String = responseDict["id"]!.string!
//                            self.sendPostMessage(imId)
//                        }
//                    }else{
//                        GlobalFunction().showAlert("Upload Image Failed!", message: "Error unknown")
//                    }
                }else{
                    GlobalFunction().showAlert("Upload Image Failed!", message: error!.description)
                }
        }
    }
    
    func addHandlers() {
        self.socket.onAny {println("Got event: \($0.event), with items: \($0.items)")}
        self.socket.on("message"){[weak self] data, ack in
            println("got message! \(data?[0])")
            
            //            self?.appendText("\(data![0])")
            
        }
        self.socket.on("message post"){[weak self] dataPost, ack in
            var handled : Bool = false
            if let d = dataPost?[0] as? NSString {
                self?.generateFeeds(d, isPost: true)
                handled = true
            }
            
            if(!handled){
                self?.generateFeedsFromDict(dataPost?[0] as! NSDictionary)
            }
        }
        
        self.socket.on("message reply"){[weak self] dataReply, ack in
            var handled : Bool = false
            if let d = dataReply?[0] as? NSString {
                self?.generateFeeds(d, isPost: false)
                handled = true
            }
            
            if(!handled){
                self?.generateFeedsFromArr(dataReply?[0] as! NSArray)
            }
        }
    }
    
    func generateFeedsFromDict(jsonData : NSDictionary){
        let json = JSON(jsonData)
        
        let contentJSON = json["content"][0]
        self.generateFeedsFinal(contentJSON,isAppend: false)
    }
    
    func generateFeedsFromArr(jsonData : NSArray){
        let json = JSON(jsonData)
        
        let contentJSON = json[0]
        self.generateFeedsFinal(contentJSON,isAppend: false)
    }
    
    func generateFeeds(jsonData : NSString, isPost: Bool){
        
        var error: NSError?
        
        var dataFromNetwork:NSData! = jsonData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let jsonDict : NSDictionary? = NSJSONSerialization.JSONObjectWithData(dataFromNetwork, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
        
        
        let json = ( isPost ? JSON(jsonDict!) : JSON(data: dataFromNetwork))
        
        
        //        println("1------------")
        //        println(json)
        
        
        let contentJSON = ( isPost ? json["content"][0] : json[0] )
        
        //        println("2------------")
        //        println(contentJSON)
        
        self.generateFeedsFinal(contentJSON,isAppend: false)
    }
    
    func generateFeedsFinal(contentJSON: JSON, isAppend : Bool){
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
        
        var postImg : NSString = ""
        
        if(contentJSON[10].count > 0){
            if let postImgTemp : NSString? = contentJSON[10][0].string {
                postImg = postImgTemp!
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
        
        //        println("-----idmg:\(idImg)")
        
        let threadNew : [PostModel] = [PostModel(postContent:rowText, postDate:GlobalFunction().getTimeF(actDateInt),idImg:idImg,postImg: postImg, postId: postId, poster: poster, postOri: post )]
        
        if !isAppend {
            threadList = threadNew + threadList
        }else{
            threadList = threadList + threadNew
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    func isLoggedIn() ->Bool{
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int =  prefs.integerForKey("ISLOGGEDIN") as Int
        return isLoggedIn == 1
    }
    
    func getXN() ->String{
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        return prefs.valueForKey("XN") as! NSString as String
    }
    
    func gotoLogin(){
        self.performSegueWithIdentifier("goto_login", sender: self)
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
    
    func validateBeforePost() -> Bool {
        var post:NSString = sendTextview.text
        if ( post.isEqualToString("")) {
            GlobalFunction().showAlert("Post Failed!", message: "Please write something")
            return false
        } else {
            return true
        }
    }
    
    func sendPostMessage(imId : String){
        var post:NSString = sendTextview.text
        let globalVariables = GlobalVariables()
        
        let uname:NSString = self.getXN()
        
        var postData:NSString = "x=\(uname)&y=3&z=\(post)&i=&u=&im=\(imId)&s=3"
        
        if let responseData:NSData? = askServer("Post", url: globalVariables.serverUrl+"/stock_tab6_post_status.php", postData: postData){
            
            let responseNSStr:NSString  = NSString(data:responseData!, encoding:NSUTF8StringEncoding)!
            
            let responseStr :String = responseNSStr as String
            
            println(responseStr)
            
            let responseMsg: NSString = responseStr.substringFromIndex(advance(responseStr.startIndex,3))
            
            let responseStat: NSString = responseStr.substringToIndex(advance(responseStr.startIndex, 1))
            if(responseStat.isEqualToString("1")){
                
                var error: NSError?
                
                var dataFromNetwork:NSData! = responseMsg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                
                let jsonContent = JSON(data: dataFromNetwork)
                
                println("1------------")
                println(jsonContent)
                
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
                
                let cd : NSInteger = 0
                
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
                
                let creply : NSInteger = 0
                let hot_threaded : NSInteger = 0
                let shortlink : NSString = ""
                let pinned : NSInteger = 0
                
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
                let nbed : NSInteger = 0
                
                var post_date : NSString = "0"
                if let post_dateTemp : NSString? = jsonContent[0][21].string {
                    post_date = post_dateTemp!
                }
                
                var gender : NSInteger = 0
                if let genderTemp : NSInteger? = jsonContent[0][22].int {
                    gender = genderTemp!
                }
                
                let jsonDict = ["content" :
                    [
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
                ]
                
                self.socket.emit("message post",jsonDict)
                
                sendTextview.text = "";
                sendTextview.resignFirstResponder()
                
                if uploadImgView.image != nil {
                    self.clearUploadImg()
                }
            }else{
                println("failed2")
            }
        }
    }
    
    func appendFeeds(){
        let globalVariables = GlobalVariables()
        
        
        var post:NSString = "_lin=&_xn=&t=3&tag=&s=2&n=0&use_collection_clause=1"
        
//        NSLog("PostData: %@",post);
        
        let urlString : String = globalVariables.serverUrlDesktop+"/_wall_json_android_2.php"
        
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
                
//                NSLog("Response Feeds ==> %@", responseData);
                
                var error: NSError?
                
                let jsonArr:NSArray = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSArray
                
                for jsonPiece : AnyObject in jsonArr {
                    let json = JSON(jsonPiece as! NSArray)
                    
                    self.generateFeedsFinal(json,isAppend: true)
                }
                
            } else {
                GlobalFunction().showAlert("Failed to get chat history", message: "Connection Failed")
            }
        } else {
            if let error = reponseError {
                GlobalFunction().showAlert("Failed to get chat history", message: error.localizedDescription)
            }else{
                GlobalFunction().showAlert("Failed to get chat history", message: "Connection Failure")
            }
        }
    }
}