//
//  WalletHistoryCell.swift
//  SRAA3
//
//  Created by Apple on 24/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class WalletHistoryCell: UITableViewCell {

    @IBOutlet weak var separatorLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var pointsLbl: UILabel!
    @IBOutlet weak var arrowImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
