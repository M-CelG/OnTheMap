//
//  ShareStudentData.swift
//  On The Map
//
//  Created by Manish Sharma on 12/9/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

/* Mark: This is a singleton class to fetch and store latest student location data*/

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ShareStudentData {
    
    var sharedStudentsData = [UdacityStudent]()
    var objectID: String? = nil
    
    
    func studentData(completionHandler:(error: NSError?) -> Void) {
        UdacityParseClient.sharedInstance().getStudentData(100) {data, success, error in
            if success {
                if let data = data {
                    self.sharedStudentsData = data
                    completionHandler(error: nil)
                } else {
                    completionHandler(error: NSError(domain: "Students Data", code: 3, userInfo: [NSLocalizedDescriptionKey: "Data received is in-valid"]))
                    return
                }
            } else {
                completionHandler(error: NSError(domain: "Student Data", code: 3, userInfo: [NSLocalizedDescriptionKey: (error?.localizedDescription)!]))
                return
            }
        }
    }
    
    func logout(hostViewController: UIViewController) {
        //Delete session ID at Udacity
        UdacityParseClient.sharedInstance().deleteSession() {success, error in
            if error != nil {
                UdacityParseClient.alertUser(hostViewController, title: "Logout Session", message: "Unable to delete Udacity Session", dismissButton: "ok")
                print("Error during logout:\(error?.localizedDescription)")
            }
        }
        //Check if user login via facebook
        if FBSDKAccessToken.currentAccessToken() != nil {
            let logoutTask = FBSDKLoginManager()
            logoutTask.logOut()
        }
    }
    
    class func sharedInstance() -> ShareStudentData {
        
        struct Singleton {
            static let sharedInstance = ShareStudentData()
        }
        return Singleton.sharedInstance
    }
}
