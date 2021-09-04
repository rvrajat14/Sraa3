//
//  OrderDetailsVC.swift
//  SRAA3
//
//  Created by Apple on 25/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class OrderDetailsVC: UIViewController ,UITableViewDelegate , UITableViewDataSource ,UIGestureRecognizerDelegate{

    @IBOutlet weak var orderStatusBtn: UIButton!
    let LABEL_H_MARGIN:CGFloat = 80
    let PRICE_LABEL_WIDTH:CGFloat = 180
    let SMALL_SIZE = 13
    let BIG_SIZE = 15
    var order_id = ""
    var buttonDic: NSDictionary!
    var responseArray = NSMutableArray.init()
    var cancelReasonDataArray = NSMutableArray.init()
    var isFromOrderPlace = false
    var payment_gatewayStr = ""
    
    var serviceDetailArray = NSArray.init()
    
    @IBOutlet weak var blurV: UIView!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableV: UITableView!
    
    private let refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.tableV.rowHeight = UITableViewAutomaticDimension
        self.tableV.estimatedRowHeight = 50
        self.tableV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 90))
        NotificationCenter.default.addObserver(self, selector: #selector(BlurVHideNotification(notification:)), name: NSNotification.Name?.init(NSNotification.Name.init("BlurVHideNotification")), object: nil)
        self.orderStatusBtn.isHidden = true
        getOrderDetailApiCall(loader: true)
        if #available(iOS 10.0, *) {
            tableV.refreshControl = refreshControl
        } else {
            tableV.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
    }
    
    override func viewDidLayoutSubviews() {
//        self.orderStatusBtn.layer.cornerRadius = 10
//        self.orderStatusBtn.layer.masksToBounds = true
//        Utilities.setButtonGradiantColor(button: self.orderStatusBtn)
    }
    
    //MARK: - IBActions ------------------------ //
    
    @IBAction func popVC(_ sender: Any) {
        
        if isFromOrderPlace {
            self.navigationController?.popToRootViewController(animated: true)
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        getOrderDetailApiCall(loader: false)
    }
    
    @objc func BlurVHideNotification(notification: Notification)
    {
        if let userInfo = notification.userInfo {
            if (userInfo["actionResponse"] as? String) != nil
            {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderCancelReasonVC") as! OrderCancelReasonVC
                viewController.user_id = userDataModel.user_id
                viewController.order_id = order_id
                viewController.cancelReasonDataArray = cancelReasonDataArray
                self.present(viewController, animated: true, completion: nil)
            }
            if let msg = userInfo["toastMsg"] as? String
            {
                self.view.makeToast(msg, duration: 2, position: .center, title: "", image: nil, style: .init(), completion: nil)
                self.blurV.isHidden = true
                self.responseArray.removeAllObjects()
                self.getOrderDetailApiCall(loader: false)
            }
        }
        else
        {
            self.blurV.isHidden = true
            self.responseArray.removeAllObjects()
            self.getOrderDetailApiCall(loader: false)
        }
    }
    
    @IBAction func orderStatusBtnTaped(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderActionVC") as! OrderActionVC
        
        let btnAction = self.buttonDic.value(forKey: "action")as! String
        
        if btnAction == "cancel" {
            self.view.bringSubview(toFront: blurV)
            self.blurV.isHidden = false
            viewController.orderActionType = "cancel"
            viewController.order_id = order_id
            self.present(viewController, animated: true, completion: nil)
            
        }
        if btnAction == "feedback" {
            self.blurV.isHidden = false
            viewController.orderActionType = "feedback"
            viewController.order_id = order_id
            self.present(viewController, animated: true, completion: nil)
            return
        }
    }
    
    //MARK: - TableView Delegate And DataSources  --------------- //
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.responseArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mainDataDic = self.responseArray.object(at: section) as! NSDictionary
        
        if mainDataDic.object(forKey: "type") as! String == "items" || mainDataDic.object(forKey: "type") as! String == "payment_summary" || mainDataDic.object(forKey: "type") as! String == "order_info" || mainDataDic.object(forKey: "type") as! String == "form_fields" {
            
            let itemsArray = mainDataDic.value(forKey: "data")as! NSArray
            return itemsArray.count
        }
        else
        {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let mainDataDic = self.responseArray.object(at: indexPath.section) as! NSDictionary
        
        if mainDataDic.object(forKey: "type") as! String == "order_status" {
            
            let orderDatadic = mainDataDic.object(forKey: "data") as! NSDictionary
            
            let nib:UINib = UINib(nibName: "OrderStatusCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "OrderStatusCell")
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderStatusCell", for: indexPath) as! OrderStatusCell
            
            cell.orderStatusLbl.layer.cornerRadius = 4
            cell.orderStatusLbl.text = (orderDatadic["order_status"] as! String).uppercased()
            cell.orderIdLbl.text = "#\(order_id)"
            cell.dateLbl.text =  orderDatadic["created_at"] as? String
           
            cell.orderStatusLbl.backgroundColor = self.hexStringToUIColor(hex: (orderDatadic.object(forKey: "order_color") as! String))
            cell.orderStatusLbl.layer.cornerRadius = 15
            var imageUrl : URL!
            if (self.serviceDetailArray.count > 0) {
                let serviceDetailDic = (self.serviceDetailArray).object(at: 0)as! NSDictionary
                imageUrl = URL(string: BASE_IMAGE_URL + KCategory_Api + "/" + (serviceDetailDic.value(forKey: "category_photo")as! String))
                 cell.imgV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_subCategory"), options: .refreshCached, completed: nil)
                cell.titleLbl.text = CommonClass.checkForNull(string:(serviceDetailDic.value(forKey: "category_title"))as AnyObject)
            }
            else
            {
            if let image = orderDatadic.object(forKey: "store_photo") as? String
            {
                let imageUrl = URL(string: BASE_IMAGE_URL + "store/" +  image)
                cell.imgV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_subCategory"), options: .refreshCached, completed: nil)
            }
            }
            cell.selectionStyle = .none
            
            return cell
        }
        
        if mainDataDic.object(forKey: "type") as! String == "store" {
            
            let storeDatadic = (mainDataDic.object(forKey: "data") as! NSArray)[0] as! NSDictionary
            
            let nib:UINib = UINib(nibName: "StoreDetailsTableViewCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "StoreDetailsTableViewCell")
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "StoreDetailsTableViewCell", for: indexPath) as! StoreDetailsTableViewCell
            cell.storeNameLbl.text = (storeDatadic["store_title"] as! String)
            cell.storeInfoLbl.text =  (storeDatadic["store_phone"] as! String)
           
            cell.ratedLbl.isHidden = false
            cell.ratedValueLbl.isHidden = false
            cell.ratedValueLbl.text = CommonClass.checkForNull(string: storeDatadic["store_rating"] as AnyObject)
                if let image = storeDatadic.object(forKey: "store_photo") as? String
                {
                    let imageUrl = URL(string: BASE_IMAGE_URL + "store/" +  image)
                    cell.storeImgV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_subCategory"), options: .refreshCached, completed: nil)
                }
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        if mainDataDic.object(forKey: "type") as! String == "order_info" {
            
            let orderDatadic = (mainDataDic.object(forKey: "data") as! NSArray).object(at: indexPath.row) as! NSDictionary
            
            let nib:UINib = UINib(nibName: "OrderSummaryTableCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "OrderSummaryTableCell")
            
            let cell:OrderSummaryTableCell = tableView.dequeueReusableCell(withIdentifier: "OrderSummaryTableCell", for: indexPath) as! OrderSummaryTableCell
           let titleString = orderDatadic.object(forKey: "title") as? String
            var valueString = orderDatadic.object(forKey: "display_value") as? String
            if (valueString?.isEmpty)!
            {
                valueString = orderDatadic.object(forKey: "value") as? String
            }
            if(indexPath.row == 0)
            {
                cell.titleTopConstraints.constant = 10
            }
            else
            {
                cell.titleTopConstraints.constant = 0
            }
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold(titleString! + ":   ", size: 15)
                .normal(valueString!, size: 15)
            
            
            cell.value1Lbl.attributedText = formattedString
        
            cell.selectionStyle = .none
            
            return cell
        }
        if mainDataDic.object(forKey: "type") as! String == "items" {
            
            let itemDataArray = mainDataDic.object(forKey: "data") as! NSArray
            
            let itemDataDic = itemDataArray[indexPath.row]as! NSDictionary
            
            let nib:UINib = UINib(nibName: "OrderItemsTableCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "OrderItemsTableCell")
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderItemsTableCell", for: indexPath) as! OrderItemsTableCell
            
            cell.selectionStyle = .none
            
            cell.titleLbl.text = itemDataDic.value(forKey: "item_title") as? String
            
           // cell.desLbl.text = itemDataDic.value(forKey: "item_title") as? String
            
            cell.totalPriceLbl.text = currencySymbol + CommonClass.checkForNull(string: itemDataDic.value(forKey: "total_item_display_price") as AnyObject)
            
            cell.numberOfItemsLbl.text = CommonClass.checkForNull(string: itemDataDic.value(forKey: "quantity") as AnyObject) + "X"
            
            if let image = itemDataDic.object(forKey: "item_thumb_photo") as? String
            {
                let imageUrl = URL(string: BASE_IMAGE_URL + "item/" +  image)
                cell.imgV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_subCategory"), options: .refreshCached, completed: nil)
            }
            if indexPath.row == self.tableV.numberOfRows(inSection: indexPath.section) - 1
            {
                cell.separatorView.isHidden = true
            }
            else
            {
                cell.separatorView.isHidden = false
            }
         
            return cell
        }
        
          if mainDataDic.object(forKey: "type") as! String == "form_fields" {
            
            let itemDataArray = mainDataDic.object(forKey: "data") as! NSArray
            
            let itemDataDic = itemDataArray[indexPath.row]as! NSDictionary
            
            let nib:UINib = UINib(nibName: "OrderFormFieldsCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "OrderFormFieldsCell")
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderFormFieldsCell", for: indexPath) as! OrderFormFieldsCell
            
            cell.selectionStyle = .none
            
            cell.titleLbl.text = itemDataDic.value(forKey: "value") as? String
            
            return cell
        }
        
        if mainDataDic.object(forKey: "type") as! String == "payment_summary"  {
            
            let orderPaymentSummaryDataDic = (mainDataDic.object(forKey: "data")  as! NSArray).object(at: indexPath.row) as! NSDictionary
            
            let pam_title = orderPaymentSummaryDataDic.object(forKey: "title") as! String
           
            if pam_title == "line"
            {
                let nib  = UINib(nibName: "LineVTableCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "LineVTableCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "LineVTableCell", for: indexPath) as! LineVTableCell
                
                cell.selectionStyle = .none
                return cell
            }
            
            let nib:UINib = UINib(nibName: "PaymentSummaryTableCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "PaymentSummaryTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentSummaryTableCell", for: indexPath) as! PaymentSummaryTableCell
            cell.selectionStyle = .none
            
            if(pam_title == "Payment Mode")
            {
                 cell.valueLbl.text = CommonClass.checkForNull(string: orderPaymentSummaryDataDic.object(forKey: "value") as AnyObject )
            }
            else
            {
            cell.valueLbl.text = currencySymbol + CommonClass.getCorrectPriceFormat(price: String(format: "%@", orderPaymentSummaryDataDic.object(forKey: "value") as! CVarArg))
            }
            cell.titleLbl.text = pam_title
            
            if indexPath.row == self.tableV.numberOfRows(inSection: indexPath.section) - 1
            {
                cell.separatorView.isHidden = false
            }
            else
            {
                cell.separatorView.isHidden = true
            }
            return cell
        }
        
        if mainDataDic.object(forKey: "type") as! String == "image"  {
            
            let dataDic = (mainDataDic.object(forKey: "data")  as! NSArray).object(at: indexPath.row) as! NSDictionary
            
            let nib:UINib = UINib(nibName: "AddImageCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "AddImageCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddImageCell", for: indexPath) as! AddImageCell
            cell.selectionStyle = .none
           // cell.titleLbl.text = ""
//            let str = (dataDic.object(forKey: "value") as! String)
//
//            let image_url = URL(string: BASE_IMAGE_URL + "checkout/" + str)
//            cell.crossBtn.isHidden = true
//            cell.imgV.sd_setImage(with: image_url, placeholderImage:#imageLiteral(resourceName: "empty_subCategory"))
//
//            cell.selectImgBtn.addTarget(self, action: #selector(showImgTaped(_:)), for:.touchUpInside)
//            cell.selectImgBtn.tag = indexPath.section
//            cell.statusLbl.isHidden = true
//            cell.priceLbl.isHidden = true
            
            cell.imgCollectionView.delegate = self
            cell.imgCollectionView.dataSource = self
            cell.imgCollectionView.tag = indexPath.section
            DispatchQueue.main.async {
                cell.imgCollectionView.reloadData()
            }
            return cell
        }
        
        if mainDataDic.object(forKey: "type") as! String == "delivery_address"    {
            
            let orderAddressDatadictionary = ((mainDataDic.object(forKey: "data") as! NSArray).object(at: 0) as! NSDictionary)["data"] as! NSDictionary
            
            let nib:UINib = UINib(nibName: "OrderDeliveryAddressTableCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "OrderDeliveryAddressTableCell")
            
            let cell:OrderDeliveryAddressTableCell = tableView.dequeueReusableCell(withIdentifier: "OrderDeliveryAddressTableCell", for: indexPath) as! OrderDeliveryAddressTableCell
            print(orderAddressDatadictionary)
           // cell.titleLbl.text = (mainDataDic["title"] as! String)
            var addressString = ""
            addressString  = (orderAddressDatadictionary.object(forKey: "address_title") as! String)
            
            addressString += "\n" + CommonClass.checkForNull(string: (orderAddressDatadictionary.object(forKey: "address_line1") as AnyObject))
            
            addressString += ", " + CommonClass.checkForNull(string: (orderAddressDatadictionary.object(forKey: "address_line2") as AnyObject))
            
            addressString += "\n" + CommonClass.checkForNull(string: (orderAddressDatadictionary.object(forKey: "city") as AnyObject))
            
            addressString += ", " + CommonClass.checkForNull(string: (orderAddressDatadictionary.object(forKey: "state") as AnyObject))
            
            if(!(CommonClass.checkForNull(string: (orderAddressDatadictionary.object(forKey: "country") as AnyObject))).isEmpty)
            {
                addressString += ", " + CommonClass.checkForNull(string: (orderAddressDatadictionary.object(forKey: "country") as AnyObject))
            }
   //         cell.mapButton.tag = indexPath.section
          //  cell.mapButton.addTarget(self, action: #selector(mapButton(_:)), for:.touchUpInside)
            cell.deliveryAddressLbl.text = addressString
            cell.selectionStyle = .none
            
            return cell
        }
        
        if mainDataDic.object(forKey: "type") as! String == "payment_transaction"  {
            
            let dataDic = (mainDataDic.object(forKey: "data")  as! NSArray).object(at: indexPath.row) as! NSDictionary
            
            let nib:UINib = UINib(nibName: "AddImageCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "AddImageCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddImageCell", for: indexPath) as! AddImageCell
            cell.selectionStyle = .none
            
            cell.crossBtn.isHidden = true
            cell.statusLbl.isHidden = false
            cell.priceLbl.isHidden = false
            
            let str = (dataDic.object(forKey: "image") as! String)
            
            let image_url = URL(string: BASE_IMAGE_URL + "invoice/" + str)
            
            cell.imgV.sd_setImage(with: image_url, placeholderImage:#imageLiteral(resourceName: "empty_subCategory"))
            
            cell.statusLbl.text = CommonClass.checkForNull(string: dataDic.value(forKey: "status") as AnyObject).uppercased()
            cell.priceLbl.text = userDataModel.currencySymbol + " " + CommonClass.checkForNull(string: dataDic.value(forKey: "amount") as AnyObject)
            cell.selectImgBtn.addTarget(self, action: #selector(showImgTaped(_:)), for:.touchUpInside)
            cell.selectImgBtn.tag = indexPath.section
            
            return cell
        }
        return UITableViewCell(frame: CGRect.zero)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
       
        if responseArray.count > 0 {
            return 54
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let mainDataDic = self.responseArray.object(at: section) as! NSDictionary
        if mainDataDic.object(forKey: "type") as! String == "items" {
        let tottal_items = (mainDataDic.object(forKey: "data") as! NSArray).count
        
        return self.getHeaderView(title: "\(tottal_items)  \(mainDataDic.object(forKey: "title") as! String)" )
        }
        return self.getHeaderView(title: (mainDataDic.object(forKey: "title") as! String) )
    }
    
    //MARK: - HeaderView For Section
    
    func getHeaderView(title: String) -> UIView {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 54))
         headerView.backgroundColor = UIColor.groupTableViewBackground
        let innerView:UIView = UIView(frame: CGRect(x: 0, y: 10, width: self.view.frame.size.width, height: 44))
       innerView.backgroundColor = .white
        let infoLabel:UILabel = UILabel(frame: CGRect(x: 16, y: 13, width: self.view.frame.size.width - 32, height: 24))
        
        infoLabel.text = title
       
        infoLabel.font = UIFont(name: KMainFontSemiBold, size: 17)
        innerView.addSubview(infoLabel)
        headerView.addSubview(innerView)
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let mainDataDic = self.responseArray.object(at: section) as! NSDictionary
        
        if mainDataDic.object(forKey: "type") as! String == "payment_summary"
            {
                return 50
            }
            return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let mainDataDic = self.responseArray.object(at: section) as! NSDictionary
        
            if mainDataDic.object(forKey: "type") as! String == "payment_summary"
            {
                print(mainDataDic)
                let total = String(format: "%@", ((mainDataDic.object(forKey: "total")) as! CVarArg ))
                
                if self.payment_gatewayStr.isEmpty
                {
                    return self.getFooterView(title: "Total", price: total, xPosition: 15)
                }
                return self.getFooterView(title: "Total(\(self.payment_gatewayStr))", price: total, xPosition: 15)
            }
        
        return UIView.init(frame: CGRect.zero)
    }
    
    func getFooterView(title: String,price: String,xPosition:Int) -> UIView {
        
        let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        footerView.backgroundColor = UIColor.white
        var totalTitleLbl:UILabel!
        if xPosition == 0 {
            totalTitleLbl = UILabel(frame: CGRect(x: LABEL_H_MARGIN, y: 10, width: 80, height: 24))
        }
        else
        {
            totalTitleLbl = UILabel(frame: CGRect(x: xPosition, y: 10, width: 140, height: 24))
        }
        
        totalTitleLbl.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
        totalTitleLbl.text = title
        //infoLabel.alpha = 0.80
        totalTitleLbl.font = UIFont(name: KMainFontSemiBold, size: 17)
        
        footerView.addSubview(totalTitleLbl)
        
        let totalPriceLbl: UILabel = UILabel(frame: CGRect(x: self.view.frame.size.width - PRICE_LABEL_WIDTH - 15, y: totalTitleLbl.frame.origin.y, width: PRICE_LABEL_WIDTH, height: 24))
        totalPriceLbl.textAlignment = NSTextAlignment.right
        //deliveryDateLbl.numberOfLines = 0
        totalPriceLbl.text = currencySymbol + CommonClass.getCorrectPriceFormat(price: price)
        totalPriceLbl.font = UIFont(name: KMainFontSemiBold, size: 17)
        
        footerView.addSubview(totalPriceLbl)
        
        return footerView
        
    }
    
    @objc func showImgTaped(_ sender: UIButton) {
        
        let mainDataDic = self.responseArray.object(at: sender.tag) as! NSDictionary
        
        if mainDataDic.object(forKey: "type") as! String == "image" {
        
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowImageVC") as! ShowImageVC
            
            let dataDic = (mainDataDic.object(forKey: "data")  as! NSArray).object(at: 0) as! NSDictionary
            let str = (dataDic.object(forKey: "value") as! String)
            vc.imgStr = str
            vc.imageType = "checkout/"
           self.present(vc, animated: false, completion: nil)
            
        }
        
        if mainDataDic.object(forKey: "type") as! String == "payment_transaction" {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowImageVC") as! ShowImageVC
            
            let dataDic = (mainDataDic.object(forKey: "data")  as! NSArray).object(at: 0) as! NSDictionary
            let str = (dataDic.object(forKey: "image") as! String)
            vc.imgStr = str
            vc.imageType = "invoice/"
            self.present(vc, animated: false, completion: nil)
            
        }
    }
    
    //MARK: - APi Call ------------------------ //
    
    func getOrderDetailApiCall(loader: Bool) {
        
        WebService.requestGetUrl(strURL: ROrder_Api + "/" + order_id + "?user_id=\(userDataModel.user_id!)&timezone=\(localTimeZoneName)&type=sraa3", is_loader_required: loader, success: { (response) in
            print(response)
            self.refreshControl.endRefreshing()
            self.responseArray = NSMutableArray.init()
            if (response.value(forKey: "status_code")as! NSNumber) == 1
            {
                self.orderStatusBtn.isHidden = false
                
                let tempArray = (response["data"] as! NSArray)
                
                for dic in tempArray
                {
                    let dic1 =  (dic as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
                    if dic1.object(forKey: "type") as! String == "order_status"
                    {
                        self.responseArray.add(dic1)
                    }
                    
                  if dic1.object(forKey: "type") as! String == "order_info"
                    {
                        let array = (dic1["data"] as! NSArray)
                        if(array.count > 0)
                        {
                            self.responseArray.add(dic1)
                        }
                    }
                    if dic1.object(forKey: "type") as! String == "store"
                    {
                        if (dic1.object(forKey: "data") as! NSArray).count > 0
                        {
                        self.responseArray.add(dic1)
                        }
                    }
                    if dic1.object(forKey: "type") as! String == "delivery_address"
                    {
                        self.responseArray.add(dic1)
                    }
                    if dic1.object(forKey: "type") as! String == "items"
                    {
                        let array = (dic1["data"] as! NSArray)
                        if(array.count > 0)
                        {
                            self.responseArray.add(dic1)
                        }
                    }
                    
                    if dic1.object(forKey: "type") as! String == "payment_summary"
                    {
                        
                        let amountStr = CommonClass.checkForNull(string: dic1.value(forKey: "total") as AnyObject)
                        
                        if amountStr == "0"
                        { }
                        else
                        {
                            let array = (dic1["data"] as! NSArray)
                            if(array.count > 0)
                            {
                                self.responseArray.add(dic1)
                                 self.payment_gatewayStr = (CommonClass.checkForNull(string: dic1.value(forKey: "payment_gateway")as AnyObject)).capitalizingFirstLetter()
                            }
                        }
                    }
                    
                    /*if dic1.object(forKey: "type") as! String == "pickup_address"
                    {
                        self.allDataArray.add(dic1)
                    }
                    */
                    
                    if dic1.object(forKey: "type") as! String == "image"
                    {
                        let array = (((dic1["data"] as! NSArray)[0] as! NSDictionary)["value"] as! NSArray)
                        if(array.count > 0)
                        {
                            self.responseArray.add(dic1)
                        }
                    }
                    if dic1.object(forKey: "type") as! String == "form_fields"
                    {
                        let array = (dic1["data"] as! NSArray)
                        if(array.count > 0)
                        {
                            self.responseArray.add(dic1)
                        }
                    }
                    if dic1.object(forKey: "type") as! String == "order_cancel_reasons"
                    {
                        self.responseArray.add(dic1)
                    }
                    if dic1.object(forKey: "type") as! String == "payment_transaction"
                    {
                        let dataArray = dic1.value(forKey: "data")as! NSArray
                    
                        if(dataArray.count > 0)
                        {
                            let dataDic = dataArray.object(at: 0)as! NSDictionary
                           
                            let imageStr = (CommonClass.checkForNull(string: dataDic.value(forKey: "image")as AnyObject))
                            if !(imageStr.isEmpty)
                            {
                                 self.responseArray.add(dic1)
                            }
                        }
                    }
                }
               
               // self.responseArray = (response["data"] as! NSArray).mutableCopy() as! NSMutableArray
                self.buttonDic = response["button"] as? NSDictionary
                if (self.buttonDic.count != 0){
                    self.orderStatusBtn.isHidden = false
                    self.orderStatusBtn.setTitle(CommonClass.checkForNull(string: self.buttonDic.value(forKey: "title")as!
                        NSObject).uppercased(), for: .normal)
                    
                    self.orderStatusBtn.backgroundColor = UIColor.hexToColor(hexString: self.buttonDic.value(forKey: "color") as! String)
                    
                    if (self.buttonDic.value(forKey: "enabled")as! NSNumber == 0)
                    {
                        self.orderStatusBtn.isUserInteractionEnabled = false
                    }
                    else
                    {
                        let btnAction = self.buttonDic.value(forKey: "action")as! String
                        
                        if btnAction == "cancel"
                        {
                            let tmpArray = (self.buttonDic["reason"] as! NSArray) as! [String]
                            self.cancelReasonDataArray.removeAllObjects()
                            for value in tmpArray
                            {
                                self.cancelReasonDataArray.add(NSDictionary(dictionaryLiteral: ("title",value),("isSelected","0")))
                            }
                        }
                        self.orderStatusBtn.isUserInteractionEnabled = true
                    }
                }
                
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

extension OrderDetailsVC : UICollectionViewDelegate , UICollectionViewDataSource {
    //MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dataDictionary = (responseArray[collectionView.tag] as! NSDictionary)
        print(dataDictionary)
        let imageArray = ((dataDictionary["data"] as! [NSDictionary])[0] ).value(forKey: "value") as! [NSDictionary]
//        if imageArray.count < 1 {
//            imageArray = selectedImagesArray
//        }
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "AddImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "AddImageCollectionCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCollectionCell", for: indexPath) as! AddImageCollectionCell
//        cell.selectionStyle = .none
    //  cell.titleLbl.text = "Add Images related to service"
        cell.crossBtn.isHidden = true
        cell.selectImageBtn.isHidden = true
        cell.imageV.isHidden = false
        let dataDictionary = responseArray.object(at: collectionView.tag) as! NSDictionary
        let mainDataDictionary = ((dataDictionary["data"] as! [NSDictionary])[0] )
        let str = ((mainDataDictionary.object(forKey: "value") as! [String])[indexPath.row])
            let image_url = URL(string: BASE_IMAGE_URL + "checkout/" + str)
            cell.imageV.sd_setImage(with: image_url, placeholderImage:#imageLiteral(resourceName: "empty_subCategory"))
         
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 100, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 7, left: 15, bottom: 7, right: 0)
    }
    
    
}
