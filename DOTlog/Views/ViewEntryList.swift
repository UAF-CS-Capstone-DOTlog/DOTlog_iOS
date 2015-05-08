//
//  EntryList.swift
//  DOTlog
//
//  Created by William Showalter on 15/03/18.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewEventList: UIViewController, UITableViewDelegate, UITableViewDataSource, ErrorObserver, UIActionSheetDelegate {

	// This class is an ErrorObserver from the Observer design pattern
	// This allows the class to have subjects that keep references to itself
	// and notify this viewcontroller with errors through the notify(NSError) function.
	// http://en.wikipedia.org/wiki/Observer_pattern

	@IBOutlet weak var entryTableView: UITableView!

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	let hasNotBeenSyncedAlert = UIAlertController(title: "Run Initial Sync Before Adding Events", message: nil, preferredStyle: .Alert)
	let successfullySyncedAlert = UIAlertController(title: "Sync Completed Successfully", message: nil, preferredStyle: .Alert)
	let syncManagerObj = SyncManager()

	var hasBeenErrorSinceLastSync = false
	var eventEntries = [EventEntry]()
	var keychainObj = KeychainAccess()

	private var username : String?
	private var password : String?
	var baseURL : String?

	override func viewDidLoad() {
		super.viewDidLoad()
		entryTableView.dataSource = self
		entryTableView.delegate = self

		self.hasNotBeenSyncedAlert.addAction(UIAlertAction(title: "Dismiss",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))
		self.successfullySyncedAlert.addAction(UIAlertAction(title: "Okay",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))

		let longPress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")

		entryTableView.addGestureRecognizer(longPress)
	}

	func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
		if UIGestureRecognizerState.Began == gestureRecognizer.state {
			let longPress = gestureRecognizer as! UILongPressGestureRecognizer
			let state = longPress.state
			var locationInView = longPress.locationInView(entryTableView)
			var indexPath = entryTableView.indexPathForRowAtPoint(locationInView)

			let deleteCellActionSheet = createDeleteEventActionSheet()
			if let indexPathVal = indexPath {
				deleteCellActionSheet.accessibilityElements = [] as [NSIndexPath]
				deleteCellActionSheet.accessibilityElements.append(indexPathVal)
				deleteCellActionSheet.showInView(self.view)
			}
		}
	}

	func createDeleteEventActionSheet() -> UIActionSheet {
		var actionSheet = UIActionSheet()

		actionSheet.addButtonWithTitle("Delete Event")
		actionSheet.addButtonWithTitle("Cancel")
		actionSheet.destructiveButtonIndex = 0
		actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1

		actionSheet.delegate = self
		return actionSheet
	}

	func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
		if let var indexPath : NSIndexPath = actionSheet.accessibilityElements[0] as? NSIndexPath {
			switch buttonIndex {
			case 0:
				let entryToDelete = eventEntries[indexPath.row]
				managedObjectContext?.deleteObject(entryToDelete)

				eventEntries.removeAtIndex(indexPath.row)
				entryTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

				managedObjectContext?.save(nil)
				break;
			default:
				break;
			}
		}
	}

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		fetchEvents()
		self.entryTableView.reloadData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func fetchEvents(){
		let eventFetch = NSFetchRequest (entityName:"EventEntry")
		eventEntries = managedObjectContext!.executeFetchRequest(eventFetch, error:nil) as! [EventEntry]
	}

	// Functions for UITableViewDataSources
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return eventEntries.count;
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var newCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("EventEntry") as? UITableViewCell

		if newCell == nil {
			newCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "EventEntry")
		}

		let eventEntry = eventEntries[indexPath.row]
		newCell!.textLabel!.text = eventEntry.faa_code + " | " + eventEntry.category_title + " - " + eventEntry.event_text
		return newCell!
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {
			let entryToDelete = eventEntries[indexPath.row]
			managedObjectContext?.deleteObject(entryToDelete)
			managedObjectContext?.save(nil)

			eventEntries.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
	}

	@IBAction func addEventButton(sender: AnyObject) {
		if hasNotBeenSynced() {
			self.presentViewController(hasNotBeenSyncedAlert, animated: true, completion:nil)
		}
		else {
			performSegueWithIdentifier("AddEventSegue", sender: self)
		}
	}

	func hasNotBeenSynced() -> Bool {
		var airports = Array<String>()
		var categories = Array<String>()

		let airportFetch = NSFetchRequest (entityName:"AirportEntry")
		if let airportResults = managedObjectContext!.executeFetchRequest(airportFetch, error:nil) as? [AirportEntry]{
			for airport in airportResults {
				airports.append(airport.faa_code)
			}
		}

		let categoryFetch = NSFetchRequest (entityName:"CategoryEntry")
		if let categoryResults = managedObjectContext!.executeFetchRequest(categoryFetch, error:nil) as? [CategoryEntry]{
			for category in categoryResults {
				categories.append(category.category_title)
			}
		}

		return (airports.count == 0 || categories.count == 0)
	}

	@IBAction func syncButton(sender: AnyObject) {
		hasBeenErrorSinceLastSync = false
		setURL()

		if attemptCredentialFetch() {
			syncManagerObj.runSync(username!, password: password!, baseURL: baseURL!, observer: self)
		}
		else {
			performSegueWithIdentifier("SyncCredentials", sender: self)
		}
	}

	func setURL () {
		let URLFetch = NSFetchRequest (entityName:"SyncURLEntry")
		if let URLs = managedObjectContext!.executeFetchRequest(URLFetch, error:nil) as? [SyncURLEntry] {
			if URLs.count != 0 {
				baseURL = URLs[0].urlString
			}
			else {
				baseURL = defaultBaseURL
			}
		}
		else {
			baseURL = defaultBaseURL
		}
	}

	func attemptCredentialFetch() -> Bool {

		if let usernameFetch = keychainObj.getUsername(){
			username = usernameFetch;
		}
		else {
			username = "";
		}

		if let passwordFetch = keychainObj.getPassword(){
			password = passwordFetch;
		}
		else {
			password = "";
		}

		return (!(username == "")) && (!(password == ""))
	}

	func notify (error : NSError) {

		syncManagerObj.reduceActiveSyncCount()

		if !hasBeenErrorSinceLastSync {
			hasBeenErrorSinceLastSync = true

			self.presentViewController(ErrorFactory.ErrorAlert(error, caller: self), animated: true, completion: nil)
		}
	}

	// Returns to this view controller
	@IBAction func ButtonCancelToEventList(segue: UIStoryboardSegue) {
	}

	func notifyFinishSuccess () {
		syncManagerObj.reduceActiveSyncCount()

		if (syncManagerObj.getActiveSyncCount() == 0 && !hasBeenErrorSinceLastSync) {
			self.presentViewController(successfullySyncedAlert, animated: true, completion: nil)
		}

		self.viewWillAppear(true)
	}

	override func disablesAutomaticKeyboardDismissal() -> Bool {
		return false
	}
}