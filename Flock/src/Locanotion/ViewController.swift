//
//  ViewController.swift
//  Locanotion
//
//  Created by William Bertrand, Greg Leeper, and Nicholas Pai on 3/27/15.
//  Copyright (c) 2015 Flock. All rights reserved.
//

import UIKit
import CoreLocation

//This is the home page, it is a CLLocationManagerDelegate

class ViewController: UIViewController, CLLocationManagerDelegate{
    @IBOutlet var CurrentUserLabel: UILabel!

    var logoImage : UIImageView!
    
    @IBOutlet var logoView: UIImageView!
    @IBOutlet var asd: UIButton!
    
    let locationManager = CLLocationManager()
    
    //Properties for side-panel menu
    var delegate: CenterViewControllerDelegate?
    
    @IBAction func menuTapped(sender: AnyObject) {
        delegate?.toggleLeftPanel?()
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            CurrentUserLabel.text = currentUser!.username
        }
        else {
            CurrentUserLabel.text = "No User"
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        let logoFrame = CGRect(x: 0, y: (self.view.frame.height / 2) - 200, width: self.view.frame.width, height: 400)
        logoImage = UIImageView(frame: logoFrame)
        logoImage.image = UIImage(named: "FlockLogo")
        logoImage.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(logoImage)
        var user :PFUser = PFUser.currentUser()!
        var userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(user.objectId!, block: { (result:PFObject?, error:NSError?) -> Void in
            if (result == nil){
                NSLog("user is nil")
            }
            let res = result as! PFUser
            
            UserCurrentClub = res["LocationName"] as! String
          
            NSLog("ended")
        })
        self.createLocationManager()
        
    }
    
    func createLocationManager() {
        //begin updating gps
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let firstLocation = locations.first as? CLLocation
        if firstLocation?.horizontalAccuracy < 30 {
            self.getAndUpdateUserLocationDescription(firstLocation!)
        }
    }
    
    
    //called when locations are updated by CLLocationDelegate, find closest club to the user and 
    //change their location name on parse
    func getAndUpdateUserLocationDescription(loc: CLLocation) {
        
        //locationManager.stopUpdatingLocation()
        var lastLocation = UserCurrentClub
        let lat = loc.coordinate.latitude
        let lon = loc.coordinate.longitude
        
        //var currentLocationDescription = "Migrating"
        
        var currentClosestClub : String = "Migrating"
        var currentClosestDistance = CGFloat(30)
        
        for clubLocIndex in 0 ..< GLOBAL_ClubLocations.count {
            if CGFloat(GLOBAL_ClubLocations[clubLocIndex].distanceFromLocation(loc)) < currentClosestDistance {
                currentClosestClub = CLUB_NAMES[clubLocIndex]
                currentClosestDistance = CGFloat(GLOBAL_ClubLocations[clubLocIndex].distanceFromLocation(loc))
            }
        }
        UserCurrentClub = currentClosestClub
        var user : PFUser? = PFUser.currentUser()
        //check to make sure the user exists
        if user != nil {
            let user2 : PFUser = user! as PFUser // force downcast
            user2["LocationName"] = UserCurrentClub
            user2.saveInBackground()//upload changes to Parse
        }


    }
    
    
    //MARK FBSDKLoginButtonDelegate Methods
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        self.locationManager.stopUpdatingLocation()
        let del = delegate as! ContainerViewController
        let nav = del.centerNavigationController
        nav.popViewControllerAnimated(true)
        
    }
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        //Don't need to do anything here since logging out takes user back to the splash screen
    }
    
}



