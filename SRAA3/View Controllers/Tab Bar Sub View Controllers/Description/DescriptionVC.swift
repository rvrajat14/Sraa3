//
//  DescriptionVC.swift
//  SRAA3
//
//  Created by Apple on 26/02/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

protocol PopBackVCDelegate{
    func popBackVC()
}

class DescriptionVC: UIViewController {

    var form_id = ""
    var category_title = ""
    var descriptionStr = ""
    var category_id = ""
    var isFromQuesAnsVC = false
    var popBackVCDelegate : PopBackVCDelegate!
    var isItemsAvailable = false
    
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var txtV: UITextView!
    @IBOutlet weak var backV: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // Utilities.shadowLayer1(viewLayer: self.backV.layer, shadow: true)
       // self.titleLbl.text = category_title
        self.titleLbl.text = "Price and Terms"
      /*  let data = Data(descriptionStr.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            self.txtV.attributedText = attributedString
            self.txtV.font = UIFont(name: KMainFont, size: 14)
        }*/
        let modifiedFont = NSString(format:"<span style=\"font-family: \(KMainFont); font-size: 15\">%@</span>" as NSString, descriptionStr) as String
        
        let theAttributedString = try! NSAttributedString(data: modifiedFont.data(using: String.Encoding(rawValue: String.Encoding.unicode.rawValue), allowLossyConversion: false)!,options: [.documentType: NSAttributedString.DocumentType.html],documentAttributes: nil)
        
        self.txtV.attributedText = theAttributedString
        
        
     //   self.txtV.text = descriptionStr
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        self.proceedButton.layer.cornerRadius = 10
        self.proceedButton.layer.masksToBounds = true
        Utilities.setButtonGradiantColor(button: self.proceedButton)
    }
    
    @IBAction func popVC(_ sender: Any){
        self.navigationController?.popViewController(animated: false)
        if !isItemsAvailable{
            self.popBackVCDelegate.popBackVC()
        }
    }
    
    @IBAction func cancelBtnTaped(_ sender: Any) {
        
        questionAnswerCartArray = NSMutableArray.init()
        NotificationCenter.default.post(name: Notification.Name("orderCancel"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func proceedBtnTaped(_ sender: Any) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckOutVC") as! CheckOutVC
//        vc.category_id = self.category_id
//        self.navigationController?.pushViewController(vc, animated: false)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        vc.isFromQuesAnsVC = isFromQuesAnsVC
        vc.category_id = self.category_id
        vc.category_title = self.category_title
        vc.isItemsAvailable = self.isItemsAvailable
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
}
