//
//  UIImageView + Extension.swift
//  Sercal
//
//  Created by Sucharu on 17/05/18.
//  Copyright © 2018 TrothMatrix (OPC) Private Limited. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage


extension UIImageView {
    
    func makeRounded() {
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.size.height / 2.0

    }
    
    
    func loadImageWithUrlWithFullSize(urlString:String)
    {
        
        let url1 = urlString.replacingOccurrences(of: " ", with: "%20")
        
        guard let url = URL(string: url1) else { return }
        
        
        let image:UIImage! = UIImage(named:"Logo")
        
        self.sd_setImage(with: url, placeholderImage: image, options: SDWebImageOptions.progressiveDownload)  { (image, bubble, _, _) in
            
            if image != nil
            {
                SDImageCache.shared().store(image, forKey: url.absoluteString)
                self.image = image
                  self.contentMode = UIViewContentMode.scaleAspectFill
                
            }
 
        }
        
    }
    
    func loadProfileImage(with urlString:String)
    {
        
        let url1 = urlString.replacingOccurrences(of: " ", with: "%20")
        
        guard let url = URL(string: url1) else { return }
        
        let image:UIImage! = UIImage(named:"user_placeholder")
        
        self.sd_setImage(with: url, placeholderImage: image, options: SDWebImageOptions.progressiveDownload)  { (image, bubble, _, _) in
            
            if image != nil
            {
                SDImageCache.shared().store(image, forKey: url.absoluteString)
                self.image = image
                self.contentMode = UIViewContentMode.scaleAspectFill
                
            }
            
        }
  
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}
