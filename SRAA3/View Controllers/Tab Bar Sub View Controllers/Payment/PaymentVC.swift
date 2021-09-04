//
//  PaymentVC.swift
//  My MM
//
//  Created by Kishore on 24/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import NotificationCenter
//import PaymentSDK
import SVProgressHUD
import Alamofire
import Razorpay

class PaymentVC: UIViewController,UITextFieldDelegate {
    
    private var razorpay:RazorpayCheckout?
    var razorPay_id = ""
    var paymentSummaryDic = NSDictionary.init()
//    var pgTransactionVC = PGTransactionViewController()
    var paymentOptionsArray = NSMutableArray.init()
    var params = NSDictionary.init()
    var totalPrice = "", sub_total = ""
    var payment_gateway_type = "", payment_mode = ""
    var couponSuccessMsg = "",couponFailMsg = ""
    var oldPaymentSummaryDic = NSDictionary.init()
    var order_number = ""
    
    var isForApplyCoupon = true, isForLoyaltyPoints = false
    var isLoyaltyPointApplied = false, isCouponCodeApplied = false
    var pointsSuccessMsg = "",pointsFailMsg = ""
    var pointsStr = ""
    var points = ""
    var isPointsApplied = false
    var isPointsDisplayed = false
    
    @IBOutlet weak var proceedView: UIView!
    @IBOutlet weak var tableV: UITableView!
    var couponCode = ""
    

    var isForCOD = true
    var isForPayPal = false
    var isForCard = false
    var isCouponApplied = false
  
    var payamentSummaryIsHidden = true
    
    @IBAction func proceedButton(_ sender: UIButton) {
 
        if payment_gateway_type.isEmpty {
            
            DispatchQueue.main.async {
                COMMON_ALERT.showAlert(title: "Select payment type" , msg: "", onView: self) }
            return
        }
        
        else if self.payment_gateway_type == "razorpay"
        {
            getRazorPayIdApi()
      /*     */
        }
        else
        {
            placeOrderAPI(transaction_id: "")
        }
    }
    
    @IBOutlet weak var proceedButton: UIButton!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTaped(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name("OrderCancelFromCheckOut"), object: nil)
        
