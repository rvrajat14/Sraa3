//
//  AddImageCell.swift
//  SRAA3
//
//  Created by Apple on 16/02/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class AddImageCell: UITableViewCell {

    @IBOutlet weak var selectImgBtn: UIButton!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var imgV: UIImageView!
    
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var imgCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
