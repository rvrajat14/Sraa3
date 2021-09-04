//
//  SelectPickupTimeTableCell.swift
//  Dry Clean City
//
//  Created by Kishore on 20/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class SelectTimeTableCell: UITableViewCell {

    @IBOutlet weak var toTimeLbl: UILabel!
    @IBOutlet weak var fromTimeLbl: UILabel!
    @IBOutlet weak var selectDateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       //  toTimeLbl.layer.borderWidth = 1
       // toTimeLbl.layer.borderColor = UIColor.darkGray.cgColor
        
        fromTimeLbl.layer.borderWidth = 1
        fromTimeLbl.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
