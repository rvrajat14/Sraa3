//
//  ForgotPasswordVC.swift
//  TaxiApp
//
//  Created by Apple on 11/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    var user_id = ""
    var email_id = ""
    var otp = ""
    var isFromlogin = false
    @IBOutlet weak var emailTxtF: UITextField!
    var isFromChangePassword = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(isFromlogin == true)
        {
            emailTxtF.layer.borderWidth = 1
            emailTxtF.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            emailTxtF.isUserInteractionEnabled = true
        }
        else
        {
       
        email_id = userDataModel.email_id
        
        emailTxtF.isUserInteractionEnabled = false
        let atSign = email_id.index(of: "@")! // email.index(of: "@") ?? email.endIndex
        
        let userID = email_id[..<atSign]
        print(userID + email_id.suffix(from: atSign))
        
        let lastLetterInx = email_id.index(before:atSign)
        
        var inx = email_id.startIndex
        
        var result = ""
        while(true) {
            if (inx >= lastLetterInx) {
                result.append(String(email_id[lastLetterInx...]))
                break;
            }
            print(inx)
            if (inx > email_id.startIndex && email_id[inx] != ".") {
                result.append("*")
            } else {
                result.append(email_id[inx])
            }
            
            inx = email_id.index(after: inx)
        }
        self.emailTxtF.text = result
        print (result)
        }
    }
    
    @IBAction func submitBtnTaped(_ sender: Any) {
        
        if (emailTxtF.text == "") {
            COMMON_ALERT.showAlert(title: AppMessages.enterLoginEmail.rawValue, msg: "", onView: self)
        }
     /*   else if !self.emailTxtF.text!.isValidEmail()
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidEmail.rawValue, msg: "", onView: self)
        } */
        else{
            if(isFromlogin == true)
            {
                verifyEmailAPI(email: emailTxtF.text!)
            }
            else
            {
                verifyEmailAPI(email: email_id)
            }
        }
    }
    
    func verifyEmailAPI(email:String)  {
        let params = ["email": email]
        let api_name = KUsers_Api + "/forgot-password-email"
        
        WebService.requestPostUrl(strURL: api_name, params: params as NSDictionary, is_loader_required: true, success: { (response) in
            print(response)
            if response["status_code"] as! NSNumber == 1
            {
                DispatchQueue.main.async {
                    let viewController  = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerifyVC") as! OTPVerifyVC
                    viewController.isFromSignUp = false
                    viewController.forgotPasswordDataDic = params as NSDictionary
                    
                    if(self.isFromChangePassword)
                    {
                       viewController.isFromChangePassword = true
                    }
                    self.navigationController?.pushViewController(viewController, animated: false)
                    return
                }
            }
            else
            {
                let alert = UIAlertController(title: nil, message: (response["message"] as! String), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.emailTxtF.text = ""
                    self.emailTxtF.becomeFirstResponder()
                    return
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func popVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
