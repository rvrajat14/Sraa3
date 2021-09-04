//
//  ItemsVC.swift
//  SRAA3
//
//  Created by Apple on 21/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ItemsVC: UIViewController , UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var cartBtn: UIButton!
    
    @IBOutlet weak var tableV: UITableView!
    
    var category_id = ""
    var category_title = ""
    var category_photo = ""
    
    var descriptionStr = ""
    var allItemsDataArray = NSMutableArray.init()
    
    @IBOutlet weak var headerTitleLbl: UILabel!
    
    @IBOutlet weak var selectionsButton: UIButton!
    var selectedOptionsArray = [NSDictionary]()
    var isFromQuesAnsVC = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectionsButton.layer.cornerRadius = 5
        self.selectionsButton.isHidden = self.isFromQuesAnsVC ? false : true
        self.tabBarController?.tabBar.isHidden = true
        headerTitleLbl.text = category_title
        self.cartBtn.isHidden = true
        self.tableV.isHidden = true
        isFromQuesAnsVC ? getOptionItemsApi() : getItemsApiCall()
        tableV.estimatedRowHeight = 130
        NotificationCenter.default.addObserver(self, selector: #selector(clearCartData), name: NSNotification.Name("OrderCancelFromCheckOut"), object: nil)
       
        self.tableV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 90))
        
    }
    
    override func viewDidLayoutSubviews() {
        self.cartBtn.layer.cornerRadius = 10
        self.cartBtn.layer.masksToBounds = true
        Utilities.setButtonGradiantColor(button: self.cartBtn)
    }
    
    @IBAction func selectionsButton(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OptionItemsVC") as! OptionItemsVC
        vc.selectedOptionsArray = self.selectedOptionsArray
        self.present(vc, animated: true, completion: nil)

    }
 
    @objc private func clearCartData(_ sender: Any) {
        productCartArray.removeAllObjects()
        questionAnswerCartArray = NSMutableArray.init()
        self.tableV.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statusOfBottomBtn()
        self.tableV.reloadData()
    }
    
    @IBAction func cartBtnTaped(_ sender: Any){
        
        if isFromQuesAnsVC {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DescriptionVC") as! DescriptionVC
            vc.isFromQuesAnsVC = isFromQuesAnsVC
            vc.category_id = self.category_id
            vc.category_title = self.category_title
            vc.descriptionStr = descriptionStr
            vc.isItemsAvailable = true
            self.navigationController?.pushViewController(vc, animated: false)
        }
        else {
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
           vc.isFromQuesAnsVC = isFromQuesAnsVC
           vc.category_id = self.category_id
           self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @IBAction func popVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView = UIView.init()
       
        var headerImgV = UIImageView.init()
      /*  if UIDevice.current.userInterfaceIdiom == .pad
        {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 250))
          headerImgV = UIImageView(frame: CGRect(x: 0, y: 0, width: self.tableV.frame.size.width, height: 240))
        }
        else
        { */
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: (self.tableV.frame.size.width)*0.48))
        headerImgV = UIImageView(frame: CGRect(x: 0, y: 0, width: self.tableV.frame.size.width, height: ((self.tableV.frame.size.width)*0.48)))
      //  }
         headerView.backgroundColor = UIColor.groupTableViewBackground
        let imageUrl = URL(string: BASE_IMAGE_URL + KCategory_Api + "/" + category_photo)
        headerImgV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .refreshCached, completed: nil)
        headerImgV.contentMode = .scaleToFill
        headerView.addSubview(headerImgV)
        
       /* let bottomGredientV = UIView(frame: CGRect(x: 0, y: headerView.frame.size.height - 60, width: self.view.frame.size.width, height: 72))
        
        let gradient = CAGradientLayer()
        gradient.colors = [(UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.0)).cgColor, (UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.7)).cgColor]
        gradient.frame = CGRect(x: 0, y: 0, width: view.frame.size.height, height: 52)
        bottomGredientV.layer.insertSublayer(gradient, at: 0)
        headerView.addSubview(bottomGredientV)
        
        let infoLabel:UILabel = UILabel(frame: CGRect(x: 16, y: bottomGredientV.frame.origin.y + 15, width: self.view.frame.size.width - 32, height: 24))
        
         infoLabel.font = UIFont(name: KMainFont, size: 18)
         infoLabel.text = category_title
         infoLabel.textColor = UIColor.white
         headerView.addSubview(infoLabel) */
        
        return isFromQuesAnsVC ? UIView.init() : headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       /* if UIDevice.current.userInterfaceIdiom == .pad
        {
        return 250
        } */
        return isFromQuesAnsVC ? 12 : (self.tableV.frame.size.width)*0.48 + 12
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allItemsDataArray.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "ItemCell"
        var cell: ItemCell! = tableView.dequeueReusableCell(withIdentifier: identifier)as? ItemCell
        if cell == nil {
            var nib = Bundle.main.loadNibNamed("ItemCell", owner: self, options: nil)
            cell = nib![0] as? ItemCell
        }
        cell.selectionStyle = .none
        let dataDic = allItemsDataArray[indexPath.row] as! NSDictionary
        
        var imageUrl : URL!
        if let imgPath = dataDic["thumb_photo"] as? String
        {
            imageUrl = URL(string: BASE_IMAGE_URL + "item/" + imgPath)
        }
        cell.itemImageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .refreshCached, completed: nil)
        cell.itemNameLbl.text = (dataDic["item_title"] as! String)
        cell.itemNameLblHeightConstraint.constant = cell.itemNameLbl.heightForLabel() + 10
        let item_id =  isFromQuesAnsVC ? CommonClass.checkForNull(string: dataDic["id"] as AnyObject) : CommonClass.checkForNull(string: dataDic["item_id"] as AnyObject)
        
    
        cell.itemDetailLbl.text = (dataDic["description"] as! String)

