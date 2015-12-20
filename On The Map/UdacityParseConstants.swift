//
//  UdacityParseConstants.swift
//  On The Map
//
//  Created by Manish Sharma on 11/28/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

/*
// Various constants that are utilized multiple times in the application
*/

import Foundation

extension UdacityParseClient {
   
    struct Constants {
        //API Constants
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let BaseParseURL = "https://api.parse.com/1/classes/StudentLocation"
        static let BaseUdacityURl = "https://www.udacity.com/api/"
    }
    
    //Student Information
    struct StudentKey {
        
        //Make of a Student
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
    }
    
    struct Methods  {
        static let UdacitySession = "session"
        static let UdacityUsers = "users/"
    }
    
    struct MethodOptions  {
        static let limit = "limit"
        static let skip = "skip"
        static let order = "order"
    }
    
    struct jsonBodyParameters {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
    }
    
    struct jsonResponse {
        static let account = "account"
        static let registered = "registered"
        static let session = "session"
        static let id = "id"
        static let key = "key"
        static let results = "results"
        static let user = "user"
        static let firstName = "first_name"
        static let lastName = "last_name"
    }
    
    struct HttpBody {
        static let Facebook = "facebook_mobile"
        static let AccessToken = "access_token"
        static let UserName = "username"
        static let Password = "password"
        static let Udacity = "udacity"
    }
    
    
}
