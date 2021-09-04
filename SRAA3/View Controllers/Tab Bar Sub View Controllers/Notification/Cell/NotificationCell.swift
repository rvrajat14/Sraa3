//
//  NotificationCell.swift
//  SRAA3
//
//  Created by Apple on 22/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(data:NSDictionary)  {
        titleLbl.text = CommonClass.checkForNull(string: data["title"] as AnyObject)
         descriptionLbl.text = CommonClass.checkForNull(string: data["sub_title"] as AnyObject)
         timeLbl.text = CommonClass.checkForNull(string: data["time"] as AnyObject)
        
    }
    
}
