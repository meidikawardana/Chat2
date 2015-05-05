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
    func configureCell(texts:CTModel, atIndexPath indexPath: NSIndexPath){
        
        contentLabel.text = texts.titleName as String
        dateLabel.text = texts.categoryName as String
        
        idImageView.image = UIImage(named: "bullsmile.png")
        
        let postImg: NSString = texts.postImg
        if postImg.isEqualToString("") {
            self.postImageView.image = nil
            //            self.postImageView.hidden = true
            
            self.postImageView.removeConstraint(NSLayoutConstraint(item: self.postImageView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 119))
            
            self.postImageView.addConstraint(NSLayoutConstraint(item: self.postImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0))
        }else{
            
            self.postImageView.addConstraint(NSLayoutConstraint(item: self.postImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 119))
            
            //            self.postImageView.hidden = false
            println("\( self.getActualImg(postImg) )")
            
            ImageLoader.sharedLoader.imageForUrl(self.getActualImg(postImg) as String, completionHandler:{(image: UIImage?, url: String) in
                self.postImageView.image = image!
                //                let imageView = UIImageView(image: image!)
                //
                //                imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
                //
                //                imageView.add
                //
                //                self.postImageView = imageView
            })
        }
        
        //    idImageView.image = UIImage(named: texts.idImg as String)
    }
    
    func getActualImg(url:NSString) ->NSString{
        var img_post : NSString = url
        img_post = img_post.stringByReplacingOccurrencesOfString("http://localhost/fsocial", withString: GlobalVariables().serverUrlDesktop)
        img_post = img_post.stringByReplacingOccurrencesOfString("http://localhost/m", withString: GlobalVariables().serverUrl)
        return img_post
    }
}