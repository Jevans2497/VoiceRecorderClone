//
//  VoiceRecorderCloneTests.swift
//  VoiceRecorderCloneTests
//
//  Created by Jonathan Evans on 5/3/19.
//  Copyright © 2019 Jon Evans. All rights reserved.
//

import XCTest
@testable import VoiceRecorderClone

class VoiceRecorderCloneTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRecordingInitializationSuccess() {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		let recordingPop = Recording.init(name: "Pop Song", timeCreated: "5:15AM", recordingLength: "00:08")
			XCTAssertNotNil(recordingPop)
		}

	func testRecordingInitializationFails() {
		let recordingRap = Recording.init(name: "", timeCreated: "6:43PM", recordingLength: "01:12")
		XCTAssertNil(recordingRap)
	}
	
	func testLoadSampleRecordingsSuccess() {
		let rctv: RecordingTableViewController = RecordingTableViewController.init()
		rctv.viewDidLoad()
		XCTAssert(rctv.recordings.count == 3)
	}
	

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
