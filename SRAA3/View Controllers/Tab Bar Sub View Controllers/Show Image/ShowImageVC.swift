//
//  ShowImageVC.swift
//  SRAA3
//
//  Created by Apple on 28/02/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ShowImageVC: UIViewController {

    @IBOutlet weak var imageV: UIImageView!
    var imgStr = ""
    var imageType = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageUrl = URL(string: BASE_IMAGE_URL + imageType + imgStr)
        self.imageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .refreshCached, completed: nil)
    }
    
    @IBAction func closeBtnTaped(_ sender: Any) {
        
        self.dismiss(animated: false, completion: nil)
        
    }

}
