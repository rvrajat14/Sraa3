//
//  DeliveryAddressCell.swift
//  TaxiApp
//
//  Created by Apple on 05/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class DeliveryAddressCell: UITableViewCell {

    @IBOutlet weak var setDefaultCheckBoxButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
