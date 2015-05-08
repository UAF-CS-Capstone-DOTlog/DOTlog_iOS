//
//  ViewAddEventHub.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/30.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewAddEventDistrict: UITableViewController {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var districts : [String] = []
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
		return districts.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell : UITableViewCell?
		if districts[indexPath.row] == currentDistrict {
			cell = tableView.dequeueReusableCellWithIdentifier("selectedDistrictCell") as! UITableViewCell?
		}
		else {
			cell = tableView.dequeueReusableCellWithIdentifier("districtCell") as! UITableViewCell?
		}
		cell?.textLabel?.text = districts[indexPath.row]

		return cell!
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView.cellForRowAtIndexPath(indexPath)
		currentDistrict = cell?.textLabel?.text
		performSegueWithIdentifier("SegueDistrictsToHubs", sender: self)
	}

	func resetPage() {
		let districtFetch = NSFetchRequest (entityName:"DistrictEntry")
		if let districtResults = managedObjectContext!.executeFetchRequest(districtFetch, error:nil) as? [DistrictEntry]{
			districts = Array<String>() // Clear old array
			for district in districtResults {
				if (currentRegion == district.region.region_name || currentRegion == nil) {
					districts.append(district.district_name)
				}
			}
		}
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "SegueDistrictsToHubs" {
			var destinationViewController = segue.destinationViewController as! ViewAddEventHub
			destinationViewController.currentRegion = currentRegion
			destinationViewController.currentDistrict = currentDistrict
			destinationViewController.currentHub = currentHub
			destinationViewController.currentAirport = currentAirport
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}