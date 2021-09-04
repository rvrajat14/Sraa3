//
//  DebitCreditCardVC.swift
//  My MM
//
//  Created by Kishore on 23/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CCValidator

class DebitCreditCardVC: UIViewController {
    
    var cardName = ""
    
    @IBOutlet weak var serverErrorView: UIView!
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var userNameTxtField: UITextField!
    
    @IBOutlet weak var confirmDetailsButton: UIButton!
    @IBOutlet weak var cvvTxtField: UITextField!
    @IBOutlet weak var expiryYearTxtField: UITextField!
    @IBOutlet weak var expiryMonthTxtField: UITextField!
    @IBOutlet weak var cardImgV: UIImageView!
    @IBOutlet weak var cardNumberTxtField: UITextField!
    
    @IBAction func confirmDetailsButton(_ sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardNumberTxtField.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMatchedPattern(pattern:String) -> (card_name:String,card_image:UIImage) {
    
      let type = CCValidator.typeCheckingPrefixOnly(creditCardNumber: pattern)
        
        switch type {
        case .Visa:
            return ("Visa",#imageLiteral(resourceName: "coupon_box"))
          
        case .AmericanExpress:
            return ("American Express",#imageLiteral(resourceName: "coupon_box"))
          
        case .MasterCard:
            return ("MasterCard",#imageLiteral(resourceName: "coupon_box"))
            
        case .DinersClub:
            return ("Diners Club",#imageLiteral(resourceName: "coupon_box"))
            
        case .Discover:
           return ("Discover",#imageLiteral(resourceName: "coupon_box"))
            
        case .JCB:
           return ("JCB",#imageLiteral(resourceName: "coupon_box"))
            
        default:
            return ("",UIImage.init())
        }
    }
}

extension DebitCreditCardVC : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        if textField.tag == 1 {
            
            if (textField.text?.count)! > 0 || (textField.text?.count)! < 18
            {
              let(name,image) = getMatchedPattern(pattern: newString)
                if !name.isEmpty
                {
                    self.cardImgV.isHidden = false
                    cardName = name
                    self.cardImgV.image = image
                }
               else
                {
                    self.cardImgV.isHidden = true
                }
                return true
            }
        }
        return false
    }
}
