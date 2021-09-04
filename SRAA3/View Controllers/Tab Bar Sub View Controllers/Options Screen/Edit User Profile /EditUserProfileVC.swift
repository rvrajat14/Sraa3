//
//  EditUserProfileVC.swift
//  FoodApplication
//
//  Created by Kishore on 06/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CropViewController

import Alamofire
import SVProgressHUD

class EditUserProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
    var image_data:AnyObject!
    var imagePath = ""
    var gender = ""
    @IBOutlet weak var tableView: UITableView!
    var userImage:UIImage?
    var selectedDate:String = ""
    var datePicker:UIDatePicker?
    var firstName:String = ""
    var lastName:String = ""
    var email:String = ""
    var contact_number:String = ""
    var allDataArray:NSMutableArray!
    var allFieldsDataArray:NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allDataArray = NSMutableArray.init()
        allFieldsDataArray = NSMutableArray.init()
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        /*  if let filePath = Bundle.main.path(forResource: "taxi_edit_profile", ofType: "json"), let data = NSData(contentsOfFile: filePath) {
         do {
         let json = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments)
         print(json)
         allFieldsDataArray  = ((json as! NSDictionary).object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray
         print("taxi_e \(allFieldsDataArray)")
         self.tableView.reloadData()
         }
         catch {
         //Handle error
         }
         }*/
        
        getFieldsDataFromAPI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tableView.reloadData()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Selector Methods//////////
    
    @IBAction func updateBtnTaped(_ sender: Any) {
        
        if (firstName.count < 3)
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidFirstName.rawValue , msg: "", onView: self)
        }
        else if contact_number.count < 10 || contact_number.count > 15
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidMobileNo.rawValue , msg: "", onView: self)
        }
            
        else if !(CommonClass.isValidPhone(phone: contact_number))
        {
            COMMON_ALERT.showAlert(title: AppMessages.enterValidMobileNo.rawValue, msg: "", onView: self)
        }
            
        else
        {
         self.updateFieldDataArray()
         self.updateProfileAPI()
        }
    }
    
    @IBAction func popVC(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func datePickerAction(_ sender: UIDatePicker)
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        selectedDate = formatter.string(from: sender.date)
    }
    
    @objc func editImageButton(_ sender: UIBarButtonItem)
    {
        let alertController = UIAlertController(title: "Add Photo!", message: "Select Photo", preferredStyle: .alert)
        
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
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userImage = pickedImage
            //            if UIImagePNGRepresentation(pickedImage) != nil
            //            {
            //                image_data = UIImagePNGRepresentation(pickedImage) as AnyObject
            //            }
            
        }
        picker.dismiss(animated: true, completion: nil)
        self.presentCropViewController()
    }
    
    
    @objc func presentCropViewController() {
        
        
        let cropViewController = CropViewController(croppingStyle: .circular, image: userImage!)
        
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    @objc func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        //userImage = image
        cropViewController.dismiss(animated: true, completion: nil)
        image_data = UIImageJPEGRepresentation(image, 0.5) as AnyObject
        apiMultipart(imageData: image_data)
        // self.tableView.reloadData()
        
    }
    
    //MARK: Get Fields Data From API
    
    func getFieldsDataFromAPI( )  {
        let url = RFormUser_Api + "/\(userDataModel.user_id!)&user_type=1"
        
        print(url)
        
        WebService.requestGetUrl(strURL: url , is_loader_required: false, success: { (response) in
            print(response)
            
            self.allDataArray = ((response["data"] as! NSArray).mutableCopy() as! NSMutableArray)
            
            print(self.allDataArray)
            DispatchQueue.main.async {
                
                let userBasicInfoFieldsArray = (self.allDataArray.object(at: 0) as! NSDictionary).object(forKey: "fields") as! NSArray
                let additionalInfoFieldsArray =  (self.allDataArray.object(at: 1) as! NSDictionary).object(forKey: "fields") as! NSArray
                for subdic in userBasicInfoFieldsArray
                {
                    let subdic1 = subdic as! NSDictionary
                    
                    if subdic1.object(forKey: "type") as! String == "file"
                    {
                        self.allFieldsDataArray.add(subdic)
                    }
                    if subdic1.object(forKey: "type") as! String == "text"
                    {
                        self.allFieldsDataArray.add(subdic)
                    }
                    
                    if subdic1.object(forKey: "type") as! String == "email"
                    {
                        self.allFieldsDataArray.add(subdic)
                    }
                    if subdic1.object(forKey: "type") as! String == "tel"
                    {
                        self.allFieldsDataArray.add(subdic)
                    }
                }
                
                for subdic in additionalInfoFieldsArray
                {
                    let subdic1 = subdic as! NSDictionary
                    
                    if subdic1.object(forKey: "type") as! String == "datePicker"
                    {
                        
                        self.allFieldsDataArray.add(subdic)
                    }
                    if subdic1.object(forKey: "type") as! String == "radio"
                    {
                        self.allFieldsDataArray.add(subdic)
                    }
                }
                
                // self.shimmerView.isHidden = true
                // self.shimmerView.hideLoader()
                self.tableView.reloadData()
            }
            
        }) { (failure) in
            //  COMMON_FUNCTIONS.showAlert(msg: "Request Time Out !")
        }
    }
    
    
    //MARK: - Upload Image
    
    func apiMultipart(imageData: AnyObject?) {
        
        let serviceName = BASE_URL + "api/v1/upload-image?type=user"
        
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
                            self.imagePath = (JSON["data"] as! NSDictionary).object(forKey: "thumb_image") as! String
                            DispatchQueue.main.async {
                                self.imagePath = (JSON["data"] as! NSDictionary).object(forKey: "thumb_image") as! String
                                SVProgressHUD.dismiss()
                                self.tableView.reloadData()
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
    
    //MARK: Update Profile API Calling
    
    func updateProfileAPI()  {
        
        let api_url =  RFormUser_Api + "/" + userDataModel.user_id!
        print(allDataArray!)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPUTUrlWithJSONArrayParameters(strURL: api_url, is_loader_required: true, params: self.allDataArray, success: { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 1
                {
                    DispatchQueue.main.async {
                        self.updateNSUserDefaultsData(string: response["message"] as! String)
                    }
                }
                else
                {
                    COMMON_ALERT.showAlert(title: response["message"] as! String, msg: "", onView: self)
                }
               
            }) { (failure) in
                // COMMON_FUNCTIONS.showAlert(msg: "Request Time Out !")
            }
        }
    
    }
    
    //MARK: Update Fields  Data Array For JSON
    
    func updateFieldDataArray()  {
        
        for (index,data) in allDataArray.enumerated()
        {
            if data is String
            {
                allDataArray.remove(data)
            }
            else
            {
                let dataDictionary = (data as! NSDictionary).mutableCopy() as! NSMutableDictionary
                let title = dataDictionary.object(forKey: "title") as! String
                
                if title == "Basic Information" || title == "Additional Informations"
                {
                    let field_array = (dataDictionary.object(forKey: "fields") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    for (index_number,tempData) in field_array.enumerated()
                    {
                        let (isMatched,fieldDataDictionary) =       isMatchedWithTitle(dataDictionary: tempData as! NSDictionary)
                        if isMatched
                        {
                            field_array.replaceObject(at: index_number, with: fieldDataDictionary)
                        }
                        else
                        {
                            if (tempData as! NSDictionary).object(forKey: "title") as! String == "User Type"
                            {
                                
                            }
                            else
                            {
                                field_array.remove(tempData)
                            }
                        }
                    }
                    dataDictionary.setObject(field_array, forKey: "fields" as  NSCopying)
                    
                }
                allDataArray.replaceObject(at: index, with: dataDictionary)
            }
        }
        print("Updated All Data Array = \(allDataArray)")
        
    }
    
    func isMatchedWithTitle(dataDictionary: NSDictionary) -> (matched:Bool,matchedDictionary: NSDictionary) {
        
        for value in allFieldsDataArray {
            let tempDataDictionary = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
            if tempDataDictionary.object(forKey: "title") as! String  == dataDictionary.object(forKey: "title") as! String
            {
                if tempDataDictionary.object(forKey: "title") as! String == "Image"
                {
                    if imagePath.isEmpty
                    {
                        return (true,tempDataDictionary)
                    }
                    else
                    {
                        tempDataDictionary.setObject(imagePath, forKey: "value" as NSCopying)
                        return (true,tempDataDictionary)
                    }
                }
                
                if tempDataDictionary.object(forKey: "title") as! String == "Last Name"
                {
                    if (lastName.isEmpty)
                    {
                       // return (true,tempDataDictionary)
                        tempDataDictionary.setObject(lastName, forKey: "value" as NSCopying)
                        return (true,tempDataDictionary)
                    }
                    else
                    {
                        tempDataDictionary.setObject(lastName, forKey: "value" as NSCopying)
                        return (true,tempDataDictionary)
                    }
                    
                }
                
                if tempDataDictionary.object(forKey: "title") as! String == "First Name"
                {
                    if (firstName.isEmpty)
                    {
                        return (true,tempDataDictionary)
                    }
                    else
                    {
                        tempDataDictionary.setObject(firstName, forKey: "value" as NSCopying)
                        return (true,tempDataDictionary)
                    }
                }
                if tempDataDictionary.object(forKey: "title") as! String == "Email"
                {
                    if (email.isEmpty)
                    {
                        return (true,tempDataDictionary)
                    }
                    else
                    {
                        tempDataDictionary.setObject(email, forKey: "value" as NSCopying)
                        return (true,tempDataDictionary)
                    }
                }
                
                if tempDataDictionary.object(forKey: "title") as! String == "Phone"
                {
                    if (contact_number.isEmpty)
                    {
                        return (true,tempDataDictionary)
                    }
                    else
                    {
                        tempDataDictionary.setObject(contact_number, forKey: "value" as NSCopying)
                        return (true,tempDataDictionary)
                    }
                }
                
                if tempDataDictionary.object(forKey: "title") as! String == "Date of Birth"
                {
                    if (selectedDate.isEmpty)
                    {
                        return (true,tempDataDictionary)
                    }
                    else
                    {
                        tempDataDictionary.setObject(selectedDate, forKey: "value" as NSCopying)
                        return (true,tempDataDictionary)
                    }
                }
                if tempDataDictionary.object(forKey: "title") as! String == "Gender"
                {
                    if (gender.isEmpty)
                    {
                        return (true,tempDataDictionary)
                    }
                    else
                    {
                        tempDataDictionary.setObject(gender, forKey: "value" as NSCopying)
                        return (true,tempDataDictionary)
                    }
                }
                
            }
            
        }
        return (false,NSDictionary.init())
    }
    
    //MARK: - Update NSUser Defaults Data
    
    func updateNSUserDefaultsData(string: String) {
        let userDataArray = (allDataArray.object(at: 0) as! NSDictionary).object(forKey: "fields") as! NSArray
        for value in userDataArray {
            let userDataDictionary = value as! NSDictionary
            
            if userDataDictionary.object(forKey: "title") as! String == "Image"
            {
                userDataModel.profile_image = userDataDictionary.object(forKey: "value") as! String
            }
            
            if userDataDictionary.object(forKey: "title") as! String == "First Name"
            {
                userDataModel.first_name = userDataDictionary.object(forKey: "value") as! String
            }
            
            if userDataDictionary.object(forKey: "title") as! String == "Last Name"
            {
                userDataModel.last_name = userDataDictionary.object(forKey: "value") as! String
            }
            
            if userDataDictionary.object(forKey: "title") as! String == "Email"
            {
                userDataModel.email_id = userDataDictionary.object(forKey: "value") as! String
            }
            
            if userDataDictionary.object(forKey: "title") as! String == "Phone"
            {
                userDataModel.phone = userDataDictionary.object(forKey: "value") as! String
            }
        }
        
        let userData1 = UserDataClass(user_id: userDataModel.user_id, first_name: userDataModel.first_name, last_name: userDataModel.last_name, email_id: userDataModel.email_id, username: userDataModel.username, phone: userDataModel.phone, session_id: userDataModel.session_id, profile_image: userDataModel.profile_image ,currencySymbol: userDataModel.currencySymbol)
        
        let userDefaults = UserDefaults.standard
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: userData1)
        userDefaults.set(encodedData, forKey: "userData")
        userDefaults.synchronize()
        
        if userDefaults.object(forKey: "userData") != nil  {
            let decoded  = userDefaults.object(forKey: "userData") as! Data
            userDataModel = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
            print("user_id \(userDataModel.user_id)")
        }
        
        UIApplication.shared.keyWindow?.makeToast(string, duration: 1.0, position: .bottom)
        self.navigationController?.popViewController(animated: true)
       /* let alert = UIAlertController(title: nil, message: "User Updated Successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        let viewController = UIApplication.shared.keyWindow?.rootViewController
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = viewController?.view
        popPresenter?.sourceRect = (viewController?.view.bounds)!
        viewController?.present(alert, animated: true, completion: nil)
 */
    }
}

