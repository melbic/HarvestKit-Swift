//
//  HarvestController.swift
//  HarvestKit
//
//  Created by Matthew Cheetham on 19/11/2015.
//  Copyright © 2015 Matt Cheetham. All rights reserved.
//

#if os(iOS)
    import ThunderRequest
#elseif os(tvOS)
    import ThunderRequestTV
#elseif os (OSX)
    import ThunderRequestMac
#endif
import Foundation

/**
 The Harvest controller is responsible for all interactions with the Harvest API. It must be initialised with a company name, account username and account password.
 
 Currently the controller uses basic Auth to access the API but should support the OAuth flow in the future.
 */
public final class HarvestController {
    
    /**
     The main request controller for the harvest framework. This will be shared amongst other sub controllers for making API requests.
     */
    let requestController: TSCRequestController
    
    let apiClient:APIClient
    
    /**
     The controller for managing Timers
     */
    public let timersController: TimersController
    
    /**
     The controller for managing contacts
     */
    public let contactsController: ContactsController
    
    /**
     The controller for getting the user account
     */
    public let accountController: AccountController
    
    /**
     The controller for managing clients
     */
    public let clientsController: ClientsController
    
    /**
     The controller for managing reports
     */
    public let reportsController: ReportsController

    /**
     The controller for managing projects
     */
    public let projectsController: ProjectsController
    
    /**
     Initialises a new harvest controller with the given credentials. You must supply credentials to log in and access the harvest API.
     
     - parameter accountName: The name of the account as used when logging into the website as 'https://xxxx.harvestapp.com' where xxxx is your account name
     - parameter username: The username of the account to log in with. This is usually the users email address
     - parameter password: The password for the supplied username
     */
    public init?(accountName: String?, username: String?, password: String?) {
        
        guard let baseURL =  URL(string: "https://\(accountName!).harvestapp.com"), let username = username, let password = password  else {
            return nil
        }
        
        
        let userPasswordData = "\(username):\(password)".data(using: String.Encoding.utf8)
        let base64EncodedCredential = userPasswordData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        guard let base64Cred = base64EncodedCredential else {
            return nil
            
        }
        let authString = "Basic \(base64Cred)"
        let headers:[AnyHashable:Any] = ["Authorization":authString, "Accept":"application/json"]
        
        apiClient = APIClient(baseURL:baseURL, headers:headers)
        requestController = TSCRequestController()
        //Setup sub controllers
        timersController = TimersController(requestController: requestController)
        contactsController = ContactsController(requestController: requestController)
        accountController = AccountController(requestController: requestController)
        clientsController = ClientsController(requestController: apiClient)
        reportsController = ReportsController(requestController: requestController)
        projectsController = ProjectsController(requestController: apiClient)

    }
    
    //MARK: - Users
    
    /**
     Gets all registered users for the given account
     
     - parameter completionHandler: The completion handler to return users and errors to
     */
    public func getUsers(_ completionHandler: @escaping (_ users: [User?]?, _ requestError: NSError?) -> ()) {
        
        apiClient.get("people") { (response: JsonResponse?, requestError: Error?) -> Void in
            
            if let error = requestError {
                completionHandler(nil, error as NSError?)
                return;
            }
            
            if let usersArray = response?.array as? [[String: AnyObject]] {
                
                let users = usersArray.map({
                    
                    User(dictionary: $0)
                    
                })
                
                completionHandler(users, nil)
                
            }
            
        }
    }
    
    //MARK: - Projects
    
    /**
     Gets projects for the account
     
     - parameters:
     - completionHandler: The completion handler to return projects and errors to
     */
    public func getProjects(_ completionHandler: @escaping (_ projects: [Project?]?, _ requestError: NSError?) -> ()) {
        
        apiClient.get("projects") { (response: JsonResponse?, requestError: Error?) -> () in
            
            if let error = requestError {
                completionHandler(nil, error as NSError?)
                return;
            }
            
            if let projectsArray = response?.array as? [[String: AnyObject]] {
                
                let projects = projectsArray.map({
                    Project(dictionary: $0)
                })
                
                completionHandler(projects, nil)
            }
            
        }
    }
    
    
    //MARK: - Clients
    
    /**
     Gets clients for the account
     
     - parameters:
     - completionHandler: The completion handler to return clients and errors to
     */
    public func getClients(_ completionHandler: @escaping (_ clients: [Client]?, _ requestError: Error?) -> ()) {
        clientsController.getClients(completionHandler)
    }
}
