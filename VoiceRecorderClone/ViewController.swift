//
//  ViewController.swift
//  VoiceRecorderClone
//
//  Created by Jonathan Evans on 5/3/19.
//  Copyright © 2019 Jon Evans. All rights reserved.
//
// This code mostly came from https://www.youtube.com/watch?v=wgP-wyKuA5s

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
	
	//Create the Recording button
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var PlayButton: UIButton!
	
	//Setup the AVFoundation elements to handle recording and playback
	var voiceRecorder : AVAudioRecorder!
	var audioPlayer : AVAudioPlayer!
	var recordingSession: AVAudioSession!
	
	var fileName = "audio_file.m4a"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.startAudioSession()
	}
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
	
	func getCacheDirectory() -> URL {
		let fm = FileManager.default
		let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil,
								  create: false)
		return docsurl
	}
	func getFileURL() -> URL{
		let path  = getCacheDirectory()
		let filePath = path.appendingPathComponent("\(fileName)")
		return filePath
	}
	
	@IBAction func Record(_ sender: UIButton) {
		if sender.titleLabel?.text == "Record"{
			voiceRecorder.record()
			sender.setTitle("Stop", for: .normal)
		} else{
			voiceRecorder.stop()
			sender.setTitle("Record", for: .normal)
		}
	}
	
	func preparePlayer(){
		do {
			audioPlayer =  try AVAudioPlayer(contentsOf: getFileURL())
			audioPlayer.delegate = self
			audioPlayer.prepareToPlay()
			audioPlayer.volume = 1.0
		} catch {
			print("Audio Record Failed ")
		}
	}
	
	@IBAction func PlayRecordedAudio(_ sender: UIButton) {
		if sender.titleLabel?.text == "Play" {
			sender.setTitle("Stop", for: .normal)
			preparePlayer()
			audioPlayer.play()
		} else{
			audioPlayer.stop()
			sender.setTitle("Play", for: .normal)
		}
	}
}
