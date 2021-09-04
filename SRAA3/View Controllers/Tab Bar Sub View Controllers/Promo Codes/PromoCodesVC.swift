//
//  PromoCodesVC.swift
//  Mataem
//
//  Created by Kishore on 14/09/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit


class PromoCodesVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var topView: UIView!
    var window = UIWindow()
    var params = NSDictionary.init()
    
    @IBOutlet weak var applyButton: UIButton!
    @IBAction func applyButton(_ sender: UIButton) {
        if (couponTxtField.text?.isEmpty)! {
            self.view.makeToast("Enter coupon code")
            self.view.clearToastQueue()
            return
        }
        self.coupon_code = couponTxtField.text!
        applyCouponAPI(loader: true)
    }
    @IBOutlet weak var couponTxtField: UITextField!
    
    var coupon_code = "",responseMsg = ""
    
    var itemDataArray = NSMutableArray.init()
    var allDataArray = NSMutableArray.init()
    var paymentDataDic = NSMutableDictionary.init()
    
    var currentPage:Int = 1
    var maxPage:Int = 1
    var nextUrl = ""

    @IBOutlet weak var noDataView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 12))
        self.tableView.tableFooterView = UIView(frame: .zero)
    //  SHADOW_EFFECT.makeBottomShadow(forView: self.noDataView, shadowHeight: 5)
        getCouponListDataAPI(loader:false,page:1)
        self.topView.layer.masksToBounds = true
        self.topView.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -TableView Methods /////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if self.allDataArray.count > 0
            {
                return self.allDataArray.count
            }
            return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nib:UINib = UINib(nibName: "notificationMainTableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "notificationMainTableCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationMainTableCell") as! notificationMainTableCell
        if self.allDataArray.count>0 {
        let tmpDataDic = self.allDataArray.object(at: indexPath.row) as! NSDictionary
        cell.tag = indexPath.row
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
        
        cell.addGestureRecognizer(longPressGesture)
        cell.notificationTitleLbl.text = (tmpDataDic.object(forKey: "coupon_title") as! String)
        let coupon_code = (tmpDataDic.object(forKey: "coupon_code") as! String)
        let coupon_desc = (tmpDataDic.object(forKey: "coupon_desc") as! String)
        cell.couponCodeLbl.text = coupon_code
        if !coupon_desc.isEmpty
        {
            cell.notificationDescriptionLbl.text = (tmpDataDic.object(forKey: "coupon_desc") as! String)
        }
        else
        {
            cell.notificationDescriptionLbl.text = ""
        }
        cell.notificationTimeLbl.text = "Expires on " + (tmpDataDic.object(forKey: "expiry") as! String)
        let image_path = BASE_IMAGE_URL + "coupon/" + (tmpDataDic.object(forKey: "coupon_image") as! String)
        let imageURL = URL(string: image_path)
            cell.imageView1.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "discount"), options: .refreshCached, completed: nil)
        }
        cell.selectionStyle = .none
        return cell
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tmpDataDic = self.allDataArray.object(at: indexPath.row) as! NSDictionary
        let couponCode = (tmpDataDic.object(forKey: "coupon_code") as! String)
        self.couponTxtField.text = couponCode
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if currentPage == maxPage
        {}
        else
        {
            if (indexPath.row == self.allDataArray.count-1)
            {
                if(!nextUrl.isEmpty)
                {
                    currentPage = currentPage + 1
                   self.getCouponListDataAPI(loader: false, page: currentPage)
                }
            }
        }
    }
    
    //    //MARK: - Selector Methods//////////
    //
    
    @objc func longPressGesture(_ sender: UILongPressGestureRecognizer)
    {
        let tag_value = sender.view?.tag
        let tmpDataDic = self.allDataArray.object(at: tag_value!) as! NSDictionary
        print(tmpDataDic)
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = ""
        pasteBoard.string = (tmpDataDic.object(forKey: "coupon_code") as! String)
        sender.view?.makeToast("Coupon Code Copied")
        print(pasteBoard.string!)
    }
    
    @objc func applyButtonAction(_ sender: UIButton)
    {
        let tmpDataDic = self.allDataArray.object(at: sender.tag) as! NSDictionary
        print(tmpDataDic)
       coupon_code = (tmpDataDic.object(forKey: "coupon_code") as! String)
        applyCouponAPI(loader: true)
    }
    
    //MARK: - Call API
    func getCouponListDataAPI(loader:Bool,page:Int)  {
        
        let url = RCoupons_Api + "?page=\(page)&city_id=\(city_id)"
        
        print(url)
        WebService.requestGetUrl(strURL: url, is_loader_required: loader, success: { (response) in
            print(response)
            
             if response["status_code"] as! NSNumber == 1
            {
                self.tableView.isScrollEnabled = true
                self.noDataView.isHidden = true
                
                self.nextUrl = CommonClass.checkForNull(string: ((response["data"] as! NSDictionary).value(forKey: "next_page_url")as AnyObject))
                self.currentPage = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "current_page") as! NSNumber)
                self.maxPage = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "last_page") as! NSNumber)
                
                if (self.currentPage == 1)
                {
                    self.allDataArray.removeAllObjects()
                    self.allDataArray = NSMutableArray.init()
                }
                
                 self.allDataArray.addObjects(from: ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray as! [Any])
                self.tableView.reloadData()
            }
            else
            {
              
            }
            
        }) { (failure) in
            
           
        }
    }
    
    //MARK: Apply Coupon API
    func applyCouponAPI(loader:Bool)  {
        let api_name = RApply_Coupon_Api
        var param:[String:Any]!
        let paramMutabaledic = params.mutableCopy() as! NSMutableDictionary
   //      paramMutabaledic.setObject("1", forKey: "store_id" as NSCopying)
        paramMutabaledic.setObject(coupon_code, forKey: "coupon_code" as NSCopying)
       
        param = (paramMutabaledic as! [String : Any])

        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: loader, params: param, success: { (response) in
          
            if response["status_code"] as! NSNumber == 1
            {
              self.responseMsg = (response["message"] as! String)
                self.tableView.isScrollEnabled = true
                
                self.paymentDataDic = (response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                DispatchQueue.main.async {
                   
                        NotificationCenter.default.post(name: NSNotification.Name.init("couponNotification"), object: nil, userInfo: ["coupon_code":self.coupon_code,"payment_data":self.paymentDataDic,"responseMsg":self.responseMsg])
                    
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                    self.tableView.reloadData()
                }
            else
            {
                 self.view.makeToast((response["message"] as! String))
                 self.tableView.reloadData()
            }
            
        }) { (error) in
            
        }
    }
}
