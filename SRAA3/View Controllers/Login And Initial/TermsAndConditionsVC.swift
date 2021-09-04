//
//  TermsAndConditionsVC.swift
//  TaxiApp
//
//  Created by Apple on 11/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class TermsAndConditionsVC: UIViewController {

    @IBOutlet weak var txtV: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtV.isUserInteractionEnabled = false
        txtV.text = KAppTermsAndConditions
        
    }
    
    @IBAction func popVC(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
