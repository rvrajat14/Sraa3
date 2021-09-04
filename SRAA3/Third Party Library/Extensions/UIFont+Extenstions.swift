//
//  UIFont+Extenstions.swift
//  Sercal
//
//  Created by Sucharu on 07/05/18.
//  Copyright © 2018 TrothMatrix (OPC) Private Limited. All rights reserved.
//

import Foundation
import UIKit



extension UIFont {
    
    static var navigationBarTitle:UIFont {
        return UIFont.init(name: KMainFontBold, size: 17.0)!
    }
    static var initialLoginButtonTitle:UIFont {
        return UIFont.init(name: KMainFontBold, size: 17.0)!

    }
   
    static var privacyLabelFont:UIFont {
        return UIFont.init(name: KMainFont, size: 12.0)!
        
    }
}
