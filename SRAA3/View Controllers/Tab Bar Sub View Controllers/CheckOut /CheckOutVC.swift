//
//  CheckOutVC.swift
//  SRAA3
//
//  Created by Apple on 24/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import CropViewController
import SVProgressHUD
import Alamofire

class CheckOutVC: UIViewController ,UITableViewDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate  {
    var category_id = ""
    var current_time = ""
    var isAddressSet = false
    
    var isOrderLaterSelected = false
    var total_amount = "", sub_total = ""
    
    @IBOutlet weak var paymentBtn: UIButton!
    
    var deliveryNotes = ""
    var allMetaDataFieldsArray = NSMutableArray.init()
    var paymentSummaryDataDic = NSMutableDictionary.init()
    var allFieldsDataArray = NSMutableArray.init()
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var tableV: UITableView!
    var isFromQuesAnsVC = false
    
    var selectedImagesArray = [String].init()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 90))
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy HH:mm"
        current_time = dateFormat.string(from: Date()) + "-00:00"
        
        self.paymentBtn.isHidden = true
        self.tableV.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        getFieldsDataAPI()
    }
    
    override func viewDidLayoutSubviews() {
        self.paymentBtn.layer.cornerRadius = 10
        self.paymentBtn.layer.masksToBounds = true
        Utilities.setButtonGradiantColor(button: self.paymentBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setValuesofDataArray()
        self.tableV.reloadData()
    }
    
    @IBAction func popVC(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func proceedBtn(_ sender: Any) {
        if checkForRequiredValue()
        {
            return
        }
        else
        {
//            if(KFormId == "")
//            {
//            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
//            viewController.params = makeDataArray()
//            viewController.paymentSummaryDic = paymentSummaryDataDic
//            self.navigationController?.pushViewController(viewController, animated: true)
//            }
//
//            else
//            {
//                placeOrderAPI()
//            }
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
                        viewController.params = makeDataArray()
                        viewController.paymentSummaryDic = paymentSummaryDataDic
                        self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        
    }
    
    func placeOrderAPI() {
        
        var param:[String:Any]!
        
        let paramMutabaledic = (makeDataArray().mutableCopy()) as! NSMutableDictionary
        paramMutabaledic.setObject("", forKey: "coupon_code" as NSCopying)
        paramMutabaledic.setObject(KFormId, forKey: "form_id" as NSCopying)
        let payment_details = ["type":"cash","payment_gateway":"cash",
                               "payment_gateway_transaction_id":"23393",
                               "payment_transaction_amount":""]
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
                       //  UIApplication.shared.keyWindow?.makeToast((response["message"] as! String), duration: 1.0, position: .center)
                        let order_number = ((response["data"] as! NSDictionary).object(forKey: "order_id") as! NSNumber).stringValue
                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderConfimatedVC") as! OrderConfimatedVC
                        viewController.order_number = order_number
                        self.navigationController?.pushViewController(viewController, animated: true)
                        
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
    
    //MARK: -Get Form Fields Data From API
    func getFieldsDataAPI()   {
        var count = 1
        let api_name = ROrdersSettingMetaType_Api + "?class=sraa3&user_id=\(userDataModel.user_id!)"
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestGetUrl(strURL: api_name, is_loader_required: true, success: { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                self.paymentBtn.isHidden = false
                self.tableV.isHidden = false
                
                if(KFormId == "")
                {
                    self.paymentBtn.setTitle("Payment", for: .normal)
                }
                else
                {
                    self.paymentBtn.setTitle("Payment", for: .normal)
                }
                self.allMetaDataFieldsArray = (response["data"]  as! NSArray).mutableCopy() as! NSMutableArray
                
                for subValue in self.allMetaDataFieldsArray
                {
                    let dataDic = (subValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
                    let identifier = dataDic.object(forKey: "identifier") as! String
                    
                    let input_type = dataDic.object(forKey: "input_type") as! String
                    
                    if identifier == "customer_id"
                    {
                        continue
                    }
                    
                    if input_type == "radio"
                    {
                        let fieldsArray = (dataDic.object(forKey: "field_options") as! NSArray).mutableCopy() as! NSMutableArray
                        
                        for (index,value) in fieldsArray.enumerated()
                        {
                            let value1 = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
                            value1.setObject(count, forKey: "field_id" as NSCopying)
                            value1.setObject("0", forKey: "isSelected" as NSCopying)
                            fieldsArray.replaceObject(at: index, with: value1)
                            count = count + 1
                        }
                        dataDic.setObject(fieldsArray, forKey: "field_options" as NSCopying)
                    }
                    
                    if input_type == "image"
                    {
                        dataDic.setObject(self.selectedImagesArray, forKey: "value" as NSCopying)
                    }
                    
                    self.allFieldsDataArray.add(dataDic)
                    
                }
                
               /* self.paymentSummaryDataDic.setObject("Payment Summary", forKey: "order_setting_meta_type_title" as NSCopying)
                self.paymentSummaryDataDic.setObject("paymentSummary", forKey: "identifier" as NSCopying)
                self.paymentSummaryDataDic.setObject("paymentSummary", forKey: "input_type" as NSCopying)
                self.paymentSummaryDataDic.setObject("", forKey: "display_show_rule" as NSCopying)
                self.paymentSummaryDataDic.setObject("", forKey: "parent_identifier" as NSCopying)
                self.paymentSummaryDataDic.setObject(1, forKey: "show_bool" as NSCopying)
                self.allFieldsDataArray.add(self.paymentSummaryDataDic) */
                
                self.tableV.reloadData()
                print(self.allFieldsDataArray)
               
            }) { (failure) in
               
            }
        }
       
    }
}

extension CheckOutVC: UITableViewDataSource , UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableV.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let dataDictionary = allFieldsDataArray.object(at: indexPath.section) as! NSDictionary
        let type = dataDictionary.object(forKey: "input_type") as! String
        let identifier = dataDictionary.object(forKey: "identifier") as! String
        if type == "radio"
        {
            let nib:UINib = UINib(nibName: "RadioTableCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "RadioTableCell")
            
            let cell:RadioTableCell = tableView.dequeueReusableCell(withIdentifier: "RadioTableCell", for: indexPath) as! RadioTableCell
            
            let fieldOptionsDic = ((dataDictionary.object(forKey: "field_options") as! NSArray).object(at: indexPath.row) as! NSDictionary)
            
            if fieldOptionsDic.object(forKey: "isSelected") as! String == "0"
            {
                cell.checkBoxButton.setImage(#imageLiteral(resourceName: "radio_off"), for: .normal)
            }
            else
            {
                cell.checkBoxButton.setImage(#imageLiteral(resourceName: "radio-black"), for: .normal)
            }
            cell.variantsNameLbl.text = (fieldOptionsDic.object(forKey: "title") as! String)
            cell.checkBoxButton.tag = Int(truncating: (fieldOptionsDic.object(forKey: "field_id") as! NSNumber))
            cell.checkBoxButton.addTarget(self, action: #selector(checkboxButton(sender:event:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
        
        if type == "text" {
            
            let nib:UINib = UINib(nibName: "DeliveryInstructionsTableCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "DeliveryInstructionsTableCell")
            
            let cell:DeliveryInstructionsTableCell = tableView.dequeueReusableCell(withIdentifier: "DeliveryInstructionsTableCell", for: indexPath) as! DeliveryInstructionsTableCell
            cell.instructionTxtView.delegate = self
                if deliveryNotes == ""
                {
                    cell.instructionTxtView.text = "Type Here..."
                    cell.instructionTxtView.textColor = UIColor.lightGray
                }
                else
                {
                    cell.instructionTxtView.text = deliveryNotes
                    cell.instructionTxtView.textColor = UIColor.black
                }
            cell.instructionTxtView.tag = 2
            
            cell.selectionStyle = .none
            
            cell.instructionTxtView.layer.borderWidth = 1.5
            
            cell.instructionTxtView.layer.borderColor = UIColor.KLightGreyColor.cgColor
            
            cell.instructionTxtView.layer.cornerRadius = 5
            
            return cell
        }
        
        if type == "address" {
           
            if (dataDictionary.object(forKey: "default_value") as! String).isEmpty
            {
                let nib:UINib = UINib(nibName: "NoDeliveryAddressCell", bundle: nil)
                
                tableView.register(nib, forCellReuseIdentifier: "NoDeliveryAddressCell")
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoDeliveryAddressCell", for: indexPath) as! NoDeliveryAddressCell
                
                if identifier == "pickup_address"
                {
                    cell.btn.setTitle("Select Address", for: .normal)
                }
                else
                {
                    cell.btn.setTitle("Select Address", for: .normal)
                }
                cell.btn.addTarget(self, action: #selector(selectAddress(sender:event:)), for: .touchUpInside)
                cell.selectionStyle = .none
                return cell
            }
            else
            {
                let nib:UINib = UINib(nibName: "CheckOutAddressCell", bundle: nil)
                
                tableView.register(nib, forCellReuseIdentifier: "CheckOutAddressCell")
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckOutAddressCell", for: indexPath) as! CheckOutAddressCell
                cell.accessoryType = .disclosureIndicator
                cell.titleLbl?.text = (dataDictionary.object(forKey: "default_value") as! String)
                
                return cell
            }
        }
        
        if type == "timeSlotsPicker"  {
          
            if (dataDictionary.object(forKey: "value") as! String).isEmpty
            {
                let nib:UINib = UINib(nibName: "NoDeliveryAddressCell", bundle: nil)
                
                tableView.register(nib, forCellReuseIdentifier: "NoDeliveryAddressCell")
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoDeliveryAddressCell", for: indexPath) as! NoDeliveryAddressCell
                
                let title = dataDictionary.object(forKey: "order_setting_meta_type_title") as! String
                cell.btn.setTitle(title, for: .normal)
               
                cell.btn.addTarget(self, action: #selector(selectTime(sender:event:)), for: .touchUpInside)
               
                cell.selectionStyle = .none
                return cell
            }
            else
            {
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                if cell.isEqual(nil)
                {
                    cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
                }
                cell.selectionStyle = .none
                cell.textLabel?.numberOfLines = 0
                cell.imageView?.image = #imageLiteral(resourceName: "clock_image")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = (dataDictionary.object(forKey: "value") as! String)
                cell.textLabel?.font = UIFont(name: KMainFont, size: 15)
               
                return cell
            }
        }
        
        if type == "paymentSummary"  {
            let nib:UINib = UINib(nibName: "PaymentSummaryTableCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "PaymentSummaryTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentSummaryTableCell", for: indexPath) as! PaymentSummaryTableCell
            let dataDic = (paymentSummaryDataDic.object(forKey: "data") as! NSArray).object(at: indexPath.row) as! NSDictionary
            let title = dataDic.object(forKey: "title") as! String
            
            let value = (dataDic.object(forKey: "value") as! String)
            
            cell.titleLbl.text = title
            
            if title == "Sub Total" {
                sub_total = CommonClass.getCorrectPriceFormat(price: value)
            }
            
            cell.valueLbl.text = currencySymbol + CommonClass.getCorrectPriceFormat(price: value)
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
        
        if type == "image" {
            let nib:UINib = UINib(nibName: "AddImageCell", bundle: nil)
            
            tableView.register(nib, forCellReuseIdentifier: "AddImageCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddImageCell", for: indexPath) as! AddImageCell
            cell.selectionStyle = .none
          //  cell.titleLbl.text = "Add Images related to service"
//            cell.selectImgBtn.addTarget(self, action: #selector(addImageBtnTaped(sender:event:)), for: .touchUpInside)
//
//            cell.crossBtn.addTarget(self, action: #selector(crossBtnTaped(sender:event:)), for: .touchUpInside)
//
//            let str = (dataDictionary.object(forKey: "value") as! String)
//
//            if str.isEmpty
//            {
//                cell.crossBtn.isHidden = true
//                cell.imgV.image = #imageLiteral(resourceName: "select_image_doted")
//            }
//            else
//            {
//                let image_url = URL(string: BASE_IMAGE_URL + "checkout/" + str)
//
//                if(image_url == nil)
//                {
//                    cell.crossBtn.isHidden = true
//                    cell.imgV.image = #imageLiteral(resourceName: "select_image_doted")
//                }
//                else{
//                    cell.imgV.sd_setImage(with: image_url, placeholderImage:#imageLiteral(resourceName: "select_image_doted"))
//                    cell.crossBtn.isHidden = false
//                }
//            }
            print(dataDictionary)
            cell.imgCollectionView.delegate = self
            cell.imgCollectionView.dataSource = self
            cell.imgCollectionView.tag = indexPath.section
            DispatchQueue.main.async {
                cell.imgCollectionView.reloadData()
            }
            return cell
        }
        
        return UITableViewCell(frame: .zero)
    
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.tag == 1 {
          
        }
        else
        {
            textView.textColor = UIColor.black
            if deliveryNotes == "" {
                deliveryNotes = ""
            }
            textView.text = deliveryNotes
            
        }
        self.setValuesofDataArray()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView)
    {
        
        if textView.tag == 1 {
          
        }
        else
        {
            if textView.text.isEmpty {
                textView.text = "Type Here..."
                textView.textColor = UIColor.lightGray
            }
            else {
            deliveryNotes = textView.text
            textView.textColor = UIColor.black
            }
        }
        self.setValuesofDataArray()
    }
    
    
    
    
    //MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dataDictionary = allFieldsDataArray.object(at: collectionView.tag) as! NSDictionary
        let imageArray = (dataDictionary.object(forKey: "value") as! [NSDictionary])
//        if imageArray.count < 1 {
//            imageArray = selectedImagesArray
//        }
        return imageArray.count > 0 ? imageArray.count : imageArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "AddImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "AddImageCollectionCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCollectionCell", for: indexPath) as! AddImageCollectionCell
//        cell.selectionStyle = .none
    //  cell.titleLbl.text = "Add Images related to service"
        
        let dataDictionary = allFieldsDataArray.object(at: collectionView.tag) as! NSDictionary
        let imageArray = (dataDictionary.object(forKey: "value") as! [NSDictionary])
        
//        cell.selectImageBtn.addTarget(self, action: #selector(addImageBtnTaped(sender:event:)), for: .touchUpInside)
        
        cell.crossBtn.tag = indexPath.row
        cell.crossBtn.addTarget(self, action: #selector(crossBtnTaped(sender:event:)), for: .touchUpInside)
        
        print(dataDictionary)
        if imageArray.count == 0 && indexPath.row == 0 {
            cell.crossBtn.isHidden = true
            cell.imageV.image = #imageLiteral(resourceName: "dotted-camera-image")
        }
        else {
            let str = ((dataDictionary.object(forKey: "value") as! [String])[indexPath.row])
            if str.isEmpty
            {
                cell.crossBtn.isHidden = true
                cell.imageV.image = #imageLiteral(resourceName: "dotted-camera-image")
            }
            else
            {
                let image_url = URL(string: BASE_IMAGE_URL + "checkout/" + str)
                
                if(image_url == nil)
                {
                    cell.crossBtn.isHidden = true
                    cell.imageV.image = #imageLiteral(resourceName: "dotted-camera-image")
                }
                else{
                    cell.imageV.sd_setImage(with: image_url, placeholderImage:#imageLiteral(resourceName: "dotted-camera-image"))
                    cell.crossBtn.isHidden = false
                    cell.selectImageBtn.isHidden = true
                }
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 100, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 7, left: 15, bottom: 7, right: 0)
    }
    
    

    //MARK: - IBAction
    @IBAction func cancekBtnTaped(_ sender: Any) {
        
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
    
    @objc func crossBtnTaped(sender:UIButton, event:AnyObject)
    {
        
        self.setImagesInFormData(imagePath: "",indexPath:sender.tag)
    }
    
    @objc func addImageBtnTaped(sender:UIButton, event:AnyObject)
    {
    let alertController = UIAlertController(title: "Add Photo!", message: "", preferredStyle: .alert)
    
    alertController.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
        
        let imagePicker = UIImagePickerController.init()
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
    }))
    
    alertController.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { (action) in
        
        let imagePicker = UIImagePickerController.init()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.delegate = self
        //imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
        
    }))
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
        print("Cancel")
    }))
    
    let popPresenter = alertController.popoverPresentationController
    popPresenter?.sourceView = self.view
    popPresenter?.sourceRect = self.view.bounds
    
    self.present(alertController, animated: true, completion: nil)
    
}
    //MARK: - ImageCropping Methods
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var userImage = UIImage()
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userImage = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
        let image_data = UIImageJPEGRepresentation(userImage, 0.6) as AnyObject
       // apiMultipart(imageData: image_data)
         self.presentCropViewController(userImage: userImage)
    }
    
    @objc func presentCropViewController(userImage : UIImage) {
        
        let cropViewController = CropViewController(croppingStyle: .circular, image: userImage)
        
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    @objc func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        cropViewController.dismiss(animated: true, completion: nil)
        let image_data = UIImageJPEGRepresentation(image, 0.5) as AnyObject
        apiMultipart(imageData: image_data)
        // self.tableView.reloadData()
    }
    
    
    //MARK: - Upload Image
    
    func apiMultipart(imageData: AnyObject?) {
        
        let serviceName = BASE_URL + "api/v1/upload-image?type=checkout"
        
        SVProgressHUD.show()
        
        print(serviceName)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            if let data = imageData {
                
                multipartFormData.append(data as! Data, withName: "image", fileName: "image.jpg", mimeType: "image/jpg")
            }
            
        }, usingThreshold: UInt64.init(), to: serviceName, method: .post) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded  = \(response)")
                    if let err = response.error{
                        
                        print(err)
                        return
                    }
                    else
                    {
                        if let result = response.result.value {
                            let JSON = result as! NSDictionary
                            let imagePath = (JSON["data"] as! NSDictionary).object(forKey: "image") as! String
                            DispatchQueue.main.async {
                                let imagePath_thumb = (JSON["data"] as! NSDictionary).object(forKey: "thumb_image") as! String
                                SVProgressHUD.dismiss()
                                self.setImagesInFormData(imagePath: imagePath)
                            }
                            print(JSON)
                        }
                    }
                }
            case .failure(let error):
                SVProgressHUD.dismiss()
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
    
    func setImagesInFormData(imagePath : String, indexPath : Int? = nil)  {
      
        for (index,value) in allFieldsDataArray.enumerated() {
            let dataDic = (value as! NSDictionary).mutableCopy() as!NSMutableDictionary
//            let identifier = dataDic.object(forKey: "identifier") as! String
            let input_type = dataDic.object(forKey: "input_type") as! String
            print(selectedImagesArray)
            print(allFieldsDataArray)
            if input_type == "image"
            {
                print(dataDic)
                if indexPath != nil {
                    self.selectedImagesArray.remove(at: indexPath!)
                }
                else {
                self.selectedImagesArray.append(imagePath)
                }
                dataDic.setObject(self.selectedImagesArray, forKey: "value" as NSCopying)
                allFieldsDataArray.replaceObject(at: index, with: dataDic)
            }
            print(selectedImagesArray)
            print(allFieldsDataArray)
            
            let contentOffset = self.tableV.contentOffset
            self.tableV.reloadData()
            self.tableV.layoutIfNeeded()
            self.tableV.setContentOffset(contentOffset, animated: false)
       // self.tableV.reloadData()
    }
    }
    
    //MARK: - Set Values of DataArray
    func setValuesofDataArray() {
        
        for (index,value) in allFieldsDataArray.enumerated() {
            let dataDic = (value as! NSDictionary).mutableCopy() as!NSMutableDictionary
            let identifier = dataDic.object(forKey: "identifier") as! String
            let input_type = dataDic.object(forKey: "input_type") as! String
            
            if input_type == "timeSlotsPicker"
            {
                if !selectedPickupDate.isEmpty{
                    
                    dataDic.setObject(selectedPickupDate, forKey: "value" as NSCopying)
                }
                allFieldsDataArray.replaceObject(at: index, with: dataDic)
            }
            
            if input_type == "text"
            {
                    if !deliveryNotes.isEmpty{
                        dataDic.setObject(deliveryNotes, forKey: "value" as NSCopying)
                    }
                allFieldsDataArray.replaceObject(at: index, with: dataDic)
            }
            
            if input_type == "address"
            {
                var addressDataDic : NSDictionary!
                
                if identifier == "pickup_address"
                {
                    addressDataDic = NSDictionary(dictionary: selectedPickUpAddressDictionary)
                }
                else
                {
                    addressDataDic = NSDictionary(dictionary: selectedAddressDictionary)
                }
                
                if (addressDataDic.count) != 0 {
                    var selectedAddress = ""
                    let address1 = addressDataDic.object(forKey: "address_line1") as! String
                    let address2 = addressDataDic.object(forKey: "address_line2") as! String
                    let city = addressDataDic.object(forKey: "city") as! String
                    let state = addressDataDic.object(forKey: "state") as! String
                    let country = addressDataDic.object(forKey: "country") as! String
                    let pincode = addressDataDic.object(forKey: "pincode") as! String
                    
                    if address1.isEmpty == false
                    {
                        selectedAddress = address1
                    }
                    if address2.isEmpty == false
                    {
                        selectedAddress += "," + address2
                    }
                    if city.isEmpty == false
                    {
                        selectedAddress += "," + city
                    }
                    
                    if state.isEmpty == false
                    {
                        selectedAddress += "," + state
                    }
                    if country.isEmpty == false
                    {
                        selectedAddress += "," + country
                    }
                    if pincode.isEmpty == false
                    {
                        selectedAddress += "," + pincode
                    }
                    
                    if !selectedAddress.isEmpty
                    {
                        dataDic.setObject(self.getAddressJSONDictionary(identifier: identifier), forKey: "value" as NSCopying)
                        dataDic.setObject(selectedAddress, forKey: "default_value" as NSCopying)
                        
                    }
                    
                }
               
                allFieldsDataArray.replaceObject(at: index, with: dataDic)
            }
        }
        print(allFieldsDataArray)
}
    
    @objc func selectTime(sender:UIButton, event:AnyObject)
    {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectTimeVC") as! SelectTimeVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func selectAddress(sender:UIButton, event:AnyObject)
    {
        let touches: Set<UITouch>
        touches = (event.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableV)
        let indexPath:NSIndexPath = self.tableV.indexPathForRow(at: touchPosition)! as NSIndexPath
        
        let dataDic = (self.allFieldsDataArray.object(at: indexPath.section) as! NSDictionary)
        let identifier = dataDic.object(forKey: "identifier") as! String
        let input_type = dataDic.object(forKey: "input_type") as! String
        
        if input_type == "address" {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DeliveryAddressVC") as! DeliveryAddressVC
            if identifier == "pickup_address"
            {
                viewController.isForDeliveryAddress = false
            }
            else
            {
                viewController.isForDeliveryAddress = true
            }
            viewController.isFromCheckOut = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
@objc func checkboxButton(sender:UIButton, event:AnyObject)
    {
        let touches: Set<UITouch>
        touches = (event.allTouches!)!
        let touch:UITouch = (touches.first)!
        let touchPosition:CGPoint = touch.location(in: self.tableV)
        let indexPath:NSIndexPath = self.tableV.indexPathForRow(at: touchPosition)! as NSIndexPath
        
        let dataFieldDic1 = allFieldsDataArray.object(at: indexPath.section) as! NSDictionary
        let parent_identifier = dataFieldDic1.object(forKey: "parent_identifier") as! String
        
        if !parent_identifier.isEmpty{
            let result =  checkForParentIdentifierValue(parent_identifier:parent_identifier)
            if result
            {
                displayAlert(msg: "Select the \(parent_identifier) first")
            }
        }
        
        setSelectedRow(indexPath: indexPath as IndexPath)
        
        let dataFieldDic = allFieldsDataArray.object(at: indexPath.section) as! NSDictionary
        let fieldOptionsDic = ((dataFieldDic.object(forKey: "field_options") as! NSArray).object(at: indexPath.row) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        if fieldOptionsDic.object(forKey: "isSelected") as! String == "1" {
            let value = fieldOptionsDic["value"] as! String
            
            sender.setImage(#imageLiteral(resourceName: "icon-tick"), for: .normal)
            self.tableV.reloadData()
        }
        
    }
    
    //MARK: Set Selected Row
    
    func setSelectedRow(indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        let mainDic = (self.allFieldsDataArray.object(at: indexPath.section) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let tempFieldsValuesArray = ((mainDic.object(forKey: "field_options") as! NSArray).mutableCopy() as! NSMutableArray)
        
        for (index,value) in tempFieldsValuesArray.enumerated()
        {
            let subDic = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
            
            if selectedIndex == index
            {
                subDic.setObject("1", forKey: "isSelected" as NSCopying)
                tempFieldsValuesArray.replaceObject(at: index, with: subDic)
                let identifier = (mainDic.object(forKey: "identifier") as! String)
                let input_type = (mainDic.object(forKey: "input_type") as! String)
                
                let value = subDic.object(forKey: "value") as! String
                let title = subDic.object(forKey: "title") as! String
                
                if input_type == "radio"
                {
                    let display_show_rule = identifier + "=" + value
                    checkShowRuleValue(display_show_rule: display_show_rule, identifier: identifier)
                }
                mainDic.setObject(title, forKey: "display_value" as NSCopying)
                mainDic.setObject(value, forKey: "value" as NSCopying)
            }
            else
            {
                subDic.setObject("0", forKey: "isSelected" as NSCopying)
                tempFieldsValuesArray.replaceObject(at: index, with: subDic)
            }
        }
        mainDic.setObject(tempFieldsValuesArray, forKey: "field_options" as NSCopying)
        self.allFieldsDataArray.replaceObject(at: indexPath.section, with: mainDic)
        self.tableV.reloadData()
    }
    
    //MARK: Check For Parent Identifier Value
    
    func checkForParentIdentifierValue(parent_identifier:String) -> Bool {
        for mainValue in  self.allFieldsDataArray
        {
            let dataDic = (mainValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
            let identifier = dataDic.object(forKey: "identifier") as! String
            if identifier != "paymentSummary"
            {
                let value = dataDic.object(forKey: "value") as! String
                
                if parent_identifier == identifier
                {
                    if  value.isEmpty
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                }
            }
        }
        
        return false
    }
    
    //MARK: Check For  Show Rule
    func checkShowRuleValue(display_show_rule:String,identifier:String)  {
        
        for (index,mainValue) in  self.allFieldsDataArray.enumerated()
        {
            let dataDic = (mainValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
            let parent_identifier = dataDic.object(forKey: "parent_identifier") as! String
            let displayShowRule = dataDic.object(forKey: "display_show_rule") as! String
            
            if parent_identifier == identifier
            {
                let show_bool = dataDic.object(forKey: "show_bool") as! NSNumber
                if displayShowRule == display_show_rule
                {
                    if show_bool == 0
                    {
                        dataDic.setObject(1, forKey: "show_bool" as NSCopying)
                        self.allFieldsDataArray.replaceObject(at: index, with: dataDic)
                        if parent_identifier == "delivery_type"
                        {
                            self.isAddressSet = true
                            self.setValuesofDataArray()
                            // self.getPaymentSummaryData(loader: false, delivery_type: "home_delivery")
                        }
                        
                    }
                }
                    
                else
                {
//                    if show_bool == 1
//                    {
                        dataDic.setObject(0, forKey: "show_bool" as NSCopying)
                        dataDic.setObject("", forKey: "value" as NSCopying)
                        self.allFieldsDataArray.replaceObject(at: index, with: dataDic)
                        print(self.allFieldsDataArray)
                        if parent_identifier == "delivery_type"
                        {
                            self.isAddressSet = false
                            selectedAddressDictionary.removeAllObjects()
                        }
                        selectedPickupDate = ""
                        if (selectedAddressDictionary.count) != 0
                        {
                            self.isAddressSet = true
                        }
                        
                   // }
                }
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if allFieldsDataArray.count > 0 {
            return allFieldsDataArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if allFieldsDataArray.count > 0
        {
            let dataDic = (self.allFieldsDataArray.object(at: section) as! NSDictionary)
            let identifier = dataDic.object(forKey: "identifier") as! String
            let display_show_rule = dataDic.object(forKey: "display_show_rule") as! String
            let show_bool =  dataDic.object(forKey: "show_bool") as! NSNumber
            
            if let input_type = dataDic.object(forKey: "input_type") as? String
            {
                if input_type == "radio"
                {
                    return ((allFieldsDataArray.object(at: section) as! NSDictionary).object(forKey: "field_options") as! NSArray).count
                }
            }
            
            if identifier == "paymentSummary" && display_show_rule.isEmpty
            {
                return ((allFieldsDataArray.object(at: section) as! NSDictionary).object(forKey: "data") as! NSArray).count
            }
            
            if display_show_rule.isEmpty
            {
                return 1
            }
            
            if !display_show_rule.isEmpty && show_bool == 1 {
                return 1
            }
            else if !display_show_rule.isEmpty && show_bool == 0 {
                return 0
            }
            
            return 0
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let dataDic = (self.allFieldsDataArray.object(at: section) as! NSDictionary)
        
        let display_show_rule = dataDic.object(forKey: "display_show_rule") as! String
        let identifier = dataDic.object(forKey: "identifier") as! String
        let show_bool = dataDic.object(forKey: "show_bool") as! NSNumber
        
        if display_show_rule.isEmpty || identifier == "paymentSummary" {
            return 48
        }
        if !display_show_rule.isEmpty && show_bool == 1 {
            return 48
        }
       
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let dataDic = (self.allFieldsDataArray.object(at: section) as! NSDictionary)
        let display_show_rule = dataDic.object(forKey: "display_show_rule") as! String
        let identifier = dataDic.object(forKey: "identifier") as! String
        let show_bool = dataDic.object(forKey: "show_bool") as! NSNumber
        
        if display_show_rule.isEmpty {
            if identifier == "paymentSummary" {
                return 100
            }
            return 0
        }
        
        if !display_show_rule.isEmpty && show_bool == 1 {
            return 0
        }
        
        return 0
    }
    
    //MARK: Make Address JSON Dictionary
    
    func getAddressJSONDictionary(identifier:String) -> String {
        var dataDic = NSMutableDictionary.init()
        
        if identifier == "pickup_address" {
            dataDic = NSMutableDictionary(dictionary: selectedPickUpAddressDictionary)
        }
        else
        {
            dataDic = NSMutableDictionary(dictionary: selectedAddressDictionary)
        }
        if (dataDic.count) != 0  {
            let address1 = dataDic.object(forKey: "address_line1") as! String
            let address2 = dataDic.object(forKey: "address_line2") as! String
            let city = dataDic.object(forKey: "city") as! String
            let state = dataDic.object(forKey: "state") as! String
            let country = dataDic.object(forKey: "country") as! String
            let pincode = dataDic.object(forKey: "pincode") as! String
            let latitude = dataDic.object(forKey: "latitude") as! String
            let longitude = dataDic.object(forKey: "longitude") as! String
            var address_id = ""
            if let addresId = dataDic.object(forKey: "address_id") as? NSNumber
            {
                address_id = addresId.stringValue
            }
            else if let addresId = dataDic.object(forKey: "address_id") as? String
            {
                address_id = addresId
            }
            let created_at = dataDic.object(forKey: "created_at") as! String
            let address_title = dataDic.object(forKey: "address_title") as! String
            let address_phone = dataDic.object(forKey: "address_phone") as! String
            
            
            let dataDic1 = NSDictionary(dictionaryLiteral: ("address_id", address_id),("address_line1", address1),("address_line2", address2),("city", city),("state", state),("country", country),("pincode", pincode),("latitude", latitude),("longitude", longitude),("created_at", created_at),("address_title", address_title),("address_phone", address_phone))
            
            let jsonData = try? JSONSerialization.data(withJSONObject: dataDic1, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            print(jsonString!)
            return jsonString!
        }
        
        return ""
        
    }
    
    //MARK: - Set Section Header View ////////
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if  allFieldsDataArray.count > 0 {
            let dataDic = (self.allFieldsDataArray.object(at: section) as! NSDictionary)
            
            let display_show_rule = dataDic.object(forKey: "display_show_rule") as! String
            let show_bool = dataDic.object(forKey: "show_bool") as! NSNumber
            let title = dataDic.object(forKey: "order_setting_meta_type_title") as! String
            let type = dataDic.object(forKey: "input_type") as! String
            
            if display_show_rule.isEmpty {
               
                return self.getHeaderView(title: title, isForButton: false)
            }
            
            if !display_show_rule.isEmpty && show_bool == 1 {
                
                return self.getHeaderView(title: title, isForButton: false)
            }
            else if !display_show_rule.isEmpty && show_bool == 0 {
                return nil
            }
            return nil
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let identifier = (self.allFieldsDataArray.object(at: section) as! NSDictionary).object(forKey: "identifier") as! String
        if identifier == "paymentSummary" {
            let mainFooterView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
            mainFooterView.backgroundColor = UIColor.clear
            
            let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
            footerView.backgroundColor = UIColor.white
            mainFooterView.addSubview(footerView)
            if paymentSummaryDataDic.count > 0
            {
                let total_price = (paymentSummaryDataDic.object(forKey: "total") as! String)
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
                total_amount = CommonClass.getCorrectPriceFormat(price: total_price)
                self.totalPriceLbl.text = currencySymbol +  total_amount
                totalPriceLbl.text = currencySymbol +  total_amount
                //infoLabel.alpha = 0.80
                totalPriceLbl.font = UIFont(name: KMainFontSemiBold, size: 15)
                
                footerView.addSubview(totalPriceLbl)
                
            }
            return mainFooterView
            
        }
        return nil
    }
    
    ///////////////////////////////////
    
    // MARK: - Selection Of Item For Radio Cell///////////
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataDic = (self.allFieldsDataArray.object(at: indexPath.section) as! NSDictionary)
        let identifier = dataDic.object(forKey: "identifier") as! String
        let input_type = dataDic.object(forKey: "input_type") as! String
        
        if input_type == "radio" {
            let cell = self.tableV.cellForRow(at: indexPath as IndexPath) as! RadioTableCell
            let dataFieldDic1 = allFieldsDataArray.object(at: indexPath.section) as! NSDictionary
            let parent_identifier = dataFieldDic1.object(forKey: "parent_identifier") as! String
            
            if !parent_identifier.isEmpty{
                let result =  checkForParentIdentifierValue(parent_identifier:parent_identifier)
                if result
                {
                    displayAlert(msg: "Select the \(parent_identifier) first")
                }
            }
            
            setSelectedRow(indexPath: indexPath as IndexPath)
            
            let dataFieldDic = allFieldsDataArray.object(at: indexPath.section) as! NSDictionary
            let fieldOptionsDic = ((dataFieldDic.object(forKey: "field_options") as! NSArray).object(at: indexPath.row) as! NSDictionary).mutableCopy() as! NSMutableDictionary
            
            if fieldOptionsDic.object(forKey: "isSelected") as! String == "1" {
                let value = fieldOptionsDic["value"] as! String
               
                cell.checkBoxButton.setImage(#imageLiteral(resourceName: "round-checked"), for: .normal)
                self.tableV.reloadData()
                
            }
        }
        
         if input_type == "address" {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DeliveryAddressVC") as! DeliveryAddressVC
            if identifier == "pickup_address"
            {
                viewController.isForDeliveryAddress = false
            }
            else
            {
                viewController.isForDeliveryAddress = true
            }
            viewController.isFromCheckOut = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        if input_type == "timeSlotsPicker" {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectTimeVC") as! SelectTimeVC
            //  viewController.isForAddressEditing = false
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    /////////////////////
    
    //MARK: - Check For Required Value
    
    func checkForRequiredValue() ->Bool {
        
        for dataDic1 in self.allFieldsDataArray {
            
            let dataDic = dataDic1 as! NSDictionary
            let identifier = dataDic.object(forKey: "identifier") as! String
            
            if identifier != "paymentSummary"
            {
                var imagArray = [NSDictionary]()
                var value = ""
                if identifier == "image" {
                   imagArray = dataDic.object(forKey: "value") as! [NSDictionary]
                }
                else {
                   value = dataDic.object(forKey: "value") as! String
                }
                let required_or_not = dataDic.object(forKey: "required_or_not") as! String
                let order_setting_meta_type_title = dataDic.object(forKey: "order_setting_meta_type_title") as! String
                let show_bool = dataDic.object(forKey: "show_bool") as! NSNumber
                //                if identifier == "delivery_time"
                //                {
                //                    if value.isEmpty
                //                    {
                //                        displayAlert(msg: "\(order_setting_meta_type_title)")
                //                        return true
                //                    }
                //                }
                if show_bool == 1
                {
                    if required_or_not == "1"
                    {
                        if identifier == "image" ? imagArray.isEmpty : value.isEmpty
                        {
                            if identifier == "notes"
                            {
                                displayAlert(msg: "Enter \(order_setting_meta_type_title)")
                            }
                            else
                            {
                                displayAlert(msg: "\(order_setting_meta_type_title)")
                            }
                            
                            return true
                        }
                        
                    }
                    
                }
            }
            
        }
        return false
    }
    
    //MARK: -Display Alert View
    func displayAlert(msg:String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            return
        }))
        let popOverController = alert.popoverPresentationController
        popOverController?.sourceView = self.view
        popOverController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        popOverController?.permittedArrowDirections = []
        self.present(alert, animated: true, completion: nil)
    }

    //MARK: -Make Data Array for JSON
    
    func makeDataArray() -> NSDictionary {
        
        // let orderType = ((productCartArray.object(at: 0) as! NSDictionary).object(forKey: "type") as! String)
        for (mainIndex,dicValue) in allMetaDataFieldsArray.enumerated()
        {
            let dicValue1 = (dicValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
            let (isContain,dictionaryValue) = isContainDic(dictionary: dicValue1)
            if isContain
            {
                print(dictionaryValue)
                allMetaDataFieldsArray.replaceObject(at: mainIndex, with: dictionaryValue)
            }
            else
            {
                if dicValue1.object(forKey: "identifier") as! String == "customer_id"
                {
                    print(userDataModel.user_id!)
                    dicValue1.setObject(userDataModel.user_id!, forKey: "value" as NSCopying)
                    allMetaDataFieldsArray.replaceObject(at: mainIndex, with: dicValue1)
                }
            }
        }
        
        print(allMetaDataFieldsArray)
       
        var param = ["customer_id":userDataModel.user_id!,"type":"","loyalty_points": "", "coupon_code":"", "store_id":KStore_id,"order_meta":NSDictionary(dictionaryLiteral: ("fields",allMetaDataFieldsArray)) , "service_id": self.category_id ,"city_id":city_id,"is_option_items": isFromQuesAnsVC ? "1" : "0"] as NSDictionary
        let paramMutabaledic = param.mutableCopy() as! NSMutableDictionary
        if KFormId != "" {
//        paramMutabaledic.setObject(productCartArray, forKey: "items" as NSCopying)
        paramMutabaledic.setObject(selectedOptionsIdsArray, forKey: "selected_options" as NSCopying)
        if (selectedOptionsIdsArray.count > 0) && (productCartArray.count > 0) {
            paramMutabaledic.setObject(productCartArray, forKey: "items" as NSCopying)
         }
        }
        else {
            paramMutabaledic.setObject(productCartArray, forKey: "items" as NSCopying)
        }
        param = paramMutabaledic
        print(param)
        return param
    }
    
    func isContainDic(dictionary: NSDictionary) -> (isContain:Bool,dic:NSMutableDictionary) {
        for (index,value) in allFieldsDataArray.enumerated() {
            let dataDic = value as! NSMutableDictionary
            if dataDic.object(forKey: "identifier") as! String == dictionary.object(forKey: "identifier") as! String
            {
                _  = dataDic.object(forKey: "parent_identifier") as! String
                
                if dataDic.object(forKey: "input_type") as! String == "address"
                {
                    return (true,self.makeAddressJSON(dic: dataDic.mutableCopy() as! NSMutableDictionary, index: index))
                }
                return (true,dataDic)
            }
        }
        return (false,NSMutableDictionary.init())
    }

    /////////////////////////////////////////////
    
    func makeAddressJSON(dic:NSMutableDictionary,index:Int) -> NSMutableDictionary  {
        let identifier = dic.object(forKey: "identifier") as! String
        _ = dic.object(forKey: "show_bool") as! NSNumber
        var default_address = ""
        
        if let defaultAddress = dic["default_value"] as? String
        {
            default_address = defaultAddress
        }
        if identifier == "delivery_address"
        {
            if selectedAddressDictionary.count == 0
            {
                dic.setObject(default_address, forKey: "value" as NSCopying)
            }
            else
            {
                dic.setObject(getAddressJSONDictionary(identifier:"delivery_address"), forKey: "value" as NSCopying)
            }
        }
        if identifier == "pickup_address"
        {
            dic.setObject(getAddressJSONDictionary(identifier: "pickup_address"), forKey: "value" as NSCopying)
        }
        return dic
        
    }
    
    //MARK: - HeaderView For Section
    
    func getHeaderView(title: String,isForButton:Bool) -> UIView {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 58))
        headerView.backgroundColor = UIColor.groupTableViewBackground
        let innerView:UIView = UIView(frame: CGRect(x: 0, y: 10, width: self.view.frame.size.width, height: 48))
        innerView.backgroundColor = UIColor.white
        let infoLabel:UILabel = UILabel(frame: CGRect(x: 16, y: 9, width: self.view.frame.size.width - 32, height: 30))
        infoLabel.textColor = UIColor.black
        infoLabel.text = title
        
      //  let fontD:UIFontDescriptor = infoLabel.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic)!
     //   infoLabel.font = UIFont(descriptor: fontD, size: 17)
        
        infoLabel.font = UIFont(name: KMainFontSemiBold, size: 17)
        
        let addButton: UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 40, y: 9, width: 30, height: 30))
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont(name: KMainFont, size: 23)
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.layer.cornerRadius = 10
        addButton.contentMode = .center
        addButton.backgroundColor = UIColor.black
        addButton.addTarget(self, action: #selector(addImageBtnTaped(sender:event:)), for: .touchUpInside)
        
        if title == "Payment Summary" {
            infoLabel.textColor = UIColor.KMainColorCode
        }
        if title == "Add Images" {
            innerView.addSubview(addButton)
        }
        
        innerView.addSubview(infoLabel)
        headerView.addSubview(innerView)
        return headerView
    }
    
    func removeAllSubViewOfCells(cell: UITableViewCell) {
        
        let views:NSArray = cell.contentView.subviews as NSArray
        
        
        for (index,view)  in views.enumerated(){
            
            let _:UIView = views.object(at: index) as! UIView
            (view as AnyObject).removeFromSuperview()
            print(index)
            
        }
    }
    
    //MARK: Local Json
    func getLocalJSON()  {
        if let path = Bundle.main.path(forResource: "OrderFormLocalJSON", ofType: "json")
        {
            do
            {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String,AnyObject>
                {
                    var count = 1
                    self.allMetaDataFieldsArray = ((jsonResult as NSDictionary)["fields"]  as! NSArray).mutableCopy() as! NSMutableArray
                    
                    for subValue in self.allMetaDataFieldsArray
                    {
                        let dataDic = (subValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        
                        let identifier = dataDic.object(forKey: "identifier") as! String
                        
                        let input_type = dataDic.object(forKey: "input_type") as! String
                        
                        if identifier == "customer_id"
                        {
                            continue
                        }
                        
                        if input_type == "radio"
                        {
                            let fieldsArray = (dataDic.object(forKey: "field_options") as! NSArray).mutableCopy() as! NSMutableArray
                            
                            for (index,value) in fieldsArray.enumerated()
                            {
                                let value1 = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
                                value1.setObject(count, forKey: "field_id" as NSCopying)
                                value1.setObject("0", forKey: "isSelected" as NSCopying)
                                fieldsArray.replaceObject(at: index, with: value1)
                                count = count + 1
                            }
                            dataDic.setObject(fieldsArray, forKey: "field_options" as NSCopying)
                            
                        }
                        
                        self.allFieldsDataArray.add(dataDic)
                        
                    }
                    
                    
                    self.paymentSummaryDataDic.setObject("Payment Summary", forKey: "order_setting_meta_type_title" as NSCopying)
                    self.paymentSummaryDataDic.setObject("paymentSummary", forKey: "identifier" as NSCopying)
                    self.paymentSummaryDataDic.setObject("", forKey: "display_show_rule" as NSCopying)
                    self.paymentSummaryDataDic.setObject("", forKey: "parent_identifier" as NSCopying)
                    self.paymentSummaryDataDic.setObject(1, forKey: "show_bool" as NSCopying)
                    self.allFieldsDataArray.add(self.paymentSummaryDataDic)
                    self.tableV.reloadData()
                    print(self.allFieldsDataArray)
                }
                
            }
            catch
            {
                
            }
        }
        
    }
    
}
