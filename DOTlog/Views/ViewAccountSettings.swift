
//
//  ViewController.swift
//  DOTlog
//
//  Created by William Showalter on 15/02/28.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit
import CoreData

let defaultBaseURL : String = "http://dotlog.uafcsc.com"

class ViewAccountSettings: UITableViewController, UITextFieldDelegate {

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
		// Populates URL, then replaces with remembered if present
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
		deleteOldURL()
		var scheme : String = "https"

		if let baseURLUnstrippedTry = NSURLComponents(string: UIFieldBaseURL.text) {
			var baseURLUnstripped = baseURLUnstrippedTry
			if let baseURLScheme : String = baseURLUnstripped.scheme {
				scheme = baseURLScheme
				println("Unwrapped scheme")
			}

			deleteOldURL()

			if let urlHostWithOrWithoutBase = baseURLUnstripped.host {
				println("Host unwrapped to \(urlHostWithOrWithoutBase)")
			}
			else {
				if let baseURLUnstrippedWithScheme = NSURLComponents(string: scheme + "://" + UIFieldBaseURL.text) {
					baseURLUnstripped = baseURLUnstrippedWithScheme
				}
			}


			if let urlHost = baseURLUnstripped.host {
				// Create new
				let entityDescription =
				NSEntityDescription.entityForName("SyncURLEntry",
					inManagedObjectContext: managedObjectContext!)

				let url = SyncURLEntry(entity: entityDescription!,
					insertIntoManagedObjectContext: managedObjectContext)

				url.urlString = scheme + "://" + urlHost
				println("Saving string \(url.urlString)")
				managedObjectContext?.save(&error)
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
		// Delete old
		let fetch = NSFetchRequest (entityName:"SyncURLEntry")
		let entries = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [SyncURLEntry]
		for entry in entries {
			managedObjectContext?.deleteObject(entry)
		}
	}

	@IBAction func ButtonSave(sender: AnyObject) {
		saveCreds()
		saveURL()
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
		forgetCreds()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

