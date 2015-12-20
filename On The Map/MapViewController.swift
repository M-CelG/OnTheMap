//
//  mapViewController.swift
//  On The Map
//
//  Created by Manish Sharma on 11/30/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    //Array to store Student Data
    var students = [UdacityStudent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Assign Map View Delegate to self
        mapView.delegate = self
        
        //Load Student Data
        ShareStudentData.sharedInstance().studentData()

    }
    
    override func viewWillAppear(animated: Bool) {
        self.mapView.reloadInputViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Update student data
        students = ShareStudentData.sharedInstance().sharedStudentsData
        
        //Create array of annotations
        var annotations = [MKPointAnnotation]()
        
        //Create annotation for each student
        for student in students {
            let coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = student.firstName + " " + student.lastName
            annotation.subtitle = student.mediaURL
            
            //Append student annotation to the array
            annotations.append(annotation)
            
        }
        //Add Annotation to the Map
        self.mapView.addAnnotations(annotations)
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        
        UdacityParseClient.sharedInstance().deleteSession() {success, error in
            if error != nil {
                print("Error during logout:\(error?.localizedDescription)")
            }
        }
        //Check if user logged in via FB
        if FBSDKAccessToken.currentAccessToken() != nil {
            let logoutTask = FBSDKLoginManager()
            logoutTask.logOut()
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func postUserLocation(sender: AnyObject) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func refreshData(sender: AnyObject) {
        ShareStudentData.sharedInstance().studentData()
    }
    
    
    // Mark: Delegate functions for Map View
    
    
    //Returns reuseable pin
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    //Responds to when right call accessary is tapped
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let url = view.annotation?.subtitle! {
                app.openURL(NSURL(string: url)!)
            }
        }
    }
}
