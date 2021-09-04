//
//  SelectionCollectionCell.swift
//  My MM
//
//  Created by Kishore on 22/02/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class SelectionCollectionCell: UICollectionViewCell {

    @IBOutlet weak var lblHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var selectionTypeLbl: UILabel!
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var backV: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
