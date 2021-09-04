//
//  PaymentSummaryTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 24/07/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class PaymentSummaryTableCell: UITableViewCell {

    @IBOutlet weak var detailsButton: UIButton!
    
    @IBOutlet weak var downImgV: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var valueLbl: UILabel!
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
