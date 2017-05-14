//
// Created by Samuel Bichsel on 14.05.17.
// Copyright (c) 2017 Matt Cheetham. All rights reserved.
//

import Foundation
typealias Headers = [AnyHashable:Any]
struct APIClient {
    let urlSession:URLSession
    let baseURL:URL
    init(baseURL: URL, headers:Headers? = nil) {
        let config = URLSessionConfiguration.default
        if let headers = headers {
            config.httpAdditionalHeaders = headers
        }
        urlSession = URLSession(configuration: config)
        self.baseURL = baseURL
    }
}

extension APIClient {
    var sharedHeaders:Headers?{
        get{
            return urlSession.configuration.httpAdditionalHeaders
        }
    }
    
    func get(_ endpoint:String, completion: @escaping (JsonResponse?, Error?)->()) {
        let task = urlSession.dataTask(with: baseURL.appendingPathComponent(endpoint)){ data, urlResponse, error in
            completion(JsonResponse(data), error)
        }
        task.resume()
    }
}

struct JsonResponse {
    let jsonObject: Any
    init?(_ data:Data?) {
        guard let data = data else {
            return nil
        }
        
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data)
        }   catch {
            print(error)
            return nil
        }
        
    }
}

extension JsonResponse {
    var array:[Any?]?     {
        get {
            return jsonObject as? [Any?]
        }
    }
}
