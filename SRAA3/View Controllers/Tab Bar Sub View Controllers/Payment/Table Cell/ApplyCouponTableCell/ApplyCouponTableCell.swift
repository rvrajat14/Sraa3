//
//  ApplyCouponTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 24/07/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class ApplyCouponTableCell: UITableViewCell {

    @IBOutlet weak var couponCrossButton: UIButton!
    @IBOutlet weak var pointsCrossButton: UIButton!
    @IBOutlet weak var couponCodeTxtField: UITextField!
    @IBOutlet weak var couponMainBackV: UIView!
    //@IBOutlet weak var offersListButton: UIButton!
    @IBOutlet weak var couponMainButton: UIButton!
    @IBOutlet weak var couponBottomLbl: UILabel!
    
    @IBOutlet weak var pointsBottomLbl: UILabel!
    @IBOutlet weak var pointsMainButton: UIButton!
    @IBOutlet weak var pointsButton: UIButton!
    @IBOutlet weak var pointsLbl: UILabel!
    @IBOutlet weak var pointBackV: UIView!
    @IBOutlet weak var couponButton: UIButton!
    
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
