//
//  SocialMediaVC.swift
//  My MM
//
//  Created by Kishore on 02/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class SocialMediaVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var socialMediaDataArray = NSMutableArray.init()
    
    @IBAction func backButton(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        getSocialDataAPI()
        
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 10))
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        navigationItem.title = "Social Media"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - Selector Methods//////////
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if socialMediaDataArray.count > 0 {
            return socialMediaDataArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if cell.isEqual(nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        if socialMediaDataArray.count > 0 {
            cell.textLabel?.font = UIFont(name: KMainFont, size: 15)
            cell.textLabel?.text = ((socialMediaDataArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "key_display_title") as! String)
          //  cell.textLabel?.font = UIFont(name: KMainFontSemiBold, size: 16)
            cell.accessoryType = .disclosureIndicator
            
            let str = ((socialMediaDataArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "key_title")
                as! String)
            
            if(str == "facebook")
            {
                cell.imageView?.image = #imageLiteral(resourceName: "facebook-logo")
            }
            if(str == "google")
            {
                cell.imageView?.image = #imageLiteral(resourceName: "google-logo")
            }
            if(str == "twitter")
            {
                cell.imageView?.image = #imageLiteral(resourceName: "twitter-logo")
            }
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = ((socialMediaDataArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "key_value") as! String)
        UIApplication.shared.open(URL(string : url)!, options: [:], completionHandler: { (status) in
            
        })
        
    }
   
    //MARK: Call API
    
    func getSocialDataAPI() {
        
        let api_name = KAppSettings + "?type=social"
        
        WebService.requestGetUrl(strURL: api_name , is_loader_required: false, success: { (response) in
            print(response)
            
            if response["status_code"] as! NSNumber == 1
            {
                let dataArray = (response["data"] as! NSArray).mutableCopy() as! NSMutableArray
                for item in dataArray {
                    let keyTitle = (item as! NSDictionary).value(forKey: "key_title") as! String
                    if keyTitle == "facebook" || keyTitle == "google" || keyTitle == "twitter" {
                        self.socialMediaDataArray.add(item)
                    }
                }
                self.tableView.reloadData()
            }
            else
            {
                 COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
            }
        }) { (failure) in
           
        }
        
    }
}