//        let oldPrice = Float(CommonClass.checkForNull(string: dataDic["old_price"] as AnyObject))!
        let itemPrice = Float(CommonClass.checkForNull(string: dataDic["item_price"] as AnyObject))!
        let realPrice = Float(CommonClass.checkForNull(string: dataDic["real_price"] as AnyObject))!
        let discount = CommonClass.checkForNull(string: dataDic["item_discount"] as AnyObject)
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: currencySymbol + CommonClass.getCorrectPriceFormat(price: CommonClass.checkForNull(string: dataDic["item_price"] as AnyObject)))
        attributeString.addAttributes([NSAttributedStringKey.strikethroughStyle : 1,NSAttributedStringKey.font: UIFont(name: KMainFontSemiBold, size: 13)!,NSAttributedStringKey.foregroundColor:hexStringToUIColor(hex: "#959698")], range: NSMakeRange(0, attributeString.length))
       // attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        if itemPrice > realPrice {
           cell.oldPriceLbl.attributedText = attributeString
           cell.oldPriceLbl.isHidden = false
           cell.oldPriceHeightConstraint.constant = 18
        }
        else
        {
            cell.oldPriceLbl.attributedText = NSAttributedString(string: "gggg")
            cell.oldPriceLbl.isHidden = true
            cell.oldPriceHeightConstraint.constant = 0
        }
        print(discount)
        let itemPriceAttributeString: NSMutableAttributedString = NSMutableAttributedString(string: currencySymbol + CommonClass.getCorrectPriceFormat(price: CommonClass.checkForNull(string: dataDic["real_price"] as AnyObject)))
