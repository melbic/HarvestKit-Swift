//
// Created by Samuel Bichsel on 27.05.17.
// Copyright (c) 2017 Matt Cheetham. All rights reserved.
//

import Foundation

public class ProjectsController {
    
    let endpoint = "projects"
    /**
     The request controller used to load contact information. This is shared with other controllers
     */
    let apiClient: APIClient
    /**
     Initialises a new controller.
     - parameter requestController: The request controller to use when loading client information. This must be passed down from HarvestController so that authentication may be shared
     */
    internal init(requestController: APIClient) {
        
        self.apiClient = requestController
    }
    /**
     Creates a new project entry in the Harvest system. You may configure any of the parameters on the contact object you are creating and they will be saved.
     
     - parameter project: The new project object to send to the API
     - parameter completion: The completion handler to return any errors to
     - requires: `name` on the project object as a minimum
     */
    public func create(_ project: Project, completion: @escaping (_ error: Error?) -> ()) {
        do {
            try apiClient.post(endpoint, bodyParams: project.serialisedObject) { (response: JsonResponse?, error: Error?) in
                
                if let _error = error {
                    completion(_error)
                    return
                }
                
                if let responseStatus = response?.status, responseStatus == 201 {
                    completion(nil)
                    return
                }
                
                completion(ClientError.unexpectedResponseCode)
            }
        } catch {
            completion(error)
        }
    }
    
    //MARK - Requesting Projects
    
    /**
     Requests a specific project from the API by identifier
     
     - parameter projectsIdentifier: The identifier of the project to look up in the system
     */
    public func get(_ projectsIdentifier: Int, completion: @escaping (_ project: Project?, _ error: Error?) -> ()) {
        
        apiClient.get(endpoint+"/\(projectsIdentifier)") { (response: JsonResponse?, error: Error?) in
            
            if let _error = error {
                completion(nil, _error)
                return
            }
            
            if let responseDictionary = response?.dictionary as? [String: AnyObject] {
                
                let project = Project(dictionary: responseDictionary)
                completion(project, nil)
                return
            }
            
            completion(nil, ClientError.malformedData)
        }
    }
    
    /**
     Requests all projects in the system for this company
     
     - parameter completion: A closure to call with an optional array of `projects` and an optional `error`
     */
    public func getProjects(_ completion: @escaping (_ projects: [Project]?, _ error: Error?) -> ()) {
        
        apiClient.get(endpoint) { (response: JsonResponse?, error: Error?) in
            
            if let _error = error {
                completion(nil, _error)
                return
            }
            
            if let responseArray = response?.array as? [[String: AnyObject]] {
                
                let projects = responseArray.flatMap({Project(dictionary: $0)})
                completion(projects, nil)
                return
            }
            
            completion(nil, ClientError.malformedData)
        }
    }
    /**
     Deletes a project from the Harvest API.
     
     - parameter project: The project to delete in the API
     - parameter completion: The closure to call with potential errors
     - requires: `identifier` on the client object as a minimum
     - note: You will not be able to delete a client if they have assosciated projects or invoices
     */
    public func delete(_ project: Project, completion: @escaping (_ error: Error?) -> ()) {
        
        guard let projectIdentifier = project.identifier else {
            completion(ClientError.missingIdentifier)
            return
        }
        
        apiClient.delete(endpoint+"/\(projectIdentifier)") { (response: JsonResponse?, error: Error?) in
            
            if let _error = error {
                
                if let responseStatus = response?.status, responseStatus == 400 {
                    completion(ClientError.hasProjectsOrInvoices)
                    return
                }
                
                completion(_error)
                return
            }
            
            if let responseStatus = response?.status, responseStatus == 200 {
                completion(nil)
                return
            }
            
            completion(ClientError.unexpectedResponseCode)
        }
        
    }
    
}
