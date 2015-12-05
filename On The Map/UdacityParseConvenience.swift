//
//  UdacityParseConvenience.swift
//  On The Map
//
//  Created by Manish Sharma on 11/29/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import Foundation
import UIKit

extension UdacityParseClient {
    
    //Method for login
    func loginToUdacityDirectly (username: String, password: String, completionHandler:(success: Bool, error: NSError?) -> Void) {
        //Method for Login Session
        let method = UdacityParseClient.Methods.UdacitySession
        
        let httpBody = [
            "udacity": [
                "username": username,
                "password": password
            ]
            ]
        
        
        udacityLoginDataTask(method, jsonBody: httpBody){results, error in
            if let error = error {
                print("Loging Failed with Udacity:\(error)")
                completionHandler(success: false, error: error)
            } else {
                if let returnAccount = results[UdacityParseClient.jsonResponse.account] as? [String: AnyObject] {
                    if let key = returnAccount[UdacityParseClient.jsonResponse.key] as? String {
                        print("Here is the key from account information:\(key)")
                        self.userID = key
                    } else {
                        let userInfo = "Login failed as response does not include Key"
                        completionHandler(success: false, error: NSError(domain: "loginToUdacityDirectly", code: 2, userInfo: [NSLocalizedDescriptionKey: userInfo]))
                    }
                } else {
                    let userInfo = "Login failed as response does not include Key"
                    completionHandler(success: false, error: NSError(domain: "loginToUdacityDirectly", code: 2, userInfo: [NSLocalizedDescriptionKey: userInfo]))
                }
                
                if let returnSession = results[UdacityParseClient.jsonResponse.session] as? [String: AnyObject] {
                    if let sessionInfo = returnSession[UdacityParseClient.jsonResponse.id] as? String {
                        print("Here is session ID: \(sessionInfo)")
                        self.sessionID = sessionInfo
                        completionHandler(success: true, error: nil)
                    } else {
                        let userInfo = "Login failed as response does not include Session ID"
                        completionHandler(success: false, error: NSError(domain: "loginToUdacityDirectly", code: 2, userInfo: [NSLocalizedDescriptionKey: userInfo]))
                    }
                } else {
                    let userInfo = "Login failed as response does not include Session ID"
                    completionHandler(success: false, error: NSError(domain: "loginToUdacityDirectly", code: 2, userInfo: [NSLocalizedDescriptionKey: userInfo]))
                }
                
                
            }
        }
        
    }
    
    //Method to get Student Data
    func getStudentData (limit: Int, completionHandler:(data: [UdacityStudent]?, success: Bool, error: NSError?) ->Void) ->Void {
        
        let parameters = [
            "limit": limit
        ]
        
        getStudentDataTask("", parameters: parameters) {results, error in
            //Check if error was returned
            if error != nil {
                print("Error returned during the data task: \(error)")
                completionHandler(data: nil, success: false, error: error!)
            } else {
                if let result = results[UdacityParseClient.jsonResponse.results] as? [[String : AnyObject]] {
                    let studentData = UdacityStudent.studentsFromResults(result)
                    completionHandler(data: studentData, success: true, error: nil)
                } else {
                    print("Error during retreiving Student Data from results")
                    let userInfo = [NSLocalizedDescriptionKey: "Error while retriving Student Data"]
                    completionHandler(data: nil, success: false, error: NSError(domain: "getStudentData", code: 3, userInfo: userInfo))
                }
            }
        }
    }
}
