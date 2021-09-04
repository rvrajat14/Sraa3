//
//  MyOrdersVC.swift
//  SRAA3
//
//  Created by Apple on 23/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class MyOrdersVC: UIViewController {
    var responseArray = NSMutableArray.init()
    @IBOutlet weak var tableV: UITableView!
    private let refreshControl = UIRefreshControl()
    
    var currentPage:Int = 1
    var maxPage:Int = 1
    var nextUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentPage = 1
        self.tableV.rowHeight = UITableViewAutomaticDimension
        self.tableV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        self.tableV.tableFooterView = UIView(frame: CGRect.zero)
        self.tableV.emptyDataSetSource = self
        self.tableV.emptyDataSetDelegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 10.0, *) {
            tableV.refreshControl = refreshControl
        } else {
            tableV.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name("OrderListUpdated"), object: nil)
        
        self.tableV.isHidden = true
        
//        orderApiCall(loader: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: "userData") != nil {
            orderApiCall(loader: true)
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
        self.currentPage = 1
        orderApiCall(loader: false)
    }
    
    //MARK: -CALL API
    
    func orderApiCall(loader: Bool){
        
        let url = ROrder_Api + "?page=\(currentPage)&include_address=true&customer_id=\(userDataModel.user_id!)&orderby=created_at&per_page=10&timezone=\(localTimeZoneName)"
        
        print(url)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestGetUrl(strURL: url , is_loader_required: loader, success: { (response) in
              self.refreshControl.endRefreshing()
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                
                self.tableV.isHidden = false
                if response["status_code"] as! NSNumber == 1
                {
                    let array = (((response.value(forKey: "data") as! NSDictionary).value(forKey: "data"))as! NSArray)
                    
                    self.nextUrl = CommonClass.checkForNull(string: ((response["data"] as! NSDictionary).value(forKey: "next_page_url")as AnyObject))
                    self.currentPage = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "current_page") as! NSNumber)
                    self.maxPage = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "last_page") as! NSNumber)
                    
                    if (self.currentPage == 1)
                    {
                        self.responseArray.removeAllObjects()
                        self.responseArray = NSMutableArray.init()
                    }
                    
                    for item in array
                    {
                        let dic = item as! NSDictionary
                        let model = OrderListModel()
                        model.order_id = CommonClass.checkForNull(string: (dic.value(forKey:"order_id") as AnyObject))
                        model.order_status = CommonClass.checkForNull(string: (dic.value(forKey:"order_status") as AnyObject))
                        model.order_color = CommonClass.checkForNull(string: (dic.value(forKey:"order_color") as AnyObject))
                        model.sub_total = CommonClass.checkForNull(string: (dic.value(forKey:"sub_total") as AnyObject))
                        model.total = CommonClass.checkForNull(string: (dic.value(forKey:"total") as AnyObject))
                        model.store_photo = CommonClass.checkForNull(string: (dic["store_photo"] as AnyObject))
                        model.sub_total = CommonClass.checkForNull(string: (dic.value(forKey:"sub_total") as AnyObject))
                        model.store_thumbnail = CommonClass.checkForNull(string: (dic.value(forKey: "store_thumb_photo") as AnyObject))
                        model.created_at_formatted = CommonClass.checkForNull(string: (dic.value(forKey: "created_at_formatted") as AnyObject))
                        model.store_name = CommonClass.checkForNull(string: (dic.value(forKey: "store_name") as AnyObject))
                        
                        model.service_details = dic.value(forKey: "service_details")as! NSArray
                        
                        self.responseArray.add(model)
                    }
                    self.tableV.reloadData()
                }
                else
                {
                 self.tableV.reloadData()
                }
               
            }) { (failure) in
               
            }
        }
       
    }
}

//MARK : -TableView DataSource Methods///////

extension MyOrdersVC:UITableViewDataSource, DZNEmptyDataSetSource , DZNEmptyDataSetDelegate
{
    //MARK: - Empty TableView
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "empty-bookings")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "NO REQUEST"
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont(name:KMainFontSemiBold, size: 17)!]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "There is no request history to show here."
        
        let attribs = [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont(name:KMainFont, size: 13)!]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 10
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return 0
       return responseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let identifier = "OrderCell"
        var cell: OrderCell! = tableView.dequeueReusableCell(withIdentifier: identifier)as? OrderCell
        if cell == nil {
            var nib = Bundle.main.loadNibNamed("OrderCell", owner: self, options: nil)
            cell = nib![0] as? OrderCell
        }
        cell.selectionStyle = .none
        
        let model = self.responseArray.object(at: indexPath.row)as! OrderListModel
        var imageUrl : URL!
        if model.service_details.count > 0 {
            let serviceDetailDic = (model.service_details).object(at: 0)as! NSDictionary
            imageUrl = URL(string: BASE_IMAGE_URL + KCategory_Api + "/" + (serviceDetailDic.value(forKey: "category_photo")as! String))
            cell.nameLbl.text = (serviceDetailDic.value(forKey: "category_title")as! String)
        }
        else
        {
        imageUrl = URL(string: BASE_IMAGE_URL + "store/" +  model.store_photo)
            
            if(model.store_name.isEmpty)
            {
                cell.nameLbl.text = "NA"
                cell.nameLbl.textColor = UIColor.hexToColor(hexString: "#9A9A9A")
            }
            else
            {
                cell.nameLbl.text = model.store_name
                cell.nameLbl.textColor = UIColor.black
            }
        }
        cell.imageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .refreshCached, completed: nil)
     
        cell.orderStatusButton.backgroundColor = UIColor.hexToColor(hexString: model.order_color)
    
        cell.orderStatusButton.layer.cornerRadius = 15
        
        cell.orderNumberLbl.text = "#" + model.order_id
        cell.dateLbl.text = model.created_at_formatted
        cell.priceLbl.text = currencySymbol + CommonClass.getCorrectPriceFormat(price: model.total)
      
        cell.priceLbl.layer.cornerRadius = 10
        cell.orderStatusButton.setTitle(model.order_status.uppercased(), for: .normal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if currentPage == maxPage
        {}
        else
        {
            if (indexPath.row == self.responseArray.count-1)
            {
                if(!nextUrl.isEmpty)
                {
                    currentPage = currentPage + 1
                    self.orderApiCall(loader: false)
                }
            }
        }
    }
}

////////////////////////////////////////////

//MARK : -TableView DataSource Methods///////

extension MyOrdersVC:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let model = self.responseArray.object(at: indexPath.row)as! OrderListModel
         let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderDetailsVC") as! OrderDetailsVC
         vc.order_id = model.order_id
         vc.serviceDetailArray = model.service_details
         self.navigationController?.pushViewController(vc, animated: true)
    }
}