//        itemPriceAttributeString.addAttributes([NSAttributedStringKey.font: UIFont(name: KMainFont, size: 13)!,NSAttributedStringKey.foregroundColor:UIColor.black], range: NSMakeRange(0, itemPriceAttributeString.length))
        let discountAttributeString: NSMutableAttributedString =  NSMutableAttributedString(string: " (save \(discount)%)")
        discountAttributeString.addAttributes([NSAttributedStringKey.font: UIFont(name: KMainFont, size: 13)!,NSAttributedStringKey.foregroundColor:hexStringToUIColor(hex: "#29B86B")], range: NSMakeRange(0, discountAttributeString.length))
        if discount != "" && discount != "0" {
            let finalStr = NSMutableAttributedString()
            finalStr.append(itemPriceAttributeString)
            finalStr.append(discountAttributeString)
            cell.itemPriceLbl.attributedText = finalStr
        }
        else {
        cell.itemPriceLbl.attributedText = itemPriceAttributeString
        }
        cell.itemPriceLblHeightConstraint.constant = cell.itemPriceLbl.heightForLabel()
        
        let (matched,_,index) = CommonClass.ifProductAlreadyInCart(productID: item_id, isOptionItem: isFromQuesAnsVC ? true : false)
        
        if matched{
//            cell.quantityView.bringSubview(toFront: cell.plusButton)
            cell.addButton.isHidden = true
            
            cell.totalQuantityLbl.text = CommonClass.getTheTotalQuantityOfProductWithId(p_id: item_id, isOptionItem: isFromQuesAnsVC ? true : false)
        }
        else
        {
            cell.addButton.isHidden = false
        }
        
        let itemStatus = dataDic["item_active_status"] as! String
        if itemStatus == "0"
        {
            cell.quantityView.isHidden = true
            cell.itemStatusView.isHidden = false
            cell.itemNotAvailableV.layer.cornerRadius = 2
            cell.itemNotAvailableV.layer.borderWidth = 1
            cell.itemNotAvailableV.layer.borderColor = UIColor.lightGray.cgColor
        }
        else
        {
            cell.itemStatusView.isHidden = true
        }
        
        cell.addButton.tag = indexPath.row
        cell.plusButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: #selector(addButton(_:event:)), for: UIControlEvents.touchUpInside)
        cell.minusButton.addTarget(self, action: #selector(minusButton(_:event:)), for: UIControlEvents.touchUpInside)
        cell.plusButton.addTarget(self, action: #selector(plusButton(_:event:)), for: UIControlEvents.touchUpInside)
        cell.selectionStyle = .none
       // cell.quantityView.layer.borderWidth = 1
       // cell.quantityView.layer.borderColor = UIColor.black.cgColor
        cell.quantityView.layer.cornerRadius = 3
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorView.isHidden = true
        }
        else
        {
            cell.separatorView.isHidden = false
        }
        return cell
    }
    
    //MARK: Add Button
    
    @objc func addButton(_ sender: UIButton?,event: AnyObject?){
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableV)
        let indexPath:NSIndexPath = self.tableV.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = self.tableV.cellForRow(at: indexPath as IndexPath) as! ItemCell
       
        let dataDic = (allItemsDataArray[indexPath.row] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
       
//            let base_price = Int(truncating: dataDic.object(forKey: "item_price") as! NSNumber)
        
            
            cell.addButton.isHidden = true
           
            cell.totalQuantityLbl.text = "1"
           // self.numberOfCartItemsLbl.text =  CommonClass.calculateTotalNumberOfItemsInCart() + " Items"
//            let discounted_price = base_price - Int(truncating: dataDic["item_discount"]! as! NSNumber)
            dataDic.setObject(NSArray.init(), forKey: "variants" as NSCopying)
//            dataDic.setObject(Double(discounted_price), forKey: "discounted_price" as NSCopying)
            dataDic.setObject(0.0, forKey: "itemTotalPrice" as NSCopying)
//            dataDic.setObject(String(base_price), forKey: "itemTotalPriceForCartPage" as NSCopying)
            dataDic.setObject(1, forKey: "quantity" as NSCopying)
            productCartArray.add(dataDic)
        
        statusOfBottomBtn()
        
        if  CommonClass.calculateTotalNumberOfItemsInCart() == "0"{
            //basketButton.badgeValue = ""
            self.cartBtn.backgroundColor = UIColor.lightGray
        }
        else
        {
          //  basketButton.badgeValue = CommonClass.calculateTotalNumberOfItemsInCart()
             self.cartBtn.backgroundColor = UIColor.black
        }
    }
    
    //MARK: Plus Button
    
    @objc func plusButton(_ sender: UIButton?,event: AnyObject?) {
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableV)
        let indexPath:NSIndexPath = self.tableV.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = self.tableV.cellForRow(at: indexPath as IndexPath) as! ItemCell
        let dataDic = (allItemsDataArray[indexPath.row] as! NSDictionary).mutableCopy() as! NSMutableDictionary
       
            let item_id = isFromQuesAnsVC ? CommonClass.checkForNull(string: dataDic["id"] as AnyObject) : CommonClass.checkForNull(string: dataDic["item_id"] as AnyObject)
            
        var (matched,quantity,index) = CommonClass.ifProductAlreadyInCart(productID: item_id, isOptionItem: isFromQuesAnsVC ? true : false)
            
            if matched
            {
                quantity += 1
                let tmpDic = (productCartArray[index] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                tmpDic.setObject(quantity, forKey: "quantity" as NSCopying)
//                let base_price = Double(truncating: tmpDic.object(forKey: "item_price") as! NSNumber)
//                var storedTotalItemPrice = Double(tmpDic.object(forKey: "itemTotalPriceForCartPage") as! String)!
//                storedTotalItemPrice += base_price
//                tmpDic.setObject(String(storedTotalItemPrice), forKey: "itemTotalPriceForCartPage" as NSCopying)
                productCartArray.replaceObject(at: index, with: tmpDic)
            }
        cell.totalQuantityLbl.text = "\(CommonClass.cartItemCount(productID: item_id,isOptionItem: isFromQuesAnsVC ? true : false))"
           statusOfBottomBtn()
       
    }
    
    //MARK: Minus Button
    
    @objc func minusButton(_ sender: UIButton?,event: AnyObject?) {
        
        let touches: Set<UITouch>
        touches = (event?.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableV)
        let indexPath:NSIndexPath = self.tableV.indexPathForRow(at: touchPosition)! as NSIndexPath
        let cell  = self.tableV.cellForRow(at: indexPath as IndexPath) as! ItemCell
        let dataDic = (allItemsDataArray[indexPath.row] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        
            let itemId = isFromQuesAnsVC ? CommonClass.checkForNull(string: dataDic["id"] as AnyObject) : CommonClass.checkForNull(string: dataDic["item_id"] as AnyObject)
        var (isMatched,itemCount,index) = CommonClass.ifProductAlreadyInCart(productID: itemId, isOptionItem: isFromQuesAnsVC ? true : false)
            
            if  isMatched == true{
                let  tempDic = (productCartArray.object(at: index) as! NSDictionary).mutableCopy() as! NSMutableDictionary
                itemCount -= 1
//                let base_price = Double(truncating: dataDic.object(forKey: "item_price") as! NSNumber)
                if itemCount < 1
                {
                    productCartArray.removeObject(at: index)
                    cell.addButton.isHidden = false
                }
                else
                {
//                    var storedTotalItemPrice = Double(tempDic.object(forKey: "itemTotalPriceForCartPage") as! String)!
                    
//                    if storedTotalItemPrice > base_price
//                    {
//                        storedTotalItemPrice -= base_price
//                    }
//                    tempDic.setObject(String(storedTotalItemPrice), forKey: "itemTotalPriceForCartPage" as NSCopying)
                    tempDic.setObject(itemCount, forKey: "quantity" as NSCopying)
                    productCartArray.replaceObject(at: index, with: tempDic)
                  
                    cell.addButton.isHidden = true
                }
            }
            
        cell.totalQuantityLbl.text = String(CommonClass.cartItemCount(productID: itemId, isOptionItem: isFromQuesAnsVC ? true : false))
            statusOfBottomBtn()
        
    }
    
    func statusOfBottomBtn()  {
        self.cartBtn.setTitle("Item Added(" + CommonClass.calculateTotalNumberOfItemsInCart() + ")" , for: .normal)
        if CommonClass.calculateTotalNumberOfItemsInCart() == "0"
        {
            self.cartBtn.backgroundColor = UIColor.lightGray
            self.cartBtn.isEnabled = false
        }
        else
        {
            self.cartBtn.backgroundColor = UIColor.black
            self.cartBtn.isEnabled = true
        }
    }

    // MARk:- Api Call
    
    func getItemsApiCall() {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestGetUrl(strURL: RItems_Api + "?" + "subcategory_id=\(self.category_id)" , is_loader_required: true, success: { (response) in
                print(response)
                
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if (response.value(forKey: "status_code")as! NSNumber) == 1
                {
                    let dataDic = response["data"] as! NSDictionary
                    print("Data: \(dataDic)")
                     self.allItemsDataArray.addObjects(from: ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray as! [Any])
                    self.cartBtn.isHidden = false
                    self.tableV.isHidden = false
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
    
    func getOptionItemsApi() {
        var idStr = ""
        for (index,item) in selectedOptionsIdsArray.enumerated() {
            if index == selectedOptionsIdsArray.count - 1 {
                idStr += item
            }
            else {
            idStr += item + ","
            }
        }
       print(idStr)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestGetUrl(strURL: ROptionItems_APi + idStr , is_loader_required: true, success: { (response) in
                print(response)
                
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if (response.value(forKey: "status_code")as! NSNumber) == 1
                {
                    self.selectedOptionsArray = response["selected_options"] as! [NSDictionary]
                    self.allItemsDataArray.addObjects(from: (response["data"] as! NSArray).mutableCopy() as! NSMutableArray as! [Any])
                    self.cartBtn.isHidden = false
                    self.tableV.isHidden = false
                    self.tableV.reloadData()
                    if self.allItemsDataArray.count < 1 {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DescriptionVC") as! DescriptionVC
                        vc.isFromQuesAnsVC = self.isFromQuesAnsVC
                        vc.category_id = self.category_id
                        vc.category_title = self.category_title
                        vc.descriptionStr = self.descriptionStr
                        vc.isItemsAvailable = false
                        vc.popBackVCDelegate = self
                        productCartArray = NSMutableArray.init()
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                }
                else
                {
                    COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
                }
               
            }) { (failure) in
                
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ItemsVC : PopBackVCDelegate {
    func popBackVC() {
        self.navigationController?.popViewController(animated: false)
    }
}
