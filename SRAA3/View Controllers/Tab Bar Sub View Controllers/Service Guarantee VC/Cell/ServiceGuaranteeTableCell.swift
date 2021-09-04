//
//  ServiceGuaranteeTableCell.swift
//  SRAA3
//
//  Created by Apple on 21/08/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ServiceGuaranteeTableCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
         
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
