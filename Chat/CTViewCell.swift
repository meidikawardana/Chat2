//
//  CTViewCell.swift
//  Chat
//
//  Created by Meidika Wardana on 4/23/15.
//  Copyright (c) 2015 BEI5000. All rights reserved.
//

import UIKit

class CTViewCell: UITableViewCell {
    
    //    @IBOutlet var titleLable : UILabel!
    //    @IBOutlet var categoryName : UILabel!
    
    @IBOutlet var contentLabel: UILabel!
    
    
    @IBOutlet var dateLabel: UILabel!
    
    
    @IBOutlet var idImageView: UIImageView!
    
    @IBOutlet var postImageView: UIImageView!
    
    //Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.8)
        dateLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.8)
        
    }
    
    // セル内セット
    func configureCell(texts:PostModel, atIndexPath indexPath: NSIndexPath){
        
        contentLabel.text = texts.postContent as String
        dateLabel.text = texts.postDate as String
        
        self.idImageView.image = UIImage(named:  "bullsmile.png")
        
        if !texts.idImg.isEqualToString("") {
            ImageLoader.sharedLoader.imageForUrl(self.getActualImg(texts.idImg) as String, completionHandler:{(image: UIImage?, url: String) in
                
                if !(image == nil) {
                    self.idImageView.image = image!
                }
            })
        }
        
        let postImg: NSString = texts.postImg
        if postImg.isEqualToString("") {
            self.postImageView.image = nil
            
            self.postImageView.removeConstraint(NSLayoutConstraint(item: self.postImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 119))
            
            self.postImageView.addConstraint(NSLayoutConstraint(item: self.postImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0))
        }else{
            
            self.postImageView.removeConstraint(NSLayoutConstraint(item: self.postImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 119))
            
            self.postImageView.removeConstraint(NSLayoutConstraint(item: self.postImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0))
            
            self.postImageView.addConstraint(NSLayoutConstraint(item: self.postImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 119))
            
//            println("\( self.getActualImg(postImg) )")
            
            ImageLoader.sharedLoader.imageForUrl(self.getActualImg(postImg) as String, completionHandler:{(image: UIImage?, url: String) in
                self.postImageView.image = image!
            })
        }
    }
    
    func getActualImg(url:NSString) ->NSString{
        var img_post : NSString = url
        img_post = img_post.stringByReplacingOccurrencesOfString("http://localhost/fsocial", withString: GlobalVariables().serverUrlDesktop)
        img_post = img_post.stringByReplacingOccurrencesOfString("http://localhost/m", withString: GlobalVariables().serverUrl)
        return img_post
    }
}