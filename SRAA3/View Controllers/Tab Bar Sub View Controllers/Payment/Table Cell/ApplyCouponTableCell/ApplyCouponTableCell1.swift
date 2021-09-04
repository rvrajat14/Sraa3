//
//  ApplyCouponTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 24/07/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class ApplyCouponTableCell1: UITableViewCell {

    @IBOutlet weak var offersListButton: UIButton!
    
    @IBOutlet weak var couponButton: UIButton!
    
   
    @IBOutlet weak var couponLbl: UILabel!
   
   
    @IBOutlet weak var couponView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
