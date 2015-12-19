//
//  AlertView.swift
//  On The Map
//
//  Created by Manish Sharma on 12/12/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import Foundation
import UIKit

class AlertView: UIAlertController {
    
    class func userAlert(title: String, message: String, dismissButton: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: dismissButton, style: .Cancel, handler: nil)
        alert.addAction(action)
        UIViewController.presentViewController(<#T##UIViewController#>)
    }
    
}