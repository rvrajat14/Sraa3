//
//  RegenratePasswordVC.swift
//  SRAA3
//
//  Created by Apple on 19/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import PasswordTextField

class RegenratePasswordVC: UIViewController {
    
    var window: UIWindow?
    var emailStr = ""
    var user_id = ""
    var isFromChangePassword = false
    
    @IBOutlet weak var newpasswordTxtF: PasswordTextField!
    @IBOutlet weak var confirmPasswordTxtF: PasswordTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        newpasswordTxtF.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func resetPasswordBtnTaped(_ sender: Any) {
         if (newpasswordTxtF.text == "")
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterLoginPassword.rawValue, msg: "", onView: self)
        }
            /*else if !self.passwordTxtF.text!.isValidSecurePassword()
             {
             COMMON_ALERT.showAlert(title: AppMessages.enterValidPassword.rawValue, msg: "", onView: self)
             }*/
        else if ((newpasswordTxtF.text?.count)! < 6)
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidPassword.rawValue, msg: "", onView: self)
        }
        else if self.confirmPasswordTxtF.text! != self.newpasswordTxtF.text!
        {
            COMMON_ALERT.showAlert(title: AppMessages.passwordDosntMatch.rawValue, msg: "", onView: self)
        }
        else
         {
        self.createNewPasswordAPI()
        }
    }
    
    @IBAction func popVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func createNewPasswordAPI()  {
        
        let params = ["user_id": user_id,"password":self.newpasswordTxtF.text!,"email":emailStr]
        let api_name = KUsers_Api + "/forgot-password-change-password"
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrl(strURL: api_name, params: params as NSDictionary, is_loader_required: true, success: { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 1
                {
                   // UserDefaults.standard.removeObject(forKey: "user_data")
                    
                    if self.isFromChangePassword
                    {
                        self.alert(title: (response["message"] as! String), msg: "")
                    }
                    else
                    {
                        let alert = UIAlertController(title: nil, message: (response["message"] as! String), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            DispatchQueue.main.async {
                                CommonClass.emptyUserDefaultData()
                                let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                                self.window = UIWindow(frame: UIScreen.main.bounds)
                                
                                let yourVc = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                                let navigationController = UINavigationController(rootViewController: yourVc!)
                                if let window = self.window {
                                    window.rootViewController = navigationController
                                }
                                self.window?.makeKeyAndVisible()
                            }
                        }))
                        let popPresenter = alert.popoverPresentationController
                        popPresenter?.sourceView = self.view
                        popPresenter?.sourceRect = self.view.bounds
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else
                {
                    let alert = UIAlertController(title: nil, message: (response["message"] as! String), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.newpasswordTxtF.becomeFirstResponder()
                        return
                    }))
                    let popPresenter = alert.popoverPresentationController
                    popPresenter?.sourceView = self.view
                    popPresenter?.sourceRect = self.view.bounds
                    self.present(alert, animated: true, completion: nil)
                }
               
            }) { (failure) in
                // COMMON_FUNCTIONS.showAlert(msg: "Request Time Out !")
            }
        }
        
    }
    
    //MARK: - Show Alert With Option
    
    func alert(title:String,msg:String)   {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            let viewControllers = self.navigationController!.viewControllers as [UIViewController]
            for aViewController:UIViewController in viewControllers {
                if aViewController.isKind(of: ProfileVC.self) {
                    self.navigationController?.popToViewController(aViewController, animated: true)
                    break
                }
            }
        }))
        
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.sourceRect = self.view.bounds
        self.present(alert, animated: true, completion: nil)
    }
}
