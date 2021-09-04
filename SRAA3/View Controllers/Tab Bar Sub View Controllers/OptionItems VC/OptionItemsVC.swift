//
//  OptionItemsVC.swift
//  SRAA3
//
//  Created by IOS on 29/10/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class OptionItemsVC: UIViewController {

    
    @IBOutlet weak var tableV: UITableView!
    var selectedOptionsArray = [NSDictionary]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 15))
        
    }
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension OptionItemsVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedOptionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if( !(cell != nil))
               {
                   cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
               }
        let dict = self.selectedOptionsArray[indexPath.row]
        cell!.textLabel?.text = (dict.value(forKey: "title") as! String)
        cell!.selectionStyle = .none
        return cell!
    }
    
}
