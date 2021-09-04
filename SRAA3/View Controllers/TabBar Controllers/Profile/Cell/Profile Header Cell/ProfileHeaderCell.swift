//
//  ProfileHeaderCell.swift
//  SRAA3
//
//  Created by Apple on 22/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UITableViewCell {
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var profileImgV: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImgV.layer.cornerRadius = self.profileImgV.frame.size.width/2
        self.profileImgV.layer.masksToBounds = true
        editBtn.layer.borderWidth = 0.5
        editBtn.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