//MARK: - TableView DataSource Methods

extension EditUserProfileVC:UITableViewDataSource,UITextFieldDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allFieldsDataArray.count > 0 {
            return allFieldsDataArray.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if allFieldsDataArray.count > 0 {
            
            let dataDictionary = allFieldsDataArray.object(at: indexPath.row) as! NSDictionary
            
            if dataDictionary.object(forKey: "type") as! String == "file"
            {
                let nib:UINib = UINib(nibName: "EditUserImageTableCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "EditUserImageTableCell")
                
                let cell:EditUserImageTableCell = tableView.dequeueReusableCell(withIdentifier: "EditUserImageTableCell") as! EditUserImageTableCell
                cell.userImageView.layer.borderWidth = 1
                cell.userImageView.layer.borderColor = UIColor.lightGray.cgColor
                cell.userImageView.layer.cornerRadius = cell.userImageView.frame.size.width/2
                
                if (dataDictionary.object(forKey: "value") as! String).isEmpty == true {
                    cell.userImageView.image = UIImage(named: "user_placeholder")
                }
                else
                {
                    let image_url = URL(string: BASE_IMAGE_URL + "user/" + (dataDictionary.object(forKey: "value") as! String))
                    let name = userDataModel.first_name + " " + userDataModel.last_name
                    if(image_url == nil)
                    {
                        cell.userImageView.setImage(string: name, color: UIColor.colorHash(name: name), circular: true)
                    }
                    else{
                        cell.userImageView.sd_setImage(with: image_url, placeholderImage:UIImage(named: "user_placeholder"))
                    }
                }
                if userImage != nil
                {
                    cell.userImageView.image = userImage
                    cell.userImageView.contentMode = .scaleAspectFit
                }
                cell.editImageButton.addTarget(self, action: #selector(editImageButton(_:)), for: .touchUpInside)
                cell.editImageView.layer.borderWidth = 1
                cell.editImageView.layer.borderColor = UIColor.lightGray.cgColor
                cell.editImageView.layer.cornerRadius = cell.editImageView.frame.size.width/2
                cell.selectionStyle = .none
                
                return cell
            }
            
            if dataDictionary.object(forKey: "type") as! String == "text" || dataDictionary.object(forKey: "type") as! String == "email" || dataDictionary.object(forKey: "type") as! String == "tel"
            {
                if dataDictionary.object(forKey: "title") as! String == "First Name"
                {
                    let nib:UINib = UINib(nibName: "TextFieldTableCell", bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: "TextFieldTableCell")
                    
                    let cell:TextFieldTableCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableCell") as! TextFieldTableCell
                    cell.selectionStyle = .none

                    cell.textField.delegate = self
                    
                    cell.textField.isUserInteractionEnabled = true
                    cell.textField.keyboardType = .default
                    if firstName.isEmpty
                    {
                        cell.textField.placeholder = (dataDictionary.object(forKey: "title") as! String)
                        cell.textField.text = (dataDictionary.object(forKey: "value") as! String)
                    }
                    else
                    {
                        cell.textField.text = firstName
                    }
                    
                    firstName = cell.textField.text!
                    return cell
                }
                if dataDictionary.object(forKey: "title") as! String == "Last Name"
                {
                    let nib:UINib = UINib(nibName: "TextFieldTableCell", bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: "TextFieldTableCell")
                    
                    let cell:TextFieldTableCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableCell") as! TextFieldTableCell
                    cell.selectionStyle = .none
                    cell.textField.delegate = self
                    cell.textField.isUserInteractionEnabled = true
                    cell.textField.keyboardType = .default
                    if lastName.isEmpty
                    {
                        cell.textField.placeholder = (dataDictionary.object(forKey: "title") as! String)
                        cell.textField.text = (dataDictionary.object(forKey: "value") as! String)
                    }
                    else
                    {
                        cell.textField.text = lastName
                    }
                    
                    lastName = cell.textField.text!
                    return cell
                }
                if dataDictionary.object(forKey: "title") as! String == "Email"
                {
                    let nib:UINib = UINib(nibName: "TextFieldTableCell", bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: "TextFieldTableCell")
                    
                    let cell:TextFieldTableCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableCell") as! TextFieldTableCell
                    cell.selectionStyle = .none
                    cell.textField.delegate = self
                    
                    cell.textField.isUserInteractionEnabled = false
                    cell.textField.keyboardType = .emailAddress
                    if email.isEmpty
                    {
                        cell.textField.placeholder = (dataDictionary.object(forKey: "title") as! String)
                        cell.textField.text = (dataDictionary.object(forKey: "value") as! String)
                    }
                    else
                    {
                        cell.textField.text = email
                    }
                    
                    email = cell.textField.text!
                    return cell
                }
                if dataDictionary.object(forKey: "title") as! String == "Phone"
                {
                    let nib:UINib = UINib(nibName: "TextFieldTableCell", bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: "TextFieldTableCell")
                    
                    let cell:TextFieldTableCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableCell") as! TextFieldTableCell
                   
                    cell.textField.delegate = self
                    cell.textField.isUserInteractionEnabled = true
                    cell.textField.keyboardType = .phonePad
                    if contact_number.isEmpty
                    {
                        cell.textField.placeholder = (dataDictionary.object(forKey: "title") as! String)
                        if let value = (dataDictionary.object(forKey: "value") as? String)
                        {
                            cell.textField.text = value
                        }
                    }
                    else
                    {
                        cell.textField.text = contact_number
                    }
                    contact_number = cell.textField.text!
                    cell.selectionStyle = .none
                    return cell
                }
            }
            
            if dataDictionary.object(forKey: "type") as! String == "datePicker"
            {
                let nib:UINib = UINib(nibName: "AdditionalTableCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "AdditionalTableCell")
                
                let cell:AdditionalTableCell = tableView.dequeueReusableCell(withIdentifier: "AdditionalTableCell") as! AdditionalTableCell
                cell.titleLbl.text = "Date of Birth"
                
                if selectedDate.isEmpty
                {
                    if let value = (dataDictionary.object(forKey: "value") as? String)
                    {
                        if(value.isEmpty)
                        {
                            cell.subTitleLbl.text = ""
                        }
                        else
                        {
                       cell.subTitleLbl.text = self.dateFormetterChange(DOB: value)
                          // cell.subTitleLbl.text = value
                        }
                    }
                }
                else
                {
                    cell.subTitleLbl.text = self.dateFormetterChange(DOB: selectedDate)
                  //  cell.subTitleLbl.text = selectedDate
                }
                cell.selectionStyle = .none
                return cell
            }
            if dataDictionary.object(forKey: "type") as! String == "radio"
            {
                let nib:UINib = UINib(nibName: "AdditionalTableCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "AdditionalTableCell")
                
                let cell:AdditionalTableCell = tableView.dequeueReusableCell(withIdentifier: "AdditionalTableCell") as! AdditionalTableCell
                cell.titleLbl.text = "Select Gender"
                
                if gender.isEmpty
                {
                    if let value = (dataDictionary.object(forKey: "value") as? String)
                    {
                        cell.subTitleLbl.text = value
                    }
                }
                else
                {
                    cell.subTitleLbl.text = gender
                }
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell(frame: CGRect.zero)
    }
    
    //    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    //        let view:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
    //        view.backgroundColor = tableView.backgroundColor
    //        return view
    //    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        print("textField Placeholder : \(String(describing: textField.placeholder))")
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        print(newString)
        if (textField.placeholder == "First Name")
        {
            firstName = newString
            if textField.text?.count == 25 {
                if (string == "") {
                    print("Backspace")
                    return true
                }
                return false
            }
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_ONLY_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered)
        }
        if (textField.placeholder == "Last Name")
        {
            lastName = newString
            if textField.text?.count == 25 {
                if (string == "") {
                    print("Backspace")
                    return true
                }
                return false
            }
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_ONLY_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered)
        }
        
        if (textField.placeholder == "Phone")
        {
            contact_number = newString
            if textField.text?.count == 15 {
                if (string == "") {
                    print("Backspace")
                    return true
                }
                return false
            }
          return true
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            if(textField.placeholder == "Last Name")
            {
                
            }
            else
            {
                self.isTextFieldValid(string: textField.placeholder!,textField: textField)
            }
        }
    
        if textField.placeholder == "First Name" {
            firstName = textField.text!
            return
        }
        
        if textField.placeholder == "Last Name" {
            lastName = textField.text!
            return
        }
        if textField.placeholder == "Email" {
            email = textField.text!
            return
        }
        if textField.placeholder == "Phone" {
            contact_number = textField.text!
            return
        }
    }
    
    func dateFormetterChange(DOB: String) -> String {
        
        var dobStr = ""
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateStr: Date? = dateFormatterGet.date(from: DOB)
        
        let dateString = dateFormatterGet.string(from: dateStr!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let dateStr2: Date? = dateFormatterGet.date(from: dateString)
        dobStr  = dateFormatter.string(from: dateStr!)
        
        return dobStr
    }
   
}


//MARK: - TableView Delegate Methods

extension EditUserProfileVC:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 130
        }
        else if indexPath.row == 5 || indexPath.row == 6
        {
            return 84
        }
        else
        {
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 5 {
            
            self.selectDate(indexPath: indexPath)
        }
        else if indexPath.row == 6
        {
            self.selectGender(indexPath: indexPath)
        }
        else
        {
            return
        }
    }
    
    //MARK: - Popup AlertView for TexField Validations
    
    func isTextFieldValid(string: String, textField: UITextField)   {
        
        let alertController = UIAlertController(title: "TextField Validation", message: "Please enter valid text in " + string, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            // textField.becomeFirstResponder()
            return
        }))
        let popPresenter = alertController.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.sourceRect = self.view.bounds
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Popup AlertView for Gender Selection
    