        let viewControllers = self.navigationController!.viewControllers as [UIViewController]
        for aViewController:UIViewController in viewControllers {
            if aViewController.isKind(of: ItemsVC.self) {
                self.navigationController?.popToViewController(aViewController, animated: true)
                break
            }
            
            if aViewController.isKind(of: HomeVC.self) {
                self.navigationController?.popToViewController(aViewController, animated: true)
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(points)
        self.tableV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        
       // rzp_live_ILgsfZCZoFIKMb Just for testing
         razorpay = RazorpayCheckout.initWithKey(RazorPay_Key, andDelegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(couponNotificationAction(notification:)), name: NSNotification.Name.init("couponNotification"), object: nil)
        
        self.oldPaymentSummaryDic = paymentSummaryDic
        print(paymentSummaryDic)
        for value in (self.oldPaymentSummaryDic.object(forKey: "data") as! NSArray) as! [NSDictionary]
        {
            if value["title"] as! String == "Sub Total"
            {
                self.sub_total = (value["value"] as! String)
            }
        }
        
        totalPrice = CommonClass.checkForNull(string: oldPaymentSummaryDic["total"] as AnyObject)
        
        getPaymentGateways()
        self.tableV.backgroundColor = UIColor.groupTableViewBackground
        self.tableV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        self.automaticallyAdjustsScrollViewInsets = false
        getPoints()
    }
    
    override func viewDidLayoutSubviews() {
        self.proceedView.layer.cornerRadius = 10
        self.proceedView.layer.masksToBounds = true
        let gradientColor = CAGradientLayer()
         gradientColor.frame = proceedView.bounds
         gradientColor.colors = [#colorLiteral(red: 0.1277451515, green: 0.1185270026, blue: 0.1236923411, alpha: 1).cgColor,#colorLiteral(red: 0.1277451515, green: 0.1185270026, blue: 0.1236923411, alpha: 1).cgColor,#colorLiteral(red: 0.1277451515, green: 0.1185270026, blue: 0.1236923411, alpha: 1).cgColor,#colorLiteral(red: 0.2372479439, green: 0.2372866571, blue: 0.2372357547, alpha: 1).cgColor]
         gradientColor.startPoint = CGPoint(x: 0.0, y: 0.0)
         gradientColor.endPoint = CGPoint(x: 1.0, y: 0.0)
         proceedView.layer.insertSublayer(gradientColor, at: 0)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField)
    {
        couponCode = textField.text!
        return
    }
    
    //MARK: Points API
    func getPoints()  {
        let api_name = RSpendPoints_Api
        let param = ["user_id":userDataModel.user_id,"type":"order","amount":sub_total]
        WebService.requestPostUrl(strURL: api_name, params: param as NSDictionary, is_loader_required: false, success: { (response) in
            print(response)
            if response["status_code"] as! NSNumber == 1
            {
                self.points = CommonClass.checkForNull(string: (response["data"] as! NSDictionary)["total_coin"] as AnyObject)
                self.pointsStr = CommonClass.checkForNull(string: (response["data"] as! NSDictionary)["text"] as AnyObject)
            }
            else
            {
                self.view.makeToast((response["message"] as! String))
                self.view.clearToastQueue()
            }
        }) { (failure) in
            
        }
    }
    
    // Get razorPayId
    func getRazorPayIdApi()  {
        let api_name =  RCreate_Order_Api
        let param = ["amount":(paymentSummaryDic["total"] as! String)]
        WebService.requestPostUrl(strURL: api_name, params: param as NSDictionary, is_loader_required: false, success: { (response) in
            print(response)
            if response["status_code"] as! NSNumber == 1
            {
                
                let order_id = CommonClass.checkForNull(string: ((response["data"] as! NSDictionary)["order_id"]) as AnyObject)
                
                let amount = (Float(self.paymentSummaryDic["total"] as! String)!) * 100
                
                let options: [String:Any] = [
                    "amount" : amount,//mandatory in paise like:- 1000 paise ==  10 rs
                    "description": "Our Service build smile",
                    "order_id": order_id,
                    "name": "SRAA3",
                    "prefill": [
                        "contact": "",
                        "email": ""
                    ],
                    "theme": [
                        "color": "#000000"
                    ]
                ]
                self.razorpay?.open(options)
            }
            else
            {
               
            }
        }) { (failure) in
            
        }
    }
    
    //MARK: Apply Coupon API
    func applyPointsAPI(loader:Bool,isForPoints: Bool)  {
        let api_name = RApply_Coupon_Api + "?timezone=\(localTimeZoneName)"
        var param:[String:Any]!
        let paramMutabaledic = params.mutableCopy() as! NSMutableDictionary
        if isForPoints {
            paramMutabaledic.setObject(points, forKey: "points" as NSCopying)
            paramMutabaledic.setObject("", forKey: "coupon_code" as NSCopying)
        }
        else
        {
            paramMutabaledic.setObject("", forKey: "points" as NSCopying)
            paramMutabaledic.setObject(couponCode, forKey: "coupon_code" as NSCopying)
        }
        
        param = (paramMutabaledic as! [String : Any])
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: loader, params: param, success: { (response) in
                print("couson response \(response)")
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 1
                {
                    if isForPoints
                    {
                        self.isPointsApplied = true
                        self.pointsSuccessMsg = (response["text"] as! String)
                    }
                    else
                    {
                        self.isCouponApplied = true
                    }
                    self.paymentSummaryDic = (response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    self.totalPrice = ( self.paymentSummaryDic["total"] as! String)
                    DispatchQueue.main.async {
                        self.tableV.reloadData()
                    }
                    self.view.makeToast((response["message"] as! String))
                    self.view.clearToastQueue()
                    
                }
                else
                {
                    DispatchQueue.main.async {
                        self.tableV.reloadData()
                    }
                    self.view.makeToast((response["message"] as! String))
                }
                
            }) { (error) in
                
               // self.tableV.e
            }
        }
      
    }
    
     //MARK: Get Payment Gateways
    func getPaymentGateways()  {
        
        let api_name = RGetPaymentGateway_Api + "/\(userDataModel.user_id!)" + "?app_type=sraa"
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestGetUrl(strURL: api_name, is_loader_required: true, success: { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 1
                {
                    let tmpData = (response["data"] as! NSArray).mutableCopy() as! NSMutableArray
                    
                    for value in tmpData as! [NSDictionary]
                    {
                        let dataDic = value.mutableCopy() as! NSMutableDictionary
                        if value["default_payment_method"] as! NSNumber == 1
                        {
                            dataDic.setObject("1", forKey: "isSelected" as NSCopying)
                            self.payment_mode = (value["type"] as! String)
                            self.payment_gateway_type = (value["identifier"] as! String)
                        }
                        else
                        {
                            dataDic.setObject("0", forKey: "isSelected" as NSCopying)
                        }
                        self.paymentOptionsArray.add(dataDic)
                    }
                    DispatchQueue.main.async {
                        self.tableV.reloadData()
                    }
                }
                
              
            }) { (failure) in
                
            }
        }
       
    }
    
