//
//  BasicCell.swift
//  DeviantArtBrowser
//
//  Created by Meidika Wardana on 5/7/15.
//  Copyright (c) 2015 Razeware, LLC. All rights reserved.
//

import UIKit

class BasicCell: UITableViewCell {
    
    @IBOutlet var posterImageView: UIImageView!
    
    @IBOutlet var posterLabel: UILabel!
    
    @IBOutlet var postLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
