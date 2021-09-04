//
//  QuestionAndAnswerTableCell.swift
//  My MM
//
//  Created by Kishore on 25/02/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class FAQQuestionAndAnswerCell: UITableViewCell {

    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var answerLbl: UILabel!
    @IBOutlet weak var questionLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
