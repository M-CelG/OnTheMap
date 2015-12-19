//
//  InforPostViewController.swift
//  On The Map
//
//  Created by Manish Sharma on 12/5/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import UIKit
import MapKit

class InfoPostViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    @IBOutlet weak var findOnMapButton: SpecialButton!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var mapUIView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lowerBarView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var upperBarView: UIView!
    @IBOutlet weak var stackViewUpperBar: UIStackView!
    @IBOutlet weak var submitButton: SpecialButton!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var lat: CLLocationDegrees = 0.0
    var lon: CLLocationDegrees = 0.0
    
    var mapString: String? = nil
    var mediaUrl: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure initial UI
        configureUI()
        
        //Delegate for the text fields
        placeTextField.delegate = self
        mediaURLTextField.delegate = self
        
        mapView.delegate = self
        
        //Subscribe to keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        //Get the First and Last name for the User
        publicUserData()
        
        //Get Object ID if the User has already posted location info
        getPreviousObjectID()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        //Un-subscribe to keyboard notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        //Stop Activity Indicator from Animating
        activityIndicator.stopAnimating()
    }
    
    
    //Hide keyboard if user touches outside of text fields
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if placeTextField.isFirstResponder() {
            placeTextField.resignFirstResponder()
        }
        if mediaURLTextField.isFirstResponder() {
            mediaURLTextField.resignFirstResponder()
        }
    }
    
    func publicUserData() {
        UdacityParseClient.sharedInstance().getUserPublicData {success, error in
            if error != nil {
                print("Unable to get User public data")
            }
            if success {
                print(" Here is first name: \(UdacityParseClient.sharedInstance().firstName)")
            }
        }
    }
    
    func getPreviousObjectID() {
        
        if UdacityParseClient.sharedInstance().objectID == nil {
            UdacityParseClient.sharedInstance().getUserStudentData(){success, error in
                if error != nil {
                    print("Previous Object ID do not exist")
                    return
                }                
                if success {
                    print("Object ID for previous post found")
                }
            }
        }
        
    }
    
    // Return to Map or Table View
    @IBAction func cancelButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnMapAction(sender: AnyObject) {
        //Start the activity Indicator
        activityIndicator.hidden = false
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()
        
        if let text = placeTextField.text {
            if text.isEmpty {
                UdacityParseClient.alertUser(self, title: "Address Missing", message: "Address field is empty", dismissButton: "Ok")
            } else {

                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(text) {places, error in
                    if error != nil {
                        UdacityParseClient.alertUser(self, title: "Address", message: "Incorrect Address", dismissButton: "Retry")
                        //Stop activity Indicator
                        dispatch_async(dispatch_get_main_queue()){
                            self.activityIndicator.stopAnimating()
                        }

                    } else if let mark = places?[0] {
                        self.mapView.addAnnotation(MKPlacemark(placemark: mark))
                        let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(mark.location!.coordinate, 1000, 1000)
                        self.mapView.setRegion(region, animated: true)
                        self.configureForwardGeocodeUI()
                        self.mapString = text
                        self.latitude = mark.location?.coordinate.latitude
                        self.longitude = mark.location?.coordinate.longitude
                        
                    } else {
                        UdacityParseClient.alertUser(self, title: "Error", message: "Unable to find place", dismissButton: "Retry")
                    }

                }

            }
        }

    }

    @IBAction func submitButtonAction(sender: AnyObject) {
        
        if let text = mediaURLTextField.text {
            if text.isEmpty {
                UdacityParseClient.alertUser(self, title: "Media Link Missing", message: "Please Enter Media Link", dismissButton: "Ok")
                return
            } else {
                mediaUrl = text
            }
            
            let jsonBody = [
                UdacityParseClient.jsonBodyParameters.UniqueKey: UdacityParseClient.sharedInstance().userID!,
                UdacityParseClient.jsonBodyParameters.FirstName: UdacityParseClient.sharedInstance().firstName!,
                UdacityParseClient.jsonBodyParameters.LastName: UdacityParseClient.sharedInstance().lastName!,
                UdacityParseClient.jsonBodyParameters.MapString: mapString!,
                UdacityParseClient.jsonBodyParameters.MediaURL: mediaUrl!,
                UdacityParseClient.jsonBodyParameters.Latitude: latitude!,
                UdacityParseClient.jsonBodyParameters.Longitude: longitude!
            ]
            
            var httpMethod: String!
            var method: String!
            if UdacityParseClient.sharedInstance().objectID == nil {
                httpMethod = "POST"
                method = ""
            } else {
                httpMethod = "PUT"
                method = "/\(UdacityParseClient.sharedInstance().objectID!)"
            }
        
            UdacityParseClient.sharedInstance().postAndPutStudentLocationDataTask(method, httpMethod: httpMethod, jsonBody: jsonBody as! [String : AnyObject]){data, error in
                //If unable to post alert user
                if error != nil {
                    print("Unable to post user data: \(error)")
                    dispatch_async(dispatch_get_main_queue()) {
                        UdacityParseClient.alertUser(self, title: "Posting Data", message: "Unable to Post Data", dismissButton: "Retry")
                    }
                    return
                }
                //If posting user location for first time extract Object ID for resuse
                if let newData = data as? [String: AnyObject] {
                    if let objectID = newData["objectId"] as? String {
                        UdacityParseClient.sharedInstance().objectID = objectID
                        print("Posted location information with ObjectID:\(objectID)")

                        }
                    }
                dispatch_async(dispatch_get_main_queue()){
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            
        }
    }
    // MARK: - Configure start UI
    
    func configureUI() -> Void {
        
        //Initially hide the map View
        mapUIView.hidden = true
        
        //Hide Unused button and Textfieds
        submitButton.hidden = true
        mediaURLTextField.hidden = true
        
        //Configure Find on the Map Button
        findOnMapButton.backgroundColor = UIColor.whiteColor()
        findOnMapButton.setTitleColor(UIColor(red: 0.24, green: 0.47, blue: 0.85, alpha: 1.0), forState: .Normal)
        findOnMapButton.backingColor = UIColor.whiteColor()
        findOnMapButton.highlightedBackingColor = UIColor.lightGrayColor()
        findOnMapButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        
        //Hide Activity Indicator
        activityIndicator.hidden = true
        activityIndicator.hidesWhenStopped = true
        
        // Place text field White font
        placeTextField.attributedPlaceholder = NSAttributedString(string: "Enter your Place here!!", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
    }
    
    func configureForwardGeocodeUI() -> Void{
        mapUIView.hidden = false
        placeTextField.hidden = true
        findOnMapButton.hidden = true
        submitButton.hidden = false
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        mediaURLTextField.hidden = false
        stackViewUpperBar.hidden = true
        upperBarView.backgroundColor = UIColor(red: 0.2784, green: 0.4675, blue: 0.68, alpha: 1.0)
        lowerBarView.backgroundColor = UIColor(white: 0.5, alpha: 0.3)
        submitButton.setTitle("Submit", forState: .Normal)
        submitButton.backgroundColor = UIColor(white: 0.9, alpha: 0.8)
        submitButton.backingColor = UIColor(white: 0.9, alpha: 0.8)
        submitButton.highlightedBackingColor = UIColor.grayColor()
        submitButton.setTitleColor(UIColor(red: 0.2784, green: 0.4675, blue: 0.68, alpha: 1.0), forState: .Normal)
        
        
        //Media URL text field white font
        mediaURLTextField.attributedPlaceholder = NSAttributedString(string: "Enter Media URL", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])

    }
    
    /* Mark: Text Field Delegate methods */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if placeTextField.isFirstResponder() {
            view.frame.origin.y -= 50
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    /* Mark: Map Delegate function */
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        //Hide and stop activityIndicator when Map finishes loading
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.alpha = 0.0
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        }
    }

}
