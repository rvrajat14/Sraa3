//
//  OrderDeliveryAddressTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 07/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class OrderDeliveryAddressTableCell: UITableViewCell {

    @IBOutlet weak var mapButton: UIButton!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var deliveryAddressLbl: UILabel!
     
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
