//
//  OrderItemsTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 07/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class OrderItemsTableCell: UITableViewCell {

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
  
    @IBOutlet weak var desLbl: UILabel!
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var numberOfItemsLbl: UILabel!
   
    @IBOutlet weak var imgV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