    //MARK: -Selector Methods
    
    @objc func detailsButton(sender:UIButton)
    {
        let cell = tableV.cellForRow(at: IndexPath(row: 0, section: 2)) as! PaymentSummaryTableCell
        if cell.downImgV.image == #imageLiteral(resourceName: "down_triangle_arrow") {
            self.payamentSummaryIsHidden = false
            cell.downImgV.image = #imageLiteral(resourceName: "up_arrow_triangle")
        }
        else
        {
            self.payamentSummaryIsHidden = true
            cell.downImgV.image = #imageLiteral(resourceName: "down_triangle_arrow")
        }
        self.tableV.reloadData()
    }
    
    @objc func couponNotificationAction(notification : Notification)
    {
        if let userInfo = notification.userInfo {
            if let ccd = userInfo["coupon_code"] as? String {
                print(ccd)
                 couponCode = ccd
            }
            if let paymentData = userInfo["payment_data"] as? NSDictionary {
                print(paymentData)
               self.paymentSummaryDic = paymentData
                
            }
            if let responseMsg = userInfo["responseMsg"] as? String
            {
                self.view.makeToast(responseMsg, duration: 2, position: .center, title: "", image: nil, style: .init(), completion: nil)
            }
            self.isCouponApplied = true
            self.tableV.reloadData()
        }
    }
    
    func setSelectedRow(item_id: Int)  {
        
        let tmpArray = paymentOptionsArray
        
        for (index,value) in tmpArray.enumerated() {
            let dataDic = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
           
            if dataDic["id"] as! Int == item_id
            {
               if item_id == 1
               {
                isForCard = true
                isForCOD = false
                isForPayPal = false
                }
                if item_id == 3
                {
                    isForCard = false
                    isForCOD = false
                    isForPayPal = true
                }
                if item_id == 4
                {
                    isForCard = false
                    isForCOD = true
                    isForPayPal = false
                }
               
                dataDic.setObject("1", forKey: "isSelected" as NSCopying)
            }
            else
            {
                dataDic.setObject("0", forKey: "isSelected" as NSCopying)
            }
            
            paymentOptionsArray.replaceObject(at: index, with: dataDic)
        }
    }
 }

