//
//  ViewAddEventAirport.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/30.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewAddEventAirport: UITableViewController {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var airports : [String] = []
	var currentAirport : String?
	var currentHub : String?
	var currentDistrict : String?
	var currentRegion : String?

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		resetPage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return airports.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell : UITableViewCell?
		if airports[indexPath.row] == currentAirport {
			cell = tableView.dequeueReusableCellWithIdentifier("selectedAirportCell") as! UITableViewCell?
		}
		else {
			cell = tableView.dequeueReusableCellWithIdentifier("airportCell") as! UITableViewCell?
		}
		cell?.textLabel?.text = airports[indexPath.row]

		return cell!
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView.cellForRowAtIndexPath(indexPath)
		currentAirport = cell?.textLabel?.text
		performSegueWithIdentifier("SegueAirportsToAddEvent", sender: self)
	}

	func resetPage() {
		let airportFetch = NSFetchRequest (entityName:"AirportEntry")
		if let airportResults = managedObjectContext!.executeFetchRequest(airportFetch, error:nil) as? [AirportEntry]{
			airports = Array<String>() // Clear old array
			for airport in airportResults {
				if currentHub == airport.hub.hub_name || currentHub == nil {
					airports.append(airport.faa_code)
				}
			}
		}
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "SegueAirportsToAddEvent" {
			var destinationViewController = segue.destinationViewController as! ViewAddEvent
			destinationViewController.currentRegion = currentRegion
			destinationViewController.currentDistrict = currentDistrict
			destinationViewController.currentHub = currentHub
			destinationViewController.UIFieldAirport.text = currentAirport
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}