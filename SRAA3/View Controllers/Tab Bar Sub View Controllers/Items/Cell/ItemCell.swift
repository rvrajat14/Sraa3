//
//  ItemCell.swift
//  SRAA3
//
//  Created by Apple on 21/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    
    @IBOutlet weak var oldPriceTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var oldPriceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemNotAvailableV: UIView!
    
    @IBOutlet weak var itemStatusView: UIView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var totalQuantityLbl: UILabel!
    @IBOutlet weak var quantityView: UIView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var oldPriceLbl: UILabel!
    @IBOutlet weak var itemDetailLbl: UILabel!
    @IBOutlet weak var itemPriceLbl: UILabel!
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var itemImageV: UIImageView!
    
    @IBOutlet weak var itemPriceLblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemNameLblHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        oldPriceLbl.text = ""
        addButton.layer.cornerRadius = 4
        addButton.layer.borderColor = UIColor(red: 245/255.0, green: 65/255.0, blue: 19/255.0, alpha: 1).cgColor
        addButton.layer.borderWidth = 1
        
    }
    
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
