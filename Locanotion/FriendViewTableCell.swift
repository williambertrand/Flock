//
//  FriendViewTableCell.swift
//  Locanotion
//
//  Created by William Bertrand, Greg Leeper, and Nicholas Pai on 3/29/15.
//  Copyright (c) 2015 Flock. All rights reserved.
//

import Foundation

class FriendViewTableCell : UITableViewCell {
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var locLabel : UILabel!
    @IBOutlet var pictureView : UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    
}
