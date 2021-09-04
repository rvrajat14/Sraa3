//
//  SelectionCell.swift
//  SRAA3
//
//  Created by Apple on 22/02/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class SelectionCell: UITableViewCell {

    @IBOutlet weak var checkBoxBtn: UIButton!
    @IBOutlet weak var checkBoxImgV: UIImageView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var backV: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
