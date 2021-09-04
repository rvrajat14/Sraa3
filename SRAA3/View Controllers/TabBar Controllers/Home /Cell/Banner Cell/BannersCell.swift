//
//  BannersCell.swift
//  SRAA3
//
//  Created by Apple on 19/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class BannersCell: UITableViewCell {

    @IBOutlet weak var carousel: iCarousel!
    
    @IBOutlet weak var pageControllerV: UIPageControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
