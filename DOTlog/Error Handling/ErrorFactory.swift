//
//  ErrorFactory.swift
//  DOTlog
//
//  Created by William Showalter on 15/05/02.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ErrorFactory {

	// Class that creates alerts given internally designated error codes and a view controller to present the errors to.
	
	class func ErrorAlert (error: NSError, caller: UIViewController) -> UIAlertController {
		let code = error.code

		var errorTitle = "Unable to Sync"
		var errorDetailTitle = "Error Code: \(code)"
		var errorMessage = "Contact Regional Aviation Office If Problem Persists."
		var errorDetailMessage = error.localizedDescription

		if let detailMessage : [NSObject : AnyObject] = error.userInfo {
			if let errorDetailMessageText = detailMessage["NSLocalizedDescriptionKey"] as? String {
				errorDetailMessage = "\(errorDetailMessageText)"
			}
		}

		if code == 401 {
			errorTitle = error.domain
			errorMessage = ""
		}

		if code == -1003 {
			errorTitle = "Bad Address" // Needs to match page wording
			errorMessage = "Confirm Address in Account Settings"
		}

		let errorAlert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
		let errorAlertDetail = UIAlertController(title: errorDetailTitle, message: errorDetailMessage as String, preferredStyle: UIAlertControllerStyle.Alert)

		errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler:{ (ACTION :UIAlertAction!)in }))
		errorAlert.addAction(UIAlertAction(title: "Details", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in caller.presentViewController(errorAlertDetail, animated: true, completion: nil)}))
		errorAlertDetail.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler:{ (ACTION :UIAlertAction!)in }))

		return errorAlert
	}
}