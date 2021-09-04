//
//  OrderSummaryTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 07/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class OrderSummaryTableCell: UITableViewCell {
 
    @IBOutlet weak var titleTopConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var titleLblHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var value1Lbl: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
