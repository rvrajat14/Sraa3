//
//  WalletVC.swift
//  SRAA3
//
//  Created by Apple on 24/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class WalletVC: UIViewController , UITableViewDataSource , UITableViewDelegate , DZNEmptyDataSetSource , DZNEmptyDataSetDelegate {
   
     private let refreshControl = UIRefreshControl()
 
    @IBOutlet weak var earnedLine: UIView!
    @IBOutlet weak var spentLine: UIView!
    @IBOutlet weak var spentButton: UIButton!
    @IBOutlet weak var earnedButton: UIButton!
    @IBOutlet weak var headerTotalPointsLbl: UILabel!
    @IBOutlet weak var headerTitleLbl: UILabel!
    var responseArray = NSMutableArray.init()
    @IBOutlet weak var tableV: UITableView!
    var walletFilter = "EARNED"
    
    
    @IBAction func earnedButton(_ sender: UIButton) {
        self.walletFilter = "EARNED"
        self.getWalletApiCall(loader: true)
    }
    
    @IBAction func spentButton(_ sender: UIButton) {
        self.walletFilter = "SPENT"
        self.getWalletApiCall(loader: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableV.rowHeight = UITableViewAutomaticDimension
        self.tableV.estimatedRowHeight = 50
        self.tableV.tableFooterView = UIView(frame: .zero)
        self.tableV.emptyDataSetSource = self
        self.tableV.emptyDataSetDelegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 10.0, *) {
            tableV.refreshControl = refreshControl
        } else {
            tableV.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.tableV.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "userData") != nil {
            getWalletApiCall(loader: true)
        }
        else {
            let alert = UIAlertController(title: "Login Required", message: "You have to login first to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (action) in
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let navigationController = UINavigationController(rootViewController: viewController)
                isFromAppdelegate = false
                self.present(navigationController, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                self.tabBarController?.selectedIndex = 0
            }))
            
            let popPresenter = alert.popoverPresentationController
            popPresenter?.sourceView = self.view
            popPresenter?.sourceRect = self.view.bounds
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    
    @objc private func refreshData(_ sender: Any) {
       // self.currentPage = 1
        getWalletApiCall(loader: false)
    }
    
    func getWalletApiCall(loader: Bool) {
        var titleVal = ""
        if walletFilter == "EARNED" {
            self.earnedLine.isHidden = false
            self.spentLine.isHidden = true
            titleVal = "1"
        }
        else {
            self.earnedLine.isHidden = true
            self.spentLine.isHidden = false
            titleVal = "0"
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestGetUrl(strURL: RWallet_Api + "/" + (userDataModel.user_id!) + "?earn=\(titleVal)", is_loader_required: loader, success: { (response) in
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                print("Wallet response \(response)")
                self.tableV.isHidden = false
                self.responseArray = NSMutableArray.init()
                self.refreshControl.endRefreshing()
                if (response.value(forKey: "status_code")as! NSNumber) == 1
                {
                    let dic = response["data"]as! NSDictionary
                    self.responseArray = ((dic.value(forKey: "history")) as! NSArray).mutableCopy() as! NSMutableArray
                    self.headerTotalPointsLbl.text = CommonClass.checkForNull(string: dic["total_points"]as AnyObject)
                    self.headerTitleLbl.text = dic["total_money"] as? String
                    self.tableV.reloadData()
                }
                else
                {
                    COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
                }
                
                
            }) { (failure) in
                
            }
        }
        
    }
    
    //MARK: - Empty TableView
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "empty-wallet")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "NO HISTORY"
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont(name:KMainFontSemiBold, size: 16)!]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "There is no history to show here."
        
        let attribs = [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont(name:KMainFont, size: 13)!]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 1
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 10
    }
    
    //MARK: - TableView Delegate And Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      //  return 0
        return self.responseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let identifier = "WalletHistoryCell"
        
        var cell: WalletHistoryCell! = tableView.dequeueReusableCell(withIdentifier: identifier)as? WalletHistoryCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("WalletHistoryCell", owner: self, options: nil)
            cell = nib![0] as? WalletHistoryCell
        }
        
        cell.selectionStyle = .none
        let dic = self.responseArray[indexPath.row]as! NSDictionary
        let points = CommonClass.checkForNull(string: dic["points"] as AnyObject)
        if points == "1"
        {
            cell.pointsLbl.text = "\(points) point " + CommonClass.checkForNull(string: dic["text"] as AnyObject)
        }
        else
        {
            cell.pointsLbl.text = "\(points) points " + CommonClass.checkForNull(string: dic["text"] as AnyObject)
        }
        
        cell.dateLbl.text = CommonClass.checkForNull(string: dic["date"] as AnyObject)
        let status = CommonClass.checkForNull(string: dic["earn"] as AnyObject)
        if status == "0"
        {
            cell.arrowImg.image = #imageLiteral(resourceName: "arrow_red")
        }
        else
        {
            cell.arrowImg.image = #imageLiteral(resourceName: "arrow_green")
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        {
            cell.separatorLbl.isHidden = true
        }
        else
        {
            cell.separatorLbl.isHidden = false
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView.init()
        var titleLbl = UILabel.init()
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        titleLbl = UILabel(frame: CGRect(x: 16, y: 12, width: self.view.frame.size.width - 32, height: 20))
       
        titleLbl.text = "History"
       
        headerView.backgroundColor = UIColor.white
        titleLbl.font = UIFont(name: KMainFont, size: 16)
        titleLbl.textColor = UIColor.black
        headerView.addSubview(titleLbl)
        return headerView
    }
    
}
