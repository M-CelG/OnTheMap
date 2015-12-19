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
    
    //Getting User Data and parsing it
    func getUserPublicData(completionHandler: (success: Bool, error: NSError?) ->Void) {
        guard let userID = UdacityParseClient.sharedInstance().userID else {
            print("Unable to get User ID")
            completionHandler(success: false, error: NSError(domain: "User ID not found", code: 4, userInfo: [NSLocalizedDescriptionKey: "Missing User ID from login process"]))
            return
        }
        
        getStudentPublicDataTask(userID) {data, error in
        
            if error != nil {
                print("Error in getting user public data")
                completionHandler(success: false, error: error)
                return
            }
            
            if let newData = data![UdacityParseClient.jsonResponse.user] as? [String: AnyObject] {
                
                print("\(newData)")
  
                if let firstName = newData[UdacityParseClient.jsonResponse.firstName] as? String {
                    UdacityParseClient.sharedInstance().firstName = firstName
                    print("Here is User's first name: \(firstName)")
                }
                
                if let lastName = newData[UdacityParseClient.jsonResponse.lastName] as? String {
                    UdacityParseClient.sharedInstance().lastName = lastName
                    print("Here is User's last name: \(lastName)")
                    completionHandler(success: true, error: nil)
                }
                
            }
            
            
            

        }
    }
    
    func getUserStudentData(completionHandler:(success: Bool, error: NSError?) -> Void) {
        
        let parameters = [
            "where": "{\"\(UdacityParseClient.StudentKey.UniqueKey)\": \"\(UdacityParseClient.sharedInstance().userID!)\"}"
        ]
        
        getStudentDataTask("", parameters: parameters) {results, error in
            if error != nil {
                print("Unable to get prior location information for the student:\(error)")
            }
            
            print("\(results)")
            guard let result = results[UdacityParseClient.jsonResponse.results] as? [[String : AnyObject]] else {
                completionHandler(success: false, error: NSError(domain: "Get Student Data", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unable to get results from Student location entry"]))
                return
            }
            print("\(result)")
            let studentResult = result[0]
            print("\(studentResult)")
            guard let resultObjectID = studentResult[UdacityParseClient.StudentKey.ObjectID] as? String else {
                completionHandler(success: false, error: NSError(domain: "Get Student Data", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unable to get Object ID from Student location entry"]))
                return
            }
            
            UdacityParseClient.sharedInstance().objectID = resultObjectID
        }
    }

}
