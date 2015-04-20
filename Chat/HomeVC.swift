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
    @IBOutlet weak var sendText: UITextField!
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
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            let xn = prefs.valueForKey("XN") as! NSString as String
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
        self.socket.emit("message",sendText.text)
        sendText.text = "";
        sendText.resignFirstResponder()
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
}