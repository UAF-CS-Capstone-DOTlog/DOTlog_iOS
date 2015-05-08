
//
//  ViewAccountSettingsTableView.swift
//  DOTlog
//
//  Created by William Showalter on 15/02/28.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit
import CoreData

class ViewAccountSettingsTableView: UITableViewController, UITextFieldDelegate {

	let managedObjectContext =
	(UIApplication.sharedApplication().delegate
		as! AppDelegate).managedObjectContext

	@IBOutlet weak var UIFieldBaseURL: UITextField!
	@IBOutlet weak var UIFieldUsername: UITextField!
	@IBOutlet weak var UIFieldPassword: UITextField!

	var keychainObj = KeychainAccess()

	var airportResource = APIAirportResource(baseURLString: "/")
	var categoryResource = APICategoryResource(baseURLString: "/")
	var eventResource = APIEventResource(baseURLString: "/")
	var errorReceivedSinceLastSync = false

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(animated: Bool){
		populateURL()

		if let username = keychainObj.getUsername(){
		UIFieldUsername.text = username;
		}
		else {
		UIFieldUsername.text = "";
		}

		if let password = keychainObj.getPassword(){
		UIFieldPassword.text = password;
		}
		else {
		UIFieldPassword.text = "";
		}
	}

	func populateURL () {
		UIFieldBaseURL.text = defaultBaseURL
		let URLFetch = NSFetchRequest (entityName:"SyncURLEntry")
		if let URLs = managedObjectContext!.executeFetchRequest(URLFetch, error:nil) as? [SyncURLEntry] {
			if URLs.count != 0 {
				UIFieldBaseURL.text = URLs[0].urlString
			}
		}
	}

	func saveURL () {
		var error: NSError?
		var errorMessage : String = "Could not save URL - coredata save failure."
		var scheme : String = "https"

		deleteOldURL()

		if let userURLFromInput = NSURLComponents(string: UIFieldBaseURL.text) {
			var userURL = userURLFromInput
			if let baseURLScheme : String = userURL.scheme {
				scheme = baseURLScheme
			}
			else {
				if let urlWithSchemeAdded = NSURLComponents(string: scheme + "://" + UIFieldBaseURL.text) {
					userURL = urlWithSchemeAdded
				}
			}

			if let urlHost = userURL.host {
				if urlHost != "" {
					let entityDescription =
					NSEntityDescription.entityForName("SyncURLEntry",
						inManagedObjectContext: managedObjectContext!)

					let url = SyncURLEntry(entity: entityDescription!,
						insertIntoManagedObjectContext: managedObjectContext)

					url.urlString = scheme + "://" + urlHost
					managedObjectContext?.save(&error)
				}
				else {
					errorMessage = "No domain found in \(UIFieldBaseURL.text)"
					error = NSError (domain: "Cannot Save: No Domain", code: 32, userInfo : ["NSLocalizedDescriptionKey":errorMessage])
				}
			}
			else {
				errorMessage = "Could not parse domain from \(UIFieldBaseURL.text)"
				error = NSError (domain: "Cannot Save: Bad Address", code: 31, userInfo : ["NSLocalizedDescriptionKey":errorMessage])
			}
		}
		else {
			errorMessage = "No URL Address, cannot save."
			error = NSError (domain: "Cannot Save: No Address", code: 30, userInfo : ["NSLocalizedDescriptionKey":errorMessage])
		}

		if let err = error {
			let URLErrorAlert = UIAlertController(title: err.domain, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)

			URLErrorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler:{ (ACTION :UIAlertAction!)in }))

			presentViewController(URLErrorAlert, animated: true, completion: nil)
		}

		populateURL()
	}

	func deleteOldURL () {
		let fetch = NSFetchRequest (entityName:"SyncURLEntry")
		let entries = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [SyncURLEntry]
		for entry in entries {
			managedObjectContext?.deleteObject(entry)
		}
	}

	func SaveAccountSettings() {
		saveCreds()
		saveURL()

		let CredsSavedAlert = UIAlertController(title: "Credentials Saved", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
		CredsSavedAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in }))
		presentViewController(CredsSavedAlert, animated: true, completion: nil)
	}

	func saveCreds () {
		keychainObj.setUsernamePassword(UIFieldUsername.text, pass: UIFieldPassword.text)
	}

	func forgetCreds () {
		UIFieldUsername.text = nil
		UIFieldPassword.text = nil
		saveCreds()
	}

	@IBAction func ButtonLogout(sender: AnyObject) {

		let unsyncedEventsAlert = UIAlertController(title: "Unsynced Messages", message: "Sync or delete messages before logout", preferredStyle: UIAlertControllerStyle.Alert)
		let logoutConfirmAlert = UIAlertController(title: "Logout Will Exit DOTlog", message: "All data will be saved.", preferredStyle: UIAlertControllerStyle.Alert)
		let deleteEventsObj = APIEventResource(baseURLString: "/");

		logoutConfirmAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:{ (ACTION :UIAlertAction!)in }))
		unsyncedEventsAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:{ (ACTION :UIAlertAction!)in }))

		logoutConfirmAlert.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.Default,
			handler:
			{ (ACTION :UIAlertAction!)in
				self.forgetCreds(); exit(0);
			}
		))

		unsyncedEventsAlert.addAction(UIAlertAction(title: "Delete Events", style: UIAlertActionStyle.Default,
			handler:
			{ (ACTION :UIAlertAction!)in
				deleteEventsObj.deleteOld(); self.presentViewController(logoutConfirmAlert, animated: true, completion: nil)
			}
		))

		// Check for unsynced
		let fetch = NSFetchRequest (entityName:"EventEntry")
		let events = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [EventEntry]

		if events.count != 0 {
			presentViewController(unsyncedEventsAlert, animated: true, completion: nil)
		}
		else {
			presentViewController(logoutConfirmAlert, animated: true, completion: nil)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

