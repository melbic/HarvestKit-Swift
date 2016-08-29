//
//  ReportsController.swift
//  HarvestKit
//
//  Created by Terrence Geernaert on 2016-08-19.
//  Copyright © 2016 Matt Cheetham. All rights reserved.
//

import Foundation

#if os(iOS)
    import ThunderRequest
#elseif os(tvOS)
    import ThunderRequestTV
#elseif os (OSX)
    import ThunderRequestMac
#endif

/**
 Handles retrieving information from the Reports API
 */

public final class ReportsController {

    /**
     The request controller used to load contact information. This is shared with other controllers
     */
    public let requestController: TSCRequestController

    let harvestReportDateFormatter = NSDateFormatter()
    

    /**
     Initialises a new controller.
     - parameter requestController: The request controller to use when loading client information. This must be passed down from HarvestController so that authentication may be shared
     */
    internal init(requestController: TSCRequestController) {

        self.requestController = requestController
        self.harvestReportDateFormatter.dateFormat = "yyyyMMdd"
    }

    internal func dateString(date: NSDate) -> String {

        return self.harvestReportDateFormatter.stringFromDate(date)
    }

    public func getTimeReport(project: Project, start: NSDate, end: NSDate, completion: (timers: [Timer?]?, error: NSError?) -> ()) {

        guard let _ = project.name else {
            completion(timers: nil, error: NSError(domain: "", code: 0, userInfo: nil))
            return
        }

        requestController.get("projects/(:projectIdentifier)/entries?from=(:from)&to=(:to)", withURLParamDictionary:["projectIdentifier" : project.identifier!, "from": self.dateString(start), "to":self.dateString(end)]) {

            (response: TSCRequestResponse?, error: NSError?) in

            if let _error = error {
                completion(timers: nil, error: _error)
                return
            }
            
            if let timeReportResponseArray = response?.array as? Array<[String: AnyObject]> {

                let timersArray = timeReportResponseArray.map { dayEntry in
                    Timer(dictionary: dayEntry["day_entry"] as! [String : AnyObject])
                    }
                
                completion(timers: timersArray, error: nil)
                return;
            }
            
            completion(timers: nil, error: nil)
        }
    }
    
    public func getTimeReport(user: User, start: NSDate, end: NSDate, completion: (timers: [Timer?]?, error: NSError?) -> ()) {

        guard let _ = user.identifier else {
            completion(timers: nil, error: NSError(domain: "", code: 0, userInfo: nil))
            return
        }

        requestController.get("people/(:userIdentifier!)/entries?from=(:from)&to=(:to)", withURLParamDictionary:["userIdentifier" : user.identifier!,"from": self.dateString(start), "to":self.dateString(end)]) {

            (response: TSCRequestResponse?, error: NSError?) in

            if let _error = error {
                completion(timers: nil, error: _error)
                return
            }
            
            if let timeReportResponseArray = response?.array as? Array<[String: AnyObject]> {
                
                let timersArray = timeReportResponseArray.map { dayEntry in
                    Timer(dictionary: dayEntry["day_entry"] as! [String : AnyObject])
                }
                
                completion(timers: timersArray, error: nil)
            }
        }
    }
}
