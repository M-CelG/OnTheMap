//
//  ViewController.swift
//  On The Map
//
//  Created by Manish Sharma on 11/27/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    //Outlets from the view
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var loginButton: SpecialButton!
    @IBOutlet weak var loginFacebook: SpecialButton!
    @IBOutlet weak var contentView: UIView!
        
    @IBOutlet weak var scrollView: UIScrollView!
    var session: NSURLSession!
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Get Session
        session = NSURLSession.sharedSession()
        self.configureUI()
        passwdTextField.secureTextEntry = true
        passwdTextField.delegate = self
        emailTextField.delegate = self
        scrollView.keyboardDismissMode = .OnDrag
        
        //Subscribe to keyboard notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        //Un-subscribe to keyboard notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func loginUser(sender: AnyObject) {
        var username = ""
        var password = ""
        
        
        if !Reachability.isConnectedToNetwork() {
            alertUser("Internet Connection", message: "Please check Internet Connection", dismissButton: "Retry")
        } else {
        
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
                    print("Error during login:\(error)")
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
        }
    
    //Mark: Action to present safari for sign-up
    @IBAction func signUpUser(sender: AnyObject) {
        let url = "https://www.udacity.com/account/auth#!/signup"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }

    func presentMapView() {
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabViewController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    //Mark: Configure Login and Facebook Login Buttons
    func configureUI() -> Void {
        
        //Configure Facebook Login Button
        loginFacebook.titleLabel?.font = UIFont(name:"AvenirNext-Medium", size: 17.0)
        loginFacebook.backgroundColor = UIColor(red: 0.00, green: 0.501, blue: 0.839, alpha: 1.0)
        loginFacebook.highlightedBackingColor = UIColor(red: 0.00, green: 0.298, blue: 0.686, alpha: 1.0)
        loginFacebook.backingColor = UIColor(red: 0.00, green: 0.501, blue: 0.839, alpha: 1.0)
        loginFacebook.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
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
    
    func keyboardWasShown (notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let height = keyboardSize.CGRectValue().height
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= height
        
        if !(CGRectContainsPoint(aRect, activeField!.frame.origin)) {
            scrollView.scrollRectToVisible(activeField!.frame, animated: true)
        }
    }
    
    func keyboardWillHide (notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}




