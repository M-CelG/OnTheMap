//
//  TabViewController.swift
//  On The Map
//
//  Created by Manish Sharma on 12/21/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import Foundation
import UIKit

class TabViewController: UITabBarController {
    var students = [UdacityStudent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load data prior to Map View
        loadData()
    }
    
    func loadData() {
        ShareStudentData.sharedInstance().studentData(){error in
            if error != nil {
                UdacityParseClient.alertUser(self, title: "Students Location Data", message: "Unable to fetch data", dismissButton: "0k")
            }
                        
        }
    }
    
}
