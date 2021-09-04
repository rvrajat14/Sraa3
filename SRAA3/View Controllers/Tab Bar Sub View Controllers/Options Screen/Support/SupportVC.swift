//
//  SupportVC.swift
//  TaxiApp
//
//  Created by Apple on 11/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MessageUI

class SupportVC: UIViewController ,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var emailBackV: UIView!
    @IBOutlet weak var calBackV: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        Utilities.AddBorder(view: calBackV)
        calBackV.layer.cornerRadius = 4
        emailBackV.layer.cornerRadius = 4
        
    }

    @IBAction func popVC(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func callBtnTaped(_ sender: Any) {
        call(with: KAdminContact)
    }
    
    @IBAction func sendMailBtnTaped(_ sender: Any) {
        askToOpenEmail(with: KAdminEmail)
    }
    
    func call(with phoneNumber:String)  {
        if let url = URL.init(string: "tel://\(phoneNumber)"){
            
            if UIApplication.shared.canOpenURL(url) {
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { (_) in
                        
                    })
                } else {
                    // Fallback on earlier versions
                }
                
            } else {
                COMMON_ALERT.showAlert(title: AppMessages.callFunctionalityNotAvailable.rawValue, msg: "", onView: self)
            }
        }
    }
    
    func askToOpenEmail(with email:String) {
        
        let ac = UIAlertController.init(title: nil, message: AppMessages.composeMailTitle.rawValue, preferredStyle: UIAlertControllerStyle.alert)
        
        let a1 = UIAlertAction.init(title: "Yes", style: UIAlertActionStyle.default) { (_) in
            
            self.requestForEmail(with: email)
        }
        let a2 = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil)
        
        ac.addAction(a1)
        ac.addAction(a2)
        
        self.present(ac, animated: true, completion: nil)
        
    }
    
    func requestForEmail(with email:String) {
        
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
        mailComposeViewController.setToRecipients([email])
        mailComposeViewController.setSubject("Inquiry\("")")
        
        mailComposeViewController.setMessageBody("", isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            COMMON_ALERT.showAlert(title: AppMessages.ifEmailIsNotFailed.rawValue, msg: "", onView: self)
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
