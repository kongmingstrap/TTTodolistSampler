//
//  TrelloAPI.swift
//  TTTodolistSample
//
//  Created by Takaaki Tanaka on 2015/07/30.
//  Copyright © 2015年 Takaaki Tanaka. All rights reserved.
//

import Foundation
import APIKit

protocol TrelloRequest: Request {
    
}

extension TrelloRequest {
    var baseURL: NSURL {
        return NSURL(string: "http://localhost:9000")!
    }
}

class TrelloAPI: API {
    
    
    
    struct GetToken: TrelloRequest {
        typealias Response = Token
        
        var method: HTTPMethod {
            return .GET
        }
        
        var path: String {
            return "/todos"
        }
        
        var parameters: [String: AnyObject] {
            return ["key": "1f5ad85ac2d35d8282c7464ba40bf759", "name": "TakaakiTanaka+TodolistSample", "expiration": "1day", "response_type": "token", "scope": "read,write"]
        }
        
        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
            guard let dictionary = object as? [String: AnyObject] else {
                return nil
            }
            
            guard let rateLimit = RateLimit(dictionary: dictionary) else {
                return nil
            }
            
            return rateLimit
        }
    }
    
    struct GetRateLimit: TrelloRequest {
        typealias Response = RateLimit
        
        var method: HTTPMethod {
            return .GET
        }
        
        var path: String {
            return "/rate_limit"
        }
        
        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
            guard let dictionary = object as? [String: AnyObject] else {
                return nil
            }
            
            guard let rateLimit = RateLimit(dictionary: dictionary) else {
                return nil
            }
            
            return rateLimit
        }
    }
}

struct RateLimit {
    let count: Int
    let resetDate: NSDate
    
    init?(dictionary: [String: AnyObject]) {
        guard let count = dictionary["rate"]?["limit"] as? Int else {
            return nil
        }
        
        guard let resetDateString = dictionary["rate"]?["reset"] as? NSTimeInterval else {
            return nil
        }
        
        self.count = count
        self.resetDate = NSDate(timeIntervalSince1970: resetDateString)
    }
}


struct Token {
    let count: Int
    let resetDate: NSDate
    
    init?(dictionary: [String: AnyObject]) {
        guard let count = dictionary["rate"]?["limit"] as? Int else {
            return nil
        }
        
        guard let resetDateString = dictionary["rate"]?["reset"] as? NSTimeInterval else {
            return nil
        }
        
        self.count = count
        self.resetDate = NSDate(timeIntervalSince1970: resetDateString)
    }
}