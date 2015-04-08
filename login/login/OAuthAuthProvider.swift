//
//  OAuthAuthProvider.swift
//  login
//
//  Created by Anthony Rodriguez on 4/6/15.
//  Copyright (c) 2015 capitalofcode. All rights reserved.
//

import Foundation
import UIKit

enum RequestType {
    case get, post
}

struct Credentials {
    var username: String
    var password: String
}

struct OAuthToken {
    
    //  Define configuration variables
    let client_id       = "In9wHQ4qXx0y5P8x"
    let client_secret   = "feyBl72EySihY3xxzmSFeDGcsibTwMvk"
    let grant_type      = "password"
    let url: NSURL?
    
    var bodyDataString: NSData {
        let bodyComposition = "grant_type=\(self.grant_type)&client_id=\(self.client_id)&client_secret=\(client_secret)&password=\(self.credentials.password)&username=\(self.credentials.username)"
        
        println(bodyComposition)
        return bodyComposition.dataUsingEncoding(NSUTF8StringEncoding)!

    }
    
    var credentials: Credentials
    
    init(credentials: Credentials, baseUrl: NSURL){
        self.credentials = credentials
        self.url = NSURL(string: "/oauth/access_token", relativeToURL: baseUrl)
        
    }
    
    func request(handler: (result: NSData?, error: String?)->Void){
        let request = NSMutableURLRequest(URL: self.url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = self.bodyDataString
        let taskInstance = DataTaskHandler()
        
//      Async dataTaskWithRequest
        taskInstance.make(request, handler: handler)
    }
}

class OAuthAuthProvider {
    
    //Base URL
    let baseUrl = NSURL(string: "http://homestead.app/")
    var access_token: String? = nil
    
    //Asynchronous call, returning a handler
    func getAccessToken(credentials: Credentials, handler: (token: String?, error: String?)->Void){
        let oauthTokenInstance = OAuthToken(credentials: credentials, baseUrl: self.baseUrl!)
        //handle the response. Get token and store it
        oauthTokenInstance.request({ (result, error) -> Void in
            if let res = result {
                if let jsonDictionary = JSONParser(data: res).dictionary(){
                    self.access_token = jsonDictionary["access_token"] as? String
                    handler(token: self.access_token!, error: error)
                }

            }else{
                handler(token: nil, error:error)
            }
        })
    }
    
    func me(handler: (name: String) -> Void){
        let url = NSURL(string: "/me", relativeToURL: self.baseUrl)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"

        // The request if valid only if the access_token exists
        if let t = self.access_token {
            request.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
            let taskInstance = DataTaskHandler()
            taskInstance.make(request, { (result, error) -> Void in
                if let res = result {
                    if let jsonDictionary = JSONParser(data: res).dictionary(){
                        let name = jsonDictionary["name"] as? String
                        handler(name: name!)
                    }
                    
                }
                
            })
        }
    }
}






