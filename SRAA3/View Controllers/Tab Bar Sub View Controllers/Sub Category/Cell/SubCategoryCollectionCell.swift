//
//  SubCategoryCollectionCell.swift
//  SRAA3
//
//  Created by Apple on 21/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class SubCategoryCollectionCell: UICollectionViewCell {

    let kLabelVerticalInsets: CGFloat = 8.0
    let kLabelHorizontalInsets: CGFloat = 8.0
    
    @IBOutlet weak var descriptionLblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backV: UIView!
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var desLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Set what preferredMaxLayoutWidth you want
        desLbl.preferredMaxLayoutWidth = self.bounds.width - 2 * kLabelHorizontalInsets
         titleLbl.preferredMaxLayoutWidth = self.bounds.width - 2 * kLabelHorizontalInsets
    }
    
    func configCell(title: String, content: String, imageName: String) {
        titleLbl.text = title
        desLbl.text = content
          let imageUrl = URL(string: BASE_IMAGE_URL + KCategory_Api + "/" + imageName)
        imgV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_item"), options: .cacheMemoryOnly, completed: nil)
        backV.layer.borderWidth = 1
        backV.layer.borderColor = UIColor.hexToColor(hexString: "E7EAEF").cgColor
        imgV.layer.cornerRadius = 5
        imgV.clipsToBounds = true
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
}
