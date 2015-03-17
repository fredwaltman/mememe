//
//  MemeTableViewCell.swift
//  MemeMe
//
//  Created by Fred Waltman on 3/14/15.
//  Copyright (c) 2015 Fred Waltman. All rights reserved.
//

import UIKit

class MemeTableViewCell: UITableViewCell {

    @IBOutlet weak var cellText: UILabel!    
    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
