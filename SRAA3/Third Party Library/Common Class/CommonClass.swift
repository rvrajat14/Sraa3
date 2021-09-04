//
//  CommonClass.swift
//  OneTime
//
//  Created by Apple on 04/09/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import SVProgressHUD

let ACCEPTABLE_CHARACTERS = "abcdefghijklmnopqrstuvwxyz0123456789_."
//let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."
let ACCEPTABLE_ONLY_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

var KStore_id = "0"

let KNavigationTitleSize = 19
let KEmptyTableCellTitleSize = 17
let KMainFont = "OpenSans"
let KMainFontBold = "OpenSans-Bold"
let KMainFontSemiBold = "OpenSans-Semibold"

let KAnimationDuration = 0.7
let KSpringDamping = 0.7
let KSpringVelocity = 0.2
let KCameraZoom = 12
let KNavTitleSize = 17

let KGoogleMap_Key = "AIzaSyC8i3j9ZZAQVWkRX3d4-9HH5yP97gaSUVQ"

let RazorPay_Key = "rzp_test_wM9lBkERzB7NUd"
//let RazorPay_Key = "rzp_live_WSjiRinpwReLJG"


// Common Variabeles

var selectedAddressDic = NSMutableDictionary.init()

var KAppTermsAndConditions = ""
var KAdminContact = ""
var KAppVersion = ""
var KAdminEmail = ""
var KAgentAvailableStatus = ""
var currencySymbol = ""
var notification_token = ""
var KFormId = ""

class CommonClass: NSObject {
   class func isValidPhone(phone: String) -> Bool {
        
        let phoneRegex = "^[+]?[0-9]{10,15}$";
        let valid = NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
        return valid
    }
    
    class func StartLoader()
    {
        SVProgressHUD .show()
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.setRingNoTextRadius(14.0)
    }
   
    class func StopLoader()
    {
        SVProgressHUD.dismiss()
    }
    
    class func checkForNull(string: AnyObject) -> ( String) {
        
        if string is NSNull || (String(format: "%@", string as! CVarArg)).isEmpty {
            return ( "")
        }
        return ((String(format: "%@", string as! CVarArg)))
    }

    class func emptyUserDefaultData() {
        
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "userData")
        userDefaults.removeObject(forKey: "expireDate")
        userDefaults.removeObject(forKey: "refresh_token")
        userDefaults.removeObject(forKey: "access_token")
        userDefaults.removeObject(forKey: "token_type")
        userDefaults.synchronize()
    }
    
    class func setUserData(userDictionary:NSDictionary)  {
        
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
        
        var username = ""
        var password = ""
        
        let social_id = CommonClass.checkForNull(string: (userDictionary.object(forKey: "social_id") as AnyObject))
        let user_email = CommonClass.checkForNull(string: (userDictionary.object(forKey: "email") as AnyObject))
        let user_phone = CommonClass.checkForNull(string: (userDictionary.object(forKey: "phone") as AnyObject))
        
        username = (user_email != "") ? user_email : user_phone
        password = social_id
      
        
      
        let api_name = KOauthToken_Api
//        let username = CommonClass.checkForNull(string: (userDictionary.object(forKey: "username") as AnyObject))
//        let password = CommonClass.checkForNull(string: (userDictionary.object(forKey: "password") as AnyObject))
        let param = ["grant_type":"password","client_secret":"f36F4ZZN84kWE9cwYbFj2Y6er5geY9OBXF3hEQO4","client_id":"2","username":username,"password":password]
        
        WebService.requestPostUrl(strURL: api_name, params: param as NSDictionary, is_loader_required: true, success: { (response) in
            
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
        
        
    }
    
    class func cartItemCount (productID: String?,isOptionItem: Bool?) -> Int {
        var count = Int()
        count = 1
        
        for (index,value) in (productCartArray.enumerated()) {
            let dic = value as! NSDictionary
            let final_id = isOptionItem ?? false ? "id" : "item_id"
            if CommonClass.checkForNull(string: dic[final_id] as AnyObject) == productID
            {
                count = dic.object(forKey: "quantity") as! Int
                break
            }
        }
        return count
    }
    
    class func ifProductAlreadyInCart (productID: String?,isOptionItem: Bool?) -> (isMatched: Bool, count: Int, index: Int) {
        var result: Bool
        var count = 0
        
        
        result = false
        
        for (index,value) in (productCartArray.enumerated()){
            let dic = value as! NSDictionary
            
            let final_id = isOptionItem ?? false ? "id" : "item_id"
            if (dic[final_id] as? NSNumber)?.stringValue == productID
            {
                result = true
                count = dic.object(forKey: "quantity") as! Int
                return (result,count,index)
                
            }
            result = false
        }
        return (result,count,-1)
    }
    class func getCorrectPriceFormat(price: String) -> String {
        if price.isEmpty {
            return ""
        }
        let newPrice = price.replacingOccurrences(of: ",", with: "")
        
        let float_value = Float(newPrice)
        return String(format: "%.2f", (float_value)!)
        
        
    }
    //MARK: Total Number of Items in Cart
    
    class func calculateTotalNumberOfItemsInCart() -> String {
        if productCartArray.count > 0 {
            var total_items = 0
            for dataDic1 in productCartArray {
                let dataDic = dataDic1 as! NSDictionary
                let count = Int(truncating: dataDic.object(forKey: "quantity") as! NSNumber)
                total_items = total_items + count
            }
            return String(total_items)
        }
        return "0"
    }
    
    class func getTheTotalQuantityOfProductWithId(p_id: String,isOptionItem: Bool?) -> String {
        
        var count = 0
        
        for dataDic in (productCartArray) {
            let final_id = isOptionItem ?? false ? "id" : "item_id"
            if CommonClass.checkForNull(string: (dataDic as! NSDictionary).object(forKey: final_id) as AnyObject) ==  (p_id)
            {
                count += ((dataDic as! NSDictionary).object(forKey: "quantity") as! Int)
            }
        }
        
        return String(count)
        
    }
    
    
}

class COMMON_ALERT {
    class func showAlert (title:String, msg:String, onView: UIViewController)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            return
        }))
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = onView.view
        popPresenter?.sourceRect = (onView.view.bounds)
        onView.present(alert, animated: true, completion: nil)
    }
}

