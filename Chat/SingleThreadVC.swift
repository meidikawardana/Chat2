//
//  SingleThreadVC.swift
//  Chat
//
//  Created by Meidika Wardana on 5/6/15.
//  Copyright (c) 2015 BEI5000. All rights reserved.
//

import UIKit

class SingleThreadVC: UIViewController {
    
    @IBOutlet weak var bottomSpacingConstraint: NSLayoutConstraint!

    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet weak var bottomSpacingConstraintImg: NSLayoutConstraint!
    
    
    @IBOutlet weak var bottomSpacingConstraintBtn: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillHideNotification, object: nil);
        
        self.postImageView.removeConstraint(NSLayoutConstraint(item: self.postImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 75))
        
        self.postImageView.addConstraint(NSLayoutConstraint(item: self.postImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0))

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
        
        if let userInfo = notification.userInfo {
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

}
