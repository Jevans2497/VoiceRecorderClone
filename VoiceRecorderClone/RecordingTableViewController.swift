//
//  RecordingTableViewController.swift
//  VoiceRecorderClone
//
//  Created by Jonathan Evans on 5/3/19.
//  Copyright © 2019 Jon Evans. All rights reserved.
//

import UIKit

class RecordingTableViewController: UITableViewController {
	
	//MARK: Properties
	var recordings = [Recording]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		//Set the title of the nav bar to Voice Memos
		self.navigationItem.title = "Voice Memos"
				
		loadSampleRecordings()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return recordings.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "RecordingTableViewCell"
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecordingsTableViewCell else {
			fatalError("The dequeued cell is not an instance of RecordingTableViewCell.")
		}
		
		// Configure the cell...
		let recording = recordings[indexPath.row]
		cell.recordingNameLabel.text = recording.name
		cell.timeCreatedLabel.text = recording.timeCreated
		cell.recordingLengthLabel.text = recording.recordingLength
		
		return cell
	}
	
	/*
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
	// Return false if you do not want the specified item to be editable.
	return true
	}
	*/
	
	/*
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
	if editingStyle == .delete {
	// Delete the row from the data source
	tableView.deleteRows(at: [indexPath], with: .fade)
	} else if editingStyle == .insert {
	// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}
	}
	*/
	
	/*
	// Override to support rearranging the table view.
	override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
	
	}
	*/
	
	/*
	// Override to support conditional rearranging of the table view.
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
	// Return false if you do not want the item to be re-orderable.
	return true
	}
	*/
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destination.
	// Pass the selected object to the new view controller.
	}
	*/
	
	//MARK: Private Methods
	/*
	This methods loads sample recordings into the TableView
	*/
	private func loadSampleRecordings() {
		let name1 = "Country song"
		let name2 = "Rap song"
		let name3 = "Pop song"
		
		let timeCreated1 = "4:15 PM"
		let timeCreated2 = "5:45 AM"
		let timeCreated3 = "12:13 PM"
		
		let recordingLength1 = "00:05"
		let recordingLength2 = "10:27"
		let recordingLength3 = "7:35"
		
		guard let recording1 = Recording(name: name1, timeCreated: timeCreated1, recordingLength: recordingLength1) else {
			fatalError("Unable to initialize sample recording 1")
		}
		
		guard let recording2 = Recording(name: name2, timeCreated: timeCreated2, recordingLength: recordingLength2) else {
			fatalError("Unable to initialize sample recording 2")
		}
		
		guard let recording3 = Recording(name: name3, timeCreated: timeCreated3, recordingLength: recordingLength3) else {
			fatalError("Unable to initialize sample recording 3")
		}
		
		recordings += [recording1, recording2, recording3]
	}
}