class Utilities {
    
    class func topCornerBorder(view: UIView)  {
        
        if #available(iOS 11.0, *){
            view.clipsToBounds = true
            view.layer.cornerRadius = 10
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }else{
          /*  let rectShape = CAShapeLayer()
            rectShape.bounds = view.frame
            rectShape.position = view.center
            rectShape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
            view.layer.mask = rectShape */
            
            view.clipsToBounds = true
            view.layer.cornerRadius = 10
            
        }
    }
    
    class  func dropShadow(viewlayer: UIView , scale: Bool = true) {
        viewlayer.layer.masksToBounds = false
        viewlayer.layer.shadowColor = UIColor(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 0.3).cgColor
        viewlayer.layer.shadowOpacity = 0.5
        viewlayer.layer.shadowOffset = CGSize(width: 0, height: 2.5)
        viewlayer.layer.shadowRadius = 3.0
        viewlayer.layer.shouldRasterize = true
        viewlayer.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    class func shadowLayer1(viewLayer: CALayer , shadow: Bool)
    {
        //  viewLayer.masksToBounds = true
        viewLayer.masksToBounds = false
        viewLayer.backgroundColor = UIColor.white.cgColor
        viewLayer.cornerRadius = 14
        viewLayer.shadowColor = UIColor.black.cgColor
        viewLayer.shadowOffset = CGSize(width: 1, height: 5)
        viewLayer.shadowRadius = 8
        viewLayer.shadowOpacity = 0.2
        viewLayer.shadowPath = UIBezierPath(roundedRect: viewLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 14, height: 14)).cgPath
        // viewLayer.shadowShouldRasterize = true
        // viewLayer.shadowRasterizationScale = UIScreen.main.scale
    }
    class func shadowLayerToLabel(viewLayer: CALayer , shadow: Bool)
    {
        viewLayer.masksToBounds = true
        viewLayer.borderColor = UIColor(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1).cgColor
        viewLayer.borderWidth = 0.0
        if shadow {
             viewLayer.masksToBounds = false
            viewLayer.borderColor = UIColor.KBorderDarkColorCode.cgColor
            viewLayer.shadowColor = UIColor(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1).cgColor
            viewLayer.shadowOffset = CGSize(width: 0, height: 2.0)
            viewLayer.shadowOpacity = 0.7
            viewLayer.shadowRadius = 3.0
            viewLayer.cornerRadius = 5.0
        }
    }
    
    class func shadowLayerToCollectionCell(viewLayer: CALayer , shadow: Bool)
    {
        viewLayer.borderColor = UIColor(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 0.14).cgColor
        viewLayer.borderWidth = 0.5
        if shadow {
            viewLayer.masksToBounds = false
            viewLayer.shadowColor = UIColor(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 0.2).cgColor
            viewLayer.shadowOffset = CGSize(width: 0, height: 2.5)
            viewLayer.shadowOpacity = 1.5
            viewLayer.shadowRadius = 2.0
            viewLayer.cornerRadius = 2.0
        }
    }
    
    class func shadowLayerToProfileView(viewLayer: CALayer)
    {
            viewLayer.masksToBounds = false
            viewLayer.shadowColor = UIColor.black.cgColor
            viewLayer.shadowOffset = CGSize(width: 0.5, height: 1.0)
            viewLayer.shadowOpacity = 0.35
            viewLayer.shadowRadius = 3.0
           // viewLayer.cornerRadius = 1.0
    }
    class func shadowLayerWithLightColor(viewLayer: CALayer , shadow: Bool)
    {
        viewLayer.borderColor = UIColor(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 0.1).cgColor
        viewLayer.borderWidth = 0.5
        if shadow {
            viewLayer.masksToBounds = false
            viewLayer.shadowColor = UIColor(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 0.2).cgColor
            viewLayer.shadowOffset = CGSize(width: 0, height: 2.5)
            viewLayer.shadowOpacity = 1.5
            viewLayer.shadowRadius = 2.0
            viewLayer.cornerRadius = 3.0
        }
    }
    class func AddBorder(view: UIView)
    {
        view.layer.borderColor = UIColor.lightGray.cgColor
       // view.layer.borderColor = (UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0) .cgColor)
        view.layer.borderWidth = 1.0
        view.layer.masksToBounds = true
    }
    
   class func circularView(view: UIView) {
    
        view.layer.cornerRadius = view.frame.size.width/2
        view.layer.masksToBounds = true
    
    }
    
   class func setButtonGradiantColor(button:UIButton) {
      let gradientColor = CAGradientLayer()
       gradientColor.frame = button.bounds
       gradientColor.colors = [#colorLiteral(red: 0.1277451515, green: 0.1185270026, blue: 0.1236923411, alpha: 1).cgColor,#colorLiteral(red: 0.1277451515, green: 0.1185270026, blue: 0.1236923411, alpha: 1).cgColor,#colorLiteral(red: 0.1277451515, green: 0.1185270026, blue: 0.1236923411, alpha: 1).cgColor,#colorLiteral(red: 0.2372479439, green: 0.2372866571, blue: 0.2372357547, alpha: 1).cgColor]
       gradientColor.startPoint = CGPoint(x: 0.0, y: 0.0)
       gradientColor.endPoint = CGPoint(x: 1.0, y: 0.0)
       button.layer.insertSublayer(gradientColor, at: 0)
    }

}

