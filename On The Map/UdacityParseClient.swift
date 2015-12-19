//
//  UdacityParseClient.swift
//  On The Map
//
//  Created by Manish Sharma on 11/28/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import Foundation
import UIKit

//Udacity Parse Client Object

class UdacityParseClient: NSObject {
    
    // Shared Session
    var session: NSURLSession
    
    //Session ID from Login
    var sessionID: String? = nil
    //User ID
    var userID: String? = nil
    //User First Name
    var firstName: String? = nil
    //User Last Name
    var lastName: String? = nil
    //Object ID
    var objectID: String? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func getStudentDataTask(method: String, parameters: [String: AnyObject], completionHandler: (results: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //Create URL from paramters passed to get Task
        let url = UdacityParseClient.Constants.BaseParseURL + method + UdacityParseClient.urlPartFromParameters(parameters)
        let requestURL = NSURL(string: url)
        print(url)
        
        let request = NSMutableURLRequest(URL: requestURL!)
        request.addValue(UdacityParseClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityParseClient.Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) {data, response, error in
            
            //Check if there is an error
            if error != nil {
                print("Error getting data during get request response: \(error)")
                completionHandler(results: nil, error: error)
            }
            
            //Check for unsuccessful response error
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Here is the error response code:\(response.statusCode)")
                } else if let response = response {
                    print("Here is error response:\(response)")
                } else {
                    print("Your request received invalid response")
                }
                return
            }
            
            //Check if data is received
            guard let data = data else {
                print("No data returned for the request")
                return
            }
            
            //Parsed the received data
            UdacityParseClient.parseJSONResponse(data, completionHandler: completionHandler)
            
        }
        //Start task
        task.resume()
        
