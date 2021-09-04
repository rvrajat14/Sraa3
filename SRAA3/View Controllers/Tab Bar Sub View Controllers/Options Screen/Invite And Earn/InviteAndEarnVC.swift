//
//  InviteAndEarnVC.swift
//  SRAA3
//
//  Created by Apple on 22/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class InviteAndEarnVC: UIViewController {

    var invite_text = ""
    var inviteCode = ""
    var rewardPoints  = ""
    
    @IBOutlet weak var backV: UIView!
    @IBOutlet weak var activityIndicatorV: UIActivityIndicatorView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var desLbl: UILabel!
    @IBOutlet weak var txtF: UITextField!
    
    @IBOutlet weak var promoCodeTxtF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backV.isHidden = true
        activityIndicatorV.isHidden = false
        activityIndicatorV.startAnimating()
        getPoitsApiCall()
        // Do any additional setup after loading the view.
    }

    @IBAction func popVC(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func inviteFrdBtnTaped(_ sender: UIButton) {
        let vc = UIActivityViewController(activityItems: [invite_text , "Moreover Enter my Referal Code: " +
            inviteCode  + " to Earn \(rewardPoints) Points"], applicationActivities: [])
        self.present(vc, animated: true, completion: nil)
        if let pop = vc.popoverPresentationController {
            let v = sender as UIView
            pop.sourceView = v
            pop.sourceRect = v.bounds
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Api Call ------------------ //
    
    func getPoitsApiCall() {
        
        WebService.requestGetUrl(strURL: RUser_Api + "/" + KPoints_Api + "/" + (userDataModel.user_id!) + "?type=sara" , is_loader_required: false, success: { (response) in
            print(response)
            
            if (response.value(forKey: "status_code")as! NSNumber) == 1
            {
                self.backV.isHidden = false
                let dataDic = response["data"]as! NSDictionary
                self.rewardPoints = CommonClass.checkForNull(string: dataDic["reward_points"]as AnyObject)
                self.titleLbl.text = "You have \(self.rewardPoints) reward points"
              //  self.desLbl.text = "Invite friends & earn \(self.rewardPoints) reward points on their first transcation."
                 self.desLbl.text = "Invite friends & earn 10 reward points on their first transcation."
                self.inviteCode =  CommonClass.checkForNull(string: dataDic["invite_code"] as AnyObject)
                self.invite_text =  CommonClass.checkForNull(string: dataDic["invite_text"] as AnyObject)
                self.txtF.text = self.inviteCode
            }
            else
            {
                COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
            }
            
            self.activityIndicatorV.isHidden = true
            self.activityIndicatorV.stopAnimating()
            
        }) { (failure) in
            
        }
    }

}
