//
//  ChangePasswordVC.swift
//  TaxiApp
//
//  Created by Apple on 11/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import PasswordTextField

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var currentPasswordTxtF: PasswordTextField!
    @IBOutlet weak var newPasswordTxtF: PasswordTextField!
    @IBOutlet weak var confirmPasswordTxtF: PasswordTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func popVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updateBtnTaped(_ sender: Any) {
        
        if (currentPasswordTxtF.text == "")
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterOldPassword.rawValue, msg: "", onView: self)
        }
        else if (newPasswordTxtF.text == "")
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterNewPassword.rawValue, msg: "", onView: self)
        }
      /*  else if !self.newPasswordTxtF.text!.isValidSecurePassword()
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidPassword.rawValue, msg: "", onView: self)
        } */
        else if ((self.newPasswordTxtF.text?.count)! < 5)
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidPassword.rawValue, msg: "", onView: self)
        }
        else if (confirmPasswordTxtF.text == "")
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterConfirmPassword.rawValue, msg: "", onView: self)
        }
        else if self.confirmPasswordTxtF.text! != self.newPasswordTxtF.text!
        {
            COMMON_ALERT.showAlert(title: AppMessages.passwordDosntMatch.rawValue, msg: "", onView: self)
        }
        else
        {
            // Hit Api
            changePasswordApiCall()
        }
    }
    
    @IBAction func forgotPasswordBtnTaped(_ sender: Any) {
       
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        vc.isFromChangePassword = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // API Call
    func changePasswordApiCall() {
        let params = ["old_password": self.currentPasswordTxtF.text! , "new_password": self.newPasswordTxtF.text! , "password_confirmation": self.confirmPasswordTxtF.text!] as [String : Any]
        print("update password param: \(params)")
        
        WebService.requestPutUrl(strURL: KUpdatePassword_Api + "/" + userDataModel.user_id! , params: params as NSDictionary, is_loader_required: true, success: { (response) in
            
            print(response)
            if response["status_code"] as! NSNumber == 1
            {
                self.confirmPasswordTxtF.resignFirstResponder()
                self.currentPasswordTxtF.becomeFirstResponder()
                self.currentPasswordTxtF.text = ""
                self.newPasswordTxtF.text = ""
                self.confirmPasswordTxtF.text = ""
               // self.navigationController?.popViewController(animated: true)
                self.alert(title:response.value(forKey: "message") as! String , msg: "")
            }
            
            COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
            
        }) { (failure) in
            
        }
    }
    
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
