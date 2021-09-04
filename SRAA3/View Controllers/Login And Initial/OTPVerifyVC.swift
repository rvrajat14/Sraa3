//
//  OTPVerifyVC.swift
//  TaxiApp
//
//  Created by Apple on 11/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class OTPVerifyVC: UIViewController , UITextFieldDelegate {
    
    var timer: Timer?
    var totalTime = 60
    var isFromSignUp = false
    var otpStr = ""
    
    var isFromChangePassword = false
   
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var firstTxtF: UITextField!
    @IBOutlet weak var secondtxtf: UITextField!
    @IBOutlet weak var thirdTxtF: UITextField!
    @IBOutlet weak var forthTextF: UITextField!
    @IBOutlet weak var fifthTxtF: UITextField!
    @IBOutlet weak var sixthTxtF: UITextField!
    
    @IBOutlet weak var regenrateTitleLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var regenerateOtpBtn: UIButton!
    @IBOutlet weak var backV: UIView!
    
    @IBOutlet weak var verifyButton: UIButton!
    let userDefaults = UserDefaults.standard
    var signUpDataDic = NSDictionary.init()
    
    var forgotPasswordDataDic = NSDictionary.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isFromSignUp {
        
//        let emailId = self.getSecureEmail(emailStr: signUpDataDic.value(forKey: "email") as! String)
            
//        let main_string = "Please enter the code from Email we've send you at \(emailId)"
            let main_string = "One Time Password has been Sent to your mobile number"
//        let string_to_color = emailId
//
//        let range = (main_string as NSString).range(of: string_to_color)
//
//        let attribute = NSMutableAttributedString.init(string: main_string)
//        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.init(red: 56.0/255.0, green: 152.0/255.0, blue: 227.0/255.0, alpha: 1) , range: range)
//
//        self.subTitleLbl.attributedText = attribute
            self.subTitleLbl.text = main_string
            
        }
        else
        {
            let emailId = self.getSecureEmail(emailStr: forgotPasswordDataDic.value(forKey: "email") as! String)
            
            let main_string = "Please enter the code from Email we've send you at \(emailId)"
            
            let string_to_color = emailId
            
            let range = (main_string as NSString).range(of: string_to_color)
            
            let attribute = NSMutableAttributedString.init(string: main_string)
            
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.init(red: 56.0/255.0, green: 152.0/255.0, blue: 227.0/255.0, alpha: 1) , range: range)
            
            self.subTitleLbl.attributedText = attribute
        }
        startOtpTimer()
        firstTxtF.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        self.verifyButton.layer.cornerRadius = 5
        self.verifyButton.layer.masksToBounds = true
        Utilities.setButtonGradiantColor(button: self.verifyButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.firstTxtF.background = UIImage(named: "ic_otpeditext")
        self.secondtxtf.background = UIImage(named: "ic_otpeditext")
        self.thirdTxtF.background = UIImage(named: "ic_otpeditext")
        self.forthTextF.background = UIImage(named: "ic_otpeditext")
        self.fifthTxtF.background = UIImage(named: "ic_otpeditext")
        self.sixthTxtF.background = UIImage(named: "ic_otpeditext")
        self.regenerateOtpBtn.isHidden = true
        self.firstTxtF.text = ""
        self.secondtxtf.text = ""
        self.thirdTxtF.text = ""
        self.forthTextF.text = ""
        self.fifthTxtF.text = ""
        self.sixthTxtF.text = ""
        self.firstTxtF.becomeFirstResponder()
        self.timeLbl.text = "(" + "00:00" + ")"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timer?.fire()
    }
    
    func getSecureEmail(emailStr : String) -> String {
        
        var str = ""
       // let atSign = emailStr.index(before: emailStr.index(before: emailStr.index(of: "@")!)) // email.index(of: "@") ?? email.endIndex
        let atSign = emailStr.index(before: emailStr.index(of: "@")!)
        let userID = emailStr[..<atSign]
        print(userID + emailStr.suffix(from: atSign))
        
        let lastLetterInx = emailStr.index(before:atSign)
        
        var inx = emailStr.startIndex
        
        var result = ""
        while(true) {
            if (inx >= lastLetterInx) {
                result.append(String(emailStr[lastLetterInx...]))
                break;
            }
            if (inx > emailStr.startIndex && emailStr[inx] != ".") {
                result.append("*")
            } else {
                result.append(emailStr[inx])
            }
            
            inx = emailStr.index(after:inx)
        }
        str = result
        print (result)
        return str
    }
    
    @IBAction func backBtnTaped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func verifyBtnTaped(_ sender: Any) {
        
        /*if isFromSignUp {
            NotificationCenter.default.post(name: NSNotification.Name.init("signUpOTPNotification"), object: nil, userInfo: ["otp":otpStr])
            self.dismiss(animated: true, completion: nil)
        } */
        
        if (otpStr.isEmpty) {
            self.view.makeToast("Enter OTP")
            return
        }
        
        if isFromSignUp {
//            createNewUserAPI()
            userLoginApi()
        }
        
        else
        {
            verifyOTPAPI(email: forgotPasswordDataDic.value(forKey: "email") as! String, otp: otpStr)
        }
    }
    
    @IBAction func regenrateOtpBtnTaped(_ sender: Any) {
        regenerateOtpBtn.isHidden = true
        regenrateTitleLbl.textColor = UIColor.lightGray
        timeLbl.textColor = UIColor.lightGray
        self.timeLbl.text = "(" + "00:00" + ")"
        self.timer?.invalidate()
        self.timer?.fire()
      //  startOtpTimer()
        sendOTP()
    }
    
    private func startOtpTimer() {
        self.totalTime = 60
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        print(self.totalTime)
        
        self.timeLbl.text = "(" + self.timeFormatted(self.totalTime) + ")" // will show timer
        if totalTime != 0 {
            totalTime -= 1  // decrease counter timer
            
        } else {
            if let timer = self.timer {
                timer.invalidate()
                self.timer = nil
                self.timer?.invalidate()
                self.timer?.fire()
              //  self.startOtpTimer()
            }
            regenrateTitleLbl.textColor = UIColor.KMainColorCode
            timeLbl.textColor = UIColor.KMainColorCode
            regenerateOtpBtn.isHidden = false
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    //MARK: - Call API
    func verifyOTPAPI(email:String,otp:String)  {
        let params = ["email": email,"otp":otp]
        let api_name = KUsers_Api + "/forgot-password-verify-otp"
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrl(strURL: api_name, params: params as NSDictionary, is_loader_required: true, success: { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                
                if response["status_code"] as! NSNumber == 1
                {
                    self.otpStr = ""
                    self.timer?.invalidate()
                    self.timer?.fire()
                    let dataDic = ((response["data"] as! NSArray) as! [NSDictionary])[0]
                    let user_id = CommonClass.checkForNull(string: dataDic["id"] as! NSObject)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegenratePasswordVC") as! RegenratePasswordVC
                    if(self.isFromChangePassword)
                    {
                        self.regenerateOtpBtn.isHidden = false
                        self.firstTxtF.text = ""
                        self.secondtxtf.text = ""
                        self.thirdTxtF.text = ""
                        self.forthTextF.text = ""
                        self.fifthTxtF.text = ""
                        self.sixthTxtF.text = ""
                        self.firstTxtF.becomeFirstResponder()
                        vc.isFromChangePassword = true
                        self.timeLbl.text = "(" + "00:00" + ")"
                    }
                    vc.user_id = user_id
                    vc.emailStr = dataDic["email"] as! String
                    
                     UIApplication.shared.keyWindow?.makeToast((response["message"] as! String), duration: 1.0, position: .center)
                    
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                else
                {
                    self.otpStr = ""
                    let alert = UIAlertController(title: nil, message: (response["message"] as! String), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                       // self.regenerateOtpBtn.isHidden = false
                        self.firstTxtF.text = ""
                        self.secondtxtf.text = ""
                        self.thirdTxtF.text = ""
                        self.forthTextF.text = ""
                        self.fifthTxtF.text = ""
                        self.sixthTxtF.text = ""
                        self.firstTxtF.becomeFirstResponder()
                        return
                    }))
                    let popPresenter = alert.popoverPresentationController
                    popPresenter?.sourceView = self.view
                    popPresenter?.sourceRect = self.view.bounds
                    self.present(alert, animated: true, completion: nil)
                }
            }) { (failure) in
                
            }
        }
       
    }
    
    //MARK: Login User
    func userLoginApi() {
        
        let api_name = KLogin_Api
        let params = NSMutableDictionary()
        params.setObject(otpStr, forKey: "otp" as NSCopying)
        params.setObject(otpStr, forKey: "password" as NSCopying)
        params.setObject("1", forKey: "user_type" as NSCopying)
        params.setObject(signUpDataDic.value(forKey: "username") as! String, forKey: "user" as NSCopying)
        params.setObject(notification_token, forKey: "notification_token" as NSCopying)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name, is_loader_required: true, params: params as! [String : Any]) { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 1
                {
                    // DispatchQueue.main.async {
                    self.self.userDefaults.set(response.value(forKey: "currency"), forKey: "currency")
                    self.userDefaults.synchronize()
                    
                    let userDictionary = (response["data"] as! NSArray).object(at: 0) as! NSDictionary
                    self.setUserData(userDictionary: userDictionary)
                }
                    
                else
                {
                    DispatchQueue.main.async {
                        COMMON_ALERT.showAlert(title: response["message"] as! String , msg: "", onView: self) }
                }
                
            } failure: { (error) in
                print(error)
            }

        }
        
    }
    
     func setUserData(userDictionary:NSDictionary)  {
        
        print("userDic \(userDictionary)")
        
        var user_idStr:String!,first_nameStr:String!,last_nameStr:String!,usernameStr:String!,email_idStr:String!,phoneStr:String!,session_idStr:String!,profile_imageStr:String! , currencySymbolStr: String
        
        user_idStr = CommonClass.checkForNull(string: (userDictionary.object(forKey: "id") as AnyObject))
        
        first_nameStr = CommonClass.checkForNull(string: (userDictionary.object(forKey: "first_name") as AnyObject))
        
        last_nameStr = CommonClass.checkForNull(string: (userDictionary.object(forKey: "last_name") as AnyObject))
        
        usernameStr = " "
        
        email_idStr = CommonClass.checkForNull(string: (userDictionary.object(forKey: "email") as AnyObject))
        
        phoneStr = CommonClass.checkForNull(string: (userDictionary.object(forKey: "phone") as AnyObject))
        
        session_idStr = CommonClass.checkForNull(string: (userDictionary.object(forKey: "user_session_id") as AnyObject))
        
        profile_imageStr = CommonClass.checkForNull(string: (userDictionary.object(forKey: "photo") as AnyObject))
        
        currencySymbolStr = CommonClass.checkForNull(string: (userDictionary.object(forKey: "currency_symbol") as AnyObject))
        
        let user_data = UserDataClass.init(user_id: user_idStr, first_name: first_nameStr, last_name: last_nameStr, email_id: email_idStr, username: usernameStr, phone: phoneStr, session_id: session_idStr, profile_image: profile_imageStr , currencySymbol: currencySymbolStr)
        
        let userDefaults = UserDefaults.standard
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: user_data)
        userDefaults.set(encodedData, forKey: "userData")
        userDefaults.synchronize()
        
        if userDefaults.object(forKey: "userData") != nil  {
            let decoded  = userDefaults.object(forKey: "userData") as! Data
            userDataModel = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
            print("user_id \(userDataModel.user_id)")
        }
        
        
        let api_name = KOauthToken_Api
        let username = CommonClass.checkForNull(string: (signUpDataDic.object(forKey: "username") as AnyObject))
        let password = otpStr
        let param = ["grant_type":"password","client_secret":"f36F4ZZN84kWE9cwYbFj2Y6er5geY9OBXF3hEQO4","client_id":"2","username":username,"password":password]
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false, completion: {
 
            WebService.requestPostUrl(strURL: api_name, params: param as NSDictionary, is_loader_required: true, success: { (response) in
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                print(response)
                access_token = (response["access_token"] as! String)
                refresh_token = (response["refresh_token"] as! String)
                token_type  = (response["token_type"] as! String)
                let expireTime = (response["expires_in"] as! NSNumber)
                // let expireDate = Date().addingTimeInterval(TimeInterval(exactly: 60)!)
                 let expireDate = Date().addingTimeInterval(TimeInterval(exactly: expireTime)!)
                UserDefaults.standard.setValue(expireDate, forKey: "expireDate")
                UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
                UserDefaults.standard.setValue(access_token, forKey: "access_token")
                UserDefaults.standard.setValue(token_type, forKey: "token_type")
                DispatchQueue.main.async {
                    
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    
    //                if  isFromAppdelegate
    //                {
    //                    COMMON_FUNCTIONS.addCustomTabBar()
    //                }
    //                else
    //                {
    //                    NotificationCenter.default.post(name: NSNotification.Name("login_update_notitfication"), object: nil)
    //                    self.dismiss(animated: true, completion: nil)
    //                }
                    
                }
               
            }) { (failure) in
                
            }
            
        })
    
    }
    
    
    //MARK: Create New User
    func createNewUserAPI()  {
        var api_name = ""
        api_name = KUsers_Api + "?timezone=\(localTimeZoneName)"
        let params =   signUpDataDic.mutableCopy() as! NSMutableDictionary
        params.setObject(otpStr, forKey: "otp" as NSCopying)
        
        print(params)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: true, params: params as! [String : Any], success: { (response) in
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                DispatchQueue.main.async {
                    if response["status_code"] as! NSNumber == 1
                    {
                        self.otpStr = ""
                        self.timer?.invalidate()
                        self.timer?.fire()
                        
                       // self.view.makeToast((response["message"] as! String), duration: 2, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
                          /*  let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                            self.window = UIWindow(frame: UIScreen.main.bounds)
                            let yourVc = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? UINavigationController
                            if let window = self.window {
                                window.rootViewController = yourVc
                            }
                            self.window?.makeKeyAndVisible() */
                          //  self.alert(title: (response["message"] as! String), msg: "")
                          //  self.navigationController?.popToRootViewController(animated: true)
                             UIApplication.shared.keyWindow?.makeToast((response["message"] as! String), duration: 1.0, position: .center)
                        // })
                        self.timer?.invalidate()
                        self.timer?.fire()
                    }
                    else
                    {
                        self.otpStr = ""
                      //  self.regenerateOtpBtn.isHidden = false
                        self.firstTxtF.text = ""
                        self.secondtxtf.text = ""
                        self.thirdTxtF.text = ""
                        self.forthTextF.text = ""
                        self.fifthTxtF.text = ""
                        self.sixthTxtF.text = ""
                        self.firstTxtF.becomeFirstResponder()
                        self.view.makeToast((response["message"] as! String), point: CGPoint(x: self.view.center.x, y: self.view.center.y), title: "", image: nil, completion: nil)
                        
                        self.view.clearToastQueue()
                    }
                }
                
               
                
            }) { (failure) in
                self.view.makeToast("Request Time Out !")
                self.view.clearToastQueue()
            }
        }
        
    }
    
    func sendOTP()  {
        
        var param = NSDictionary.init()
        var api_name = ""
        
        if isFromSignUp {
            param = signUpDataDic
            api_name = KOTP_GENERATE_Api
        }
        else
        {
            api_name = KUsers_Api + "/forgot-password-email"
            param = forgotPasswordDataDic
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            
            WebService.requestPostUrl(strURL: api_name , params: param as NSDictionary, is_loader_required: true, success: { (response) in
                print(response)
                self.presentingViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 1
                {
                    self.timer?.invalidate()
                    self.timer?.fire()
                    self.startOtpTimer()
                }
                 self.view.makeToast((response["message"] as! String), duration: 2, position: .center, title: "", image: nil, style: .init(), completion: nil)
                
                
            }) { (failure) in
               // COMMON_ALERT.showAlert(title: <#String#>, msg: "Request Time Out !")
            }
        }
      
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // On inputing value to textfield
        if (range.length == 0){
            if textField == firstTxtF {
                secondtxtf?.becomeFirstResponder()
            }
            if textField == secondtxtf {
                thirdTxtF?.becomeFirstResponder()
            }
            if textField == thirdTxtF {
                forthTextF?.becomeFirstResponder()
            }
            if textField == forthTextF {
                fifthTxtF?.becomeFirstResponder()
            }
            if textField == fifthTxtF {
                sixthTxtF?.becomeFirstResponder()
            }
            if textField == sixthTxtF {
                sixthTxtF?.becomeFirstResponder()
             /*After the otpbox6 is filled we capture the All the OTP textField and do the server call. If you want to capture the otpbox6 use string.*/
                otpStr = "\((firstTxtF?.text)!)\((secondtxtf?.text)!)\((thirdTxtF?.text)!)\((forthTextF?.text)!)\((fifthTxtF?.text)!)\((sixthTxtF?.text)!)\(string)"
            }
            textField.text? = string
            return false
        }else if (range.length == 1) {
            if textField == sixthTxtF {
                fifthTxtF?.becomeFirstResponder()
            }
            if textField == fifthTxtF {
                forthTextF?.becomeFirstResponder()
            }
            if textField == forthTextF {
                thirdTxtF?.becomeFirstResponder()
            }
            if textField == thirdTxtF {
                secondtxtf?.becomeFirstResponder()
            }
            if textField == secondtxtf {
                firstTxtF?.becomeFirstResponder()
            }
            if textField == firstTxtF {
                firstTxtF?.resignFirstResponder()
            }
            textField.text? = ""
            return false
        }
        return true
    }
    
    //MARK: - Show Alert With Option
    func alert(title:String,msg:String)   {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.navigationController?.popToRootViewController(animated: true)
            
        }))
        
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.sourceRect = self.view.bounds
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
