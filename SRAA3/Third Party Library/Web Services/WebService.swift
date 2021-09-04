//
//  WebService.swift
//  Go Agent
//
//  Created by Apple on 22/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class WebService: NSObject {

    class func showAlert ()
    {
        let alert = UIAlertController(title: nil, message: "Check the Internet connection", preferredStyle: .alert)
        let uiView = UIView(frame: CGRect(x: alert.view.frame.origin.x, y: 15, width: 250, height: 150))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
           return
        }))
        let viewController = UIApplication.shared.keyWindow?.rootViewController
        
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = viewController?.view
        popPresenter?.sourceRect = (viewController?.view.bounds)!
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    class func authenticationFunction(isForLogin:Bool)
    {
   
        if isForLogin {
            return
        }
        
        if  UserDefaults.standard.value(forKey: "expireDate") != nil
        {
            let currentDate = Date()
            let expireDate = (UserDefaults.standard.value(forKey: "expireDate") as! Date)
            
            if UserDefaults.standard.value(forKey: "refresh_token") != nil
            {
                refresh_token = (UserDefaults.standard.value(forKey: "refresh_token") as! String)
            }
            if currentDate > expireDate
            {
               
                        let api_name = KOauthToken_Api
                        let param = ["grant_type":"refresh_token","client_secret":"f36F4ZZN84kWE9cwYbFj2Y6er5geY9OBXF3hEQO4","client_id":"2","refresh_token":refresh_token]
                        
                        var request = URLRequest(url: NSURL(string: BASE_URL.appending(api_name))! as URL)
                        print(BASE_URL.appending(api_name))
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.httpMethod = "POST"
                        
                        do
                        {
                            // json format
                            let body = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                            
                            let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
                            
                            print("Post Data -> \(String(describing: postString))")
                            
                            request.httpBody = body
                            
                        }
                        catch let error as NSError
                        {
                            print(error)
                        }
                        
                        
                        var response: URLResponse?
                         var resultDictionary: NSDictionary!
                        do
                        {
                           let urlData = try NSURLConnection.sendSynchronousRequest(request, returning: &response)
                            resultDictionary = try (JSONSerialization.jsonObject(with: urlData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary)
                            print(resultDictionary)
                            
                            if resultDictionary["error"] != nil
                            {
                                  NotificationCenter.default.post(name: NSNotification.Name.init("LogoutNotification"), object: nil)
                             return
                            }
                            else
                            {
                                access_token = (resultDictionary["access_token"] as! String)
                                refresh_token = (resultDictionary["refresh_token"] as! String)
                                token_type  = (resultDictionary["token_type"] as! String)
                                let expireTime = (resultDictionary["expires_in"] as! NSNumber)
                                let expireDate = Date().addingTimeInterval(TimeInterval(exactly: expireTime)!)
                                UserDefaults.standard.setValue(access_token, forKey: "access_token")
                                UserDefaults.standard.setValue(expireDate, forKey: "expireDate")
                                UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
                                UserDefaults.standard.setValue(token_type, forKey: "token_type")
                                 return
                            }
                            
                        
                        }
                        catch
                        {
                            
                        }
                        
                
            }
        }
         return
    }
    
    
    class func requestGetUrl(strURL:String,is_loader_required:Bool, success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            
            if is_loader_required
            {
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setRingNoTextRadius(14.0)
                SVProgressHUD.setForegroundColor(UIColor.KMainColorCode)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
//                SVProgressHUD .show()
                
            }
            authenticationFunction(isForLogin: false)
            
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
                
            ]
            print("URl: \(BASE_URL.appending(strURL))")
            print("Headers: \(headers)")
            
            Alamofire.request(BASE_URL.appending(strURL),headers: headers).responseJSON { (response) in
                
                switch(response.result) {
                    
                case .success(_):
                    if let data = response.data
                    {
                        if is_loader_required
                        {
//                            SVProgressHUD.dismiss()
                        }
                        if let dataDictionary = JSON(data).dictionaryObject
                        {
                            success(dataDictionary as NSDictionary)
                        }
                        if let dataArray = JSON(data).arrayObject
                        {
                            success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                        }
                    }
                    break
                    
                case .failure(_):
//                    SVProgressHUD.dismiss()
                    let viewController = UIApplication.shared.keyWindow?.rootViewController
                 //   viewController?.view.makeToast(response.error?.localizedDescription, duration: 1.0, position: .bottom)
                    failure(response.error.debugDescription )
                    break
                }
            }
        }
            
        else
        {
            showAlert()
            return
        }
    }
    
    class func requestPostUrl(strURL:String, params:NSDictionary,is_loader_required:Bool, success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
        
            if is_loader_required
            {
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setRingNoTextRadius(14.0)
                SVProgressHUD.setForegroundColor(UIColor.KMainColorCode)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
//                SVProgressHUD .show()
            }
            authenticationFunction(isForLogin: false)
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
            ]
            
        print(BASE_URL + strURL)
        print("Headers: \(headers)")
        print(params)
            do
            {
                // json format
                let body = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                
                let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
                
                print("Post Data -> \(String(describing: postString))")
                
            }
            catch let error as NSError
            {
                print(error)
            }
            
        Alamofire.request(BASE_URL + strURL, method: HTTPMethod.post, parameters: params as? Parameters, encoding: JSONEncoding.default, headers: headers).responseData { (response:DataResponse<Data>) in
            
            switch(response.result) {
            case .success(_):
                if let data = response.data
                {
                    if is_loader_required
                    {
//                        SVProgressHUD.dismiss()
                    }
                    if let dataDictionary = JSON(data).dictionaryObject
                    {
                     //   print("ressss \(dataDictionary)")
                        success(dataDictionary as NSDictionary)
                    }
                    if let dataArray = JSON(data).arrayObject
                    {
                        success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                    }
                }
                break
                
            case .failure(_):
//                 SVProgressHUD.dismiss()
                 print(response.error as Any)
                 let viewController = UIApplication.shared.keyWindow?.rootViewController
               //  viewController?.view.makeToast(response.error?.localizedDescription, duration: 1.0, position: .bottom)
                 failure(response.error.debugDescription )
                 break
                }
            }
        }
            
        else
        {
            showAlert()
            return
        }
    }
    
    class func requestPutUrl(strURL:String, params:NSDictionary,is_loader_required:Bool, success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            
            if is_loader_required
            {
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setRingNoTextRadius(14.0)
                SVProgressHUD.setForegroundColor(UIColor.KMainColorCode)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
//                SVProgressHUD .show()
            }
            authenticationFunction(isForLogin: false)
            
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
            ]
            
            print(BASE_URL + strURL)
            print("Headers: \(headers)")
            print(params)
            Alamofire.request(BASE_URL + strURL, method: HTTPMethod.put, parameters: params as? Parameters, encoding: JSONEncoding.default, headers: headers).responseData { (response:DataResponse<Data>) in
                
                switch(response.result) {
                case .success(_):
                    if let data = response.data
                    {
                        if is_loader_required
                        {
//                            SVProgressHUD.dismiss()
                        }
                        if let dataDictionary = JSON(data).dictionaryObject
                        {
                            success(dataDictionary as NSDictionary)
                        }
                        if let dataArray = JSON(data).arrayObject
                        {
                            success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                        }
                    }
                    break
                    
                case .failure(_):
//                    SVProgressHUD.dismiss()
                    print(response.error as Any)
                    let viewController = UIApplication.shared.keyWindow?.rootViewController
                //    viewController?.view.makeToast(response.error?.localizedDescription, duration: 1.0, position: .bottom)
                    failure(response.error.debugDescription )
                    break
                }
            }
        }
            
        else
        {
            showAlert()
            return
        }
    }
    class func requestPostUrlWithJSONDictionaryParameters(strURL:String,is_loader_required:Bool, params:[String:Any], success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            
            if is_loader_required
            {
//                SVProgressHUD .show()
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setRingNoTextRadius(14.0)
            }
            
            authenticationFunction(isForLogin: false)
            
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
            ]
            
            print(BASE_URL.appending(strURL))
            print("Headers: \(headers)")
            print(params)
            
            do
            {
                // json format
                let body = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                
                let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
                
                print("Post Data -> \(String(describing: postString))")
                
            }
            catch let error as NSError
            {
                print(error)
            }
            print(BASE_URL.appending(strURL))
            Alamofire.request(BASE_URL.appending(strURL), method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { (response:DataResponse<Data>) in
                
                switch(response.result) {
                case .success(_):
                    if let data = response.data
                    {
                        print(JSON(data))
                        if is_loader_required
                        {
//                            SVProgressHUD.dismiss()
                        }
                        if let dataDictionary = JSON(data).dictionaryObject
                        {
                            success(dataDictionary as NSDictionary)
                        }
                        if let dataArray = JSON(data).arrayObject
                        {
                            success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                        }
                    }
                    break
                    
                case .failure(_):
//                    SVProgressHUD.dismiss()
                    failure(response.error.debugDescription )
                    break
                }
                
                
            }
        }
            
        else
        {
            showAlert()
            return
        }
    }
    
    
    class func requestPUTUrlWithJSONArrayParameters(strURL:String,is_loader_required:Bool, params:NSArray, success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            if is_loader_required
            {
//                SVProgressHUD .show()
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setRingNoTextRadius(14.0)
            }
            
            authenticationFunction(isForLogin: false)
            
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
                
            ]
            
            print(BASE_URL.appending(strURL))
            print("Headers: \(headers)")
            var request = URLRequest(url: NSURL(string: BASE_URL.appending(strURL))! as URL)
            print(BASE_URL.appending(strURL))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            do
            {
                // json format
                let body = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                
                let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
                
                print("Post Data -> \(String(describing: postString))")
                
                request.httpBody = body
                
            }
            catch let error as NSError
            {
                print(error)
            }
            
            Alamofire.request(request)
                .responseString { response in
                    // do whatever you want here
                    switch response.result {
                    case .success(_):
                        if let data = response.data
                        {
                            print(JSON(data))
                            if is_loader_required
                            {
//                                SVProgressHUD.dismiss()
                            }
                            if let dataDictionary = JSON(data).dictionaryObject
                            {
                                success(dataDictionary as NSDictionary)
                            }
                            if let dataArray = JSON(data).arrayObject
                            {
                                success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                            }
                        }
                        break
                        
                    case .failure(_):
//                        SVProgressHUD.dismiss()
                        failure(response.error.debugDescription )
                        print(response.error.debugDescription)
                        break
                    }
            }
        }
            
        else
        {
            showAlert()
            return
        }
    }
        
    class func requestDelUrl(strURL:String,is_loader_required:Bool, success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            
            if is_loader_required
            {
//                SVProgressHUD .show()
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setRingNoTextRadius(14.0)
            }
            
            authenticationFunction(isForLogin: false)
        
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
                
            ]
        print(BASE_URL.appending(strURL))
        print("Headers: \(headers)")
        Alamofire.request(BASE_URL.appending(strURL), method: HTTPMethod.delete, parameters: [:], encoding: JSONEncoding.default, headers: headers).responseData { (response:DataResponse<Data>) in
            switch(response.result) {
            case .success(_):
                if let data = response.data
                {
                    print(data)
                    if is_loader_required
                    {
//                        SVProgressHUD.dismiss()
                    }
                    if let dataDictionary = JSON(data).dictionaryObject
                    {
                        success(dataDictionary as NSDictionary)
                    }
                    if let dataArray = JSON(data).arrayObject
                    {
                        success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                    }
                    
                }
                break
                
            case .failure(_):
//                SVProgressHUD.dismiss()
                failure(response.error.debugDescription )
                break
            }
            
        }
        }
            
        else
        {
            showAlert()
            return
        }
    }
}


class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
