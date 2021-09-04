//
//  SelectionTypeTableCell.swift
//  My MM
//
//  Created by Kishore on 22/02/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class SelectionTypeTableCell: UITableViewCell {

   
    @IBOutlet weak var separatorV: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
