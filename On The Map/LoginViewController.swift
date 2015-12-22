//
//  ViewController.swift
//  On The Map
//
//  Created by Manish Sharma on 11/27/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

// This view controller manages login into the application

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class LoginViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, FBSDKLoginButtonDelegate {

    //Outlets from the view
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: SpecialButton!
    @IBOutlet weak var loginFacebook: FBSDKLoginButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var session: NSURLSession!
    /*This var is used to tag active text field so to adjust scroll view 
    // whenever keyboard is shown or hides
    */
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Get Session
        session = NSURLSession.sharedSession()
        self.configureUI()
        
        //Delegate for facebook login button
        loginFacebook.delegate = self
        
        //Delegate for textfields
        passwdTextField.delegate = self
        emailTextField.delegate = self
        
        scrollView.keyboardDismissMode = .OnDrag
        
        //Subscribe to keyboard notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        //Un-subscribe to keyboard notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Login directly to Udacity using username and password
    @IBAction func loginUser(sender: AnyObject) {
        var username = ""
        var password = ""
        
        //Check if internet connection is available
        if !Reachability.isConnectedToNetwork() {
            alertUser("Internet Connection", message: "Please check Internet Connection", dismissButton: "Retry")
        } else {
            //Make sure username and password textfields are not empty
            if let text = emailTextField.text {
                if text.isEmpty {
                    UdacityParseClient.alertUser(self, title: "Login Error", message: "Please enter email address", dismissButton: "Retry")
                    return
                } else {
                    username = text
                }
            }
            if let text = passwdTextField.text {
                if text.isEmpty {
                    UdacityParseClient.alertUser(self, title: "Login Error", message: "Password Missing", dismissButton: "Retry")
                    return
                } else {
                    password = text
                }
            }
            
            //Call login convience function with the credentials passed by user
            UdacityParseClient.sharedInstance().loginToUdacityDirectly(username, password: password) {success, error in
                if error != nil  {
                    if let dictionary = error?.userInfo {
                        if (dictionary[NSLocalizedDescriptionKey])! as! String == "Invalid Email and/or Password" {
                            UdacityParseClient.alertUser(self, title: "Login Error", message: "Invalide Email and/or Password", dismissButton: "Retry")
                            return
                        } else if (dictionary[NSLocalizedDescriptionKey])! as! String == "The request timed out." {
                            UdacityParseClient.alertUser(self, title: "Connection Error", message: "Check Internet Connection", dismissButton: "Retry")
                            return
                        }
                    }
                } else {
                    if success {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.emailTextField.text = ""
                            self.passwdTextField.text = ""
                        }
                        self.presentMapView()
                        }
                        
                    }
                }
            }
        }
    
    //Mark: Action to present safari for sign-up
    @IBAction func signUpUser(sender: AnyObject) {
        let url = "https://www.udacity.com/account/auth#!/signup"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }

    // This func presents the tab view once login is successful
    func presentMapView() {
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    //Mark: Configure Login and Facebook Login Buttons
    func configureUI() -> Void {
        
        passwdTextField.secureTextEntry = true
        
        //Configure Udacity Login Button
        loginButton.titleLabel?.font = UIFont(name:"AvenirNext-Medium", size: 17.0)
        loginButton.backgroundColor = UIColor(red: 0.96, green: 0.70, blue: 0.42, alpha: 1.0)
        loginButton.highlightedBackingColor = UIColor(red: 1.00, green: 0.60, blue: 0.0, alpha: 1.0)
        loginButton.backingColor = UIColor(red: 0.96, green: 0.70, blue: 0.42, alpha: 1.0)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)

    }
    
    //Mark: Common function to alert Users
    func alertUser (title: String, message: String, dismissButton: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: dismissButton, style: .Cancel, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /* Mark: Text Field Delegates */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    
    //Scroll Textifields into view when user is entering text
    func keyboardWasShown (notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let height = keyboardSize.CGRectValue().height
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        //Code to specifically adjust textfields into view
        var aRect = self.view.frame
        aRect.size.height -= height
        
        if !(CGRectContainsPoint(aRect, activeField!.frame.origin)) {
            scrollView.scrollRectToVisible(activeField!.frame, animated: true)
        }
    }
    //Ajust scroll view when keyboard will hide
    func keyboardWillHide (notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    //Delegate functions for Facebook Button Delegate 
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error != nil {
            UdacityParseClient.alertUser(self, title: "Facebook Login", message: error.localizedDescription, dismissButton: "ok")
            return
        } else {
            if let accessToken = result.token.tokenString  {
                
                UdacityParseClient.sharedInstance().loginToUdacityViaFacebook(accessToken) {success, error in
                    if error != nil {
                        UdacityParseClient.alertUser(self, title: "Facebook Login", message: (error?.localizedDescription)!, dismissButton: "ok")
                        return
                    }
                    
                    if success {
                        self.presentMapView()
                    }
                }
            }
        }
    }
    //Additional clean if needed after login out
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
}




