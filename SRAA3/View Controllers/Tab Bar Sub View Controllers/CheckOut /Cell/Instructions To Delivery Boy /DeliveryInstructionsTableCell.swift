//
//  DeliveryInstructionsTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 05/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import IQKeyboardManager
class DeliveryInstructionsTableCell: UITableViewCell {

    @IBOutlet weak var instructionTxtView: IQTextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
