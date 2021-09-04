//
//  LoginVC.swift
//  TaxiApp
//
//  Created by Apple on 10/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices

class LoginVC: UIViewController, GIDSignInDelegate {

    @IBOutlet weak var orLbl: UILabel!
    @IBOutlet weak var orRightLine: UIView!
    @IBOutlet weak var orLeftLine: UIView!
    @IBOutlet weak var fbLoginView: UIView!
    @IBOutlet weak var googleLoginView: UIView!
    @IBOutlet weak var skipLoginView: UIView!
    @IBOutlet weak var mobileTextView: UIView!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var loginSignupButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    
    @IBOutlet weak var appleLoginView: UIView!
    var appleAuthorizationCode = ""
    var appleIdentityToken = ""
    
    let userDefaults = UserDefaults.standard
    var device_id = ""
    var fbResult = NSDictionary.init()
    var email = ""
    var password = ""
    var device_size = ""
    var first_name = ""
    var last_name = ""
    var social_user_id = ""
    var social_token = ""
    var user_profile_photo_url = ""
    var ios_version = ""

    
    @IBAction func skipLoginButton(_ sender: UIButton) {
      DispatchQueue.main.async {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
    
    
    @IBAction func loginSignupButton(_ sender: UIButton) {
        generateTokenApi()
    }
    
    @IBAction func crossButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mobileTextView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.mobileTextView.layer.borderWidth = 1
        self.mobileTextView.layer.cornerRadius = 5
        self.mobileTextField.delegate = self
        self.googleLoginView.layer.cornerRadius = 5
        self.googleLoginView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.googleLoginView.layer.borderWidth = 1
        self.fbLoginView.layer.cornerRadius = 5
        self.fbLoginView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.fbLoginView.layer.borderWidth = 1
        self.skipLoginView.layer.cornerRadius = self.skipLoginView.frame.height/2
        self.skipLoginView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.skipLoginView.layer.borderWidth = 1
        self.loginSignupButton.layer.cornerRadius = 5
        
        var localTimeZoneName: String { return TimeZone.current.identifier }
        navigationController?.navigationBar.shadowImage = UIImage()
       
        notification_token = CommonClass.checkForNull(string: userDefaults.value(forKey: "notification_token") as AnyObject)
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        device_size = "\(width) * \(height)"
        ios_version = UIDevice.current.systemVersion
        device_id = UIDevice.current.identifierForVendor!.uuidString
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if #available(iOS 13.0, *) {
            self.appleLoginView.isHidden = false
        } else {
            // Fallback on earlier versions
            self.appleLoginView.isHidden = true
        }
        
        if isFromAppdelegate {
            self.crossButton.isHidden = true
            self.skipLoginView.isHidden = false
        }
        else
        {
            self.crossButton.isHidden = false
            self.skipLoginView.isHidden = true
            
        }
        
        self.mobileTextField.text = ""
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func googeLoginBtn(_ sender: Any) {
       
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    @IBAction func fbLoginBtn(_ sender: Any) {
        
        let fbLoginManager = LoginManager.init()
        fbLoginManager.logOut()
//        if let version = Double(UIDevice.current.systemVersion)
//        {
//            if version <= 9.0 {
//                fbLoginManager.loginBehavior = FBSDKLoginBehavior.systemAccount
//            }else
//            {
//                fbLoginManager.loginBehavior = FBSDKLoginBehavior.web
//            }
//        }

        fbLoginManager.logIn(permissions: [Permission.publicProfile, Permission.email], viewController: self) { (loginResult) in
          switch loginResult {
          case .success(let granted, let declined, let token):
            /*
            Sample log:
              granted: [FBSDKCoreKit.Permission.email, FBSDKCoreKit.Permission.publicProfile],
              declined: [],
              token: <FBSDKAccessToken: 0x282f50fc0>
            */
            
            let fbLoginParameters = ["fields":"email,first_name, last_name,birthday,picture,gender,hometown"]

            let fbSDKGraphRequest = GraphRequest.init(graphPath: "me", parameters: fbLoginParameters, httpMethod: HTTPMethod(rawValue: "GET"))

            fbSDKGraphRequest.start(completionHandler: { (connection, fbSDKGraphResult, fbSDKGraphError) in

                if (fbSDKGraphError != nil)
                {

                }
                else
                {
                    let result = (fbSDKGraphResult as! NSDictionary)
                    print(result)
                    self.fbResult = result
                    print("access token :\(token)")

                    let fbLoginParameters = ["fields" : "email,first_name, last_name,birthday,picture,gender,hometown"]

                    let fbSDKGraphRequest = GraphRequest.init(graphPath: "me", parameters: fbLoginParameters, httpMethod: HTTPMethod(rawValue: "GET"))

                    fbSDKGraphRequest.start(completionHandler: { (connection, fbSDKGraphResult, fbSDKGraphError) in

                        if (fbSDKGraphError != nil)
                        {

                        }
                        else
                        {
                            self.social_token = AccessToken.current!.tokenString
                            self.first_name = (result.object(forKey: "first_name") as? String)!
                            self.last_name = (result.object(forKey: "last_name") as? String)!
//                            self.email = (result.object(forKey: "email") as? String)!
                            let picDic = (result.value(forKey: "picture")as! NSDictionary)
                            self.social_user_id = CommonClass.checkForNull(string: (result.object(forKey: "id") as AnyObject))

                            print(self.social_token)
                            if let _ = result.object(forKey: "email") as? String {
                                self.email = (result.object(forKey: "email") as? String)!
                            }
                            else {
                                COMMON_ALERT.showAlert(title: "", msg: "Use an account which uses Email ID. ", onView: self)
                                return
                            }
                            
                            if (picDic != nil)
                            {
                                let dataDic = (picDic.value(forKey: "data")as! NSDictionary)
                                self.user_profile_photo_url = dataDic.value(forKey: "url")as! String
                            }

                            self.callSocialLoginAPI(type: "facebook")

                        }
                        print("FBGraph Result = \(fbSDKGraphResult!)")
                    })
                }
                print("FBGraph Result = \(fbSDKGraphResult!)")
            })
            
              print("granted: \(granted), declined: \(declined), token: \(token)")
          case .cancelled:
              print("Login: cancelled.")
          case .failed(let error):
            print("Login with error: \(error.localizedDescription)")
          }
        }
        
        
        
//        fbLoginManager.logIn(withReadPermissions: ["public_profile","email"], from: self) { (fbLoginResult) in
//            switch loginResult {
//            case .success(let granted, let declined, let token):
//
//                    let fbLoginParameters = ["fields":"email,first_name, last_name,birthday,picture,gender,hometown"]
//
//                    let fbSDKGraphRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: fbLoginParameters, httpMethod: "GET")
//
//                    fbSDKGraphRequest?.start(completionHandler: { (connection, fbSDKGraphResult, fbSDKGraphError) in
//
//                        if (fbLoginError != nil)
//                        {
//
//                        }
//                        else
//                        {
//                            let result = (fbSDKGraphResult as! NSDictionary)
//                            print(result)
//                            self.fbResult = result
//                            print("access token :\(String(describing: fbLoginResult?.token.tokenString!))")
//
//                            let fbLoginParameters = ["fields" : "email,first_name, last_name,birthday,picture,gender,hometown"]
//
//                            let fbSDKGraphRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: fbLoginParameters, httpMethod: "GET")
//
//                            fbSDKGraphRequest?.start(completionHandler: { (connection, fbSDKGraphResult, fbSDKGraphError) in
//
//                                if (fbLoginError != nil)
//                                {
//
//                                }
//                                else
//                                {
//                                    self.first_name = (result.object(forKey: "first_name") as? String)!
//                                    self.last_name = (result.object(forKey: "last_name") as? String)!
//                                    self.email = (result.object(forKey: "email") as? String)!
//                                    let picDic = (result.value(forKey: "picture")as! NSDictionary)
//
//                                    if (picDic != nil)
//                                    {
//                                        let dataDic = (picDic.value(forKey: "data")as! NSDictionary)
//                                        self.user_profile_photo_url = dataDic.value(forKey: "url")as! String
//                                    }
//
//                                    self.callSocialLoginAPI(type: "facebook")
//
//                                }
//                                print("FBGraph Result = \(fbSDKGraphResult!)")
//                            })
//                        }
//                        print("FBGraph Result = \(fbSDKGraphResult!)")
//                    })
//                    print("Fb Login Successfully Result = \(fbLoginResult!)")
//
//
//
//            case .cancelled :
//                print("FBResult Login Cancelled = \(fbLoginResult!)")
//
//            case .declined :
//                print("FBResult Login declined = \(fbLoginResult!)")
//            }
        
//        }
            
//            if (fbLoginError != nil)
//            {
//                print("FBLoginError = \(fbLoginError!)")
//            }
//            else if (fbLoginResult?.isCancelled)!
//            {
//                print("FBResult Login Cancelled = \(fbLoginResult!)")
//            }
//            else
//            {
//                let fbLoginParameters = ["fields":"email,first_name, last_name,birthday,picture,gender,hometown"]
//
//                let fbSDKGraphRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: fbLoginParameters, httpMethod: "GET")
//
//                fbSDKGraphRequest?.start(completionHandler: { (connection, fbSDKGraphResult, fbSDKGraphError) in
//
//                    if (fbLoginError != nil)
//                    {
//
//                    }
//                    else
//                    {
//                        let result = (fbSDKGraphResult as! NSDictionary)
//                        print(result)
//                        self.fbResult = result
//                        print("access token :\(String(describing: fbLoginResult?.token.tokenString!))")
//
//                        let fbLoginParameters = ["fields" : "email,first_name, last_name,birthday,picture,gender,hometown"]
//
//                        let fbSDKGraphRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: fbLoginParameters, httpMethod: "GET")
//
//                        fbSDKGraphRequest?.start(completionHandler: { (connection, fbSDKGraphResult, fbSDKGraphError) in
//
//                            if (fbLoginError != nil)
//                            {
//
//                            }
//                            else
//                            {
//                                self.first_name = (result.object(forKey: "first_name") as? String)!
//                                self.last_name = (result.object(forKey: "last_name") as? String)!
//                                self.email = (result.object(forKey: "email") as? String)!
//                                let picDic = (result.value(forKey: "picture")as! NSDictionary)
//
//                                if (picDic != nil)
//                                {
//                                    let dataDic = (picDic.value(forKey: "data")as! NSDictionary)
//                                    self.user_profile_photo_url = dataDic.value(forKey: "url")as! String
//                                }
//
//                                self.callSocialLoginAPI(type: "facebook")
//
//                            }
//                            print("FBGraph Result = \(fbSDKGraphResult!)")
//                        })
//                    }
//                    print("FBGraph Result = \(fbSDKGraphResult!)")
//                })
//                print("Fb Login Successfully Result = \(fbLoginResult!)")
//            }
//        }
    }
//    Google SignIn
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName

            first_name = user.profile.givenName
            last_name = user.profile.familyName
            email = user.profile.email
            social_user_id = user.userID
            social_token = idToken ?? ""

            print("user_id = \(userId!)")
            print("idToken = \(idToken!)")
            print("fullName = \(fullName!)")
            print("givenName = \(givenName!)")

            print("email = \(email)")

            callSocialLoginAPI(type: "gmail")

        }
    }
    
