//
//  LeaderboardCell.swift
//  FinalProject
//
//  Created by AJ Fite on 6/12/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit
import Firebase

class LeaderboardCell: UITableViewCell {
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    
    var userID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
