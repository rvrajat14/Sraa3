//
//  SubCategoryTableCell.swift
//  SRAA3
//
//  Created by Apple on 08/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class SubCategoryTableCell: UITableViewCell {

    @IBOutlet weak var backV: UIView!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imgV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    func configCell(title: String, content: String, imageName: String) {
        titleLbl.text = title
        subTitleLbl.text = ""
        let imageUrl = URL(string: BASE_IMAGE_URL + KCategory_Api + "/" + imageName)
        imgV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .cacheMemoryOnly, completed: nil)
        backV.layer.borderWidth = 1
        backV.layer.borderColor = UIColor.hexToColor(hexString: "E7EAEF").cgColor
        imgV.layer.cornerRadius = 5
        imgV.clipsToBounds = true
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
}
