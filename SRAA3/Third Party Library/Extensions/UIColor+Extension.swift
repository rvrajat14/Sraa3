//
//  UIColor+Extension.swift
//  Sercal
//
//  Created by Sucharu on 07/05/18.
//  Copyright © 2018 TrothMatrix (OPC) Private Limited. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
        
   static let buttonTopColor = UIColor.hexToColor(hexString: "#1062C1")
   static let KMainBackVColor = UIColor(red: 242.0/255.0, green: 243.0/255.0, blue: 247.0/255.0, alpha: 1)
   static let KLightGreyColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1)
   static let KMainColorCode = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
   static let KBorderDarkColorCode = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1)
   static let KBorderColorCode = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.15)
   static let KLinkColorCode = UIColor(red: 73.0/255.0, green: 92.0/255.0, blue: 140.0/255.0, alpha: 1)
   
    class func hexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    class func intFromHexString(_ hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
    
}