    func selectGender(indexPath : IndexPath) {
        
        let alertController = UIAlertController(title: "Select Gender", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Male", style: .default, handler: { (action) in
            self.gender = "Male"
            let cell:AdditionalTableCell  = self.tableView.cellForRow(at: indexPath) as! AdditionalTableCell
            cell.subTitleLbl.text = "Male"
            cell.subTitleLbl.isHidden = false
            return
        }))
        
        alertController.addAction(UIAlertAction(title: "Female", style: .default, handler: { (action) in
            
            self.gender = "Female"
            let cell:AdditionalTableCell  = self.tableView.cellForRow(at: indexPath) as! AdditionalTableCell
            cell.subTitleLbl.text = "Female"
            cell.subTitleLbl.isHidden = false
            return
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            print("Cancel")
        }))
        
        if UIDevice().userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - Pop AlertView for Date Selection
    
    func selectDate(indexPath : IndexPath) {
        
        let alertController = UIAlertController(title: "Select Date", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        datePicker = UIDatePicker(frame: CGRect(x: alertController.view.frame.origin.x, y: 15, width: 250, height: 210))
       
        alertController.view.addSubview(datePicker!)
        datePicker?.clipsToBounds = true
        datePicker?.datePickerMode = .date
        datePicker?.maximumDate = Date()
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            print("Cancel")
        }))
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            print("Ok")
            
            let cell:AdditionalTableCell  = self.tableView.cellForRow(at: indexPath) as! AdditionalTableCell
            cell.subTitleLbl.text =   self.dateFormetterChange(DOB: self.selectedDate)
           // cell.subTitleLbl.text =   self.selectedDate
            cell.subTitleLbl.isHidden = false
            
        }))
        let popPresenter = alertController.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.sourceRect = self.view.bounds
        self.present(alertController, animated: true, completion: nil)
        datePicker?.addTarget(self, action: #selector(datePickerAction(_:)), for: .valueChanged)
        
    }
    
}




