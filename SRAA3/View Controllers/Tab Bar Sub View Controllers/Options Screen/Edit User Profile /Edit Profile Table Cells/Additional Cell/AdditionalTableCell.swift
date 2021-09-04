//
//  AdditionalTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 06/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class AdditionalTableCell: UITableViewCell {

    @IBOutlet weak var subTitleLbl: UILabel!
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