func getLabelHeight(_ text: String?, withWidth width: CGFloat , withFont fontSize:Int,fontName: String) -> CGFloat {
    var size = CGSize.zero
    if text?.count == 0 {
        size = CGSize(width: 0, height: 0)
    }
    else {
        let constraint = CGSize(width: width, height: 8000)
        let context = NSStringDrawingContext()
        let boundingBox: CGSize = text!.boundingRect(with: constraint, options: .usesLineFragmentOrigin, attributes: [.font: UIFont(name: fontName, size: CGFloat(fontSize)) as Any], context: context).size
        size = CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
    }
    return size.height
}




extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 0))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIView {
    
    func setGradientTopToBottom(color1: UIColor , color2: UIColor , color3: UIColor ) {
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0) //Dark From bottom
        
        gradient.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        
        self.layer.insertSublayer(gradient, at: 0)
        
    }
    
    func setGradientLeftToRight(color1: UIColor , color2: UIColor , color3: UIColor ) {
        //[mainView setBackgroundColor:[UIColor clearColor]];
        let grad = CAGradientLayer()
        grad.frame = self.bounds
        grad.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        self.layer.insertSublayer(grad, at: 0)
        grad.startPoint = CGPoint(x: 0.0, y: 0.5)
        grad.endPoint = CGPoint(x: 1.0, y: 0.5)
    }

}

  
