//
//  PromoCodeTableCell.swift
//  My MM
//
//  Created by Kishore on 26/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class PromoCodeTableCell: UITableViewCell {

    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var offerNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
