//
//  SubCategoryCell.swift
//  SRAA3
//
//  Created by Apple on 19/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class SubCategoryCell: UITableViewCell {

    @IBOutlet weak var backV: UIView!
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var desLbl: UILabel!
    @IBOutlet weak var btn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
