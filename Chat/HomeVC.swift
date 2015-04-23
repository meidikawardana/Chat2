//
//  HomeVC.swift
//  SwiftLoginScreen
//
//  Created by Dipin Krishna on 31/07/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.

import UIKit

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet var usernameLabel : UILabel!
    
    @IBOutlet weak var chatTextview: UITextView!
    @IBOutlet weak var sendTextview: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    
    @IBOutlet var tableView: UITableView!
    
//    let socket = SocketIOClient(socketURL: "192.168.1.100:8080")
    let socket = SocketIOClient(socketURL: GlobalVariables().socketUrl)
    
    var threadList : [CTModel] = [
//        CTModel(titleName:"Barack Obama", categoryName:"today",idImg:"Barack-Obama.jpg"),
//        CTModel(titleName:"Bill Gates", categoryName:"yesterday",idImg:"bill-gates.jpg"),
//        CTModel(titleName:"Brad Paisley", categoryName:"12 Oct 15 at 12:01PM",idImg:"Brad-Paisley.jpg"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addHandlers()
        self.socket.connect()
        
        tableView.delegate = self
        tableView.dataSource = self
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
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    // セル表示
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        //cell deque
        let cell: CTViewCell = self.tableView.dequeueReusableCellWithIdentifier("customCell") as! CTViewCell
        //cell中身セット（引数　セル、indexPath）
        cell.configureCell(threadList[indexPath.row] as CTModel, atIndexPath : indexPath)
        
        return cell
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
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logoutTapped(sender : UIButton) {
        
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        
        self.performSegueWithIdentifier("goto_login", sender: self)
    }
    
    
    @IBAction func sendTapped(sender: AnyObject) {
        
        if (!self.isLoggedIn()) {
            self.gotoLogin()
        } else {
            var post:NSString = sendTextview.text
            if ( post.isEqualToString("")) {                           
                self.showAlert("Post Failed!", message: "Please write something")
            } else {
                let globalVariables = GlobalVariables()
            
                let uname:NSString = self.getXN()
                
                var postData:NSString = "x=\(uname)&y=3&z=\(post)&i=&u=&im=&s=3"
                
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
                        }else{
                            println("failed2")
                        }
                }
            }
        }
    }
    
    func addHandlers() {
        self.socket.onAny {println("Got event: \($0.event), with items: \($0.items)")}
        self.socket.on("message"){[weak self] data, ack in
            println("got message! \(data?[0])")
            
            self?.appendText("\(data![0])")
            
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
        self.generateFeedsFinal(contentJSON)
    }
    
    func generateFeedsFromArr(jsonData : NSArray){
        let json = JSON(jsonData)
        
        let contentJSON = json[0]
        self.generateFeedsFinal(contentJSON)
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

        self.generateFeedsFinal(contentJSON)
    }
    
    func generateFeedsFinal(contentJSON: JSON){
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
            rowText =  "\(poster) > \" \(post)\""
        }else{
            rowText =  "\(replier) replied \(poster) > \" \(reply)\""
        }
        
//        self.appendText(rowText as String)
        
        threadList.append(CTModel(titleName:rowText as String, categoryName:"today",idImg:"Barack-Obama.jpg"))
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    func appendText(chat : String){
        if(chatTextview.text == ""){
            chatTextview.text = chat
        }else{
            chatTextview.text = chatTextview.text + "\n"+chat
        }
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
                self.showAlert(requestName+" Failed!", message: "Connection Failed")
            }
        } else {
            
            var msg : String = "Connection Failure"
            
            if let error = reponseError {
                msg = (error.localizedDescription)
            }
            
            self.showAlert(requestName+" Failed!", message: msg)
        }

        return nil
    }
    
    func showAlert(title:String,message:String){
        var alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
}