//
//  ViewController.swift
//  On The Map
//
//  Created by Manish Sharma on 11/27/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    //Outlets from the view
    @IBOutlet weak var userLoginError: UILabel!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var session: NSURLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Get Session
        session = NSURLSession.sharedSession()
    }
    
    @IBAction func loginUser(sender: AnyObject) {
        let username = emailTextField.text
        let password = passwdTextField.text
        UdacityParseClient.sharedInstance().loginToUdacityDirectly(username!, password: password!) {success, error in
            if error != nil  {
                print("Error during login:\(error)")
            } else {
                if success {
                    print("Successful in login")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.emailTextField.text = ""
                        self.passwdTextField.text = ""
                    }
                    self.presentMapView()
                    }
                    
                }
            }
        }
    
    //Mark: Action to present safari for sign-up
    @IBAction func signUpUser(sender: AnyObject) {
        let url = "https://www.udacity.com/account/auth#!/signup"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }

    func presentMapView() {
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
}

