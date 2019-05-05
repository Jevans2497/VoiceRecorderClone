//
//  Recording.swift
//  VoiceRecorderClone
//
//  Created by Jonathan Evans on 5/3/19.
//  Copyright © 2019 Jon Evans. All rights reserved.
//

import UIKit

class Recording: NSObject {
	
	//MARK: Properties
	var name: String
	var timeCreated: String
	var recordingLength: String
	//Going to need to add a field for the actual audio file once I figure that out
	
	//MARK: Initialization
	init?(name: String, timeCreated: String, recordingLength: String) {
		guard !name.isEmpty else {
			return nil
		}
		
		self.name = name
		self.timeCreated = timeCreated
		self.recordingLength = recordingLength
	}

}
