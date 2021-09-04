//
//  AddNewAddressVC.swift
//  FoodApplication
//
//  Created by Kishore on 17/07/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class AddNewAddressVC: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate {
    
    @IBAction func doneButton(_ sender: UIButton) {
      
        let (isValid,title) = self.isValid()
        if isValid == true {
          //  self.navigationController?.popViewController(animated: true)
            addNewAddressAPI()
        }
        else
        {
            DispatchQueue.main.async {
                COMMON_ALERT.showAlert(title: title , msg: "", onView: self) }
        }
    }
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var navLbl: UILabel!
    var countryStr = ""
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    
    var placesClient: GMSPlacesClient!
    
    @IBAction func homeButton(_ sender: UIButton) {
        workButton.backgroundColor = .white
        otherButton.backgroundColor = .white
        otherButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
        workButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
        sender.backgroundColor = UIColor.KMainColorCode
        sender.setTitleColor(.white, for: .normal)
        address_title = "Home"
    }
    
    @IBAction func workButton(_ sender: UIButton) {
        homeButton.backgroundColor = .white
        otherButton.backgroundColor = .white
        otherButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
        homeButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
         sender.backgroundColor = UIColor.KMainColorCode
        sender.setTitleColor(.white, for: .normal)
        address_title = "Work"
    }
    
    @IBAction func otherButton(_ sender: UIButton) {
        homeButton.backgroundColor = .white
        workButton.backgroundColor = .white
        workButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
        homeButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
        sender.backgroundColor = UIColor.KMainColorCode
        sender.setTitleColor(.white, for: .normal)
        address_title = "Other"
    }
    
     var isDataSet = false
   
    var address_title = "Home"
   
    var address_latitude = 0.0
    var address_longitude = 0.0
    
    var isDefaultAddress = false
    var model = AddressListModel()
    var isForAddressEditing = false
    
    @IBOutlet weak var stateTxtField: UITextField!
    @IBOutlet weak var cityTownTxtField: UITextField!
    @IBOutlet weak var pincodeTxtField: UITextField!
    @IBOutlet weak var addressLine2TxtField: UITextField!
    @IBOutlet weak var addressLine1TxtField: UITextField!
    @IBOutlet weak var googleMapiew: GMSMapView!
    var locationManager = CLLocationManager()
    var user_current_location = ""
    var marker = GMSMarker()
    
    @IBOutlet weak var markerImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.googleMapiew?.isMyLocationEnabled = true
        self.googleMapiew.padding = UIEdgeInsetsMake(0, 0, 15, 0)
        //Location Manager code to fetch current location
       
        var currentPosition:CLLocationCoordinate2D!
        print(isForAddressEditing)
        if isForAddressEditing {
            
            let old_latitude = Double(model.latitude)
            let old_longitude = Double(model.longitude)
            currentPosition = CLLocationCoordinate2D(latitude: old_latitude!, longitude: old_longitude!)
            
            workButton.backgroundColor = .white
            otherButton.backgroundColor = .white
            otherButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
            workButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
            homeButton.backgroundColor = UIColor.KMainColorCode
            homeButton.setTitleColor(.white, for: .normal)
            print("selectedAddresssssss:\(model)")
            
            address_title = model.title
            
            if(address_title == "Work")
            {
                homeButton.backgroundColor = .white
                otherButton.backgroundColor = .white
                otherButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
                homeButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
                workButton.backgroundColor = UIColor.KMainColorCode
                workButton.setTitleColor(.white, for: .normal)
            }
            else if (address_title == "Home")
            {
                workButton.backgroundColor = .white
                otherButton.backgroundColor = .white
                otherButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
                workButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
                homeButton.backgroundColor = UIColor.KMainColorCode
                homeButton.setTitleColor(.white, for: .normal)
            }
            else
            {
                homeButton.backgroundColor = .white
                workButton.backgroundColor = .white
                workButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
                homeButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
                otherButton.backgroundColor = UIColor.KMainColorCode
                otherButton.setTitleColor(.white, for: .normal)
            }
        }
        else
        {
            currentPosition = CLLocationCoordinate2D(latitude: Double(currentLati), longitude: Double(currentLongi))
            workButton.backgroundColor = .white
            otherButton.backgroundColor = .white
            otherButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
            workButton.setTitleColor(UIColor.KMainColorCode, for: .normal)
            homeButton.backgroundColor = UIColor.KMainColorCode
            homeButton.setTitleColor(.white, for: .normal)
        }
       
        var googleMapCamera = GMSCameraPosition.camera(withTarget: currentPosition, zoom: 20)
        googleMapiew.camera = googleMapCamera
        googleMapiew.settings.myLocationButton = true
        googleMapiew.isMyLocationEnabled = true
        googleMapiew.delegate = self
        googleMapiew.mapType = .normal
        googleMapCamera = GMSCameraPosition(target: currentPosition, zoom: 14, bearing: 0.0, viewingAngle: 0.0)
        
        googleMapiew.animate(to: googleMapCamera)
        self.googleMapiew.bringSubview(toFront: markerImageView)
        self.locationManager.delegate = self
        locationManager.startUpdatingLocation()
        placesClient = GMSPlacesClient.shared()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        if isForAddressEditing {
            self.setTextFieldsValue()
            self.navLbl.text = "Update Address"
            self.doneButton.setTitle("UPDATE ADDRESS", for: .normal)
        }
        else
        {
           self.isDataSet = true
           self.navLbl.text = "Add Address"
            self.doneButton.setTitle("ADD ADDRESS", for: .normal)
        }
        self.homeButton.layer.borderWidth = 1
        self.homeButton.layer.borderColor = UIColor.KMainColorCode.cgColor
        
        self.workButton.layer.borderWidth = 1
        self.workButton.layer.borderColor = UIColor.KMainColorCode.cgColor
        
        self.otherButton.layer.borderWidth = 1
        self.otherButton.layer.borderColor = UIColor.KMainColorCode.cgColor
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        mapView.clear()
        
        print("Position = \(position)")
        
        let point = mapView.center
         print("point = \(point)")
        let mapCoordinate = mapView.projection.coordinate(for: point)
        
        let clGeocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)
        address_latitude = mapCoordinate.latitude
        address_longitude = mapCoordinate.longitude
        clGeocoder.reverseGeocodeLocation(clLocation) { (placemark, error) in
            if error == nil && (placemark?.count)! > 0
            {
                let placemark1 = placemark?.last
                
                print("Placemark = \(placemark1!)")
                print("Street Address = \(placemark1?.thoroughfare ?? "error")")
             
                print("Address Dictionary = \(String(describing: placemark1?.description))")
                print("Address Dictionary = \(String(describing: placemark1?.addressDictionary))")
                var address1 = "   placemark1?.addressDictionary"
                
                    if let name = placemark1?.name
                    {
                         print("\n name \(name)\n")
                         address1 = name
                    }
                
                    if let subLocality = placemark1?.subLocality
                    {
                        print("\n subLocality \(subLocality)\n")
                        address1 +=  " "  + subLocality
                        self.addressLine1TxtField.text = address1
                    }
                        
                    else
                    {
                      self.addressLine1TxtField.text = address1
                    }
                
                    if let locality = placemark1?.locality
                    {
                         print("\n locality \(locality)\n")
                        self.cityTownTxtField.text = locality
                    }
                        
                else
                    {
                        self.cityTownTxtField.text = ""
                    }
                    if let administrativeArea = placemark1?.administrativeArea
                    {
                           print("\n administrativeArea \(administrativeArea)\n")
                          self.stateTxtField.text = administrativeArea
                    }
                else
                    {
                     self.stateTxtField.text = ""
                    }
                    if let country = placemark1?.country
                    {
                          print("\n country \(country)\n")
                        self.countryStr = country
                    }
                
                    if let postalCode = placemark1?.postalCode
                    {
                          print("\n postalCode \(postalCode)\n")
                          self.pincodeTxtField.text = postalCode
                    }
                else
                    {
                       self.pincodeTxtField.text = ""
                    }
            }
            else
            {
                print(error!)
            }
        }
    }
    
    //MARK: - Selector Methods//////////
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: -Set TextFields Value
    func setTextFieldsValue() {
        
        print("saved value : \(model)")
        
         addressLine1TxtField.text = model.line1
         addressLine2TxtField.text = model.line2
         stateTxtField.text = model.state
         cityTownTxtField.text = model.city
         pincodeTxtField.text = model.pincode
        
        isDataSet = true
    }
    
    //MARK: -Check For Validation
    
    func isValid() -> (isValid: Bool,title: String) {
        
        if self.addressLine1TxtField.text?.isEmpty == true
        {
            return (false,"Enter Area, Locality")
        }
        if self.addressLine2TxtField.text?.isEmpty == true
        {
            return (false,"Enter Cabin, Floor")
        }
        if self.pincodeTxtField.text?.isEmpty == true {
            return (false,"Enter Pincode")
        }
        if currentLati.isZero == true {
            return (false,"")
        }
        if currentLongi.isZero == true {
            return (false,"")
        }
        if self.stateTxtField.text?.isEmpty == true {
            return (false,"Enter State Name")
        }
        if self.cityTownTxtField.text?.isEmpty == true {
            return (false,"Enter city or town name")
        }
        return (true,"Congratulations!")
    }
    
    //MARK: - Add New Address API
    
    func addNewAddressAPI()  {
        
        let lati_str = String(address_latitude)
        let longi_str = String(address_longitude)
        print(userDataModel.phone)
        let params = ["address_type":"customer","address_title":address_title,"address_line1":self.addressLine1TxtField.text!,"address_line2":addressLine2TxtField.text!,"address_phone":(userDataModel.phone! != "") ? (userDataModel.phone!) : "","latitude":lati_str,"longitude":longi_str,"city":self.cityTownTxtField.text!,"state":self.stateTxtField.text!,"pincode":self.pincodeTxtField.text!,"country":countryStr,"linked_id":userDataModel.user_id!] as [String : Any]
        
        print(params)
       
        if isForAddressEditing
        {
            let address_id = model.id
            
         //   url = api_name.ADDRESS_API + "/\(address_id)"
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
            self.present(vc, animated: false) {
                WebService.requestPutUrl(strURL: RAddress_Api + "/\(address_id)" , params: params as NSDictionary, is_loader_required: true, success: { (response) in
                    
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                    if response["status_code"] as! NSNumber == 1
                    {
                        print(response)
                        self.alert(title: response["message"] as! String, msg: "")
                    }
                    else
                    {
                        COMMON_ALERT.showAlert(title: "", msg: response["message"] as! String, onView: self)
                        return
                    }
                    
                }) { (failure) in
                  //  COMMON_ALERT.showAlert(msg: "Request Time Out !")
                }
            }
   
        }
        else
        {
           // url = api_name.ADDRESS_API
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
            self.present(vc, animated: false) {
                WebService.requestPostUrl(strURL: RAddress_Api , params: params as NSDictionary, is_loader_required: true, success: { (response) in
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                    if response["status_code"] as! NSNumber == 1
                    {
                        print(response)
                        print(response)
                        let alert = UIAlertController(title: nil, message: (response["message"] as! String), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        let viewController = UIApplication.shared.keyWindow?.rootViewController
                        
                        let popPresenter = alert.popoverPresentationController
                        popPresenter?.sourceView = viewController?.view
                        popPresenter?.sourceRect = (viewController?.view.bounds)!
                        viewController?.present(alert, animated: true, completion: nil)
                    }
                    else
                    {
                        COMMON_ALERT.showAlert(title: "", msg: response["message"] as! String, onView: self)
                        return
                    }
                    
                }) { (failure) in
                   // COMMON_ALERT.showAlert(msg: "Request Time Out !")
                }
            }
           
        }
    }
    
    //MARK: - Show Alert With Option
    
    func alert(title:String,msg:String)   {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.sourceRect = self.view.bounds
        self.present(alert, animated: true, completion: nil)
    }
    
}
