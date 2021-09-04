//
//  ProfileVC.swift
//  SRAA3
//
//  Created by Apple on 22/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    var window: UIWindow?
    var sectionImageArray1:NSMutableArray?
    
    var user_data:UserDataClass!
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var tableV: UITableView!
     private let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        
        super.viewDidLoad()
//
//        let dic1:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "home_black")),("title","My Address"))
//        let dic2:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "key_icon")),("title","Change Password"))
//        let dic3:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "helpicon")),("title","Help & FAQ's"))
//        let dic4:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "support")),("title","Support"))
//        let dic5:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "share")),("title","Social Media"))
//        let dic6:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "inviteAndEarn")),("title","Invite & Earn"))
//
//        sectionImageArray1 = NSMutableArray(objects: dic1,dic2,dic3,dic4,dic5,dic6)
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableV.rowHeight = UITableViewAutomaticDimension
        self.tableV.estimatedRowHeight = 50
        
        if userDefaults.object(forKey: "userData") != nil {
        if #available(iOS 10.0, *) {
            tableV.refreshControl = refreshControl
        } else {
            tableV.addSubview(refreshControl)
        }
            refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        let dic1:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "home_black")),("title","My Address"))
        let dic2:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "key_icon")),("title","Change Password"))
        let dic3:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "helpicon")),("title","Help & FAQ's"))
        let dic4:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "support")),("title","Support"))
        let dic5:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "share")),("title","Social Media"))
        let dic6:NSDictionary = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "inviteAndEarn")),("title","Invite & Earn"))
        if userDefaults.object(forKey: "userData") != nil {
        
        sectionImageArray1 = NSMutableArray(objects: dic1,dic3,dic4,dic5,dic6)
            self.getUserDetailApiCall()
        }
        else
        {
           sectionImageArray1 = NSMutableArray(objects: dic3,dic4,dic5)
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        self.getUserDetailApiCall()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: -TableView DataSource Methods ------------------- //

extension ProfileVC:UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        if userDefaults.object(forKey: "userData") != nil {
            
            return 3
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if userDefaults.object(forKey: "userData") != nil {
        if section == 0 {
            return 1
        }
        if section == 2 {
            return 1
        }
        }
        return (sectionImageArray1?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0 && userDefaults.object(forKey: "userData") != nil)
        {
            let identifier = "ProfileHeaderCell"
            var cell: ProfileHeaderCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? ProfileHeaderCell
            if cell == nil {
                var nib = Bundle.main.loadNibNamed("ProfileHeaderCell", owner: self, options: nil)
                cell = nib![0] as! ProfileHeaderCell
            }
            cell.selectionStyle = .none
            
            let name = userDataModel.first_name + " " + userDataModel.last_name
            cell.usernameLbl.text = "Hi, " +  name
            let image_url = URL(string: BASE_IMAGE_URL + "user/" + userDataModel.profile_image)
            print(image_url)
            if(image_url == nil)
            {
                cell.profileImgV.setImage(string: name, color: UIColor.colorHash(name: name), circular: true)
            }
            else{
                print(image_url!)
                cell.profileImgV.sd_setImage(with: image_url, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .cacheMemoryOnly, completed: nil)
            }
             cell.editBtn.addTarget(self, action: #selector(editProfileButton(_:)), for: .touchUpInside)
            return cell
        }
        
        if (indexPath.section == 2 && userDefaults.object(forKey: "userData") != nil)
        {
            let nib:UINib = UINib(nibName: "ProfileFooterCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "ProfileFooterCell")
            let cell:ProfileFooterCell = tableView.dequeueReusableCell(withIdentifier: "ProfileFooterCell") as! ProfileFooterCell
            cell.selectionStyle = .none
            let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
            if let version = nsObject as? String
            {
               cell.versionLbl.text = "v" + version
            }
            cell.signOutBtn.addTarget(self, action: #selector(signOutButton(_:)), for: UIControlEvents.touchUpInside)
            
            return cell
        }
        else{
        var cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if cell.isEqual(nil) == true {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }
        cell.selectionStyle = .none
            
        let dic = sectionImageArray1![indexPath.row]as! NSDictionary
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.imageView?.image = dic.object(forKey: "image") as? UIImage
        cell.textLabel?.font = UIFont(name: "Open Sans", size: 14)
        cell.textLabel?.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.90)
        cell.textLabel?.text = dic.object(forKey: "title") as? String
        
        return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && userDefaults.object(forKey: "userData") != nil {
            
            let footerMainView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
            footerMainView.backgroundColor = UIColor.clear
            return footerMainView
        }
        else
        {
            return nil
        }
    }
    
    //MARK: - Selector Methods ----------------------- //
    @objc func editProfileButton(_ sender: UIButton){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "EditUserProfileVC") as! EditUserProfileVC
        self.navigationController?.pushViewController(viewController, animated: true)
}
    @objc func signOutButton(_ sender: UIButton)
    {
        let alert = UIAlertController(title: nil, message: "Do you want to sign out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
            self.signOutAPI()
        }))
        
        alert.addAction(UIAlertAction(title: "NO", style: .destructive, handler: { (action) in
            return
        }))
        
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.sourceRect = self.view.bounds
        self.present(alert, animated: true, completion: nil)
    }
    
     //MARK: - APi Call --------------------- //
    func getUserDetailApiCall() {
        
        WebService.requestGetUrl(strURL: RUsers_Api + "/" + (userDataModel.user_id!) , is_loader_required: false, success: { (response) in
            print(response)
            self.refreshControl.endRefreshing()
            if (response.value(forKey: "status_code")as! NSNumber) == 1
            {
                let dataDic = (response.value(forKey: "data")as! NSArray).object(at: 0)as! NSDictionary
                
                let user_data = UserDataClass.init(user_id: userDataModel.user_id, first_name: CommonClass.checkForNull(string: dataDic.value(forKey: "first_name")as AnyObject) , last_name: CommonClass.checkForNull(string: dataDic.value(forKey: "last_name")as AnyObject), email_id: userDataModel.email_id, username: userDataModel.username, phone: CommonClass.checkForNull(string: dataDic.value(forKey: "phone")as AnyObject), session_id: userDataModel.session_id, profile_image: CommonClass.checkForNull(string: dataDic.value(forKey: "photo")as AnyObject) , currencySymbol:userDataModel.currencySymbol)
                
                let userDefaults = UserDefaults.standard
                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: user_data)
                userDefaults.set(encodedData, forKey: "userData")
                userDefaults.synchronize()
                
                if userDefaults.object(forKey: "userData") != nil  {
                    let decoded  = userDefaults.object(forKey: "userData") as! Data
                    userDataModel = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
                    //print(userData.user_id)
                }
                self.tableV.reloadData()
            }
            else
            {
                COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
            }
            
        }) { (failure) in
            self.refreshControl.endRefreshing()
        }
    }
    //MARK: - Sign Out API
    func signOutAPI() {
        
        let user_session_id = userDataModel.session_id!
        
        notification_token = UserDefaults.standard.value(forKey: "notification_token") as! String
        
        let params = ["user_session_id": user_session_id,"notification_token":notification_token]
        
        let api_name = RLogout_Api
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrl(strURL: api_name , params: params as NSDictionary, is_loader_required: true, success: { (response) in
                print("logout response :\(response)")
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 1
                {
                    DispatchQueue.main.async {
                        CommonClass.emptyUserDefaultData()
                        
                        let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                       
                        let yourVc = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                        let navigationController = UINavigationController(rootViewController: yourVc!)
                        if let window = self.window {
                            window.rootViewController = navigationController
                        }
                        self.window?.makeKeyAndVisible()
                        UIApplication.shared.keyWindow?.makeToast((response["message"] as! String), duration: 1.0, position: .bottom)
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
}

//MARK: -TableView Delegate Methods --------------------//

extension ProfileVC:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0 || indexPath.section == 2)
        {
            return UITableViewAutomaticDimension
        }
        return 50
    }
    
    func tableView( _ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 2 || section == 1) {
            return 0
        }
        else
        {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let cell:UITableViewCell = tableView.cellForRow(at: indexPath)!
                if(indexPath.section == 0 || indexPath.section == 2)
        {
             self.tabBarController?.tabBar.isHidden = false
        }
        else
        {
             self.tabBarController?.tabBar.isHidden = true
        }
        if cell.textLabel?.text == "My Address"{
            
            let viewController:DeliveryAddressVC = self.storyboard?.instantiateViewController(withIdentifier: "DeliveryAddressVC") as! DeliveryAddressVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
        }
        else if cell.textLabel?.text == "Change Password"{
            
            let viewController:ChangePasswordVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
        }
       else if cell.textLabel?.text == "Help & FAQ's"{
            
            let viewController:HelpAndFAQVC = self.storyboard?.instantiateViewController(withIdentifier: "HelpAndFAQVC") as! HelpAndFAQVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
        }
        else if cell.textLabel?.text == "Support"{
            let viewController:SupportVC = self.storyboard?.instantiateViewController(withIdentifier: "SupportVC") as! SupportVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
        }
        else if cell.textLabel?.text == "Social Media"{
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SocialMediaVC") as! SocialMediaVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return        }
            
        else if cell.textLabel?.text == "Invite & Earn"{
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "InviteAndEarnVC") as! InviteAndEarnVC
            self.navigationController?.pushViewController(viewController, animated: true)
            return
            
        }
       
        else
        {
            
        }
    }
}
