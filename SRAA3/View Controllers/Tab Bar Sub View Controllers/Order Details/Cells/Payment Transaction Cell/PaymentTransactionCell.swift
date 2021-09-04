//
//  PaymentTransactionCell.swift
//  SRAA3
//
//  Created by Apple on 28/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class PaymentTransactionCell: UITableViewCell {

    @IBOutlet weak var selectImgBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var amountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
