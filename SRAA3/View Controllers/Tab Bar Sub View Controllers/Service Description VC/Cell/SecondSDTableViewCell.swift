//
//  SecondSDTableViewCell.swift
//  SRAA3
//
//  Created by Apple on 23/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class SecondSDTableViewCell: UITableViewCell {

     @IBOutlet weak var titleLbl: UILabel!
     @IBOutlet weak var subtitleLbl: UILabel!
     @IBOutlet weak var imgV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
