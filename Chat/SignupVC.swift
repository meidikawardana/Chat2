//
//  SignupVC.swift
//  SwiftLoginScreen
//
//  Created by Dipin Krishna on 31/07/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

import UIKit

class SignupVC: UIViewController {
    
    @IBOutlet var txtUsername : UITextField!
    
    @IBOutlet var txtEmail: UITextField!
    
    @IBOutlet var txtPassword : UITextField!
    
    @IBOutlet var txtPhone: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
    
    @IBAction func gotoLogin(sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func signupTapped(sender : UIButton) {
        var username:NSString = txtUsername.text as NSString
        var email:NSString = txtEmail.text as NSString
        var password:NSString = txtPassword.text as NSString
        var phone:NSString = txtPhone.text as NSString
        
        var cont:Bool = true
        var errMessage:NSString = ""
        
        let globalVariables = GlobalVariables()
        
        
        if(username.isEqualToString("")){
            cont = false
            errMessage = "Please enter valid Username. can only contains: a-z, A-Z, 0-9, dot (.) and underscore (_)"
        }
        
        if(!isValidUname(username)){
            cont = false
            errMessage = "Please enter valid Username. can only contains: a-z, A-Z, 0-9, dot (.) and underscore (_)"
        }
        
        if((email.isEqualToString("") || !isValidEmail(email as String)) && cont){
            cont = false
            errMessage = "Please enter valid Email"
        }
        
        if(password.isEqualToString("") && cont){
            cont = false
            errMessage = "Please enter Password"
        }
        
        if(phone.isEqualToString("") && cont){
            cont = false
            errMessage = "Please enter Phone"
        }
        
        if (!cont) {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = errMessage as String
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            
            var post:NSString = "n=\(username)&e=\(email)&pa=\(password)&ph=\(phone)"
            
            NSLog("PostData: %@",post);
            
            var url:NSURL = NSURL(string: globalVariables.serverUrl+"/stock_register_ios.php")!
            
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
                
                NSLog("Response code: %ld", res.statusCode);
                
                if (res.statusCode >= 200 && res.statusCode < 300)
                {
                    var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                    
                    NSLog("Response ==> %@", responseData);
                    
                    var error: NSError?
                    
                    let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                    
                    
                    
                    let success:NSInteger = jsonData.valueForKey("stat") as! NSInteger
                   
                    
                    //[jsonData[@"success"] integerValue];
                    
                    NSLog("Success: %ld", success);
                    
                    if(success == 1)
                    {
                        NSLog("Sign Up SUCCESS");
                        
                        let xn:NSString = jsonData.valueForKey("xn") as! NSString
                        
                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        prefs.setObject(email, forKey: "EMAIL")
                        prefs.setObject(xn, forKey: "XN")
                        prefs.setInteger(1, forKey: "ISLOGGEDIN")
                        prefs.synchronize()
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
//                        self.performSegueWithIdentifier("goto_home", sender: self)
                    } else {
                        var error_msg:NSString
                        
                        if jsonData["msg"] as? NSString != nil {
                            error_msg = jsonData["msg"] as! NSString
                        } else {
                            error_msg = "Unknown Error"
                        }
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign Up Failed!"
                        alertView.message = error_msg as String
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                        
                    }
                    
                } else {
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign Up Failed!"
                    alertView.message = "Connection Failed"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            }  else {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failure"
                if let error = reponseError {
                    alertView.message = (error.localizedDescription)
                }
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func isValidUname(testStr:NSString) -> Bool {
        var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789_.")
        if (testStr.rangeOfCharacterFromSet(characterSet.invertedSet).location != NSNotFound){
            return false
        }
        return true
    }
}
