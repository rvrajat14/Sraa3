  
//
//  DeliveryAddressVC.swift
//  Dry Clean City
//
//  Created by Kishore on 05/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
  
class DeliveryAddressVC: UIViewController {
    
    var selectedIndex:Int = 0
    var isFromCheckOut = false
    var allAddressArray = NSMutableArray.init()
     var isForDeliveryAddress = false
    var currentPage:Int = 1
    var maxPage:Int = 1
    var default_status = ""
    var nextUrl = ""
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLbl: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var tableV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableV.emptyDataSetDelegate = self
        self.tableV.emptyDataSetSource = self
        self.tableV.rowHeight = UITableViewAutomaticDimension
        self.tableV.estimatedRowHeight = 50
        self.tableV.tableFooterView = UIView.init(frame: .zero)
        self.tableV.isHidden = true
        if #available(iOS 10.0, *) {
            tableV.refreshControl = refreshControl
        } else {
            tableV.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        self.tableV.isHidden = true
        self.loadingLbl.isHidden = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.addBtn.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.currentPage = 1
        allAddressArray = NSMutableArray.init()
        self.addressListApi(loader: false)
    }
    
    
    //MARK: - Private Methods
    @objc private func refreshData(_ sender: Any) {
        
        currentPage = 1
        self.addressListApi(loader: false)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func editButton(_ sender: UIButton)
    {
       let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewAddressVC") as! AddNewAddressVC
        
        let model = allAddressArray[sender.tag] as! AddressListModel
        viewController.model = model
       
        viewController.isForAddressEditing = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func setDefaultCheckBoxButton(_ sender: UIButton)
    {
        // let dataDic = allAddressArray?.object(at: sender.tag) as! NSDictionary
       // default_status = sender.tag
       // self.tableV.reloadData()
      
        let model = allAddressArray.object(at: sender.tag) as! AddressListModel
        self.updateAddressAPI(loader: true, model: model)
    }
    
    @IBAction func popVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewAddressBtnTaped(_ sender: Any) {
    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewAddressVC") as! AddNewAddressVC
       viewController.isForAddressEditing = false
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: -Call API

    func updateAddressAPI(loader:Bool,model:AddressListModel) {
        
//        let params = ["linked_id":userDataModel.user_id!,"default":"1"]
        let params = ["default":"1","address_type":"customer","address_title":model.title,"address_line1":model.line1,"address_line2":model.line2,"address_phone":model.phone,"latitude":model.latitude,"longitude":model.longitude,"city":model.city,"state":model.state,"pincode":model.pincode,"country":model.country,"linked_id":userDataModel.user_id!]
        
        let url = RAddress_Api + "/\(model.id)"
        WebService.requestPutUrl(strURL: url , params: params as NSDictionary, is_loader_required: false, success: { (response) in
            
            if response["status_code"] as! NSNumber == 1
            {
                
                let selectedDic = NSMutableDictionary(dictionaryLiteral: ("address_line1", model.line1),("address_line2",model.line2),("city",model.city),("state",model.state),("country",model.country),("pincode",""),("latitude",model.latitude),("longitude",model.longitude),("address_id",model.id),("created_at",""),("address_phone",model.phone),("address_title",model.title))
                
                UserDefaults.standard.setValue(selectedDic, forKey: "Default_Selected_Address")
                self.currentPage = 1
                
                if self.isFromCheckOut == true {
                    
                    if self.isForDeliveryAddress {
                        selectedAddressDictionary =  selectedDic
                    }
                    else
                    {
                        selectedPickUpAddressDictionary = selectedDic
                    }
                    self.navigationController?.popViewController(animated: true)
                }
               else
                {
                self.addressListApi(loader: false)
                }
            }
            else
            {
                COMMON_ALERT.showAlert(title: "", msg: response["message"] as! String, onView: self)
                return
            }
        }) { (failure) in
            COMMON_ALERT.showAlert(title: "", msg: "Request Time Out !", onView: self)
        }
    }
    
    func addressListApi(loader:Bool){
        
        let api_name = RAddress_Api + "?address_type=customer&linked_id=\(userDataModel.user_id!)&page=\(currentPage)"
        
        print(api_name)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestGetUrl(strURL: api_name , is_loader_required: loader, success: { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                self.tableV.isHidden = false
                self.loadingLbl.isHidden = true
                self.activityIndicator.isHidden = true
                self.addBtn.isHidden = false
                self.activityIndicator.stopAnimating()
                
                self.refreshControl.endRefreshing()
                if response["status_code"] as! NSNumber == 1
                {
                    if (self.currentPage == 1)
                    {
                        self.allAddressArray.removeAllObjects()
                        self.allAddressArray = NSMutableArray.init()
                    }
                    else
                    {}
                    let array = ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray)
                    self.nextUrl = CommonClass.checkForNull(string: ((response["data"] as! NSDictionary).value(forKey: "next_page_url")as AnyObject))
                    self.currentPage = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "current_page") as! NSNumber)
                    self.maxPage = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "last_page") as! NSNumber)
                    
                    for item in array
                    {
                        let dic = item as! NSDictionary
                        let model = AddressListModel()
                        model.id = CommonClass.checkForNull(string: (dic.value(forKey:"address_id") as AnyObject))
                        model.line1 = CommonClass.checkForNull(string: (dic.value(forKey:"address_line1") as AnyObject))
                        model.line2 = CommonClass.checkForNull(string: (dic.value(forKey:"address_line2") as AnyObject))
                        model.phone = CommonClass.checkForNull(string: (dic.value(forKey:"address_phone") as AnyObject))
                        model.title = CommonClass.checkForNull(string: (dic.value(forKey:"address_title") as AnyObject))
                        model.city = CommonClass.checkForNull(string: (dic["city"] as AnyObject))
                        model.country = CommonClass.checkForNull(string: (dic.value(forKey:"country") as AnyObject))
                        model.address_default = CommonClass.checkForNull(string: (dic.value(forKey: "default") as AnyObject))
                        model.latitude = CommonClass.checkForNull(string: (dic.value(forKey: "latitude") as AnyObject))
                        model.longitude = CommonClass.checkForNull(string: (dic.value(forKey: "longitude") as AnyObject))
                        
                        model.linked_id = CommonClass.checkForNull(string: (dic.value(forKey: "linked_id") as AnyObject))
                        model.pincode = CommonClass.checkForNull(string: (dic.value(forKey: "pincode") as AnyObject))
                        model.state = CommonClass.checkForNull(string: (dic.value(forKey: "state") as AnyObject))
                        
                        self.allAddressArray.add(model)
                    }
                    self.tableV.reloadData()
                }
               else
                {
                    if(self.allAddressArray.count == 1)
                    {
                        self.allAddressArray.removeAllObjects()
                        self.allAddressArray = NSMutableArray.init()
                    }
                    self.tableV.reloadData()
                }
                
               /* if(self.allAddressArray.count == 0)
                {
                    self.tableV.backgroundColor = .white
                }
                else
                {
                    self.tableV.backgroundColor = .clear
                }*/
                self.tableV.reloadData()
            }) { (failure) in
               self.refreshControl.endRefreshing()
            }
        }
    }
    
    func deleteAddressAPI(address_id: String) {
      
        //let paramDic = ["user_address_id": address_id]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestDelUrl(strURL: RAddress_Api + "/\(address_id)" , is_loader_required: true, success: { (response) in
                
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 0
                {
                    COMMON_ALERT.showAlert(title: response["message"] as! String, msg: "", onView: self)
                }
                else
                {
                    DispatchQueue.main.async {
                        
                        self.addressListApi(loader: false)
                    }
                }
                
            }) { (failure) in
                // COMMON_FUNCTIONS.showAlert(msg: "Request Time Out !")
            }
        }
  
    }
}
  
