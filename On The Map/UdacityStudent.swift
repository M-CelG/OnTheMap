//
//  UdacityStudent.swift
//  On The Map
//
//  Created by Manish Sharma on 11/28/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

/* Struct to define the data structure of Udacity Student
// All student information received via json is stored in
// student data structure
*/

import Foundation

struct UdacityStudent {
    
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var longitude = 0.00
    var latitude = 0.00
    var mapString = ""
    var mediaURL = ""
    var objectID = ""
    var createdAt = ""
    var updatedAt = ""
    
    init (dictionary: [String: AnyObject]) {
        uniqueKey = dictionary[UdacityParseClient.StudentKey.UniqueKey] as! String
        firstName = dictionary[UdacityParseClient.StudentKey.FirstName] as! String
        lastName = dictionary[UdacityParseClient.StudentKey.LastName] as! String
        longitude = dictionary[UdacityParseClient.StudentKey.Longitude] as! Double
        latitude = dictionary[UdacityParseClient.StudentKey.Latitude] as! Double
        mapString = dictionary[UdacityParseClient.StudentKey.MapString] as! String
        mediaURL = dictionary[UdacityParseClient.StudentKey.MediaURL] as! String
        objectID = dictionary[UdacityParseClient.StudentKey.ObjectID] as! String
        createdAt = dictionary[UdacityParseClient.StudentKey.CreatedAt] as! String
        updatedAt = dictionary[UdacityParseClient.StudentKey.UpdatedAt] as! String
    }

    // Help function: Coverts an array for dictionaries to array of Udacity Students
    static func studentsFromResults (results: [[String: AnyObject]]) -> [UdacityStudent] {

        var students = [UdacityStudent]()

        for result in results {
            students.append(UdacityStudent(dictionary: result))
        }
        return students
    }


}
