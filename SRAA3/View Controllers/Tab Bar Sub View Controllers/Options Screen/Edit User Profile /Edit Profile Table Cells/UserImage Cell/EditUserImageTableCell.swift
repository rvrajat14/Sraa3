//
//  EditUserImageTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 06/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class EditUserImageTableCell: UITableViewCell {

    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
