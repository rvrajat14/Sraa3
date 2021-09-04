//
//  CartVC.swift
//  FoodApplication
//
//  Created by Kishore on 30/05/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

let LABEL_HORIZONTAL_MARGIN = 15

class CartVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    var isFromQuesAnsVC = false
    @IBOutlet weak var okayButton: UIButton!
    var category_id = ""
    var category_title = ""
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var storeNameLbl: UILabel!
    @IBAction func okayButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
   
    self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var emptyBasketV: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var proceedView: UIView!
    var itemsDataArray = NSMutableArray.init()
    var isForReorder = false
    var order_id = "",total_price = ""
    
    var isForApplyCoupon = true, isForLoyaltyPoints = false
    var isLoyaltyPointApplied = false, isCouponCodeApplied = false
    
    var isApplyCouponViewHide = true
    var paymentDataDic = NSMutableDictionary.init()
    var isProductCartArrayContainsReorderData = false
    var isItemsAvailable = false
    
    @IBOutlet weak var totalPriceLbl: UILabel!
  //  var user_data:UserDataClass!
    var paymentSummaryDataDic = NSMutableDictionary.init()
    
    let userDefaults = UserDefaults.standard
    
    //MARK: Proceed To Check Out Page
    
    @IBAction func proceedButton(_ sender: UIButton) {
        if userDefaults.object(forKey: "userData") != nil {
        isProductCartArrayContainsReorderData = false
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CheckOutVC") as! CheckOutVC
      //  viewController.total_amount = total_price
        viewController.isFromQuesAnsVC = isFromQuesAnsVC
        viewController.category_id = self.category_id
        viewController.paymentSummaryDataDic = paymentSummaryDataDic
        self.navigationController?.pushViewController(viewController, animated: true)
        }
        else {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let navigationController = UINavigationController(rootViewController: viewController)
            isFromAppdelegate = false
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var tableV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedOptionsTitleArray)
        self.tableV.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        self.tableV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 90))
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableV.rowHeight = UITableViewAutomaticDimension
        tableV.estimatedRowHeight = 130
        proceedButton.isHidden = true
        tableV.isHidden = true
       self.getPaymentSummaryData(loader: true)
    }

    override func viewDidLayoutSubviews() {
        self.proceedButton.layer.cornerRadius = 10
        self.proceedButton.layer.masksToBounds = true
        Utilities.setButtonGradiantColor(button: self.proceedButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        self.navigationItem.title = "CART"
        self.navigationController?.isNavigationBarHidden = true
        if userDefaults.object(forKey: "userData") != nil {
            self.proceedButton.setTitle("Continue", for: .normal)
        }
        else {
            self.proceedButton.setTitle("Login to proceed", for: .normal)
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
////TableView Methods///////
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.paymentSummaryDataDic.count > 0 {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if (paymentSummaryDataDic.count) > 0
            {
                if section == 0
                {
                   print(productCartArray.count > 0 ? (productCartArray.count) : (selectedOptionsTitleArray.count))
                    return (productCartArray.count > 0 ? (productCartArray.count) : (selectedOptionsTitleArray.count))
                }
                if section == 1
                {
                return (paymentSummaryDataDic.object(forKey: "data") as! NSArray).count
                }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if (productCartArray.count < 1) {
                
                let nib1 = UINib(nibName: "OptionsTitleTVCell", bundle: nil)
                    
                tableView.register(nib1, forCellReuseIdentifier: "OptionsTitleTVCell")
                    
                let cell  = tableView.dequeueReusableCell(withIdentifier: "OptionsTitleTVCell") as! OptionsTitleTVCell
                cell.selectionStyle = .none
                let title = selectedOptionsTitleArray[indexPath.row]
                cell.titleLbl.text = title
                if indexPath.row == selectedOptionsTitleArray.count - 1 {
                    cell.titleBottomConstraint.constant = 15
                }
                else {
                    cell.titleBottomConstraint.constant = 8
                }
               return cell
            }
          
            let subDataDictionary = productCartArray.object(at: indexPath.row) as! NSDictionary
                
            let nib1 = UINib(nibName: "ItemCell", bundle: nil)
                
            tableView.register(nib1, forCellReuseIdentifier: "ItemCell")
                
            let cell  = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as! ItemCell
            cell.selectionStyle = .none
           
            cell.totalQuantityLbl.text = CommonClass.checkForNull(string: subDataDictionary.object(forKey: "quantity") as AnyObject)
            
                cell.itemImageV.isUserInteractionEnabled = false
                cell.itemImageV.tag = indexPath.row
            
            var imageUrl : URL!
                if let image_path = (subDataDictionary.object(forKey: "thumb_photo") as? String)
                {
                     imageUrl = URL(string: BASE_IMAGE_URL + KItem_Api + "/" + image_path)
                }
            cell.itemImageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_subCategory"), options: .refreshCached, completed: nil)
            var item_price = "0"
            
            if let price = subDataDictionary.object(forKey: "real_price") as? NSNumber
            {
                item_price = price.stringValue
            }
            
//            cell.itemNameLbl.text = CommonClass.checkForNull(string: subDataDictionary.object(forKey: "item_title") as AnyObject) + " ( \(currencySymbol)\(item_price))"
            
            cell.itemNameLbl.text = CommonClass.checkForNull(string: subDataDictionary.object(forKey: "item_title") as AnyObject)
        
            if let price = subDataDictionary.object(forKey: "item_price_single") as? String
            {
                 cell.itemPriceLbl?.text = currencySymbol + CommonClass.getCorrectPriceFormat(price: price)
            }
            cell.itemPriceLbl.textColor = UIColor.black
            cell.totalQuantityLbl.text = CommonClass.checkForNull(string: subDataDictionary.object(forKey: "quantity") as AnyObject)
            cell.itemDetailLbl.text = ""
            cell.addButton.isHidden = true
            
            cell.plusButton?.tag = Int(isFromQuesAnsVC ? CommonClass.checkForNull(string: subDataDictionary["id"] as AnyObject) : CommonClass.checkForNull(string: subDataDictionary["item_id"] as AnyObject))!
            cell.minusButton?.tag = (cell.plusButton?.tag)!
           
            cell.minusButton.addTarget(self, action: #selector(minusButton(_:event:)), for: UIControlEvents.touchUpInside)
            
            cell.plusButton.addTarget(self, action: #selector(plusButton(_:event:)), for: UIControlEvents.touchUpInside)
            
           // cell.quantityView.layer.borderColor = UIColor.black.cgColor
           // cell.quantityView.layer.borderWidth = 1
            cell.quantityView.layer.cornerRadius = 3
            if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1)
            {
                cell.separatorView.isHidden = true
            }
            else
            {
                cell.separatorView.isHidden = false
            }
             
            cell.itemNameLblHeightConstraint.constant = cell.itemNameLbl.heightForLabel()
            
            // Black Color in Quantity View
            cell.addButton.setTitleColor(UIColor.black, for: .normal)
            cell.plusButton.setTitleColor(UIColor.black, for: .normal)
            cell.minusButton.setTitleColor(UIColor.black, for: .normal)
            cell.totalQuantityLbl.textColor = UIColor.black
            
            
            return cell
            
            }
            
        else if indexPath.section == 1
        {
            let nib1 = UINib(nibName: "PaymentSummaryTableCell", bundle: nil)
            tableView.register(nib1, forCellReuseIdentifier: "PaymentSummaryTableCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentSummaryTableCell") as! PaymentSummaryTableCell
            
            if (paymentSummaryDataDic.count) > 0
            {
                    let dataDictionary = (paymentSummaryDataDic.object(forKey: "data") as! NSArray).object(at: indexPath.row) as! NSDictionary
                    let title = dataDictionary.object(forKey: "title") as! String
                    let value = (dataDictionary.object(forKey: "value") as! String)
               
                        cell.titleLbl.text = title
                        cell.valueLbl.text =  currencySymbol + CommonClass.getCorrectPriceFormat(price: value)
                
                if (tableView.numberOfRows(inSection: indexPath.section) - 1) == indexPath.row
                {
                   cell.separatorView.isHidden = false
                }
                else
                {
                    cell.separatorView.isHidden = true
                }
                    
                }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        
      return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 1 {
            return 33
        }
         return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          if section == 0 {
            return 44
        }
        return 34
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 130
        }
        
         return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if paymentSummaryDataDic.count > 0 {
            let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
            headerView.backgroundColor = UIColor.clear
            var infoLabel = UILabel.init()
            infoLabel = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.size.width - 32, height: 24))
        
            if section == 1 {
                 infoLabel = UILabel(frame: CGRect(x: 16, y: 2, width: self.view.frame.size.width - 32, height: 24))
                 infoLabel.text = "Amount"
            }
            else
            {
                if productCartArray.count > 0 {
                    if(productCartArray.count == 1)
                    {
                        infoLabel.text = "\(productCartArray.count) Item In Cart"
                    }
                    else
                    {
                    infoLabel.text = "\(productCartArray.count) Items In Cart"
                    }
                }
                else {
                    infoLabel.text = self.category_title
                }
            }
            
            infoLabel.textColor = UIColor.black
            infoLabel.font = UIFont(name: KMainFontSemiBold, size: 17)
            headerView.addSubview(infoLabel)
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerView = UIView.init()
        if section == 1 {
            
            footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 130))
            footerView.backgroundColor = UIColor.white
            if paymentSummaryDataDic.count > 0
            {
               total_price = (paymentSummaryDataDic.object(forKey: "total") as! String)
            let titleLbl:UILabel = UILabel(frame: CGRect(x: 15, y: 10, width: 80, height: 21))
            titleLbl.textColor = UIColor.black
            titleLbl.text = "Total"
            //infoLabel.alpha = 0.80
            titleLbl.font = UIFont(name: KMainFont, size: 15)
            let fonD:UIFontDescriptor = titleLbl.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
            
            titleLbl.font = UIFont(descriptor: fonD, size: 15)
            footerView.addSubview(titleLbl)
            
            let totalPriceLbl:UILabel = UILabel(frame: CGRect(x: self.view.frame.size.width - 115, y: titleLbl.frame.origin.y, width: 100, height: 21))
            totalPriceLbl.textColor = UIColor.black
            totalPriceLbl.textAlignment = .right
             totalPriceLbl.text = currencySymbol + CommonClass.getCorrectPriceFormat(price: total_price)
           
            totalPriceLbl.font = UIFont(name: KMainFont, size: 15)
            let fonD1:UIFontDescriptor = totalPriceLbl.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
            
            totalPriceLbl.font = UIFont(descriptor: fonD1, size: 15)
            footerView.addSubview(totalPriceLbl)
                
                
                let bottomV = UIView(frame: CGRect(x: 0, y: totalPriceLbl.frame.size.height + totalPriceLbl.frame.origin.y, width: self.view.frame.size.width, height: 80))
                
        
                
                let bottomSubV = UIView(frame: CGRect(x: 10, y: 24, width: self.view.frame.size.width - 20, height: 54))
                bottomSubV.backgroundColor = UIColor.KLightGreyColor
                bottomSubV.clipsToBounds = true
                bottomSubV.layer.masksToBounds = true
                bottomSubV.layer.cornerRadius = 4
                bottomV.addSubview(bottomSubV)
                let bottomLbl = UILabel(frame: CGRect(x: 15, y: 30, width: self.view.frame.size.width - 30, height: 44))
                bottomLbl.numberOfLines = 2
                bottomLbl.font = UIFont(name: KMainFont, size: 14)
                bottomLbl.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
                bottomLbl.text = "Pay Rs. 99 as visiting charges If you do not provide the Job after inspection."
                bottomV.addSubview(bottomLbl)
                footerView.addSubview(bottomV)
                
            }
            return footerView
        }
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        footerView.backgroundColor = UIColor.hexToColor(hexString: "F6F6F8")
        return footerView
    }
/////End Table View Methods
    
    
    //MARK: - Selector Methods/////////////////////


func popVC(_ sender: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func plusButton(_ sender: UIButton?,event: AnyObject?) {
        
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableV)
        let indexPath:NSIndexPath = self.tableV.indexPathForRow(at: touchPosition)! as NSIndexPath
        
        var count = ((productCartArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "quantity") as! Int)
        
        count += 1
        let temp_dictionary = (productCartArray.object(at: indexPath.row) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        temp_dictionary.setObject(count, forKey: "quantity" as NSCopying)
        var discounted_price = 0.0
//
//        var storedTotalItemPrice = 0.0
//        var itemTotalPrice = 0.0
//
//        if let price = temp_dictionary.object(forKey: "itemTotalPriceForCartPage") as? String {
//
//            discounted_price = temp_dictionary.object(forKey: "discounted_price") as! Double
//            storedTotalItemPrice =  Double(price)!
//            itemTotalPrice = temp_dictionary.object(forKey: "itemTotalPrice") as! Double
//            storedTotalItemPrice += discounted_price + itemTotalPrice
//
//        }
//        else if let price = (temp_dictionary.object(forKey: "item_price") as? NSNumber)
//        {
//            let base_price = Double(truncating: temp_dictionary.object(forKey: "single_qu_item_price") as! NSNumber)
//            let base_discount = Double(truncating: temp_dictionary.object(forKey: "item_discount") as! NSNumber)
//            discounted_price = base_price - base_discount
//
//            storedTotalItemPrice = Double(truncating: price)
//            storedTotalItemPrice += (discounted_price + itemTotalPrice)
//        }
//        temp_dictionary.setObject(discounted_price, forKey: "discounted_price" as NSCopying)
//        temp_dictionary.setObject(String(storedTotalItemPrice), forKey: "itemTotalPriceForCartPage" as NSCopying)
//        temp_dictionary.setObject(itemTotalPrice, forKey: "itemTotalPrice" as NSCopying)
        productCartArray.replaceObject(at: indexPath.row, with: temp_dictionary)
        print("Product Cart Array = \(productCartArray)")
        
        let cell = self.tableV.cellForRow(at: indexPath as IndexPath) as! ItemCell
        cell.totalQuantityLbl.text = String(count)
        
        //let temp_array = self.getOrderProductArray() as NSArray
        
        self.getPaymentSummaryData(loader: true)
    }
    
     @objc func minusButton(_ sender: UIButton?,event: AnyObject?) {
        
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableV)
        let indexPath:NSIndexPath = self.tableV.indexPathForRow(at: touchPosition)! as NSIndexPath
        
        
        var count = ((productCartArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "quantity") as! Int)
      
        let cell = self.tableV.cellForRow(at: indexPath as IndexPath) as! ItemCell
        
        
        cell.totalQuantityLbl.text = String(count)
        if (productCartArray.count) > 0
        {
            count -= 1
            
                if count < 1
                {
                    productCartArray.removeObject(at: indexPath.row)
                    cell.addButton.isHidden = false
                    self.tableV.reloadData()
                    // return
                }
                else
                {
                    let temp_dictionary = (productCartArray.object(at: indexPath.row) as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
//                    var discounted_price = 0.0
//                    var storedTotalItemPrice = 0.0
//                    var itemTotalPrice = 0.0
//                    if let price = temp_dictionary.object(forKey: "itemTotalPriceForCartPage") as? String {
//                        discounted_price =  temp_dictionary.object(forKey: "discounted_price") as! Double
//                        storedTotalItemPrice =  Double(price)!
//                        itemTotalPrice = temp_dictionary.object(forKey: "itemTotalPrice") as! Double
//                        storedTotalItemPrice -= (discounted_price + itemTotalPrice)
//                    }
//                    else if (temp_dictionary.object(forKey: "item_price") as? NSNumber) != nil
//                    {
//                        let base_price = Double(truncating: temp_dictionary.object(forKey: "single_quantity_item_price") as! NSNumber)
//                        let base_discount = Double(truncating: temp_dictionary.object(forKey: "item_discount") as! NSNumber)
//                        discounted_price = base_price - base_discount
//
//
//                        storedTotalItemPrice -= (discounted_price + itemTotalPrice)
//                    }
//
//                    temp_dictionary.setObject(discounted_price, forKey: "discounted_price" as NSCopying)
//                    temp_dictionary.setObject(String(storedTotalItemPrice), forKey: "itemTotalPriceForCartPage" as NSCopying)
//                    temp_dictionary.setObject(itemTotalPrice, forKey: "itemTotalPrice" as NSCopying)
                    
                    temp_dictionary.setObject(count, forKey: "quantity" as NSCopying)
                    productCartArray.replaceObject(at: indexPath.row, with: temp_dictionary)
                    print("Product Cart Array = \(productCartArray)")
                    cell.totalQuantityLbl.text = String(count)
                    //return
                }
            }
         
        else
        {
            cell.addButton.isHidden = false
        }
        if productCartArray.count == 0 {
            self.navigationController?.popViewController(animated: true)
            return
        }
      
        self.getPaymentSummaryData(loader: true)
        
    }
    
    //MARK: Get Variant Price
    
    func getVariantPrice(item_price:String, item_price_difference:String) -> Double {
        
        if item_price == "0"
        {
            if item_price_difference == "0" || item_price_difference.isEmpty
            {
                return 0.0
            }
            else
            {
                return  Double(item_price_difference)!
            }
        }
        else
        {
            return Double(item_price)!
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isProductCartArrayContainsReorderData {
            if (productCartArray.count) > 0
            {
                productCartArray.removeAllObjects()
            }
        }
    }
    
    //MARK: -Get Payment Summary Data From API
   
    func getPaymentSummaryData(loader:Bool) {
        var api_name = ""
       
        var param:[String:Any]!
       
        if isForReorder {
          api_name =  KOrder_Api + "/get-reorder-data/\(order_id)"
            productCartArray.removeAllObjects()
        }else
        {
//            api_name = KOrder_Api + "/" + KCalculate
            api_name =  isFromQuesAnsVC ? ( (productCartArray.count<1) ? (RFormCalculate_Api) : (ROrderCalculate_Api)) : (ROrderCalculate_Api)
        }
       
        param = ["items":productCartArray,"coupon_code":"", "store_id":KStore_id,"loyalty_points":"","area_id":"","order_meta":NSDictionary.init(),"is_option_items":isFromQuesAnsVC ? "1" : "0","options_id": selectedOptionsIdsArray] as [String:Any]
        
        
        print("cart param: \(String(describing: param))")
        
        ///For Reorder
        
        if isForReorder {
       
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
            self.present(vc, animated: false) {
                WebService.requestGetUrl(strURL: api_name , is_loader_required: loader, success: { (response) in
                     print(response)
                   
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                    if response["status_code"] as! NSNumber == 1
                    {
                        self.paymentSummaryDataDic = ((response["data"] as! NSDictionary)["payment"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        self.itemsDataArray = ((response["data"] as! NSDictionary)["items"] as! NSArray).mutableCopy() as! NSMutableArray
                        
                            productCartArray = self.itemsDataArray
                        
                        print("Payment Data Dic  \(response)")
                        self.proceedButton.isHidden = false
                        self.tableV.isHidden = false
                        
                           self.total_price = (self.paymentSummaryDataDic.object(forKey: "total") as! NSNumber).stringValue
                            
                            self.totalPriceLbl.text =  CommonClass.getCorrectPriceFormat(price: self.total_price)
                            self.isProductCartArrayContainsReorderData = true
                            self.isForReorder = false
                        
                            self.tableV.reloadData()
                       
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            COMMON_ALERT.showAlert(title: "" , msg:  response["message"] as! String, onView: self) }
                    }
                   
                }) { (error) in
                    
                   }
            }
        
        }
        else
        {
        ///Normal API With Parameters
        
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
            self.present(vc, animated: false) {
                WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: loader, params: param, success: { (response) in
                print(response)
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                
                if response["status_code"] as! NSNumber == 1
                {
                    if productCartArray.count < 1 {
                        self.paymentSummaryDataDic = (response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    }
                    else {
                    self.paymentSummaryDataDic = ((response["data"] as! NSDictionary)["payment"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        self.itemsDataArray = ((response["data"] as! NSDictionary)["items"] as! NSArray).mutableCopy() as! NSMutableArray
                        productCartArray = self.itemsDataArray
                        print("Payment Data Dic  \(response)")
                    }
          
                    DispatchQueue.main.async {
                        let total_price = (self.paymentSummaryDataDic.object(forKey: "total") as! String)
                        
                       // self.totalPriceLbl.text =  CommonClass.getCorrectPriceFormat(price: total_price)
                        self.proceedButton.isHidden = false
                        self.tableV.isHidden = false
                        self.tableV.reloadData()
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        COMMON_ALERT.showAlert(title: "" , msg:  response["message"] as! String, onView: self) }
                }
                    
               
            }) { (error) in
           
            }
            }
            
    }
    }
    
    //MARK: - Check Cart Array for product id
    
    func isCartArrayContainsProductId(product_id: String) -> (isContain: Bool, count: Int, index: Int) {
        
        var count = 0
        
        
        for (index,dataDic) in (productCartArray.enumerated()) {
            
            if ((dataDic as! NSDictionary).object(forKey: "item_id") as! NSNumber).stringValue ==  (product_id)
            {
                count = ((dataDic as! NSDictionary).object(forKey: "quantity") as! Int)
                return (true,count,index)
            }
        }
        
        return (false, -1,-1)
    }
    
}