extension PaymentVC : UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 2 {
            if payamentSummaryIsHidden
            {
                return 1
            }
            else
            {
            return (paymentSummaryDic.object(forKey: "data") as! NSArray).count + 1
            }
        }
        if section == 1 {
            return 1
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 2 {
            
            if indexPath.row == 0
            {
                
            }
            else
            {
                print(indexPath.row)
                let dataDic = (paymentSummaryDic.object(forKey: "data") as! NSArray).object(at: indexPath.row - 1) as! NSDictionary
            let title = dataDic.object(forKey: "title") as! String
            
            if title == "line"
            {
                let nib  = UINib(nibName: "LineVTableCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "LineVTableCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "LineVTableCell", for: indexPath) as! LineVTableCell
                
                cell.selectionStyle = .none
                return cell
            }
            }
            let nib:UINib = UINib(nibName: "PaymentSummaryTableCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "PaymentSummaryTableCell")
            
            let cell:PaymentSummaryTableCell = tableView.dequeueReusableCell(withIdentifier: "PaymentSummaryTableCell", for: indexPath) as! PaymentSummaryTableCell
          
            if payamentSummaryIsHidden
            {
                let total_price = (paymentSummaryDic.object(forKey: "total") as! String)
                cell.detailsButton.addTarget(self, action: #selector(detailsButton(sender:)), for: .touchUpInside)
                cell.priceLbl.text = currencySymbol + total_price
                cell.mainView.isHidden = true
                cell.topView.isHidden = false
            }
            else
            {
                let total_price = (paymentSummaryDic.object(forKey: "total") as! String)
                cell.priceLbl.text = currencySymbol + total_price
                if indexPath.row == 0
                {
                    cell.topView.isHidden = false
                    cell.mainView.isHidden = true
                }
                else
                {
                    print(indexPath.row)
                    let dataDic = (paymentSummaryDic.object(forKey: "data") as! NSArray).object(at: indexPath.row - 1) as! NSDictionary
                    let title = dataDic.object(forKey: "title") as! String
                    let value = (dataDic.object(forKey: "value") as! String)
                    cell.titleLbl.text = title
                    cell.valueLbl.text = currencySymbol + CommonClass.getCorrectPriceFormat(price: value)
                    cell.mainView.isHidden = false
                    cell.topView.isHidden = true
                }
            }
            
            if (tableView.numberOfRows(inSection: indexPath.section) - 1) == indexPath.row
            {
                cell.separatorView.isHidden = false
            }
            else
            {
                cell.separatorView.isHidden = true
            }
            cell.selectionStyle = .none
            return cell
        }
        
        if indexPath.section == 1
        {
            let nib1 = UINib(nibName: "ApplyCouponTableCell", bundle: nil)
            tableView.register(nib1, forCellReuseIdentifier: "ApplyCouponTableCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ApplyCouponTableCell") as! ApplyCouponTableCell
            //cell.offersListButton.layer.borderWidth = 1
            //cell.offersListButton.layer.borderColor = MAIN_COLOR.cgColor
            cell.couponCrossButton.layer.cornerRadius = cell.couponCrossButton.frame.height/2
            cell.couponCrossButton.addTarget(self, action: #selector(couponCrossButton(_:)), for: .touchUpInside)
            cell.pointsCrossButton.addTarget(self, action: #selector( pointsCrossButton(_:)), for: .touchUpInside)
            cell.couponButton.addTarget(self, action: #selector(couponButton(_:)), for: .touchUpInside)
            cell.pointsButton.layer.borderWidth = 1
            cell.couponCodeTxtField.delegate = self
            cell.couponCodeTxtField.textColor = #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1)
            cell.couponButton.backgroundColor = UIColor.white
            cell.couponButton.setTitleColor(UIColor.black, for: .normal)
            if !isPointsDisplayed
            {
                cell.pointBackV.isHidden = true
                if couponCode.isEmpty
                {
                    cell.couponButton.setTitle("View List", for: .normal)
                }
                else
                {
                    cell.couponButton.setTitle("APPLY", for: .normal)
                }
                cell.couponCodeTxtField.text = couponCode
                if self.isCouponApplied
                {
                    self.isPointsApplied = false
                   // cell.pointsMainButton.isUserInteractionEnabled = false
                    cell.couponCrossButton.isHidden = false
                    cell.couponButton.isHidden = true
                    // cell.offersListButton.isHidden = true
                    cell.couponCodeTxtField.text = couponCode
                }
                else
                {
                    cell.couponButton.isHidden = false
                    cell.couponCrossButton.isHidden = true
                 //   cell.pointsMainButton.isUserInteractionEnabled = true
                    // cell.offersListButton.isHidden = false
                }
            }
            else
            {
                if isPointsApplied
                {
                    self.isCouponApplied = false
                    cell.couponMainButton.isUserInteractionEnabled = false
                    cell.pointsCrossButton.isHidden = false
                    cell.pointsButton.isHidden = true
                    cell.pointsLbl.text = pointsSuccessMsg
                }
                else if points == "0" || points == "" {
                    cell.pointsButton.isHidden = true
                }
                else
                {
                    cell.pointsButton.isHidden = false
                    cell.pointsCrossButton.isHidden = true
                    
                    cell.couponMainButton.isUserInteractionEnabled = true
                     cell.pointsLbl.text = pointsStr
                }
                
                cell.pointBackV.isHidden = false
                cell.couponMainBackV.isHidden = true
               
            }
            
            
            // cell.pointsButton.layer.borderColor = MAIN_COLOR.cgColor
            
            cell.couponMainButton.addTarget(self, action: #selector(couponMainButton(_:)), for: .touchUpInside)
            cell.pointsMainButton.addTarget(self, action: #selector(pointsMainButton(_:)), for: .touchUpInside)
            cell.pointsButton.addTarget(self, action: #selector(pointsButton(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
        else
        {
            let nib:UINib = UINib(nibName: "SelectionTypeTableCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "SelectionTypeTableCell")
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "SelectionTypeTableCell", for: indexPath) as! SelectionTypeTableCell
         
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            cell.collectionView.tag = indexPath.section
            cell.collectionView.reloadData()
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 || indexPath.section == 1
        {
            return
        }
        else
        {
            let dataDic = (paymentOptionsArray.object(at: indexPath.row) as! NSDictionary)
           
            setSelectedRow(item_id: Int(truncating: (dataDic.object(forKey: "id") as! NSNumber)))
             let fieldOptionsDic = (paymentOptionsArray.object(at: indexPath.row) as! NSDictionary)
            let cell = tableView.cellForRow(at: indexPath) as! RadioTableCell
            let identifier = fieldOptionsDic["identifier"] as! String
            
            if identifier == "card"
            {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DebitCreditCardVC") as! DebitCreditCardVC
                self.navigationController?.pushViewController(viewController, animated: true)
                return
            }
            
            
            print(fieldOptionsDic)
            if fieldOptionsDic.object(forKey: "isSelected") as! String == "1" {
                payment_mode = (fieldOptionsDic["type"] as! String)
                payment_gateway_type = (fieldOptionsDic["identifier"] as! String)
                cell.checkBoxButton.setImage(#imageLiteral(resourceName: "icon-tick"), for: .normal)
                self.tableV.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 2 {
            if !payamentSummaryIsHidden
            {
            let mainFooterView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
            mainFooterView.backgroundColor = UIColor.groupTableViewBackground
            
            let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
            footerView.backgroundColor = UIColor.white
            mainFooterView.addSubview(footerView)
            
            let titleLbl:UILabel = UILabel(frame: CGRect(x: 15, y: 10, width: 80, height: 21))
            titleLbl.textColor = UIColor.black
            titleLbl.text = "Total"
            titleLbl.font = UIFont(name: KMainFont, size: 15)
            let fonD:UIFontDescriptor = titleLbl.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
            
            titleLbl.font = UIFont(descriptor: fonD, size: 15)
            footerView.addSubview(titleLbl)
            
            let totalPriceLbl:UILabel = UILabel(frame: CGRect(x: self.view.frame.size.width - 115, y: titleLbl.frame.origin.y, width: 100, height: 21))
            totalPriceLbl.textColor = UIColor.black
            totalPriceLbl.textAlignment = .right
            totalPriceLbl.text = currencySymbol +  (paymentSummaryDic["total"] as! String)
            totalPriceLbl.font = UIFont(name: KMainFontSemiBold, size: 15)
            footerView.addSubview(totalPriceLbl)
            
            return mainFooterView
            }
            else
            {
             return UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
            }
        }
        return UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0))
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            if !payamentSummaryIsHidden
            {
                 return self.getHeaderView(title: "Payment Summary")
            }
        }
        if section == 1
        {
             return self.getHeaderView(title: "Coupon Code")
//            return nil
        }
        if section == 0 {
            return self.getHeaderView(title: "Choose Payment Type")
        }
        let tmpView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 8))
        tmpView.backgroundColor = UIColor.groupTableViewBackground
        return tmpView
    }
   
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            if !payamentSummaryIsHidden
            {
                return 100
            }
            return 50
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return  54
        }
        if(section == 1 )
        {
            return 54
        }
        if section == 2 {
            if !payamentSummaryIsHidden {
               return 54
            }
            return 10
        }
        
        return 10
    }
    
   //MARK: - HeaderView For Section
    
    func getHeaderView(title: String) -> UIView {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 54))
        headerView.backgroundColor = UIColor.clear
        let innerView:UIView = UIView(frame: CGRect(x: 0, y: 10, width: self.view.frame.size.width, height: 44))
        innerView.backgroundColor = UIColor.white
       
        let infoLabel:UILabel = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.size.width - 32, height: 24))
        infoLabel.textColor = UIColor.black
        infoLabel.text = title
       
       //  let fontD:UIFontDescriptor = infoLabel.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic)!
       //  infoLabel.font = UIFont(descriptor: fontD, size: 17)
        
        infoLabel.font = UIFont(name: KMainFontSemiBold, size: 17)
        innerView.addSubview(infoLabel)
        headerView.addSubview(innerView)
        return headerView
        
    }
    
    //MARK: -Selector Methods
    
    @objc func  couponMainButton(_ sender: UIButton)
    {
        isPointsDisplayed = false
        let cell = tableV.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        cell.pointsMainButton.setTitleColor(UIColor.lightGray, for: .normal)
        cell.pointsBottomLbl.isHidden = true
        cell.couponMainBackV.isHidden = false
        cell.pointBackV.isHidden = true
        cell.couponMainButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
        cell.couponBottomLbl.isHidden = false
        self.tableV.reloadData()
        
    }
    
    @objc func  pointsMainButton(_ sender: UIButton)
    {
        
        if self.isCouponApplied
        {
            self.view.makeToast("You can't apply points along with coupon.", point: CGPoint(x: self.view.center.x, y: self.view.center.y), title: "", image: nil, completion: nil)
        }
        else
        {
        isPointsDisplayed = true
        let cell = tableV.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        cell.couponMainButton.setTitleColor(UIColor.lightGray, for: .normal)
        cell.couponBottomLbl.isHidden = true
        cell.pointBackV.isHidden = false
        cell.couponMainBackV.isHidden = true
        cell.pointsLbl.text = pointsStr
        if points == "0" || points == "" {
            cell.pointsButton.isHidden = true
        }
        else
        {
            cell.pointsButton.isHidden = false
        }
        // getPoints()
        cell.pointsButton.layer.borderColor = UIColor.KMainColorCode.cgColor
        cell.pointsMainButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
        cell.pointsBottomLbl.isHidden = false
        self.tableV.reloadData()
        }
    }
    
    @objc func  pointsButton(_ sender: UIButton)
    {
      
        let cell = tableV.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        
        if cell.pointsCrossButton.isHidden {
            cell.pointsButton.isHidden = true
            cell.pointsCrossButton.isHidden = false
            isPointsApplied = true
            applyPointsAPI(loader: true, isForPoints: true)
        }
        else
        {
            self.paymentSummaryDic = oldPaymentSummaryDic
            totalPrice = (self.oldPaymentSummaryDic["total"] as! String)
            cell.pointsButton.setTitle("USE", for: .normal)
            cell.pointsButton.layer.borderColor = UIColor.KMainColorCode.cgColor
            cell.pointsButton.isHidden = false
            cell.pointsCrossButton.isHidden = true
            cell.pointsButton.setTitleColor(.white, for: .normal)
            cell.pointsMainButton.isUserInteractionEnabled = true
            cell.couponMainButton.isUserInteractionEnabled = true
            self.isPointsApplied = false
            self.isCouponApplied = false
            self.tableV.reloadData()
            
        }
    }
    
    @objc func   pointsCrossButton(_ sender: UIButton)
    {
        let cell = tableV.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        cell.pointsButton.isHidden = false
        cell.pointsCrossButton.isHidden = true
        self.isCouponApplied = false
        self.isPointsApplied = false
        pointsSuccessMsg = ""
        cell.pointsMainButton.isUserInteractionEnabled = true
        cell.couponMainButton.isUserInteractionEnabled = true
        couponCode = ""
        totalPrice = (self.oldPaymentSummaryDic["total"] as! String)
        self.paymentSummaryDic = self.oldPaymentSummaryDic
        self.tableV.reloadData()
        
    }
    
    @objc func  couponCrossButton(_ sender: UIButton)
    {
        let cell = tableV.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        couponCode = ""
        totalPrice = (self.oldPaymentSummaryDic["total"] as! String)
        self.paymentSummaryDic = self.oldPaymentSummaryDic
        cell.couponButton.setTitle("View List", for: .normal)
        cell.couponButton.isHidden = false
        cell.couponCrossButton.isHidden = true
        cell.pointsMainButton.isUserInteractionEnabled = true
        cell.couponMainButton.isUserInteractionEnabled = true
        self.isCouponApplied = false
        self.isPointsApplied = false
        self.tableV.reloadData()
        print(paymentSummaryDic)
    }
    
    @objc func  couponButton(_ sender: UIButton)
    {
        let cell = tableV.cellForRow(at: IndexPath(row: 0, section: 1)) as! ApplyCouponTableCell
        
        if cell.couponButton.currentTitle == "View List" {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PromoCodesVC") as! PromoCodesVC
            viewController.params =  params
            
            self.present(viewController, animated: true, completion: nil)
            
        }
        else
        {
            applyPointsAPI(loader: true, isForPoints: false)
        }
        
    }
    
    func placeOrderAPI(transaction_id: String) {
       
        var param:[String:Any]!
        print(self.points)
            let paramMutabaledic = params.mutableCopy() as! NSMutableDictionary
//            paramMutabaledic.setObject(couponCode, forKey: "coupon_code" as NSCopying)
//        paramMutabaledic.setObject(self.points, forKey: "points" as NSCopying)
        
        if isPointsApplied {
            paramMutabaledic.setObject("", forKey: "coupon_code" as NSCopying)
            paramMutabaledic.setObject(points, forKey: "points" as NSCopying)
        }
        else
        {
            paramMutabaledic.setObject("", forKey: "points" as NSCopying)
            paramMutabaledic.setObject(couponCode, forKey: "coupon_code" as NSCopying)
        }
        
            let payment_details = ["type":payment_mode,"payment_gateway":payment_gateway_type,
                               "payment_gateway_transaction_id":transaction_id,
                               "payment_transaction_amount":(paymentSummaryDic["total"] as! String)]
            paramMutabaledic.setObject(payment_details, forKey: "payment_details" as NSCopying)
        param = paramMutabaledic as? [String : Any]
       
        print("place order Param: \(String(describing: param))")
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrlWithJSONDictionaryParameters(strURL: ROrder_Api, is_loader_required: true, params: param, success: { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                DispatchQueue.main.async {
                    
                    if response["status_code"] as! NSNumber == 1
                    {
                         self.order_number = ((response["data"] as! NSDictionary).object(forKey: "order_id") as! NSNumber).stringValue
                     //   UIApplication.shared.keyWindow?.makeToast((response["message"] as! String), duration: 1.0, position: .center)
                   /*   if self.payment_gateway_type == "paytm"
                        {
                            let param = ["orderId":"OrderId\(self.order_number)" ,"amount": (self.paymentSummaryDic["total"] as! String)]
                            let type :ServerType = .eServerTypeStaging
                            WebService.requestPostUrlWithJSONDictionaryParameters(strURL: "check-sum", is_loader_required: true, params: param, success: { (response) in
                                let order = PGOrder(orderID: "", customerID: "", amount: "", eMail: "", mobile: "")
                                let dataDic = ((response["data"] as! NSDictionary)["paytmParams"] as! NSDictionary)
                                print(dataDic)
                                order.params = ["MID":(dataDic["MID"] as! String),"ORDER_ID":(dataDic["ORDER_ID"] as! String),"CUST_ID":(dataDic["CUST_ID"] as! String),"MOBILE_NO":(dataDic["MOBILE_NO"] as! String),"EMAIL":(dataDic["EMAIL"] as! String),"CHANNEL_ID":(dataDic["CHANNEL_ID"] as! String),"TXN_AMOUNT":CommonClass.checkForNull(string:dataDic["TXN_AMOUNT"] as AnyObject),"WEBSITE":(dataDic["WEBSITE"] as! String),"INDUSTRY_TYPE_ID":(dataDic["INDUSTRY_TYPE_ID"] as! String),"CALLBACK_URL":(dataDic["CALLBACK_URL"] as! String),"CHECKSUMHASH":((response["data"] as! NSDictionary)["paytmChecksum"] as! String)]
                                print(order.params)
                                self.pgTransactionVC = (self.pgTransactionVC.initTransaction(for: order) as! PGTransactionViewController)
                                self.pgTransactionVC.title = "Paytm Payments"
                                self.pgTransactionVC.setLoggingEnabled(true)
                                if(type != ServerType.eServerTypeNone) {
                                    self.pgTransactionVC.serverType = type;
                                } else {
                                    return
                                }
                                self.pgTransactionVC.merchant = PGMerchantConfiguration.defaultConfiguration()
                                self.pgTransactionVC.delegate = self
                                self.navigationController?.isNavigationBarHidden = false
                                self.navigationController?.pushViewController(self.pgTransactionVC, animated: true)
     
                            }) { (failure) in
                                
                                
                            }
                            return
                        }
                        else
                        { */
                            
                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderConfimatedVC") as! OrderConfimatedVC
                            viewController.order_number = self.order_number
                            
                            self.navigationController?.pushViewController(viewController, animated: true)
                      //  }
                        
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            COMMON_ALERT.showAlert(title: response["message"] as! String , msg: "", onView: self) }
                        return
                    }
                }
              
            }) { (error) in
           
            }
        }
       
    }
    
    @objc func  offersListButton(_ sender: UIButton)
    {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PromoCodesVC") as! PromoCodesVC
        viewController.params =  params
        
        self.present(viewController, animated: true, completion: nil)
        
    }
   
}

