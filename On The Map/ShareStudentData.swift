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

class ShareStudentData {
    
    var sharedStudentsData = [UdacityStudent]()
    var objectID: String? = nil
    
    
    func studentData() {
        UdacityParseClient.sharedInstance().getStudentData(100) {data, success, error in
            if success {
                if let data = data {
                    self.sharedStudentsData = data
                } else {
                    print("No data from get student data task")
                }
            } else {
                print("Unable to retrive Student Data:\(error)")
            }
        }
    }            
    
    class func sharedInstance() -> ShareStudentData {
        
        struct Singleton {
            static let sharedInstance = ShareStudentData()
        }
        return Singleton.sharedInstance
    }
}
