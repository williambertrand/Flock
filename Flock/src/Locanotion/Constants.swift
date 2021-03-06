//
//  Constants.swift
//  Locanotion
//
//  Created by William Bertrand, Greg Leeper, and Nicholas Pai on 4/13/15.
//  Copyright (latitude:c) 2015 Flock. All rights reserved.
//

import Foundation


//user current location
var UserCurrentClub : String!

//Constants for club location

let NUM_CLUBS = 12
let TERRACE : CLLocation = CLLocation(latitude: 40.347173,longitude: -74.653914)
let TOWER : CLLocation = CLLocation(latitude:40.347688, longitude : -74.653960)
let CANNON : CLLocation = CLLocation(latitude:40.347808, longitude :-74.653345)
let QUAD : CLLocation = CLLocation(latitude:40.348017, longitude : -74.652726)
let IVY : CLLocation = CLLocation(latitude:40.348091, longitude : -74.652179)
let COTTAGE : CLLocation = CLLocation(latitude:40.348217, longitude : -74.651682)
let CAP : CLLocation = CLLocation(latitude:40.348299, longitude : -74.650969)
let CLOISTER : CLLocation = CLLocation(latitude:40.348600, longitude : -74.650534)
let TI : CLLocation = CLLocation(latitude:40.348922, longitude : -74.652270)
let COLONIAL : CLLocation = CLLocation(latitude:40.348845, longitude : -74.652814)
let CHARTER : CLLocation = CLLocation(latitude:40.348759, longitude : -74.650019)
let BOGGLE : CLLocation = CLLocation(latitude:40.344301, longitude : -74.655562)

//Cos building location ised for demo and can be used for testing
let CS_BUILDING : CLLocation = CLLocation(latitude:40.350234, longitude : -74.652240)

//these two locations were used for testing
let WU : CLLocation = CLLocation(latitude: 40.344773, longitude: -74.656569)
let WU_LIBRARY : CLLocation = CLLocation(latitude: 40.344530, longitude: -74.656378)

let GLOBAL_ClubLocations : Array<CLLocation> = [CANNON,CAP,CHARTER,CLOISTER,COLONIAL,COTTAGE,IVY,QUAD,TERRACE,TI,TOWER,CS_BUILDING]

let CLUB_NAMES : Array<String> = ["Cannon", "Cap", "Charter", "Cloister", "Colonial","Cottage", "Ivy", "Quad", "Terrace", "Tiger Inn", "Tower", "COS Building"]

let CLUB_DISPLAY_NAMES : Array<String> = ["Cannon Dial Elm", "Cap and Gown", "Charter", "Cloister Inn", "Colonial","Cottage", "Ivy Inn", "Quadrangle Club", "Terrace", "Tiger Inn", "Tower", "COS Building"]

//color of blue for flock
var flock_COLOR = UIColor(hue: 0.546, saturation: 0.58, brightness: 0.87, alpha: 1.0)
var DIM_RED = UIColor(hue: 0.971, saturation: 0.30, brightness: 0.67, alpha: 1.0)