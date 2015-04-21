//
//  HomeVC.swift
//  SwiftLoginScreen
//
//  Created by Dipin Krishna on 31/07/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.

import UIKit

class HomeVC: UIViewController {

    @IBOutlet var usernameLabel : UILabel!
    
    @IBOutlet weak var chatTextview: UITextView!
    @IBOutlet weak var sendTextview: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    
//    let socket = SocketIOClient(socketURL: "192.168.1.100:8080")
    let socket = SocketIOClient(socketURL: GlobalVariables().socketUrl)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addHandlers()
        self.socket.connect()
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
                    
//                    var responseArr = responseStr.componentsSeparatedByCharactersInSet(separators)
                    
                    let responseMsg: NSString = responseStr.substringFromIndex(advance(responseStr.startIndex,3))
                    
                    println("1.....#\(responseMsg as String)#")
                    
                    let responseStat: NSString = responseStr.substringToIndex(advance(responseStr.startIndex, 1))
                    
                    println("2......#\(responseStat as String)#")
                        if(responseStat.isEqualToString("1")){
//                            let msg = "{\"content\":\(responseMsg)}"
//                            println(msg)
                            
//                            let replier = NSNull()
//                            let poster  = "meidika"
//                            
//                            self.socket.emit("message post",[ "content": [
//                                    [
//                                        replier,
//                                        poster,
//                                        "test7",
//                                        NSNull(),
//                                        3,
//                                        1429631885,
//                                        10776,
//                                        0,
//                                        "0161809001429095521_meidika_cropped.png",
//                                        0,
//                                        [
//                                            
//                                        ],
//                                        0,
//                                        0,
//                                        "",
//                                        0,
//                                        3,
//                                        1429631640,
//                                        [
//                                            
//                                        ],
//                                        [
//                                            
//                                        ],
//                                        0,
//                                        0,
//                                        1429631885,
//                                        1
//                                    ]
//                                ]
//                            ])
//                            sendTextview.text = "";
//                            sendTextview.resignFirstResponder()
                            

//                            let post : NSString? = jsonContent[0][2].string
//                            let reply : NSString? = jsonContent[0][3].string
//                            let cat_id : NSInteger? = jsonContent[0][4].int
//                            let act_date : NSInteger? = jsonContent[0][5].int
//                            let post_id : NSInteger? = jsonContent[0][6].int
//                            let cd : NSInteger = 0
//                            let pp : NSString? = jsonContent[0][8].string
//                            let rep_id : NSInteger? = jsonContent[0][9].int
//                            
//                            var images_str : NSString = ""
//                            
//                            if jsonContent[0][10].count > 0 {
//                                images_str = jsonContent[0][10][0].string!
//                            }
//                            
//                            var images_arr = []
//                            
//                            if(!images_str.isEqualToString("")){
//                                images_arr = [images_str]
//                            }
//                            
//                            let creply : NSInteger = 0
//                            let hot_threaded : NSInteger = 0
//                            let shortlink : NSString = ""
//                            let pinned : NSInteger = 0
//                            let sent_from : NSInteger? = jsonContent[0][15].int
//                            let act_date_before : NSInteger? = jsonContent[0][16].int //element index #16
//                            let mention_arr = []
//                            let mention_arr_reply = []
//                            let collection_count : NSInteger = 0
//                            let nbed : NSInteger = 0
//                            let post_date : NSString? = jsonContent[0][21].string
//                            let gender : NSInteger? = jsonContent[0][22].int
                            
                
                            var error: NSError?
                            
                            var dataFromNetwork:NSData! = responseMsg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                            
                            let jsonContent = JSON(data: dataFromNetwork)
                            
                            println("1------------")
                            println(jsonContent)
                            //
                            
                            let replier : NSString? = jsonContent[0][0].string
                            let poster : NSString? = jsonContent[0][1].string
                            
                            let jsonDict = ["content" :
                                [
                                    [
                                        replier
                                        ,poster
                                    ]
                                ]
                            ]

                                self.socket.emit("message post",jsonDict)
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
        if(!replier.isEqualToString("")){
            displayMode = 1 //REPLY_MODE
        }
        
        var rowText : NSString
        
        if(displayMode == 0){
            rowText =  "\(poster) > \" \(post)\""
        }else{
            rowText =  "\(replier) replied \(poster) > \" \(reply)\""
        }
        
        self.appendText(rowText as String)
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