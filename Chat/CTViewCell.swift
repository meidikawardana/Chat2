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
    
    @IBOutlet var titleLabel: UILabel!
    
    
    @IBOutlet var categoryLabel: UILabel!
    
    
    @IBOutlet var idImageView: UIImageView!
    
    //Nib
    override func awakeFromNib() {
    super.awakeFromNib()
    titleLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.8)
    categoryLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.8)
    
    }
    
    // セル内セット
    func configureCell(texts:CTModel, atIndexPath indexPath: NSIndexPath){
    
    titleLabel.text = texts.titleName as String
    categoryLabel.text = texts.categoryName as String
        
    idImageView.image = UIImage(named: "bullsmile.png")
        
//    ImageLoader.sharedLoader.imageForUrl("http://upload.wikimedia.org/wikipedia/en/4/43/Apple_Swift_Logo.png", completionHandler:{(image: UIImage?, url: String) in
//            self.idImageView.image = image!
//    })
        
//    idImageView.image = UIImage(named: texts.idImg as String)
    }
}