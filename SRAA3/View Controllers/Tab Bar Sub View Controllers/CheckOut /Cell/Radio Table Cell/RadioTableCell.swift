//
//  PopUPVCTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 28/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class RadioTableCell: UITableViewCell {

    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var variantsNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
