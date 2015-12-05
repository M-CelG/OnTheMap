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

class mapViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    //Array to store Student Data
    var students = [UdacityStudent]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.delegate = self
        
        self.parentViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutButtonAction")
        let pinBarButton = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "postUserLocation")
        let refreshBarButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "updateStudentData")
        
        self.parentViewController?.navigationItem.rightBarButtonItems = [refreshBarButton, pinBarButton]
        
        //Load Student Data
        updateStudentData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.mapView.reloadInputViews()
    }
    
    override func viewDidAppear(animated: Bool) {
  
        super.viewDidAppear(animated)
        
        //Create array of annotations
        var annotations = [MKPointAnnotation]()
        
        //Create annotation for each student
        for student in students {
            let coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = student.firstName + student.lastName
            annotation.subtitle = student.mediaURL
            
            //Append student annotation to the array
            annotations.append(annotation)
            
        }
        print("Here are annotation:\(annotations)")
        //Add Annotation to the Map
        self.mapView.addAnnotations(annotations)
        
    }
    
    func logoutButtonAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postUserLocation() {
        print("Method here to post User location")
    }
    
    func updateStudentData() {
   
        UdacityParseClient.sharedInstance().getStudentData(100) {data, success, error in
            if success {
                print("Got Student Data")
                if let data = data {
                    self.students = data
                } else {
                    print("No data from get student data task")
                }
            } else {
                print("Unable to retrive Student Data:\(error)")
            }
        }
    }
    
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let url = view.annotation?.subtitle! {
                app.openURL(NSURL(string: url)!)
            }
        }
    }
}