extension PaymentVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return paymentOptionsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "SelectionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SelectionCollectionCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectionCollectionCell", for: indexPath) as! SelectionCollectionCell
        
        let fieldOptionsDic = (paymentOptionsArray.object(at: indexPath.row) as! NSDictionary)
        if fieldOptionsDic.object(forKey: "isSelected") as! String == "0"
        {
            cell.backV.layer.borderColor = UIColor.lightGray.cgColor
            cell.selectionTypeLbl.textColor = UIColor.lightGray
            cell.backV.backgroundColor = .clear
            cell.imageV.isHidden = true
        }
        else
        {
            
           // cell.backV.backgroundColor = UIColor(red: 245/255.0, green: 248/255.0, blue: 254/255.0, alpha: 1)
            payment_mode = (fieldOptionsDic["type"] as! String)
            payment_gateway_type = (fieldOptionsDic["identifier"] as! String)
            cell.backV.backgroundColor = .white
            cell.selectionTypeLbl.textColor = UIColor.KMainColorCode
            cell.backV.layer.borderColor = UIColor.KMainColorCode.cgColor
            cell.imageV.isHidden = false
        }
        cell.selectionTypeLbl.text = (fieldOptionsDic.object(forKey: "title") as! String)
        cell.backV.layer.cornerRadius = 4
        cell.backV.layer.borderWidth = 1
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SelectionCollectionCell
        let dataDic = (paymentOptionsArray.object(at: indexPath.row) as! NSDictionary)
        setSelectedRow(item_id: Int(truncating: (dataDic.object(forKey: "id") as! NSNumber)))
        let fieldOptionsDic = (paymentOptionsArray.object(at: indexPath.row) as! NSDictionary)
        let identifier = fieldOptionsDic["identifier"] as! String
        
        if identifier == "card"
        {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DebitCreditCardVC") as! DebitCreditCardVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
            
        }
        
        if fieldOptionsDic.object(forKey: "isSelected") as! String == "1" {
            //cell.backV.backgroundColor = UIColor(red: 245/255.0, green: 248/255.0, blue: 254/255.0, alpha: 1)
            cell.backV.backgroundColor = .white
            cell.selectionTypeLbl.textColor = UIColor.KMainColorCode
            cell.backV.layer.borderColor = UIColor.KMainColorCode.cgColor
            cell.imageV.isHidden = false
            collectionView.reloadData()
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: 130, height: 70)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
    }
    
}

