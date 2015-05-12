//
//  MapPageViewController.swift
//  Locanotion
//
//  Created by William Bertrand, Greg Leeper, and Nicholas Pai on 3/31/15.
//  Copyright (c) 2015 Flock. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class MapPageViewController : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    var friendIDs :Array<String> = Array()
    //@IBOutlet var scrollView : UIScrollView!
    @IBOutlet var mapView: MKMapView!
    
    //hash map for attendences
    //var attendenceArray : Array(String, Int) = Array()
    
    ///Array of tuples:(string,int) to hold club, num people
    var clubInfoArray = [String: Int]()
    //another array to hold just friend attendence counts
    var friendsInfoArray = [String: Int]()
    var MapViewAnnotations : Array<MKAnnotation> = Array()
    
    //Properties for side-panel menu
    var delegate: CenterViewControllerDelegate?
    
    var menuButton : UIButton!
    var userLocation : CLLocation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set all club attendances to 0
        for club in CLUB_NAMES {
            friendsInfoArray[club] = 0
            clubInfoArray[club] = 0
        }
        
        //add menu button
        menuButton = UIButton(frame:CGRect(x: 10, y: 25, width: 40, height: 30))
        menuButton.setBackgroundImage(UIImage(named: "MenuIcon"), forState: UIControlState.Normal)
        menuButton.addTarget(self, action: "menuTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(menuButton)
        
        //add refresh button
        var refreshButton = UIButton(frame:CGRect(x: self.view.frame.width - 50, y: 25, width: 40, height: 30))
        refreshButton.setBackgroundImage(UIImage(named: "refreshIcon"), forState: UIControlState.Normal)
        refreshButton.addTarget(self, action: "refreshMapAnnotations", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(refreshButton)
        
        mapView.delegate = self
        
        let region = MKCoordinateRegionMakeWithDistance(
            CLLocationCoordinate2D(latitude: 40.348544, longitude: -74.652330), 280, 280)
        mapView.setRegion(region, animated: true)
        //disable zoom
        mapView.zoomEnabled = false
        
        //get all the attendances of the clubs
        self.getAllClubInfo()
    }
    
    //empty the arrays so they are ready to be filled next time
    override func viewWillDisappear(animated: Bool) {
        NSLog("disappear")
        self.clubInfoArray.removeAll()
        self.friendsInfoArray.removeAll()
        mapView.removeAnnotations(MapViewAnnotations)
        self.getAllClubInfo()
    }
    
    //tell the centerviewcontroler delegate to togle the left menu
    func menuTapped() {
        delegate?.toggleLeftPanel?()
    }

    
    //create an annotation for each club and add it to the map
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is CustomPointAnnotation {
             NSLog("SET UP YYYYYYYYYY")
            let cpaAnnotation = annotation as! CustomPointAnnotation
            let reuseID = cpaAnnotation.name
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation,reuseIdentifier: reuseID)
                anView.canShowCallout = true
            }
            else {
                anView.annotation = annotation
            }
            let cpa = annotation as! CustomPointAnnotation
            anView.image = UIImage(named:cpa.imageName)
            let frame = anView.frame
            let textFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 4)
            let textLabel = UILabel(frame: textFrame)
            textLabel.textAlignment = .Center
            textLabel.text = cpa.name
            textLabel.font = UIFont(name: "Avenir Next", size: 12)
            textLabel.textColor = UIColor.whiteColor()
            anView.addSubview(textLabel)
            let FriendFrame = CGRect(x: 0, y: textFrame.height, width: frame.width, height: frame.height / 4)
            let friendLabel = UILabel(frame: FriendFrame)
            var intA : Int = self.friendsInfoArray[cpa.name]!
            if intA == 1 {
                friendLabel.text = String(intA) + " Bird of a feather"
            }
            else{
                friendLabel.text = String(intA) + " Birds of a feather"
            }
            friendLabel.textAlignment = .Center
            friendLabel.font = UIFont(name: "Avenir Next", size: 10)
            friendLabel.textColor = UIColor.whiteColor()
            anView.addSubview(friendLabel)
            //add total attendence label
            let totalFrame = CGRect(x: 0, y: textFrame.height + FriendFrame.height, width: frame.width, height: frame.height / 4)
            let totalLabel = UILabel(frame: totalFrame)
            totalLabel.textAlignment = .Center
            let intB : Int = self.clubInfoArray[cpa.name]!
            totalLabel.text = "Flock Size: " + String(intB)
            totalLabel.font = UIFont(name: "Avenir Next", size: 11)
            totalLabel.textColor = UIColor.whiteColor()
            anView.addSubview(totalLabel)
            return anView
            
        }
        
        return nil
    }
    
    //Add new annotations to the map, which will then be created and added in mapView ViewForAnnotation above
    func setUpAllClubViews() {
        MapViewAnnotations.removeAll()
        for clubx in 0 ..< GLOBAL_ClubLocations.count {
            let cpa = CustomPointAnnotation()
            cpa.coordinate = GLOBAL_ClubLocations[clubx].coordinate
            cpa.name = CLUB_NAMES[clubx]
            cpa.imageName = "clubLabel"
            cpa.friendAttendence = friendsInfoArray[CLUB_NAMES[clubx]]
            cpa.totalAttendence = clubInfoArray[CLUB_NAMES[clubx]]
            mapView.addAnnotation(cpa)
            MapViewAnnotations.append(cpa)
        }
    }
    
    //keep track of when it should refresh 
    var refreshing = false
    //refresh the map
    @IBAction func refreshMapAnnotations(){
        if !refreshing {
            refreshing = true
            self.getAllClubInfo()
        }
        
    }
        
    
    // First set all tuples in the club info array to zero, then iterate though Parse user class, incrememnting
    //the attendance at each club for wherever a user is
    func getAllClubInfo() {
        for club in CLUB_NAMES {
            self.clubInfoArray[club] = 0
        }
        //add this fo uesrs who are not in a club
        self.clubInfoArray["Migrating"] = 0
        
        //The query, PFUser class for all users
        var peopleQuery = PFUser.query()
        peopleQuery?.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
            
            let resultArray = result as! [PFUser]
            for user in resultArray {
                let clubName = user["LocationName"] as! String
                self.clubInfoArray[clubName] = self.clubInfoArray[clubName]! + 1
            }
            //get nubmers of friends at clubs now that total attendence has been calculated
            self.getFriendsClubInfo()
        })
        
    }
    
    
    //get info for all of the user's friends based on their facebok ID's
    func getFriendsClubInfo() {
        for club in CLUB_NAMES {
            self.friendsInfoArray[club] = 0
        }
        self.friendsInfoArray["Migrating"] = 0
        
        //use this request to get all of the user's friends' ID's
        var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
            //check error
            if error == nil {
                //dictionary of dictionaries, data = [(name,ID,photo etc...),(name,ID,photo etc...)]
                var resultDict : NSDictionary = result as! NSDictionary
                var data : NSArray = resultDict.objectForKey("data") as! NSArray
                for value in data {
                    let valueDict : NSDictionary = value as! NSDictionary
                    let id = valueDict.objectForKey("id") as! String
                    var name = (valueDict.objectForKey("name") as! String)
                    
                    let userQuery = PFUser.query()
                    userQuery?.whereKey("facebook_ID", equalTo: id)
                    userQuery?.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
                        if result != nil {
                            if result!.count != 0 {
                                NSLog("not nil")
                                let res = result as! [PFUser]
                                let user = res.first!
                                let loc : String = user["LocationName"] as! String
                                self.friendsInfoArray[loc] = self.friendsInfoArray[loc]! + 1
                            }
                        }
                        NSLog("ended friend query")
                        //now that queries are done, update the map views
                        self.setUpAllClubViews()
                        self.refreshing = false
                        
                    })
                }
                
            }
            
        }
        
    }
    
}

