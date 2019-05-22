//
//  Recording.swift
//  VoiceRecorderClone
//
//  Created by Jonathan Evans on 5/3/19.
//  Copyright © 2019 Jon Evans. All rights reserved.
//

import UIKit

class Recording: NSObject, NSCoding {
	
	//MARK: Properties
	var name: String
	var timeCreated: String
	var recordingLength: String

	//MARK: Archiving Paths
	static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
	static let ArchiveURL = DocumentsDirectory.appendingPathComponent("recordings")
	
	//MARK: Types
	struct PropertyKey {
		static let name = "name"
		static let timeCreated = "timeCreated"
		static let recordingLength = "recordingLength"
	}
	
	//MARK: Initialization
	init?(name: String, timeCreated: String, recordingLength: String) {
		guard !name.isEmpty else {
			return nil
		}
		
		self.name = name
		self.timeCreated = timeCreated
		self.recordingLength = recordingLength
	}
	
	//MARK: NSCoding
	func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: PropertyKey.name)
		aCoder.encode(timeCreated, forKey: PropertyKey.timeCreated)
		aCoder.encode(recordingLength, forKey: PropertyKey.recordingLength)
	}
	
	required convenience init?(coder aDecoder: NSCoder) {
		// The name is required. If we cannot decode a name string, the initializer should fail.
		
		let name = aDecoder.decodeObject(forKey: PropertyKey.name) as! String
		let timeCreated = aDecoder.decodeObject(forKey: PropertyKey.timeCreated) as! String
		let recordingLength = aDecoder.decodeObject(forKey: PropertyKey.recordingLength) as! String
		
		// Must call designated initializer.
		self.init(name: name, timeCreated: timeCreated, recordingLength: recordingLength)
	}
}