        return task
    }
    
    func udacityLoginDataTask(method: String, jsonBody: [String: [String: String]], completionHandler:(results: AnyObject!, error: NSError?)-> Void) -> NSURLSessionDataTask {
        
        //Create url String from base URL and provided method and parameters
        let url = UdacityParseClient.Constants.BaseUdacityURl + method
        let requestURL = NSURL(string: url)

        //Create Request
        let request = NSMutableURLRequest(URL: requestURL!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        } catch {
            print("Error During creating HTTPBody from jsonBody: \(error)")
            let userInfo = [NSLocalizedDescriptionKey: "Login Failed - Unable to create Request.HTTPBody"]
            completionHandler(results: nil, error: NSError(domain: "Request.HttpBody", code: 0, userInfo: userInfo))
        }
        
        //Creat Task to send request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if downloadError != nil {
                completionHandler(results: nil, error: downloadError)
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode == 403 {
                    let userInfo = [NSLocalizedDescriptionKey: "Invalid Email and/or Password"]
                    completionHandler(results: nil, error: NSError(domain: "Login", code: 0, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey: "Login Failed - Response StatusCode -\((response as! NSHTTPURLResponse).statusCode)"]
                    completionHandler(results: nil, error: NSError(domain: "Login", code: 0, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Login failed - Invalid Response from server"]
                    completionHandler(results: nil, error: NSError(domain: "Login", code: 0, userInfo: userInfo))
                }
                return
            }
            
            print("Here is response code: \((response as? NSHTTPURLResponse)?.statusCode)")
            
            guard let data = data else {
                print("No data returned by request")
                return
            }
            // Remove first 5 bytes from Udacity API response as per spec
            let newData = data.subdataWithRange(NSMakeRange(5, (data.length ) - 5))
            
            //Call JSON data parse method to parse data
            UdacityParseClient.parseJSONResponse(newData, completionHandler: completionHandler)
        }
        //Start task
        task.resume()
        
        return task
    }
    
    func getStudentPublicDataTask(userID: String, completionHandler:((data: AnyObject?, error: NSError?) -> Void)) -> NSURLSessionDataTask {
        
        //Create URL
        let url = UdacityParseClient.Constants.BaseUdacityURl + UdacityParseClient.Methods.UdacityUsers + userID
        let requestURL = NSURL(string: url)
        print(url)
        
        //Create Request
        let request = NSMutableURLRequest(URL: requestURL!)
        
        //Create task
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if error != nil {
                print("Error Encountered during the user public task")
                completionHandler(data: nil, error: error)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode == 400 {
                    completionHandler(data: nil, error: NSError(domain: "Get User Data", code: 4, userInfo: [NSLocalizedDescriptionKey: "Response code 400 received: \(response)"]))
                    return
                } else if let response = response {
                    completionHandler(data: nil, error: NSError(domain: "Get User Data", code: 4, userInfo: [NSLocalizedDescriptionKey: "Error response received: \(response)"]))
                    return
                } else {
                    completionHandler(data: nil, error: NSError(domain: "Get User Data", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid Response to your request"]))
                    return
                }
                
            }
            
            guard let data = data else {
                completionHandler(data: nil, error: NSError(domain: "Get User Data", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid data received"]))
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            UdacityParseClient.parseJSONResponse(newData, completionHandler: completionHandler)
            
        }
        //Start Task
        task.resume()
        
        return task
    }
    
    //Post method for posting student locatio data
    func postAndPutStudentLocationDataTask(method: String, httpMethod: String, jsonBody: [String: AnyObject], completionHandler: (data: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask  {
        
        //Create URL
        let url = "https://api.parse.com/1/classes/StudentLocation" + method
        let requestURL = NSURL(string: url)
        
        //Create Request
        let request = NSMutableURLRequest(URL: requestURL!)
        request.HTTPMethod = httpMethod
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        } catch {
            print("error in converting JsonBody dictionary to json: \(error)")
            completionHandler(data: nil, error: NSError(domain: "Post Student Data", code: 3, userInfo: [NSLocalizedDescriptionKey: "\(error)"]))
        }
        
        
        //Create Data Task
        let task = session.dataTaskWithRequest(request) {data, response, error in
            //Handle the error
            if error  != nil {
                completionHandler(data: nil, error: error)
                return
            }
            
            //Handle the response
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode == 400 {
                    completionHandler(data: nil, error: NSError(domain: "Post Student Data", code: 3, userInfo: [NSLocalizedDescriptionKey: "Incorrectly formatted request"]))
                    return
                } else if let response = response {
                    completionHandler(data: nil, error: NSError(domain: "Post Student Data", code: 3, userInfo: [NSLocalizedDescriptionKey: "Error response:\(response)"]))
                    return
                } else {
                    completionHandler(data: nil, error: NSError(domain: "Post Student Data", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid Response"]))
                    return
                }
            }
            
            guard let data = data else {
                completionHandler(data: nil, error: NSError(domain: "Post Student Data", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid Data Received"]))
                return
            }
            
            UdacityParseClient.parseJSONResponse(data, completionHandler: completionHandler)
        }
        //Start Task
        task.resume()
        
        return task
    }
    
    class func parseJSONResponse(data: NSData, completionHandler:(results: AnyObject!, error: NSError?) -> Void) {
        
        var parsedData: AnyObject!
        
        do {
            parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Unable to get data from JSON: \(data)"]
            completionHandler(results: nil, error: NSError(domain: "parseJSONResponse", code: 1, userInfo: userInfo))
        }
        
        completionHandler(results: parsedData, error: nil)
        
    }
    
    class func urlPartFromParameters(parameters: [String: AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, parameter) in parameters {
            // Covert AnyObject to String
            let stringValue = String(parameter)
            //Escape the parameter values
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            //Append to the Array
            urlVars.append(key + "=" + escapedValue!)
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    class func alertUser(hostViewController: UIViewController , title: String, message: String, dismissButton: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: dismissButton, style: .Cancel, handler: nil)
        alert.addAction(action)
        dispatch_async(dispatch_get_main_queue()) {
            hostViewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    class func sharedInstance() -> UdacityParseClient {
        
        struct Singleton {
            
            static var sharedInstance = UdacityParseClient()
        }
        return Singleton.sharedInstance
    }
}
