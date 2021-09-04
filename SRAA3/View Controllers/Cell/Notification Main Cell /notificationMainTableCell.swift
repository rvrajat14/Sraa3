//
//  notificationMainTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 08/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class notificationMainTableCell: UITableViewCell {

    @IBOutlet weak var couponCodeLbl: UILabel!
    @IBOutlet weak var notificationTimeLbl: UILabel!
    @IBOutlet weak var notificationDescriptionLbl: UILabel!
    @IBOutlet weak var notificationTitleLbl: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
