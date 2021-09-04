//
//  OrderActionVC.swift
//  My MM
//
//  Created by Kishore on 29/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import IQKeyboardManager

import NotificationCenter

class OrderActionVC: UIViewController {
    var orderActionType = ""
    var order_id = ""
   // var user_data:UserDataClass!
    
    @IBOutlet weak var fTopView: UIView!
    
    @IBOutlet weak var cTopView: UIView!
    
    @IBAction func backButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil, userInfo: ["actionResponse":"CancelOrderAPI"])
        
    }
    
    @IBOutlet weak var yesButton: UIButton!
    @IBAction func oopsNoButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil)
         self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var oopsNoButton: UIButton!
    @IBOutlet weak var cancelOrderView: UIView!
    
    
    @IBAction func feedbackSubmitButton(_ sender: UIButton) {
        self.submitOrdeRatingAPI()
    }
    @IBOutlet weak var feedbackSubmitButton: UIButton!
    @IBOutlet weak var feedbackTxtView: IQTextView!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var feedbackMainV: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fTopView.layer.masksToBounds = true
        self.fTopView.layer.cornerRadius = 10
        self.ratingView.type = .halfRatings
        self.cTopView.layer.masksToBounds = true
        self.cTopView.layer.cornerRadius = 10
        
        if orderActionType == "cancel" {
            cancelOrderView.isHidden = false
            cTopView.isHidden = false
            fTopView.isHidden = true
            feedbackMainV.isHidden = true
        }
        else
        {
            cTopView.isHidden = true
            fTopView.isHidden = false
            cancelOrderView.isHidden = true
            feedbackMainV.isHidden = false
        }
        self.yesButton.layer.borderWidth = 1
        self.yesButton.layer.borderColor = UIColor.KMainColorCode.cgColor
        self.feedbackTxtView.layer.borderWidth = 1
        self.feedbackTxtView.layer.borderColor = UIColor.darkGray.cgColor
    }

    //MARK: Hide View on OutSide Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view {
            NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil)
            dismiss(animated: true, completion: nil)
        }
        super.touchesBegan(touches, with: event)
    }
    //MARK: Submit Feedback
    
    func submitOrdeRatingAPI() {
        
        let api_name = ROrderReviews_Api
        let order_review = self.feedbackTxtView.text!
        let rating_value = String(self.ratingView.rating)
        print(order_id)
        let param =  ["user_id":userDataModel.user_id!,"order_id":order_id, "review":order_review,"rating":rating_value]
        print(param)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: true, params: param, success: { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                
                if response["status_code"] as! NSNumber == 1
                {
                    NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil, userInfo: ["toastMsg":(response["message"] as! String)])
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                else
                {
                    self.view.makeToast((response["message"] as! String))
                    self.view.clearToastQueue()
                    return
                }
           
            }) { (error) in
            }
        }
  
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
