//
//  FriendDetailViewController.swift
//  Locanotion
//
//  Created by William Bertrand, Greg Leeper, and Nicholas Pai on 4/3/15.
//  Copyright (c) 2015 Flock. All rights reserved.
//

import Foundation
import MapKit


//This is a page we decided not to include yet in our app due to not being sure if the functionality is useful
//Possibly in the future we will add this page into the actual app, but for now there is no way to reach this page

class FriendDetailViewControlelr: UIViewController {
    
    
    var friendFacebook_ID : String = String()
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var backButton : UIButton!
    @IBOutlet var detailScrollView : UIScrollView!
    @IBOutlet var friendNameLabel : UILabel!
    var friendUser : PFUser!
    var friendName : String!
    var friendID : String!
    var friendLoc : String!
    var friendHistory : Array<String>!
    var historyScrollView : UIScrollView!
    
    //Properties for side-panel menu
    var delegate: CenterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.layer.cornerRadius = 3
        friendNameLabel.text = friendName
        
        //set up the map: 40.348477, -74.652612
        let location = CLLocationCoordinate2D(latitude: 40.348477, longitude: -74.652612)
        let span = MKCoordinateSpanMake(0.02, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
        
        
        historyScrollView = UIScrollView(frame:CGRect(x: 0, y: self.view.frame.height / 2, width: self.view.frame.width, height: self.view.frame.height / 2))
        historyScrollView.backgroundColor = flock_COLOR
        
        var label = UILabel(frame: CGRect(x: 0, y: 10, width: 180, height: 40))
        label.text = "\(friendName)'s History"
        label.font = UIFont(name: "Avenir Next", size: 14)
        label.textColor = UIColor.whiteColor()
        historyScrollView.addSubview(label)
        
        self.view.addSubview(historyScrollView)
        
        self.getFriendLocation()
        
    }
    
    @IBAction func backPressed(){
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        nav.popViewControllerAnimated(true)
    }
    
    
    func sendPushNotificationTo(userName:String){
        
    }
    
    func getUserInfoFromFacebookID(){
        var userQuery : PFQuery = PFUser.query()!
        userQuery.whereKey("facebook_ID", equalTo: friendID)
        userQuery.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            let user = result?.first as! PFUser
            self.friendUser = user
            self.friendLoc = user["LocationName"] as! String
            self.friendHistory = user["history"] as! Array<String>
            
            if self.friendHistory.count == 0 {
                
            }
            else {
                self.setUpHistoryTable()
            }
        }
    }
    
    func setUpHistoryTable() {
        var frame = CGRect(x: 10, y: 50, width: self.view.frame.width, height: 40)
        for i in 0 ..< friendHistory.count {
            frame.origin.y = CGFloat(i) * frame.height
            var label = UILabel(frame: frame)
            label.font = UIFont(name: "Avenir Next", size: 14)
            label.text = friendHistory[i]
            label.textColor = UIColor.whiteColor()
            self.historyScrollView.addSubview(label)
        }
        
        self.historyScrollView.contentSize = CGSize(width: self.view.frame.width, height: (frame.height * CGFloat(friendHistory.count)) + 200)
        
    }
    
    func getFriendLocation() {
        var query : PFQuery = PFUser.query()!
        NSLog("id:\(friendID)")
        query.whereKey("facebook_ID", equalTo: friendFacebook_ID)
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            let res = result as! [PFUser]
            let friend : PFUser = res[0]
            if friend["LocationName"] as! String == "Migrating" {
                var alert = UIAlertView()
                alert.title = "That friend is not out right now"
                alert.addButtonWithTitle("OK")
                alert.show()
                let del = self.delegate as! ContainerViewController
                let nav = del.centerNavigationController
                nav.popViewControllerAnimated(true)
            }
            else if friend["LocationName"] as! String == "COS Building" {
                let location = CS_BUILDING.coordinate
                let span = MKCoordinateSpanMake(0.001, 0.0005)
                let region = MKCoordinateRegion(center: location, span: span)
                
                self.mapView.setRegion(region, animated: true)
                let newAnnot : MKPointAnnotation = MKPointAnnotation()
                newAnnot.coordinate = CS_BUILDING.coordinate
                newAnnot.title = "\(self.friendName)'s Location"
                self.mapView.addAnnotation(newAnnot)
            }
            
        }
    }
    
}