    // Apple Login Button
    
    @IBAction func appleLoginButton(_ sender: UIButton) {
        
        if #available(iOS 13.0, *) {
             let provider = ASAuthorizationAppleIDProvider()
             let request = provider.createRequest()
             request.requestedScopes = [.fullName,.email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        } else {
            // Fallback on earlier versions
        }
      
        
        
    }
 

    //MARK: Google Login API
    
    func callSocialLoginAPI(type: String)   {
        if email.isEmpty && first_name.isEmpty && last_name.isEmpty {
            return
        }
//        let api_name = KUser_Api + "-login"
        let api_name = KLogin_Api
        
        if let token = userDefaults.value(forKey: "notification_token") as? String
        {
            notification_token = token
        }
        
        let params = ["user": email,"type": type,"first_name": first_name,"last_name": last_name,"phone": "","device_type": "ios","device_id": device_id,"screen_size": device_size,"device_os": "ios \(ios_version)","ip_address": "","location_name": "","latitude": "","longitude": "","browser": "","timezone": localTimeZoneName,"notification_token": notification_token,"refresh_token": "","access_token": "","user_type":"1" ,"picture": user_profile_photo_url, "social_id": social_user_id,"social_token": social_token]
        print(params)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name, is_loader_required: true, params: params, success: { (response) in
                
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 1
                {
                    print(response)
                    
                        let userDictionary = (response["data"] as! NSArray).object(at: 0) as! NSDictionary
                        CommonClass.setUserData(userDictionary: userDictionary)
                        
    //                    self.emailTxtF.text = ""
                       self.first_name = ""
                       self.last_name = ""
                       self.user_profile_photo_url = ""
                        self.self.userDefaults.set(response.value(forKey: "currency"), forKey: "currency")
                        self.userDefaults.synchronize()
                        
                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        let window = UIApplication.shared.keyWindow!
                        UIApplication.shared.keyWindow?.makeToast((response["message"] as! String), duration: 1.0, position: .bottom)
                    
                }
                else if response["status_code"] as! NSNumber == 10 {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
                   viewController.type = type
                    viewController.facebookDic = self.fbResult
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                else
                {
                    let alert = UIAlertController(title: nil, message: (response["message"] as! String), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.mobileTextField.text = ""
                        self.mobileTextField.becomeFirstResponder()
                        return
                    }))
                    let popPresenter = alert.popoverPresentationController
                    popPresenter?.sourceView = self.view
                    popPresenter?.sourceRect = self.view.bounds
                    self.present(alert, animated: true, completion: nil)
                }
            }) { (failure) in
               // COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: false, option: .transitionCurlDown)
            }
        }
        
    }
    
    private func signIn(signIn: GIDSignIn!,
                        presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
//     Dismiss the "Sign in with Google" view
    private func signIn(signIn: GIDSignIn!,
                        dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loginApiCall()  {
        
        if let token = userDefaults.value(forKey: "notification_token") as? String
        {
            notification_token = token
        }
        
        let params = ["user": "","password": "","device_type": "ios","device_id": device_id,"screen_size": device_size,"device_os": "ios \(ios_version)","ip_address": "","location_name": "","latitude": "","longitude": "","browser": "","timezone": localTimeZoneName,"notification_token": notification_token,"refresh_token": "","access_token": "","user_type":"1"]
        
        print("Params = \(params)")
        let api_name = KUser_Api + "-login"
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrl(strURL: api_name, params: params as NSDictionary, is_loader_required: true, success: { (response) in
                
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                
                if response["status_code"] as! NSNumber == 1
                {
                    // DispatchQueue.main.async {
                    
                    let userDictionary = (response["data"] as! NSArray).object(at: 0) as! NSDictionary
                    CommonClass.setUserData(userDictionary: userDictionary)
                
                    
                    self.self.userDefaults.set(response.value(forKey: "currency"), forKey: "currency")
                    self.userDefaults.synchronize()
                    
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    let window = UIApplication.shared.keyWindow!
                    UIApplication.shared.keyWindow?.makeToast((response["message"] as! String), duration: 1.0, position: .bottom)
                }
                    
                else
                {
                    DispatchQueue.main.async {
                        COMMON_ALERT.showAlert(title: response["message"] as! String , msg: "", onView: self) }
                }
            }) { (failure) in
                
            }
        }
        
    }
    
    
    func generateTokenApi() {
        if self.mobileTextField.text == "" {
            self.view.makeToast("Enter Mobile Number")
            return
        }
        
        let api_name = KOTP_GENERATE_Api
        let param = ["username":self.mobileTextField.text!]
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name, is_loader_required: true, params: param) { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 1 {
                    let viewController  = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerifyVC") as! OTPVerifyVC
                    viewController.isFromSignUp = true
                    viewController.signUpDataDic = param as NSDictionary
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                else {
                    DispatchQueue.main.async {
                        COMMON_ALERT.showAlert(title: response["message"] as! String , msg: "", onView: self) }
                }
            } failure: { (error) in
                print(error)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LoginVC : UITextFieldDelegate {

// MARK: - TextField Delegates
public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
{
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        print(newString)
    if newString.count > 10 {
        return false
    }
    if newString != "" {
    self.loginSignupButton.isHidden = false
    self.googleLoginView.isHidden = true
    self.fbLoginView.isHidden = true
    self.orLbl.isHidden = true
    self.orLeftLine.isHidden = true
    self.orRightLine.isHidden = true
    }
    else {
    self.loginSignupButton.isHidden = true
    self.googleLoginView.isHidden = false
    self.fbLoginView.isHidden = false
    self.orLbl.isHidden = false
    self.orLeftLine.isHidden = false
    self.orRightLine.isHidden = false
    }
         return true
}

public func textFieldDidBeginEditing(_ textField: UITextField) {
    print("textFieldDidBeginEditing \(textField.tag)")
    if textField.text != "" {
    self.loginSignupButton.isHidden = false
    self.googleLoginView.isHidden = true
    self.fbLoginView.isHidden = true
    self.orLbl.isHidden = true
    self.orLeftLine.isHidden = true
    self.orRightLine.isHidden = true
    }
    else {
    self.loginSignupButton.isHidden = true
    self.googleLoginView.isHidden = false
    self.fbLoginView.isHidden = false
    self.orLbl.isHidden = false
    self.orLeftLine.isHidden = false
    self.orRightLine.isHidden = false
    }
    
}

public func textFieldDidEndEditing(_ textField: UITextField)
    {
    if textField.text != "" {
    self.loginSignupButton.isHidden = false
    self.googleLoginView.isHidden = true
    self.fbLoginView.isHidden = true
    self.orLbl.isHidden = true
    self.orLeftLine.isHidden = true
    self.orRightLine.isHidden = true
    }
    else {
    self.loginSignupButton.isHidden = true
    self.googleLoginView.isHidden = false
    self.fbLoginView.isHidden = false
    self.orLbl.isHidden = false
    self.orLeftLine.isHidden = false
    self.orRightLine.isHidden = false
    }
    }
}


@available(iOS 13.0, *)
extension LoginVC :ASAuthorizationControllerDelegate
{
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error = ",error)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
     
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            self.social_token = String(decoding: credentials.identityToken!, as: UTF8.self)
            self.social_user_id = String(decoding: credentials.identityToken!, as: UTF8.self)
            appleIdentityToken = String(decoding: credentials.identityToken!, as: UTF8.self)
            appleAuthorizationCode = String(decoding: credentials.authorizationCode!, as: UTF8.self)
            
            print(appleIdentityToken)
            print(appleAuthorizationCode)
            if let email = credentials.email
            {
                if !email.contains(".appleid.com") {
                    self.email = email
                }
            }
            
            if let fname = credentials.fullName?.givenName
            {
                self.first_name = fname
            }
            if let lname = credentials.fullName?.familyName
                       {
                           self.last_name = lname
                       }
            
            if let email = credentials.email
            {
                if !email.contains(".appleid.com") {
                    self.email = email
                }
            }

         
            print(appleIdentityToken)
            print(appleAuthorizationCode)
            self.callSocialLoginAPI(type: "apple")
            
        default:
                break
        }
        
    }
    
}
extension LoginVC:ASAuthorizationControllerPresentationContextProviding
{
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    
}
