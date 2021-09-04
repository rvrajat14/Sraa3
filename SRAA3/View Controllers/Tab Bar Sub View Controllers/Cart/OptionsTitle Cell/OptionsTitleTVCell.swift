//
//  OptionsTitleTVCell.swift
//  SRAA3
//
//  Created by IOS on 09/11/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class OptionsTitleTVCell: UITableViewCell {

    @IBOutlet weak var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var titleView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
