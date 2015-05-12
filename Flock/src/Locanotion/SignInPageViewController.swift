//
//  SignInPageViewController.swift
//  Locanotion
//
//  Created by William Bertrand, Greg Leeper, and Nicholas Pai on 3/31/15.
//  Copyright (c) 2015 Flock. All rights reserved.
//

import Foundation
import UIKit

//This page represents the sign in page, it is a FBSDKLoginButtonDelegate because it handles
//logging in of facebook users

class SignInPageViewController : UIViewController, FBSDKLoginButtonDelegate {
    
    //Property for side-panel menu
    var delegate: CenterViewControllerDelegate?
    
    //set up sub views such as log in button and logo/bacground image
    override func viewDidLoad() {
        let loginButton : FBSDKLoginButton = FBSDKLoginButton()
        //check acces token to skip log in if they haven't lost access 
        if FBSDKAccessToken.currentAccessToken() != nil{
            NSLog("loaded: not nil")
            self.performSegueWithIdentifier("toMainViewSignIn", sender: self)
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            self.view.addSubview(loginButton)
            loginButton.center.x = self.view.center.x
            loginButton.center.y = self.view.center.y + (self.view.frame.height / 2) - 75
            loginButton.delegate = self
        }
        else {
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            self.view.addSubview(loginButton)
            loginButton.center.x = self.view.center.x
            loginButton.center.y = self.view.center.y + (self.view.frame.height / 2) - 75
            loginButton.delegate = self
        }
        
        //background image
        let imageFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let imageView = UIImageView(frame: imageFrame)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.image = UIImage(named:"BG")
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        //logo image (Flock)
        let logoFrame = CGRect(x: self.view.frame.width / 4, y: 20, width: self.view.frame.width / 2, height: self.view.frame.height / 6)
        let logoView = UIImageView(frame: logoFrame)
        logoView.contentMode = UIViewContentMode.ScaleAspectFill
        logoView.image = UIImage(named:"flockSimple")
        self.view.addSubview(logoView)

       
    }
    
    //required
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK FBSDKLoginButtonDelegate Methods
    
    //This is the ehavy lifting for this page, log in and handle whether a new user is needed or whether a user can just be logged in instead
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error != nil {
            //process the error
            NSLog("Error in login process")
        }
        else if result.isCancelled{
            //handle cancellation, do nothing
        }
            
        else {
            var id: String = "Uninit"
            //get facebook id using a graph request
            var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result: AnyObject!, error : NSError!) -> Void in
                if error == nil {
                    //dictonary of info returned from request
                    var resultDict : NSDictionary = result as! NSDictionary
                    //grap the facebook ID
                    id = resultDict.objectForKey("id") as! String
                    //Now create Parse Query
                    let newUserQuery : PFQuery = PFUser.query()!
                    newUserQuery.whereKey("facebook_ID", equalTo:id)
                    newUserQuery.findObjectsInBackgroundWithBlock({ (objectArray:[AnyObject]?, error:NSError?) -> Void in
                        if error != nil {
                            //error with query
                        }
                        else {
                            let objects = objectArray! // unwrap the optional
            
                            
                            //Since no parse user exists with that FB Id, make a new user
                            if objects.count == 0 {
                                NSLog("Creating a new User")
                                //perform another request to get name, id, email ... etc
                                var request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
                                
                                request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result: AnyObject!, error:NSError!) -> Void in
                                    if error == nil {
                                        let resultDict : NSDictionary  = result as! NSDictionary
                                        let fullName : String = resultDict.objectForKey("name") as! String
                                        //email not always available
                                        let email : String! = resultDict.objectForKey("email") as! String
                                        //var gender : String! = resultDict.objectForKey("gender") as String
                                        let fbID : String = resultDict.objectForKey("id") as! String
                                        
                                        //create the PFUser
                                        var newUser : PFUser = PFUser()
                                        if email != nil {
                                            newUser.username = email
                                        }
                                        //set properties of new user
                                        newUser["Full_Name"] = fullName
                                        newUser.email = email
                                        newUser["facebook_ID"] = fbID
                                        newUser["LocationName"] = "Migrating"
                                        newUser.password = "temppassword"
                                        
                                        //sign up the user asynchronously
                                        newUser.signUpInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                            if success {
                                                NSLog("Success")
                                                let alertView = UIAlertView()
                                                alertView.title = "Signed up as new user!"
                                                alertView.addButtonWithTitle("Ok")
                                                alertView.show()
                                                
                                                
                                                //log in the new user
                                                PFUser.logInWithUsernameInBackground(newUser.username!, password: newUser.password!, block: { (user:PFUser?, error:NSError?) -> Void in
                                                    if user != nil {
                                                        let user2 = user! as PFUser
                                                        UserCurrentClub = user2["LocationName"] as! String
                                                        
                                                    
                                                        
                                                        //push main screen onto uinav stack
                                                        let del = self.delegate as! ContainerViewController
                                                        let nav = del.centerNavigationController
                                                        nav.pushViewController(del.viewController, animated: true)
                                                    }
                                                    
                                                })
                                             
                                            }
                                        })
                                        
                                    }
                                    
                                }
                                
                            }//end of creating a new user
                                
                                
                            else{
                                //log in this user
                                var  curUser : PFUser = objects[0] as! PFUser
                                let username = curUser["username"] as! String
                                let password = "temppassword"
                                
                                PFUser.logInWithUsernameInBackground(username, password: password, block: { (user:PFUser?, error:NSError?) -> Void in
                                    if user != nil {
                                        let user2 = user! as PFUser
                                        UserCurrentClub = user2["LocationName"] as! String
                                        
                                        NSLog("logged in \(username)")

                                        //push main screen onto uinav stack
                                        let del = self.delegate as! ContainerViewController
                                        let nav = del.centerNavigationController
                                        nav.pushViewController(del.viewController, animated: true)
                                    }
                                    
                                })
                            }
                            
                        }
                        
                    })
                    
                }
            }
        }
    }
    
    //Second method, should never be called because a user can only log in on this page
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        NSLog("User Logged Out")
    }
    
    
    
    
}
