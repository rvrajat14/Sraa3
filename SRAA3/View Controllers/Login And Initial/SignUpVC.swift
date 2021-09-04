//
//  SignUpVC.swift
//  TaxiApp
//
//  Created by Apple on 10/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController , UITextFieldDelegate {
    
    var otp = ""
    var facebookDic = NSDictionary()
    var googleDic = NSDictionary()
    var type = ""
    var facebookImage = ""
    @IBOutlet weak var firstNameTxtF: HoshiTextField!
    @IBOutlet weak var lastNameTxtF: HoshiTextField!
    @IBOutlet weak var emailTxtF: HoshiTextField!
    @IBOutlet weak var mobileTxtF: HoshiTextField!
    @IBOutlet weak var passwordTxtF: HoshiTextField!
    @IBOutlet weak var confirmPasswordTxtF: HoshiTextField!
    
    @IBOutlet weak var referalCodeTxtF: HoshiTextField!
    @IBOutlet weak var confirmPswdBtn: UIButton!
    @IBOutlet weak var pswdBtn: UIButton!
    
    @IBOutlet weak var checkboxBtn: UIButton!
    var termsAndConBool = false
    var tap : UITapGestureRecognizer!
    @IBOutlet weak var termsAndConLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        print("type sss: \(type)")
        print("fbResult sss: \(self.facebookDic)")
        
        let htmlString = "<font color=#AAAAAA>I agreed with </font> <b><font color=#F04030>Terms and Conditions.</font></b>"
        
        let data = Data(htmlString.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            termsAndConLbl.attributedText = attributedString
            termsAndConLbl.font = UIFont(name: KMainFont, size: 14)
        }
        tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(tap:)))
        termsAndConLbl.addGestureRecognizer(tap)
        termsAndConLbl.isUserInteractionEnabled = true
        self.emailTxtF.isUserInteractionEnabled = true
       // NotificationCenter.default.addObserver(self, selector: #selector(signupOTPNotificationAcion(notification:)), name: NSNotification.Name.init("signUpOTPNotification"), object: nil)
        
        if type == "facebook" {
            self.firstNameTxtF.text = CommonClass.checkForNull(string: self.facebookDic.value(forKey: "first_name")as AnyObject)
            self.lastNameTxtF.text = CommonClass.checkForNull(string: self.facebookDic.value(forKey: "last_name")as AnyObject)
            self.emailTxtF.text = CommonClass.checkForNull(string: self.facebookDic.value(forKey: "email")as AnyObject)
            self.emailTxtF.isUserInteractionEnabled = false
            let picDic = (self.facebookDic.value(forKey: "picture")as! NSDictionary)
            
            if (picDic != nil)
            {
                let dataDic = (picDic.value(forKey: "data")as! NSDictionary)
                 facebookImage = dataDic.value(forKey: "url")as! String
            }
           
        }
        
        else if(type == "gmail")
        {
            self.firstNameTxtF.text = CommonClass.checkForNull(string: self.googleDic.value(forKey: "first_name")as AnyObject)
            self.lastNameTxtF.text = CommonClass.checkForNull(string: self.googleDic.value(forKey: "last_name")as AnyObject)
            self.emailTxtF.text = CommonClass.checkForNull(string: self.googleDic.value(forKey: "email")as AnyObject)
            self.emailTxtF.isUserInteractionEnabled = false
        }
        if #available(iOS 12.0, *) {
            passwordTxtF.textContentType = .oneTimeCode
        }
    }
    
   /* @objc func signupOTPNotificationAcion(notification:Notification)
    {
        print(notification)
        if let userInfo = notification.userInfo {
            if let OTP = userInfo["otp"] as? String
            {
                otp = OTP
                self.verifyOTPAPI(email: self.emailTxtF.text!, otp: otp)
            }
        }
    }
       */
    @IBAction func popVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmPasswordBtnTaped(_ sender: Any) {
        if (confirmPswdBtn.currentImage == #imageLiteral(resourceName: "closeEyeIcon")) {
            confirmPasswordTxtF.isSecureTextEntry = false
            confirmPswdBtn.setImage(#imageLiteral(resourceName: "openEyesIcon"), for: .normal)
        }
        else
        {
            confirmPasswordTxtF.isSecureTextEntry = true
            confirmPswdBtn.setImage(#imageLiteral(resourceName: "closeEyeIcon"), for: .normal)
        }
    }
    
    @IBAction func passwordBtnTaped(_ sender: Any) {
        
        if (pswdBtn.currentImage == #imageLiteral(resourceName: "closeEyeIcon")) {
            passwordTxtF.isSecureTextEntry = false
            pswdBtn.setImage(#imageLiteral(resourceName: "openEyesIcon"), for: .normal)
        }
        else
        {
            passwordTxtF.isSecureTextEntry = true
            pswdBtn.setImage(#imageLiteral(resourceName: "closeEyeIcon"), for: .normal)
        }
        
    }
    @objc func tapLabel(tap: UITapGestureRecognizer) {
       
        let substring = "Terms and Conditions."
        guard let range = termsAndConLbl.text!.range(of: substring)?.nsRange else {
            return
        }
        if tap.didTapAttributedTextInLabel(label: termsAndConLbl, inRange: range) {
            // Substring tapped
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionsVC") as! TermsAndConditionsVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func loginBtnTaped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpBtnTaped(_ sender: Any) {
        if (firstNameTxtF.text == "") {
            COMMON_ALERT.showAlert(title:  AppMessages.enterFirstName.rawValue, msg: "", onView: self)
        }
        else if (self.firstNameTxtF.text!.count < 3)
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidFirstName.rawValue , msg: "", onView: self)
        }
      /*  else if (lastNameTxtF.text == "")
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterLastName.rawValue, msg: "", onView: self)
        } */
        else if (emailTxtF.text == "") {
            COMMON_ALERT.showAlert(title: AppMessages.enterSignUpEmail.rawValue, msg: "", onView: self)
        }
        else if !self.emailTxtF.text!.isValidEmail()
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidEmail.rawValue, msg: "", onView: self)
        }
        else if (mobileTxtF.text == "")
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterSignUpMobileNo.rawValue, msg: "", onView: self)
        }
            
        else if !(CommonClass.isValidPhone(phone: mobileTxtF.text!))
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidMobileNo.rawValue, msg: "", onView: self)
        }
        else if (passwordTxtF.text == "")
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterLoginPassword.rawValue, msg: "", onView: self)
        }
        /*else if !self.passwordTxtF.text!.isValidSecurePassword()
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidPassword.rawValue, msg: "", onView: self)
        }*/
        else if ((passwordTxtF.text?.count)! < 5)
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidPassword.rawValue, msg: "", onView: self)
        }
        else if self.confirmPasswordTxtF.text! != self.passwordTxtF.text!
        {
            COMMON_ALERT.showAlert(title: AppMessages.passwordDosntMatch.rawValue, msg: "", onView: self)
        }
        else if !termsAndConBool
        {
            COMMON_ALERT.showAlert(title: AppMessages.acceptTermsAndConditions.rawValue, msg: "", onView: self)
        }
        else
        {
            self.generateEmailAPI(email: self.emailTxtF.text!)
            
          //  let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainVC
          //  self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func checkBoxTaped(_ sender: Any) {
        if termsAndConBool == true {
            termsAndConBool = false
            self.checkboxBtn.setImage(#imageLiteral(resourceName: "check-box-empty"), for: .normal)
        }
        else{
            termsAndConBool = true
            self.checkboxBtn.setImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        if textField == firstNameTxtF {
            
            if firstNameTxtF.text?.count == 30 {
                if (string == "") {
                    print("Backspace")
                    return true
                }
                return false
            }
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_ONLY_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered)
        }
        
        if textField == lastNameTxtF {
            if lastNameTxtF.text?.count == 30 {
                if (string == "") {
                    print("Backspace")
                    return true
                }
                return false
            }
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_ONLY_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered)
        }
        if textField == mobileTxtF {
            
            if mobileTxtF.text?.count == 15 {
                if (string == "") {
                    print("Backspace")
                    return true
                }
                return false
            }
            return true
        }
        if textField == passwordTxtF {
            
            if passwordTxtF.text?.count == 15 {
                if (string == "") {
                    print("Backspace")
                    return true
                }
                return false
            }
            return true
        }
        if textField == confirmPasswordTxtF {
            
            if confirmPasswordTxtF.text?.count == 15 {
                if (string == "") {
                    print("Backspace")
                    return true
                }
                return false
            }
            return true
        }
        return true
    }
    
    func generateEmailAPI(email:String)  {
        
      //  let params = ["email": email , "phone":self.mobileTxtF.text!]
        let api_name = KUsers_Api + "/otp/generate"
        
        let params = ["first_name":self.firstNameTxtF.text!,"last_name":self.lastNameTxtF.text!,"email":self.emailTxtF.text!,"phone":self.mobileTxtF.text!,"password":self.passwordTxtF.text!,"login_type":"email","otp":otp,"user_type":"1","invitation_code":self.referalCodeTxtF.text! ,"picture": facebookImage] as [String : Any]
        
        WebService.requestPostUrl(strURL: api_name, params: params as NSDictionary, is_loader_required: true, success: { (response) in
            print(response)
            if response["status_code"] as! NSNumber == 1
            {
                DispatchQueue.main.async {
                    let viewController  = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerifyVC") as! OTPVerifyVC
                    viewController.isFromSignUp = true
                    viewController.signUpDataDic = params as NSDictionary
                    print("params for create user:\(params)")
                    self.navigationController?.pushViewController(viewController, animated: true)
                    return
                }
            }
            else
            {
                let alert = UIAlertController(title: nil, message: (response["message"] as! String), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                   
                  //  self.navigationController?.popViewController(animated: true)
                }))
                let popPresenter = alert.popoverPresentationController
                popPresenter?.sourceView = self.view
                popPresenter?.sourceRect = self.view.bounds
                self.present(alert, animated: true, completion: nil)
            }
        }) { (failure) in
            //  COMMON_ALERT.showAlert(msg: "Request Time Out !")
        }
    }
    
   /* func verifyOTPAPI(email:String,otp:String)  {
        let params = ["email": email,"otp":otp]
        let api_name = KUsers_Api + "/otp/verify"
        
        WebService.requestPostUrl(strURL: api_name, params: params as NSDictionary, is_loader_required: true, success: { (response) in
            print(response)
            if response["status_code"] as! NSNumber == 1
            {
              //  let dataDic = ((response["data"] as! NSArray) as! [NSDictionary])[0]
                self.signupApi()
            }
            else
            {
                DispatchQueue.main.async {
                    COMMON_ALERT.showAlert(title: response["message"] as! String , msg: "", onView: self) }
            }
        }) { (failure) in
            //  COMMON_FUNCTIONS.showAlert(msg: "Request Time Out !")
        }
    }
    */
    
    //MARK: - Show Alert With Option
    func alert(title:String,msg:String)   {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
           
        }))
        
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.sourceRect = self.view.bounds
        self.present(alert, animated: true, completion: nil)
    }
        
}

extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