//MARK : -TableView DataSource Methods///////

extension DeliveryAddressVC:UITableViewDataSource , UITableViewDelegate , DZNEmptyDataSetSource , DZNEmptyDataSetDelegate
{
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "emptyAddress")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "NO ADDRESS SAVED YET"
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont(name:KMainFontSemiBold, size: 17)!]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "You can add your Home,Office or Other address details here for faster checkout."
        
        let attribs = [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont(name:KMainFont, size: 13)!]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 10
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -40
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let view = scrollView.value(forKey: "emptyDataSetView") as? UIView else {return}
        view.frame = CGRect(x: view.frame.origin.x, y: scrollView.contentOffset.y, width: view.bounds.width, height: view.bounds.height)
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return self.allAddressArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let nib:UINib = UINib(nibName: "DeliveryAddressCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "DeliveryAddressCell")
        let cell:DeliveryAddressCell = tableView.dequeueReusableCell(withIdentifier: "DeliveryAddressCell") as! DeliveryAddressCell
        cell.selectionStyle = .none

        let addressModel = self.allAddressArray.object(at: indexPath.row)as! AddressListModel
        
        cell.titleLbl.text = addressModel.title
        
        cell.detailLbl.text = addressModel.line1 + ", " +
           addressModel.line2 +
        ", \(addressModel.city)" +
        ", \(addressModel.state)"
        
        if !addressModel.country.isEmpty {
            cell.detailLbl.text = cell.detailLbl.text! +
            ", \(addressModel.country)"
        }
        
        cell.editButton.tag = indexPath.row
      //  cell.editButton.layer.borderWidth = 1
      //  cell.editButton.layer.borderColor = UIColor.KMainColorCode.cgColor
     //   cell.editButton.layer.cornerRadius = 4
        cell.editButton.addTarget(self, action: #selector(editButton(_:)), for: .touchUpInside)
        
        let default_status = addressModel.address_default
        if default_status == "1" {
            cell.setDefaultCheckBoxButton.setImage(#imageLiteral(resourceName: "radio-black"), for: .normal)
        }
        else
        {
            cell.setDefaultCheckBoxButton.setImage(#imageLiteral(resourceName: "empty-circle"), for: .normal)
        }
        cell.setDefaultCheckBoxButton.tag = indexPath.row
        cell.setDefaultCheckBoxButton.layer.borderColor = UIColor.KMainColorCode.cgColor
        cell.setDefaultCheckBoxButton.layer.cornerRadius = 1
        cell.setDefaultCheckBoxButton.addTarget(self, action: #selector(setDefaultCheckBoxButton(_:)), for: .touchUpInside)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        headerView.backgroundColor = UIColor.white
        
      /*  let lbl = UILabel.init(frame: CGRect(x: 20, y: 9, width: self.tableV.frame.size.width - 20, height: 20))
        
        lbl.text = String(self.allAddressArray.count) + " Addresses"
        
        lbl.textColor = UIColor.lightGray
        
        lbl.font = UIFont(name: KMainFont, size: 15)
        
        headerView.addSubview(lbl) */
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if currentPage == maxPage
        {}
        else
        {
            if (indexPath.row == allAddressArray.count-1)
            {
                if(!nextUrl.isEmpty)
                {
                    currentPage = currentPage + 1
                    self.addressListApi(loader: false)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = allAddressArray.object(at: indexPath.row) as! AddressListModel
        let selectedDic = NSMutableDictionary(dictionaryLiteral: ("address_line1", model.line1),("address_line2",model.line2),("city",model.city),("state",model.state),("country",model.country),("pincode",""),("latitude",model.latitude),("longitude",model.longitude),("address_id",model.id),("created_at",""),("address_phone",model.phone),("address_title",model.title))
        
        if isForDeliveryAddress {
            selectedAddressDictionary =  selectedDic
        }
        else
        {
            selectedPickUpAddressDictionary = selectedDic
        }
        if isFromCheckOut == true {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            return
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive , title: "Delete") { (action, index) in
            
            let alert = UIAlertController(title: nil, message: "Do you want to delete this address ?", preferredStyle: .alert)
           
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                let model = self.allAddressArray[index.row] as! AddressListModel
                 self.deleteAddressAPI(address_id: (model.id))
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
                return
            }))
            let popPresenter = alert.popoverPresentationController
            popPresenter?.sourceView = self.view
            popPresenter?.sourceRect = self.view.bounds
            self.present(alert, animated: true, completion: nil)
          
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
}



