//
//  UserDataClass.swift
//  Laundrit
//
//  Created by Kishore on 27/09/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class UserDataClass: NSObject, NSCoding{
    
    var user_id:String!
    var first_name:String!
    var last_name:String!
    var email_id:String!
    var username:String!
    var phone:String!
    var session_id:String!
    var profile_image:String!
    var currencySymbol:String!
    
    init(user_id: String,first_name: String,last_name: String,email_id: String,username:String, phone: String, session_id:String, profile_image: String,currencySymbol:String) {
        self.user_id = user_id
        self.first_name = first_name
        self.last_name = last_name
        self.email_id = email_id
        self.username = username
        self.phone = phone
        self.session_id = session_id
        self.profile_image = profile_image
        self.currencySymbol = currencySymbol
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let Kuser_id =  aDecoder.decodeObject(forKey: "user_id") as! String
        let Kfirst_name = aDecoder.decodeObject(forKey: "first_name") as! String
        let Klast_name = aDecoder.decodeObject(forKey: "last_name") as! String
        let Kemail_id = aDecoder.decodeObject(forKey: "email") as! String
        let Kusername = aDecoder.decodeObject(forKey: "username") as! String
        let Kphone = aDecoder.decodeObject(forKey: "phone") as! String
        let Ksession_id = aDecoder.decodeObject(forKey: "user_session_id") as! String
        let Kprofile_image = aDecoder.decodeObject(forKey: "photo") as! String
        let Kcurrency_symbol = aDecoder.decodeObject(forKey: "currency_symbol") as! String
        
        self.init(user_id: Kuser_id, first_name: Kfirst_name, last_name: Klast_name, email_id: Kemail_id,username: Kusername, phone: Kphone, session_id: Ksession_id, profile_image: Kprofile_image , currencySymbol : Kcurrency_symbol)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(user_id, forKey: "user_id")
        aCoder.encode(first_name, forKey: "first_name")
        aCoder.encode(last_name, forKey: "last_name")
        aCoder.encode(email_id, forKey: "email")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(session_id, forKey: "user_session_id")
        aCoder.encode(profile_image, forKey: "photo")
        aCoder.encode(currencySymbol, forKey: "currency_symbol")
    }
    
}

