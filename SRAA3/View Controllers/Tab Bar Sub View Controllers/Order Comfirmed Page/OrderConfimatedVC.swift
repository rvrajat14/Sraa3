//
//  OrderConfimatedVC.swift
//  SRAA3
//
//  Created by Apple on 25/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class OrderConfimatedVC: UIViewController {

    var order_number = ""
    
    @IBOutlet weak var backToHomeButton: UIButton!
    @IBOutlet weak var viewDetailBtn: UIButton!
    @IBOutlet weak var orderNumberLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDetailBtn.layer.borderWidth = 0.5
        viewDetailBtn.layer.borderColor = UIColor.black.cgColor
        self.orderNumberLbl.text = "#" + CommonClass.checkForNull(string: order_number as AnyObject)
    }
    
    override func viewDidLayoutSubviews() {
        self.backToHomeButton.layer.cornerRadius = 10
        self.backToHomeButton.layer.masksToBounds = true
        Utilities.setButtonGradiantColor(button: self.backToHomeButton)
    }
    
    @IBAction func popVC(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name("OrderListUpdated"), object: nil)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func viewDetailBtnTaped(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderDetailsVC") as! OrderDetailsVC
        vc.order_id = order_number
        vc.isFromOrderPlace = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backToHomeBtnTaped(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name("OrderListUpdated"), object: nil)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
