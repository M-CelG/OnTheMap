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
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func getStudentDataTask(method: String, parameters: [String: AnyObject], completionHandler: (results: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //Create URL from paramters passed to get Task
        let url = UdacityParseClient.Constants.BaseParseURL + method + UdacityParseClient.urlPartFromParameters(parameters)
        let requestURL = NSURL(string: url)
        
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
        print(url)
        //Create Request
        let request = NSMutableURLRequest(URL: requestURL!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
            let requestJson = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)
            print("here is the json:\(requestJson)")
        } catch {
            print("Error During creating HTTPBody from jsonBody: \(error)")
        }
        
        //Creat Task to send request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if downloadError != nil {
                print("Unable to login as POST request resulted in Error: \(downloadError)")
                completionHandler(results: nil, error: downloadError)
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
    
//    func postParseDataTask(method: String, parameters: [String: AnyObject], jsonBody: [String: AnyObject], completioHandler:(results: AnyObject!, error: NSError?)-> Void) -> NSURLSessionDataTask {
//        
//    }
//    
//    func getParseDataTask (method: String, parameters: [String: AnyObject], completionHandler: (results: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
//    
    class func parseJSONResponse(data: NSData, completionHandler:(results: AnyObject!, error: NSError?) -> Void) {
        
        var parsedData: AnyObject!
        
        do {
            let newData = NSString(data: data, encoding: NSUTF8StringEncoding)
            print("here is parsed Data just before parsing: \(newData)")
            parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            print("here is parsed Data: \(parsedData)")
            
        } catch {
            print("Why is there an error: \(error)")
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
    
    class func alertUser(hostViewController: UIViewController , title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        dispatch_async(dispatch_get_main_queue()) {
            hostViewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    class func sharedInstance() -> UdacityParseClient {
        
        struct Slingleton {
            
            static var sharedInstance = UdacityParseClient()
        }
        return Slingleton.sharedInstance
    }
}
