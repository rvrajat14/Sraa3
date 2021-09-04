//
//  NotificationsVC.swift
//  SRAA3
//
//  Created by Apple on 22/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController ,UITableViewDelegate , UITableViewDataSource {
 private let refreshControl = UIRefreshControl()
    var dataArray = NSMutableArray()
    var currentPage:Int = 1
    var maxPage:Int = 1
      var nextUrl = ""
    @IBOutlet weak var tableV: UITableView!
    
    @IBOutlet weak var clearNotificationsButton: UIButton!
    @IBOutlet weak var noDataView: UIView!
    
    
    @IBAction func clearNotificationsButton(_ sender: UIButton) {
           if dataArray.count < 1 {
            self.view.makeToast("Notifications Not Available")
            return
            }
        
            let alert = UIAlertController(title: nil, message: "Do you want to clear Notifications ?", preferredStyle: .alert)
           
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.clearNotifications()
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
                return
            }))
            let popPresenter = alert.popoverPresentationController
            popPresenter?.sourceView = self.view
            popPresenter?.sourceRect = self.view.bounds
            self.present(alert, animated: true, completion: nil)
      
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableV.rowHeight = UITableViewAutomaticDimension
        self.tableV.estimatedRowHeight = 80
        self.tableV.tableFooterView = UIView(frame: .zero)
//        if #available(iOS 10.0, *) {
//            tableV.refreshControl = refreshControl
//        } else {
//            tableV.addSubview(refreshControl)
//        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        getDataApi(loader: true)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    @objc private func refreshData(_ sender: Any) {
       self.refreshControl.endRefreshing()
    }
    
    @IBAction func popVC(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if currentPage == maxPage
        {}
        else
        {
            if (indexPath.row == self.dataArray.count - 5)
            {
                if(!nextUrl.isEmpty)
                {
                    currentPage = currentPage + 1
                    self.getDataApi(loader: false)
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "NotificationCell"
        var cell: NotificationCell! = tableView.dequeueReusableCell(withIdentifier: identifier)as? NotificationCell
        if cell == nil {
            var nib = Bundle.main.loadNibNamed("NotificationCell", owner: self, options: nil)
            cell = nib![0] as? NotificationCell
        }
        cell.configureCell(data: (dataArray[indexPath.row] as! NSDictionary))
        cell.selectionStyle = .none
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func getDataApi(loader:Bool)  {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestGetUrl(strURL: RNotificationList_Api + "/\(userDataModel.user_id!)?page=\(self.currentPage)&order=desc" , is_loader_required: loader, success: { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                 if response["status_code"] as! NSNumber == 1
                 {
                    self.nextUrl = CommonClass.checkForNull(string: ((response["data"] as! NSDictionary).value(forKey: "next_page_url")as AnyObject))
                    self.currentPage = Int(truncating: (response["data"] as! NSDictionary).object(forKey: "current_page") as! NSNumber)
                    self.maxPage = Int(truncating: (response["data"] as! NSDictionary).object(forKey: "last_page") as! NSNumber)
                    if (self.currentPage == 1)
                    {
                        self.dataArray.removeAllObjects()
                        self.dataArray = NSMutableArray.init()
                    }
                    
                    self.dataArray.addObjects(from: ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray as! [Any])
                    self.noDataView.isHidden = self.dataArray.count < 1 ? false : true
                    DispatchQueue.main.async {
                        
                        self.tableV.reloadData()
                    }
                   
                }
                 else {
                    DispatchQueue.main.async {
                        self.dataArray.removeAllObjects()
                        self.noDataView.isHidden = self.dataArray.count < 1 ? false : true
                        self.tableV.reloadData()
                    }
                 }
                
            }) { (failure) in
                
            }
        }
        
    }
    
    
    func clearNotifications() {
        let api_name = RDeleteNotificationList_Api + "/" + userDataModel.user_id
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestDelUrl(strURL: api_name, is_loader_required: true) { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 1 {
                    self.view.makeToast((response["message"] as! String), duration: 1, position: .center, title: "", image: nil, style: .init(), completion: {_ in
                        self.getDataApi(loader: true)
                    })
                }
                else {
                    self.view.makeToast((response["message"] as! String))
                    }
               
            } failure: { (error) in
                print(error)
            }
        }
     
    }
}
