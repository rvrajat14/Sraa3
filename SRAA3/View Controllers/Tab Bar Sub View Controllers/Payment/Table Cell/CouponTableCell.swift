//
//  CouponTableCell.swift
//  My MM
//
//  Created by Kishore on 24/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class CouponTableCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var appliedView: UIView!
    @IBOutlet weak var appliedCouponLbl: UILabel!
    @IBOutlet weak var msgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var arrowImagV: UIImageView!
    @IBOutlet weak var applyCouponLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
