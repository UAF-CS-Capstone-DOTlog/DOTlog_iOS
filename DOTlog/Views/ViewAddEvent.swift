//
//  ViewAddEvent.swift
//  DOTlog
//
//  Created by William Showalter on 15/03/18.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let SUMMARYCHARLIMIT : Int = 4000

class ViewAddEvent: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

	let airportNotSelectedAlert = UIAlertController(title: "No Airport", message: "Please select an airport", preferredStyle: .Alert)
	let categoryNotSelectedAlert = UIAlertController(title: "No Category", message: "Please select a category", preferredStyle: .Alert)
	let noEventSummaryAlert = UIAlertController(title: "No Event Summary", message: "Please enter an event summary", preferredStyle: .Alert)
	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var datePicker  : UIDatePicker! = UIDatePicker()
	var dateFormatter :NSDateFormatter = NSDateFormatter()
	var currentRegion : String? = nil
	var currentDistrict : String? = nil
	var currentHub : String? = nil

	@IBOutlet weak var UIFieldAirport: UITextField!
	@IBOutlet weak var UIFieldCategory: UITextField!
	@IBOutlet weak var UIFieldSummary: UITextView!
	@IBOutlet weak var UIFieldTime: UITextField!
	@IBOutlet weak var UISwitchInWeeklyReport: UISwitch!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.noEventSummaryAlert.addAction(UIAlertAction(title: "Dismiss",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))
		self.airportNotSelectedAlert.addAction(UIAlertAction(title: "Dismiss",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))
		self.categoryNotSelectedAlert.addAction(UIAlertAction(title: "Dismiss",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))
		dateFormatter.dateFormat = "MMM dd yyyy hh:mm a"

		resetPage()
	}

	func resetPage() {
		let fetchAirports = NSFetchRequest (entityName: "AirportEntry")
		let airports = managedObjectContext!.executeFetchRequest(fetchAirports, error: nil) as! [AirportEntry]
		UIFieldAirport.text = airports[0].faa_code
		currentHub = airports[0].hub.hub_name
		currentDistrict = airports[0].hub.district.district_name
		currentRegion = airports[0].hub.district.region.region_name

		UIFieldCategory.text = ""
		datePicker.date = NSDate()
		setEventTime(datePicker)
		UISwitchInWeeklyReport.on = false
		UIFieldSummary.text = ""
	}

	@IBAction func ButtonSaveEvent(sender: AnyObject) {

		if UIFieldCategory.text == "" {
			self.presentViewController(categoryNotSelectedAlert, animated: true, completion:nil)
		}

		if UIFieldAirport.text == "" {
			self.presentViewController(airportNotSelectedAlert, animated: true, completion:nil)
		}

		else if UIFieldSummary.text == "" {
			self.presentViewController(noEventSummaryAlert, animated:true, completion:nil)
		}

		else if count(UIFieldSummary.text) > SUMMARYCHARLIMIT {
			// Local alert declaration due to character count message being unknown at construction
			let summaryLengthAlert = UIAlertController(title: "Character Limit Exceeded", message: "Maximum Characters: \(String(SUMMARYCHARLIMIT))\nCurrent Characters: \(String(count(UIFieldSummary.text)))", preferredStyle: .Alert)
			summaryLengthAlert.addAction(UIAlertAction(title: "Dismiss",
				style: UIAlertActionStyle.Default,
				handler: {(alert: UIAlertAction!) in}))

			self.presentViewController(summaryLengthAlert, animated:true, completion:nil)
		}

		else {
			createEventEntry()
		}
	}

	func createEventEntry() {
		let entityDescription =
		NSEntityDescription.entityForName("EventEntry",
			inManagedObjectContext: managedObjectContext!)
		let event = EventEntry(entity: entityDescription!,
			insertIntoManagedObjectContext: managedObjectContext)

		event.faa_code = UIFieldAirport.text
		event.category_title = UIFieldCategory.text
		event.event_text = UIFieldSummary.text
		event.in_weekly_report = UISwitchInWeeklyReport.on

		var tempDate:String = UIFieldTime.text
		event.event_time = dateFormatter.dateFromString (tempDate)!

		var error: NSError?
		managedObjectContext?.save(&error)
		if let err = error {
			// Should only happen if the internal object becomes unwritable.
			let saveErrorAlert = UIAlertController(title: "Save Failed", message: "Restart or Reinstall app.", preferredStyle: .Alert)
			saveErrorAlert.addAction(UIAlertAction(title: "Dismiss",
				style: UIAlertActionStyle.Default,
				handler: {(alert: UIAlertAction!) in}))
			self.presentViewController(saveErrorAlert, animated: true, completion: nil)
		}
		else {
			var vc = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarViewController") as! TabBarViewController
			self.presentViewController(vc, animated: true, completion: nil)
		}
	}

	@IBAction func editEventTime(sender: UITextField) {
		datePicker.datePickerMode = UIDatePickerMode.DateAndTime
		sender.inputView = datePicker
		datePicker.addTarget(self, action: Selector("setEventTime:"), forControlEvents: UIControlEvents.ValueChanged)
	}

	func setEventTime(sender: UIDatePicker) {
		UIFieldTime.text = dateFormatter.stringFromDate(sender.date)
	}

	@IBAction func editAirport(sender: UITextField) {
		let fetchRegions = NSFetchRequest (entityName: "RegionEntry")
		let regions = managedObjectContext!.executeFetchRequest(fetchRegions, error: nil) as! [RegionEntry]
		if regions.count > 1 {
			performSegueWithIdentifier("SegueAddEventToRegions", sender: self)
		}
		else {
			let fetchDistricts = NSFetchRequest (entityName: "DistrictEntry")
			let districts = managedObjectContext!.executeFetchRequest(fetchDistricts, error: nil) as! [RegionEntry]
			if districts.count > 1 {
				performSegueWithIdentifier("SegueAddEventToDistricts", sender: self)
			}
			else {
				let fetchHubs = NSFetchRequest (entityName: "HubEntry")
				let hubs = managedObjectContext!.executeFetchRequest(fetchHubs, error: nil) as! [RegionEntry]
				if hubs.count > 1 {
					performSegueWithIdentifier("SegueAddEventToHubs", sender: self)
				}
				else {
					performSegueWithIdentifier("SegueAddEventToAirports", sender: self)
				}
			}
		}
	}

	@IBAction func editCategory(sender: UITextField) {
		performSegueWithIdentifier("SegueSelectCategory", sender: self)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "SegueSelectCategory" {
			var destinationViewController = segue.destinationViewController as! ViewAddEventCategory

			if let currentCategory = UIFieldCategory.text {
				destinationViewController.currentCategory = currentCategory
			}
		}
		else if segue.identifier == "SegueAddEventToRegions" {
			var destinationViewController = segue.destinationViewController as! ViewAddEventRegion

			destinationViewController.currentRegion = currentRegion
			destinationViewController.currentDistrict = currentDistrict
			destinationViewController.currentHub = currentHub
			destinationViewController.currentAirport = UIFieldAirport.text
		}
		else if segue.identifier == "SegueAddEventToDistricts" {
			var destinationViewController = segue.destinationViewController as! ViewAddEventDistrict

			destinationViewController.currentRegion = currentRegion
			destinationViewController.currentDistrict = currentDistrict
			destinationViewController.currentHub = currentHub
			destinationViewController.currentAirport = UIFieldAirport.text
		}
		else if segue.identifier == "SegueAddEventToHubs" {
			var destinationViewController = segue.destinationViewController as! ViewAddEventHub

			destinationViewController.currentRegion = currentRegion
			destinationViewController.currentDistrict = currentDistrict
			destinationViewController.currentHub = currentHub
			destinationViewController.currentAirport = UIFieldAirport.text
		}
		else if segue.identifier == "SegueAddEventToAirports" {
			var destinationViewController = segue.destinationViewController as! ViewAddEventAirport

			destinationViewController.currentRegion = currentRegion
			destinationViewController.currentDistrict = currentDistrict
			destinationViewController.currentHub = currentHub
			destinationViewController.currentAirport = UIFieldAirport.text
		}
	}

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	func textFieldDidBeginEditing(textField: UITextField) {
		textField.becomeFirstResponder()
	}

	@IBAction func ButtonReturnToAddEvent(segue: UIStoryboardSegue) {
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}