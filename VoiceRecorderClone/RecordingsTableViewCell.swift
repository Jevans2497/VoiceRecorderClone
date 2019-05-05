//
//  RecordingsTableViewCell.swift
//  VoiceRecorderClone
//
//  Created by Jonathan Evans on 5/3/19.
//  Copyright © 2019 Jon Evans. All rights reserved.
//

import UIKit

class RecordingsTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var recordingNameLabel: UILabel!
    @IBOutlet weak var timeCreatedLabel: UILabel!
    @IBOutlet weak var recordingLengthLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
