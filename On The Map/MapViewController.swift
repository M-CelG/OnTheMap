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
    
    //Create Array Annotations
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Assign Map View Delegate to self
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        mapView.reloadInputViews()
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //load student data
        students = ShareStudentData.sharedInstance().sharedStudentsData
        
        //Remove old Annotation
        mapView.removeAnnotations(annotations)

        //Annotated Map View
        loadAnnontations()
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        ShareStudentData.sharedInstance().logout(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func postUserLocation(sender: AnyObject) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func refreshData(sender: AnyObject) {
        loadData()
        //Remove old Annotations, if any
        mapView.removeAnnotations(annotations)
        //Load new Annotations
        loadAnnontations()
    }
    
    func loadData() {
        //Fetch Data from the server
        ShareStudentData.sharedInstance().studentData(){error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()){
                    UdacityParseClient.alertUser(self, title: "Error Getting Data", message: "Student Data Unable", dismissButton: "ok")
                }
                return
            }
        }
        students = ShareStudentData.sharedInstance().sharedStudentsData
    }
    
    func loadAnnontations() {
        
        //Create Annotation for each student
        for student in students {
            //Create coordinate for student location from student data
            let coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            //Create an annotation for the student
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = student.firstName + " " + student.lastName
            annotation.subtitle = student.mediaURL
            //Append annotation created for individual student to annotation array
            annotations.append(annotation)
        }
        //Add annotation array to the map view
        mapView.addAnnotations(annotations)
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
