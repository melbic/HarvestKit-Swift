//
// Created by Samuel Bichsel on 14.05.17.
// Copyright (c) 2017 Matt Cheetham. All rights reserved.
//

import Foundation

typealias Headers = [AnyHashable:Any]
typealias  NetworkCompletion = (JsonResponse?, Error?)->()

struct APIError:Error {
    let message:String?
    
    var localizedDescription:String {
        return message ?? "Unknown Error"
    }
}

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
    
    private func dataTask(with endpoint: String, method:HTTPMethod = .get,  bodyParams:Any? = nil, completionHandler: @escaping NetworkCompletion) throws -> URLSessionDataTask {
        let dataTask = try urlSession.dataTask(with: baseURL.appendingPathComponent(endpoint), method:method, bodyParams:bodyParams){data, response, error in
            let jsonResponse = JsonResponse(data, response:response)
            var error = error
            if let resp = jsonResponse, resp.status >= 300 && error == nil {
                error = APIError(message:resp.errorMessage)
            }
            completionHandler(jsonResponse, error)
        }
        return dataTask
    }
    
    func get(_ endpoint:String, completion: @escaping NetworkCompletion) {
        do {
            let task = try dataTask(with: endpoint, completionHandler: completion)
            task.resume()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    func post(_ endppoint:String, bodyParams:Any?, completion: @escaping NetworkCompletion) throws {
        let task = try dataTask(with: endppoint, method: .post, bodyParams: bodyParams, completionHandler: completion)
        task.resume()
    }
    
    func put(_ endppoint:String, bodyParams:Any?, completion: @escaping NetworkCompletion) throws {
        let task = try dataTask(with: endppoint, method: .put, bodyParams: bodyParams, completionHandler: completion)
        task.resume()
    }
    func delete(_ endpoint:String, completion: @escaping NetworkCompletion) {
        do {
            let task = try dataTask(with: endpoint, method: .delete, completionHandler: completion)
            task.resume()
        } catch {
            fatalError(error.localizedDescription);
        }
    }
}

struct JsonResponse {
    let jsonObject: Any?
    let status:Int
    
    init?(_ data:Data?, response:URLResponse?) {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }
        
        status = response.statusCode
        
        var j:Any? = nil
        if let data = data {
            do {
                j = try JSONSerialization.jsonObject(with: data)
            }   catch {
                print(error)
            }
        }
        jsonObject = j
    }
}

extension JsonResponse {
    var array:[Any?]?     {
        get {
            return jsonObject as? [Any?]
        }
    }
    var dictionary:[String:Any]?     {
        get {
            return jsonObject as? [String:Any]
        }
    }
    var errorMessage:String? {
         return dictionary?["message"] as? String
    }
    
}


extension Data {
    func print() -> String? {
        return String(data:self, encoding:String.Encoding.utf8)
        
    }
}
