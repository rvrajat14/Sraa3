//
//  String+Extensions.swift
//  Sercal
//
//  Created by Sucharu on 07/05/18.
//  Copyright © 2018 TrothMatrix (OPC) Private Limited. All rights reserved.
//

import Foundation




extension String
{
    
     
        func index(from: Int) -> Index {
            return self.index(startIndex, offsetBy: from)
        }
        
        func substring(from: Int) -> String {
            let fromIndex = index(from: from)
            return substring(from: fromIndex)
        }
        
        func substring(to: Int) -> String {
            let toIndex = index(from: to)
            return substring(to: toIndex)
        }
        
        func substring(with r: Range<Int>) -> String {
            let startIndex = index(from: r.lowerBound)
            let endIndex = index(from: r.upperBound)
            return substring(with: startIndex..<endIndex)
        }
   
    
    func isBlank() -> Bool
    {
        
        
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == ""
        
        
    }
    
    func isValidEmail() -> Bool
    {
        
        let regex = try! NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$",
                                             options: [.caseInsensitive])
        
        
        return regex.firstMatch(in: self, options:[],
                                range: NSMakeRange(0, self.count)) != nil
        
        
        
    }
    
    func isValidPassword() -> Bool
    {
        return self.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines).count <=  15 && self.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines).count >=  5
        
    }
    
    func isValidSecurePassword() -> Bool {
        
        let cs:NSCharacterSet = NSCharacterSet(charactersIn:"$%&@_-#!")
        let decimalCharacters = NSCharacterSet.decimalDigits
        
        return ((self.rangeOfCharacter(from:decimalCharacters) != nil) || (self.rangeOfCharacter(from:cs as CharacterSet) != nil)) && ((self.rangeOfCharacter(from:NSCharacterSet.uppercaseLetters) != nil) ||  (self.rangeOfCharacter(from:NSCharacterSet.lowercaseLetters) != nil) )
        
        
    }
    
}
