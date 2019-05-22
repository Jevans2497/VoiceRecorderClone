//
//  HomeViewController.swift
//  VoiceRecorderClone
//
//  Created by Jonathan Evans on 5/7/19.
//  Copyright © 2019 Jon Evans. All rights reserved.
//

import UIKit
import AVFoundation
import os.log

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
	
	//MARK: Properties
	@IBOutlet weak var recordingsTableView: UITableView!
	@IBOutlet weak var buttonAndMeterView: ButtonAndMeterView!
	var recordButton = RecordButton()
	
	//Setup the recorder and the player.
	var voiceRecorder : AVAudioRecorder!
	var audioPlayer : AVAudioPlayer!
	var recordingSession: AVAudioSession!
	var dateCreated: Date!
	
	//This value is used to set the default name for the recordings and to keep track of the number of recordings
	var numOfRecordingsCreated = 0
	
	//fileName is used to keep track of where the actual audio files are stored
	var fileName = "Placeholder"
	
	//The array of recordings
	var recordings = [Recording]()
	
	//Used for saving and loading recordings data
	static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
	static let numOfRecordingsCreatedArchiveURL = DocumentsDirectory.appendingPathComponent("numOfRecordingsCreated")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		//Set the title of the nav bar to Voice Memos
		self.navigationItem.title = "Voice Memos"
		
		//Set self as the delegate for the tableview so that the functions below are actually called.
		recordingsTableView.delegate = self
		recordingsTableView.dataSource = self
		
		setupRecordingButton()
		
		//Load sample data - primarily used to make sure everything works properly
		//loadSampleRecordings()
		
		// Load any saved recordings
		if let savedRecordingsAndSavedNums = loadRecordingsAndNumOfRecordingsCreated() {
			recordings += savedRecordingsAndSavedNums.0!
			numOfRecordingsCreated = savedRecordingsAndSavedNums.1
		}
		
		//Set the filename to the default value. Should start at "Recording_1.m4a"
		fileName = getDefaultFileAppendName()
		
		self.startAudioSession()
	}
	
	// MARK: - Table view data source
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return recordings.count
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let filenameOfRecordingToPlay = getCacheDirectory().appendingPathComponent(recordings[indexPath.row].name)
		preparePlayer(filenameOfRecordingToPlay: filenameOfRecordingToPlay)
		audioPlayer.play()
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
	
	/*
	This method is called when the button and meter view is tapped. It animates it up to the forefront of the
	screen and allows the user to see the button better and to see the meter.
	*/
	
	//MARK: Setup for Recording
	fileprivate func setupRecordingButton() {
		//Make sure when the button is created, it is not recording
		recordButton.isRecording = false
		//Add the target so that the button calls handleRecording on touchUpInside
		recordButton.addTarget(self, action: #selector(handleRecording(_:)), for: .touchUpInside)
		//Add the button to the buttonAndMeterView on the bottom of the screen
		buttonAndMeterView.addSubview(recordButton)
		recordButton.translatesAutoresizingMaskIntoConstraints = false
		//How far from the bottom of the view the button is
		recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
		//Center the button
		recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		//The width of the button
		recordButton.widthAnchor.constraint(equalToConstant: 65).isActive = true
		//The height of the button
		recordButton.heightAnchor.constraint(equalToConstant: 65 ).isActive = true
	}
	
	/*
	Establishes the ability to record audio.
	*/
	func startAudioSession(){
		recordingSession = AVAudioSession.sharedInstance()
		
		do {
			try recordingSession.setCategory(.playAndRecord)
			try recordingSession.setActive(true)
			recordingSession.requestRecordPermission() { [unowned self] allowed in
				DispatchQueue.main.async {
					if allowed {
						self.setupRecorder()
					} else {
						fatalError("Failed to get permission")
					}
				}
			}
		} catch {
			fatalError("Failed to setup recorder")
		}
	}
	
	func setupRecorder(){
		let recordSettings = [AVFormatIDKey : kAudioFormatAppleLossless,
							  AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
							  AVEncoderBitRateKey : 320000,
							  AVNumberOfChannelsKey : 2,
							  AVSampleRateKey : 44100.0 ] as [String : Any]
		do {
			voiceRecorder = try AVAudioRecorder(url: getFileURL(), settings: recordSettings)
			voiceRecorder.delegate = self
			voiceRecorder.prepareToRecord()
		}
		catch {
			print("\(error)")
		}
	}
	
	
	
	func preparePlayer(filenameOfRecordingToPlay: URL){
		do {
			audioPlayer =  try AVAudioPlayer(contentsOf: filenameOfRecordingToPlay)
			audioPlayer.delegate = self
			audioPlayer.prepareToPlay()
			audioPlayer.volume = 1.0
		} catch {
			print("Audio Play Failed ")
		}
	}
	
	//MARK: Handlers
	/*
	This is where the button's animation is handle when it is pressed.
	*/
	@objc func handleRecording(_ sender: RecordButton) {
		if recordButton.isRecording {
			handleButtonAndMeterViewSelected()
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				//				self.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.bounds.width, height: -300)
				self.view.layoutIfNeeded()
			}, completion: nil)
		} else {
			handleButtonAndMeterViewSelected()
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				//				self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 150)
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
		RecordOrStop(recordButton)
	}
	
	@objc func handleButtonAndMeterViewSelected() {
		if let window = UIApplication.shared.keyWindow {
			
			let windowHeight = window.frame.height
			
			//If the view is already up, put it down to 1/7th the size of the total window. Otherwise, set it to half (1/3) the
			//size of the window.
			var height: CGFloat
			
			//If the view is down, bring it up and show the nameLabel, timeLabel, and Meter. Otherwise, put it down and hide the views.
			if buttonAndMeterView.frame.height < windowHeight / 3 {
				height = windowHeight / 3
				buttonAndMeterView.showOtherViews()
			} else {
				height = windowHeight / 7
				buttonAndMeterView.hideOtherViews()
			}
			
			let y = window.frame.height - height
			
			UIView.animate(withDuration: 0.5, animations: {
				self.buttonAndMeterView.frame = CGRect(x: 0, y: y, width: self.buttonAndMeterView.frame.width, height: height)
			})
		}
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destination.
	// Pass the selected object to the new view controller.
	}
	*/
	
	//MARK: Button function
	@IBAction func RecordOrStop(_ sender: UIButton) {
		if recordButton.isRecording {
			voiceRecorder.record()
			dateCreated = Date()
		} else{
			voiceRecorder.stop()
			//Determine how long the recording was.
			let dateDifference = Date()
			//Save the recording as a new Recording in the tableview.
			addRecordingToTableView(recordingLength: dateDifference.timeIntervalSince(dateCreated))
			//Update fileName so that the next recording will have it's name be the next default value
			fileName = getDefaultFileAppendName()
			//Call setup recorder so that the recorder uses the new filename
			setupRecorder()
		}
	}
	
	//MARK: Private Methods
	private func addRecordingToTableView(recordingLength: TimeInterval) {
		let timeCreated = getTimeCreated()
		//Format the recordingLength so that it can appear in "00:00:00" format in the RecordingTableViewCell
		let recordingLengthFormatted = secondsToHoursMinutesSeconds(seconds: Int(recordingLength))
		//Create the newRecording to add to the tableview
		let newRecording = Recording(name: fileName, timeCreated: timeCreated, recordingLength: recordingLengthFormatted)
		//Tell the TableView where to add the new cell
		let newIndexPath = IndexPath(row: recordings.count, section: 0)
		
		if newRecording != nil {
			recordings.append(newRecording!)
			recordingsTableView.insertRows(at: [newIndexPath], with: .automatic)
		}
		//Save the recordings so that they persist throughout uses.
		saveRecordings()
	}
	
	private func getTimeCreated() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "hh:mm a" // "a" prints "pm" or "am"
		let hourString = formatter.string(from: Date()) // "12 AM"
		return hourString
	}
	
	private func secondsToHoursMinutesSeconds (seconds : Int) -> (String) {
		var result = ""
		let hours = seconds / 3600
		let minutes = (seconds % 3600) / 60
		let seconds = (seconds % 3600) % 60
		
		if hours > 0 {
			result.append("\(String(hours)):")
		}
		
		if minutes < 10 {
			result.append("0")
			result.append("\(String(minutes)):")
		} else {
			result.append("\(String(minutes)):")
		}
		
		if seconds < 10 {
			result.append("0")
			result.append(String(seconds))
		} else {
			result.append(String(seconds))
		}
		
		return result
	}
	
	
	/*
	This method allows every recording to have a default name. The user can still rename it.
	Also, numOfRecordingsCreated is always incremented since even if the user creates 100 named
	recordings, we don't want the name to be Recording_1, we want Recording_101
	*/
	private func getDefaultFileAppendName() -> String {
		numOfRecordingsCreated += 1
		let defaultName = "Recording_\(numOfRecordingsCreated).m4a"
		return defaultName
	}
	
	private func getCacheDirectory() -> URL {
		let fm = FileManager.default
		let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil,
								  create: false)
		return docsurl
	}
	
	/*
	Get the location where the soundfile is stored
	*/
	private func getFileURL() -> URL{
		let path  = getCacheDirectory()
		let filePath = path.appendingPathComponent("\(fileName)")
		return filePath
	}
	
	/*
	Save the recordings so that they appear even after exiting the app the next time the user returns.
	*/
	private func saveRecordings() {
		
		let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(recordings, toFile: Recording.ArchiveURL.path)
		let numOfRecordingsCreatedSave = NSKeyedArchiver.archiveRootObject(numOfRecordingsCreated, toFile: HomeViewController.numOfRecordingsCreatedArchiveURL.path)
		
		if isSuccessfulSave && numOfRecordingsCreatedSave {
			os_log("Recordings and the number of recordings successfully saved.", log: OSLog.default, type: .debug)
		} else {
			os_log("Failed to save Recordings and the number of recordings value...", log: OSLog.default, type: .error)
		}
	}
	
	private func loadRecordingsAndNumOfRecordingsCreated() -> ([Recording]?, Int)? {
		return (NSKeyedUnarchiver.unarchiveObject(withFile: Recording.ArchiveURL.path) as? [Recording],
				NSKeyedUnarchiver.unarchiveObject(withFile: HomeViewController.numOfRecordingsCreatedArchiveURL.path) as! Int)
	}
	
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
