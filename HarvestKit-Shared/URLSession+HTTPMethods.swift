//
//  URLSession+HTTPMethods.swift
//  HarvestKit
//
//  Created by Samuel Bichsel on 25.05.17.
//  Copyright © 2017 Matt Cheetham. All rights reserved.
//

import Foundation

typealias URLRequestCompletionHandler = (Data?, URLResponse?, Error?) -> Swift.Void

enum HTTPMethod:String {
    case get="GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
extension URLSession {
    func dataTask(with url: URL, method:HTTPMethod,  bodyParams:Any? = nil, completionHandler: @escaping URLRequestCompletionHandler) throws -> URLSessionDataTask  {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let bodyParams = bodyParams {
            
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParams)
        }
        
        return self.dataTask(with: request, completionHandler: completionHandler)
    }
}
