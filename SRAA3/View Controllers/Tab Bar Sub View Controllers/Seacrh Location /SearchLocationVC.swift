//
//  SearchLocationVC.swift
//  TaxiApp
//
//  Created by Apple on 12/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class SearchLocationVC: UIViewController , UITableViewDelegate , UITableViewDataSource , UITextFieldDelegate ,GMSMapViewDelegate,CLLocationManagerDelegate{
    
    let footerViewHeight:CGFloat = 50.0
    var placemark: CLPlacemark!
    var placesClient: GMSPlacesClient!
    var googlePlacesArray = NSArray.init()
    var tempLat = 0.0
    var tempLongi = 0.0
    var tempAddress = ""
    var selectedAdressType = ""
    var recentSerchList = NSArray()
    var savedLocationList = NSArray()
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var pickupAddressTxtF: UITextField!
    @IBOutlet weak var savedLocationTableV: UITableView!
    @IBOutlet weak var googleLocationTableV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.pickupAddressTxtF.setLeftPaddingPoints(7)
        googleLocationTableV.rowHeight = UITableViewAutomaticDimension
        googleLocationTableV.estimatedRowHeight = 50
        googleLocationTableV.tableFooterView = UIView(frame: .zero)
        savedLocationTableV.keyboardDismissMode = .interactive
        googleLocationTableV.keyboardDismissMode = .interactive
        
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "LocationInitialData") != nil {
            
            let retriveArrayData = UserDefaults.standard.object(forKey:  "LocationInitialData") as? NSData
            
            let dataDic = (NSKeyedUnarchiver.unarchiveObject(with: retriveArrayData! as Data) as? NSDictionary)
            print(" saved response = \(dataDic!)")
            
            self.recentSerchList = dataDic?.value(forKey: "recent_search")as! NSArray
            self.savedLocationList = dataDic?.value(forKey: "save_address")as! NSArray
            
            self.savedLocationTableV.reloadData()
        }
        savedLocationTableV.keyboardDismissMode = .onDrag
        googleLocationTableV.keyboardDismissMode = .onDrag
      //  addressSerachApiCall()
        
    }
    
    @IBAction func popVC(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: -TableView DataSource Methods///////
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView == savedLocationTableV {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView == savedLocationTableV) {
            if (section == 1)
            {
                if(recentSerchList.count == 0)
                {
                    return 0
                }
                return 30
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        headerView.backgroundColor = tableView.backgroundColor
        let titleLbl = UILabel(frame: CGRect(x: 50, y: 10, width: 160, height: 20))
        titleLbl.text = "RECENT SEARCHES"
        titleLbl.font = UIFont(name: KMainFont, size: 14)
        titleLbl.textColor = UIColor.black
        headerView.addSubview(titleLbl)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == googleLocationTableV) {
            return googlePlacesArray.count
        }
        
        if section == 0 {
            return 1
        }
       // return self.recentSerchList.count
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == savedLocationTableV)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            if( !(cell != nil))
            {
                cell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: "cell")
            }
            if (indexPath.section == 0)
            {
                cell?.textLabel?.text = "Current Location"
                cell?.detailTextLabel?.text = "Using GPS"
                cell?.imageView?.image = #imageLiteral(resourceName: "icon-pointer")
            }
            else
            {
                let dic = self.recentSerchList.object(at: indexPath.row)as! NSDictionary
                cell?.textLabel?.text = CommonClass.checkForNull(string: dic.value(forKey: "address_line1") as AnyObject)
                cell?.detailTextLabel?.text = CommonClass.checkForNull(string: dic.value(forKey: "state")as AnyObject)
                cell?.imageView?.image = #imageLiteral(resourceName: "icon-pointer")
            }
            return cell!
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if( !(cell != nil))
        {
            cell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: "cell")
        }
        let result: GMSAutocompletePrediction? = googlePlacesArray.object(at: indexPath.row) as? GMSAutocompletePrediction
        print(result as Any)
        
        if let primaryAddress = result?.attributedPrimaryText.string
        {
            cell?.textLabel?.text  = primaryAddress
            if let aSize = UIFont(name: KMainFont, size: 16) {
                cell?.textLabel?.font = aSize
            }
        }
        if let secondaryAddress = result?.attributedSecondaryText?.string
        {
            cell?.detailTextLabel?.text = secondaryAddress
            if let aSize = UIFont(name: KMainFont, size: 12) {
                cell?.detailTextLabel?.font = aSize
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (tableView == savedLocationTableV)
        {
            if (section == 0)
            {
                return 15
            }
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView == googleLocationTableV) {
            let resultMain: GMSAutocompletePrediction? = googlePlacesArray.object(at: indexPath.row) as? GMSAutocompletePrediction
            print(resultMain?.attributedPrimaryText.string as Any)
            DispatchQueue.main.async(execute: {
                let placeClient = GMSPlacesClient.shared() as? GMSPlacesClient
                placeClient?.lookUpPlaceID((resultMain?.placeID)!, callback: { result, error in
                    if error == nil {
                        if let aLatitude = result?.coordinate.latitude, let aLongitude = result?.coordinate.longitude {
                            print("place : \(aLatitude),\(aLongitude)")
                        }
                            self.pickupAddressTxtF.text = result?.formattedAddress
                            
                            print("lllll :\(String(describing: result?.coordinate.latitude))")
                            print("lnggggg :\(String(describing: result?.coordinate.longitude))")
                            if let aLatitude = result?.coordinate.latitude {
                                selectedAddressDic.setValue(aLatitude, forKey: "lati")
                            }
                            if let aLongitude = result?.coordinate.longitude {
                                selectedAddressDic.setValue(aLongitude, forKey: "longi")
                            }
                          //  selectedAddressDic.setValue(result?.formattedAddress, forKey: "address")
                        selectedAddressDic.setValue(resultMain?.attributedFullText.string, forKey: "address")
                        
                       // self.addNewAddressAPI(formatedArress: (result?.formattedAddress)!, latitudeValue: result?.coordinate.latitude as Any, longitudeValue: result?.coordinate.longitude as Any)
                        
                        self.googleLocationTableV.isHidden = true
                        
                        self.savedLocationTableV.isEditing = false
                        
                         NotificationCenter.default.post(name: Notification.Name("locationSelected"), object: nil)
                        self.navigationController?.popViewController(animated: true)
                        
                    }
                     else {
                        print("Error : \(error?.localizedDescription ?? "")")
                    }
                })
            })
        }
        else
        {
            if(indexPath.section == 0)
            {
               // self.saveDataInDic(selectedDic: self.savedLocationList.object(at: indexPath.row) as! NSDictionary)
                 NotificationCenter.default.post(name: Notification.Name("selectCurrentLocation"), object: nil)
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                self.saveDataInDic(selectedDic: self.recentSerchList.object(at: indexPath.row) as! NSDictionary)
            }
            googleLocationTableV.isHidden = true
            savedLocationTableV.isEditing = false
        }
    }
    
    func saveDataInDic(selectedDic : NSDictionary)  {
           self.pickupAddressTxtF.text = (selectedDic.value(forKey: "address_line1") as! String)
            if let aLatitude = selectedDic.value(forKey: "latitude") {
                let latt = (aLatitude  as AnyObject).doubleValue
                selectedAddressDic.setValue(latt, forKey: "lati")
            }
            if let aLongitude = selectedDic.value(forKey: "longitude") {
                let longg = (aLongitude  as AnyObject).doubleValue
                selectedAddressDic.setValue(longg, forKey: "longi")
            }
            selectedAddressDic.setValue(self.pickupAddressTxtF.text , forKey: "address")
        
        }
    
    @objc func setPinBtnTaped()  {
        self.googleLocationTableV.isHidden = true
        self.savedLocationTableV.isHidden = true
    }
    
    // MARK: - TextField Delegates
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
            let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            print(newString)
            self.placeAutocomplete(newString)
       
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing \(textField.tag)")
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("text cleared")
        //do few custom activities heretextField.text = ""
        self.googleLocationTableV.isHidden = true
        self.savedLocationTableV.isHidden = false
        return true
    }
    

    func placeAutocomplete(_ location: String?) {
        placesClient = GMSPlacesClient()
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        placesClient.findAutocompletePredictions(fromQuery: location!, filter: filter, sessionToken: nil) { results, error in
            if error != nil {
                print("Autocomplete error \(error?.localizedDescription ?? "")")
                self.googleLocationTableV.isHidden = true
                return
            }
            if results?.count == 0 || results == nil {
                self.googleLocationTableV.isHidden  = true
                self.savedLocationTableV.isHidden = false
            } else {
                self.googlePlacesArray = [Any]() as NSArray
                self.googlePlacesArray = results! as NSArray
                self.googleLocationTableV.isHidden  = false
                self.savedLocationTableV.isHidden = true
                self.googleLocationTableV.reloadData()
            }
        }
//        placesClient.findAutocompletePredictions(location!, bounds: nil, filter: filter, callback: { results, error in
//            if error != nil {
//                print("Autocomplete error \(error?.localizedDescription ?? "")")
//                self.googleLocationTableV.isHidden = true
//                return
//            }
//            if results?.count == 0 || results == nil {
//                self.googleLocationTableV.isHidden  = true
//                self.savedLocationTableV.isHidden = false
//            } else {
//                self.googlePlacesArray = [Any]() as NSArray
//                self.googlePlacesArray = results! as NSArray
//                self.googleLocationTableV.isHidden  = false
//                self.savedLocationTableV.isHidden = true
//                self.googleLocationTableV.reloadData()
//            }
//        })
    }

    //MARK: - Add New Address API
    
   /* func addNewAddressAPI(formatedArress: String , latitudeValue: Any , longitudeValue: Any)  {
        
        let params = ["address_type":"customer_search","address_line1":formatedArress,"latitude":latitudeValue,"longitude":longitudeValue,"linked_id":userDataModel.user_id!] as [String : Any]
        
        print(params)
       
            // url = api_name.ADDRESS_API
            WebService.requestPostUrl(strURL: KAddress_Api , params: params as NSDictionary, is_loader_required: true, success: { (response) in
                
                if response["status_code"] as! NSNumber == 1
                {
                    print(response)
                   
                }
                else
                {
                   // COMMON_ALERT.showAlert(title: "", msg: response["message"] as! String, onView: self)
                   // return
                }
            }) { (failure) in
                // COMMON_ALERT.showAlert(msg: "Request Time Out !")
            }
    }
    */
   /* func addressSerachApiCall() {
        
        WebService.requestGetUrl(strURL: KAddress_search_Api + "customer_id=\(userDataModel.user_id!)", is_loader_required: false, success: { (response) in
            print(response)
            
            if (response.value(forKey: "status_code")as! NSNumber) == 1
            {
                let dataDic = response.value(forKey: "data")as! NSDictionary
                
                let userDefaults = UserDefaults.standard
                let arrayData = NSKeyedArchiver.archivedData(withRootObject: dataDic)
                userDefaults.set(arrayData, forKey: "LocationInitialData")
                userDefaults.synchronize()
                
                self.recentSerchList = dataDic.value(forKey: "recent_search")as! NSArray
                self.savedLocationList = dataDic.value(forKey: "save_address")as! NSArray
                self.savedLocationTableV.reloadData()
            }
            else
            {
                COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
            }
            
        }) { (failure) in
            
        }
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
