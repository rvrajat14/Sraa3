//
//  AlertVC.swift
//  Taco
//
//  Created by IOS on 09/10/20.
//  Copyright © 2020 Kishore. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class AlertVC: UIViewController {

    @IBOutlet weak var gifView: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mainView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.layer.cornerRadius = 8
        gifView.loadGif(asset: "three_dots")
    }
}
