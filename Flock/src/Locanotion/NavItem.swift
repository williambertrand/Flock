//
//  NavItem.swift
//  Locanotion
//
//  Created by William Bertrand, Greg Leeper, and Nicholas Pai on 5/1/15.
//  Copyright (c) 2015 Flock. All rights reserved.
//

import Foundation
import UIKit

@objc
class NavItem {
    
    let title: String
    let image: UIImage?
    
    init(title: String, image: UIImage?) {
        self.title = title
        self.image = image
    }
    
    
    class func allItems() -> Array<NavItem> {
        return [ NavItem(title: "View Map", image: UIImage(named: "MapIcon.jpg")),
            NavItem(title: "View Friends", image: UIImage(named: "FriendsIcon.jpg")),
            NavItem(title: "View Clubs", image: UIImage(named: "ClubsIcon.jpg")),
            NavItem(title: "Home", image: UIImage(named: "ClubsIcon.jpg"))]
    }
    
    
    
}