//extension PaymentVC : PGTransactionDelegate
//{
//    func didFinishedResponse(_ controller: PGTransactionViewController, response responseString: String) {
//        let msg : String = responseString
//        var titlemsg : String = "", response_code = "", jsonResponseDataDic : [String:Any]!
//        if let data = responseString.data(using: String.Encoding.utf8) {
//            do {
//                if let jsonresponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] , jsonresponse.count > 0{
//                    jsonResponseDataDic = jsonresponse
//                    response_code = jsonresponse["RESPCODE"] as? String ?? ""
//                    titlemsg = jsonresponse["STATUS"] as? String ?? ""
//                }
//            } catch {
//                print("Something went wrong")
//            }
//        }
//        if response_code == "01" {
//            WebService.requestPostUrlWithJSONDictionaryParameters(strURL: "check-sum/match", is_loader_required: true, params: jsonResponseDataDic, success: { (response) in
//
//                if response["status_code"] as! NSNumber == 1
//                {
//                   /* alert = UIAlertController(title: "", message: (response["message"] as! String), preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
//
//                    })) */
//
//                    controller.navigationController?.isNavigationBarHidden = true
//                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderConfimatedVC") as! OrderConfimatedVC
//                    viewController.order_number = self.order_number
//                    self.navigationController?.pushViewController(viewController, animated: true)
//
//                }
//                else
//                {
//                  let alert = UIAlertController(title: "", message: (response["message"] as! String), preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
//                        controller.navigationController?.isNavigationBarHidden = true
//                        self.navigationController?.popViewController(animated: true)
//                    }))
//                     self.present(alert, animated: true, completion: nil)
//                }
//
//                print(response)
//            }) { (failure) in
//
//            }
//        }
//
//        controller.navigationController?.popViewController(animated: true)
//
//    }
//
//    //this function triggers when transaction gets cancelled
//    func didCancelTrasaction(_ controller : PGTransactionViewController) {
//       // controller.navigationController?.isNavigationBarHidden = true
//        controller.navigationController?.popViewController(animated: true)
//    }
//
//    //Called when a required parameter is missing.
//    func errorMisssingParameter(_ controller : PGTransactionViewController, error : NSError?) {
//       // controller.navigationController?.isNavigationBarHidden = true
//        controller.navigationController?.popViewController(animated: true)
//    }
//
//    }

extension PaymentVC: RazorpayPaymentCompletionProtocol {
    func onPaymentSuccess(_ payment_id: String) {
        print(payment_id)
        placeOrderAPI(transaction_id: payment_id)
       /* let alert = UIAlertController(title: "Paid", message: "Payment Success", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil) */
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        let alert = UIAlertController(title: "", message: "\(code)\n\(str)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
