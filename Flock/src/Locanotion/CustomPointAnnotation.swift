//
//  CustomPointAnnotation.swift
//  Locanotion
//
//  Created by William Bertrand, Greg Leeper, and Nicholas Pai on 4/7/15.
//  Copyright (c) 2015 Flock. All rights reserved.
//

import Foundation
import MapKit

//This custom annotation is used to add annotations to the map page 
//Contains a background image, a name string, type, and attendance counts
class CustomPointAnnotation : MKPointAnnotation {
    var imageName : String!
    var type : String!
    var name : String!
    var friendAttendence : Int!
    var totalAttendence : Int!
    
}