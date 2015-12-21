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
    
    //Method for login directly to Udacity using user name and password
    func loginToUdacityDirectly (username: String, password: String, completionHandler:(success: Bool, error: NSError?) -> Void) {
        //Method for Login Session
        let method = UdacityParseClient.Methods.UdacitySession
        
        let httpBody = [
            UdacityParseClient.HttpBody.Udacity : [
                UdacityParseClient.HttpBody.UserName : username,
                UdacityParseClient.HttpBody.Password : password
                ]
            ]
        
        udacityLoginDataTask(method, jsonBody: httpBody){results, error in
            if let error = error {
                print("Loging Failed with Udacity:\(error)")
                completionHandler(success: false, error: error)
            } else {
                //Get the User account information from the data
                if let returnAccount = results[UdacityParseClient.jsonResponse.account] as? [String: AnyObject] {
                    if let key = returnAccount[UdacityParseClient.jsonResponse.key] as? String {
                        self.userID = key
                    } else {
                        let userInfo = "Login failed as response does not include Key"
                        completionHandler(success: false, error: NSError(domain: "loginToUdacityDirectly", code: 2, userInfo: [NSLocalizedDescriptionKey: userInfo]))
                    }
                } else {
                    let userInfo = "Login failed as response does not include Key"
                    completionHandler(success: false, error: NSError(domain: "loginToUdacityDirectly", code: 2, userInfo: [NSLocalizedDescriptionKey: userInfo]))
                }
                //Get the session information from data
                if let returnSession = results[UdacityParseClient.jsonResponse.session] as? [String: AnyObject] {
                    if let sessionInfo = returnSession[UdacityParseClient.jsonResponse.id] as? String {
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
    
    //Method to login via Facebook login
    func loginToUdacityViaFacebook (token: String, completionHandler:(success: Bool, error: NSError?) ->Void) {
        let method = UdacityParseClient.Methods.UdacitySession
        
        let httpBody = [
            UdacityParseClient.HttpBody.Facebook : [
                UdacityParseClient.HttpBody.AccessToken : token
            ]
        ]
        
        udacityLoginDataTask(method, jsonBody: httpBody) {results, error in
            if error != nil {
                completionHandler(success: false, error: error)
                return
            } else {
                //Get the User account ID
                if let returnAccount = results[UdacityParseClient.jsonResponse.account] as? [String: AnyObject] {
                    if let key = returnAccount[UdacityParseClient.jsonResponse.key] as? String {
                        self.userID = key
                    } else {
                        let userInfo = "Login failed as response does not include Key"
                        completionHandler(success: false, error: NSError(domain: "loginToUdacityDirectly", code: 2, userInfo: [NSLocalizedDescriptionKey: userInfo]))
                    }
                } else {
                    let userInfo = "Login failed as response does not include Key"
                    completionHandler(success: false, error: NSError(domain: "loginToUdacityDirectly", code: 2, userInfo: [NSLocalizedDescriptionKey: userInfo]))
                }
                //Get the session ID for the user
                if let returnSession = results[UdacityParseClient.jsonResponse.session] as? [String: AnyObject] {
                    if let sessionInfo = returnSession[UdacityParseClient.jsonResponse.id] as? String {
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
            "limit": limit,
            "order": "-updatedAt"
        ]
        
        getStudentDataTask("", parameters: parameters as! [String : AnyObject]) {results, error in
            //Check if error was returned
            if error != nil {
                completionHandler(data: nil, success: false, error: error!)
            } else {
                if let result = results[UdacityParseClient.jsonResponse.results] as? [[String : AnyObject]] {
                    let studentData = UdacityStudent.studentsFromResults(result)
                    completionHandler(data: studentData, success: true, error: nil)
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Error while retriving Student Data"]
                    completionHandler(data: nil, success: false, error: NSError(domain: "getStudentData", code: 3, userInfo: userInfo))
                }
            }
        }
    }
    
    //Getting User public Data from Udacity and parsing it
    func getUserPublicData(completionHandler: (success: Bool, error: NSError?) ->Void) {
        guard let userID = UdacityParseClient.sharedInstance().userID else {
            completionHandler(success: false, error: NSError(domain: "User ID not found", code: 4, userInfo: [NSLocalizedDescriptionKey: "Missing User ID from login process"]))
            return
        }
        
        getStudentPublicDataTask(userID) {data, error in
        
            if error != nil {
                completionHandler(success: false, error: error)
                return
            }
            
            if let newData = data![UdacityParseClient.jsonResponse.user] as? [String: AnyObject] {
                
                if let firstName = newData[UdacityParseClient.jsonResponse.firstName] as? String {
                    UdacityParseClient.sharedInstance().firstName = firstName
                }
                
                if let lastName = newData[UdacityParseClient.jsonResponse.lastName] as? String {
                    UdacityParseClient.sharedInstance().lastName = lastName
                    completionHandler(success: true, error: nil)
                }
                
            }
        }
    }
    // Helper function to get user's location information, which is updated when user post's new location
    func getUserStudentData(completionHandler:(success: Bool, error: NSError?) -> Void) {
        
        let parameters = [
            "where": "{\"\(UdacityParseClient.StudentKey.UniqueKey)\": \"\(UdacityParseClient.sharedInstance().userID!)\"}"
        ]
        
        getStudentDataTask("", parameters: parameters) {results, error in
            if error != nil {
                completionHandler(success: false, error: error)
                return
            }
            
            guard let result = results[UdacityParseClient.jsonResponse.results] as? [[String : AnyObject]] else {
                completionHandler(success: false, error: NSError(domain: "Get Student Data", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unable to get results from Student location entry"]))
                return
            }
            let studentResult = result[0]
            guard let resultObjectID = studentResult[UdacityParseClient.StudentKey.ObjectID] as? String else {
                completionHandler(success: false, error: NSError(domain: "Get Student Data", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unable to get Object ID from Student location entry"]))
                return
            }
            
            UdacityParseClient.sharedInstance().objectID = resultObjectID
        }
    }
    //Udacity login session delete helper function
    func deleteSession(completionHandler: (success: Bool, error: NSError?) -> Void) {

        sessionDeleteDataTask(){results, error in
            if error != nil {
                completionHandler(success: false, error: error!)
                return
            }
            
            if let session = results![UdacityParseClient.jsonResponse.session] {
                if let _ = session![UdacityParseClient.jsonResponse.id] as? String {
                    completionHandler(success: true, error: nil)
                } else {
                    completionHandler(success: false, error: NSError(domain: "Logout - Delete Session", code: 8, userInfo:[NSLocalizedDescriptionKey: "Unable to get session ID in delete session response"]))
                }
            }
        }
    }

}
