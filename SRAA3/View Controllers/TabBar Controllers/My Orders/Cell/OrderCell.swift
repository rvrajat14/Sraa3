//
//  OrderCell.swift
//  SRAA3
//
//  Created by Apple on 23/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {

    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var orderStatusButton: UIButton!
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var orderNumberLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
