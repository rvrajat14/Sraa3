//
//  StoreDetailsTableViewCell.swift
//  SRAA3
//
//  Created by Apple on 21/08/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class StoreDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var ratedValueLbl: UILabel!
    @IBOutlet weak var ratedLbl: UILabel!
    @IBOutlet weak var storeInfoLbl: UILabel!
    @IBOutlet weak var storeNameLbl: UILabel!
    @IBOutlet weak var storeImgV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
