//
//  HomeVC.swift
//  SRAA3
//
//  Created by Apple on 19/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import CoreLocation

class HomeVC: UIViewController , UITableViewDelegate , UITableViewDataSource ,iCarouselDataSource, iCarouselDelegate , UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout ,UITextFieldDelegate  {
    
    var geocoder = CLGeocoder()
    
    private let refreshControl = UIRefreshControl()
    
    var current_bannerIndex = 0
    
    var showCitiesBool = false
    var notificationCount = ""
    
    @IBOutlet weak var notificationBadgeLbl: UILabel!
    @IBOutlet weak var headerLocationLbl: UILabel!
    @IBOutlet weak var serviceNotAvailableV: UIView!
    
    @IBOutlet weak var searchBackV: UIView!
    
    @IBOutlet weak var citiesBackV: UIView!
    @IBOutlet weak var citiesTableV: UITableView!
    @IBOutlet weak var subCategoryBackV: UIView!
    
    @IBOutlet weak var searchTxtF: UITextField!
    
    @IBOutlet weak var noDataV: UIView!
    @IBOutlet weak var tableV: UITableView!
    
    @IBOutlet weak var subcategoryTableV: UITableView!
    
    var arrayReponse = NSMutableArray.init()
    
    var allSubCategories = NSMutableArray.init()
    
    var sortedSubCategories = NSArray.init()
    
     var citiesArray = NSArray.init()
    
    var jsonArray = NSMutableArray.init()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableV.rowHeight = UITableViewAutomaticDimension
        self.tableV.estimatedRowHeight = 80
        self.tableV.tableFooterView = UIView(frame: .zero)
        
        self.subcategoryTableV.rowHeight = UITableViewAutomaticDimension
        self.subcategoryTableV.estimatedRowHeight = 50
        self.subcategoryTableV.tableFooterView = UIView(frame: .zero)
        
        self.citiesTableV.rowHeight = UITableViewAutomaticDimension
        self.citiesTableV.estimatedRowHeight = 50
        self.citiesTableV.tableFooterView = UIView(frame: .zero)
        
        searchBackV.layer.borderWidth = 1
        searchBackV.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        searchBackV.layer.cornerRadius = 8
        current_bannerIndex = 0
        let userDefaults = UserDefaults.standard
        if #available(iOS 10.0, *) {
            tableV.refreshControl = refreshControl
        } else {
            tableV.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        if userDefaults.object(forKey: "HomePageInitialData") != nil {
           
            let retriveArrayData = UserDefaults.standard.object(forKey:  "HomePageInitialData") as? NSData
            
            let arr = NSKeyedUnarchiver.unarchiveObject(with: retriveArrayData! as Data) as? NSArray
            arrayReponse = NSMutableArray.init()
            arrayReponse = (arr)?.mutableCopy() as! NSMutableArray
            
            self.tableV.reloadData()
        }
        else
        {
            CommonClass.StartLoader()
        }
        getCitiesDataApiCall()
//        getBannersDataApiCall()
        self.automaticallyAdjustsScrollViewInsets = false
      //  getLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(locationSelected), name: Notification.Name("locationSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getLocation), name: Notification.Name("selectCurrentLocation"), object: nil)
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func refreshData(_ sender: Any) {
        
        getBannersDataApiCall()
    }
    
    @IBAction func notificationBadgeButton(_ sender: UIButton) {
      
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
    
    @IBOutlet weak var notificationBadgeButton: UIButton!
    @objc func locationSelected()  {
        
        print("selected pickup \(selectedAddressDic)")
        
        self.headerLocationLbl.text = selectedAddressDic.value(forKey: "address")as? String
    }
    
    @objc func getLocation()  {
        var placemark: CLPlacemark!

        let ceo = CLGeocoder()
        let loc = CLLocation(latitude: currentLati, longitude: currentLongi)
        ceo.reverseGeocodeLocation(loc, completionHandler: { placemarks, error in
            placemark = placemarks?[0]
            
            if (placemark != nil) {
                if let aDictionary = placemark.addressDictionary {
                  //  print("addressDictionary \(aDictionary)")
                    if let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String]
                    {
                            self.headerLocationLbl.text =  addrList.joined(separator: ", ")
                           // selectedPickupAddressDic.setValue(loc.coordinate.latitude, forKey: "lati")
                           // selectedPickupAddressDic.setValue(loc.coordinate.longitude, forKey: "longi")
                           // selectedPickupAddressDic.setValue(self.pickupAddressTxtF.text, forKey: "address")
                    }
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.searchTxtF.text = ""
        self.serviceNotAvailableV.isHidden = true
        self.subcategoryTableV.isHidden = true
        self.subCategoryBackV.isHidden = true
        self.sortedSubCategories = self.allSubCategories
        
        let userDefaults = UserDefaults.standard
        
        let selectedCity = CommonClass.checkForNull(string: userDefaults.value(forKey: "selectedCity") as AnyObject)
        
        if selectedCity.isEmpty{
            self.headerLocationLbl.text = "Chandigarh"
        }
        else
        {
            self.headerLocationLbl.text = selectedCity
        }
        productCartArray.removeAllObjects()
        questionAnswerCartArray = NSMutableArray.init()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - IBActions ------------ //
    
    @objc func guaranteeBtnAction()
    {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ServiceGuaranteeVC") as! ServiceGuaranteeVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func serachLocationBtnTaped(_ sender: Any) {
      //  let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchLocationVC") as! SearchLocationVC
      //   self.navigationController?.pushViewController(vc, animated: false)
        
        if(self.citiesBackV.isHidden == true)
        {
            self.citiesBackV.isHidden = false
            self.subCategoryBackV.isHidden = true
        }
        else
        {
            self.citiesBackV.isHidden = true
            self.subCategoryBackV.isHidden = true
        }
    }
    
    
    
    // MARK: - Tableview Delegate And DataSource ----------- //
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if (tableView == subcategoryTableV || tableView == citiesTableV) {
            return 1
        }
        
        return self.arrayReponse.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == citiesTableV {
            return citiesArray.count
        }
        
        if tableView == subcategoryTableV {
            print(sortedSubCategories.count)
            return sortedSubCategories.count
        }
        
        let dic = self.arrayReponse.object(at: section)as! NSDictionary
        
        if(dic.value(forKey: "type")as! String == "offers")
        {
            return 1
        }
        if(dic.value(forKey: "type")as! String == "category")
        {
            return 1
        }
        if(dic.value(forKey: "type")as! String == "category_featured"){
        let dataArray = dic.value(forKey: "data")as! NSArray
            print(dataArray.count)
        return dataArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (tableView == subcategoryTableV || tableView == citiesTableV) {
         return 0
        }
        
        if section == 0 {
            return 15
        }
        
        if (section == 1) {
            return 40
        }
        if (section == 2) {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView.init()
        var titleLbl = UILabel.init()
        
        if (tableView == subcategoryTableV || tableView == citiesTableV) {
            return headerView
            
        }
        
        let dic = self.arrayReponse.object(at: section)as! NSDictionary
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        titleLbl = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.size.width - 32, height: 20))
        titleLbl.text = dic.value(forKey: "title")as? String
        
        if(dic.value(forKey: "type")as! String == "category_featured" || dic.value(forKey: "type")as! String == "offers" )
        {
            titleLbl.text = ""
        }
        headerView.backgroundColor = UIColor.white
        titleLbl.font = UIFont(name: KMainFont, size: 16)
        titleLbl.textColor = UIColor.black
        headerView.addSubview(titleLbl)
        
        if section == 2 {
            headerView.backgroundColor = UIColor.hexToColor(hexString: "#F8F8FA")
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (tableView == subcategoryTableV || tableView == citiesTableV) {
            return 0
        }
        if (section == 0 || section == 1) {
            return 0
        }
        return 115
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var footerView = UIView.init()
        
        if (tableView == subcategoryTableV || tableView == citiesTableV) {
           return footerView
        }
        
        if (section == 2)
        {
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 125))
        let button = UIButton(frame: footerView.frame)
        
            button.addTarget(self, action: #selector(guaranteeBtnAction), for: .touchUpInside)
            footerView.addSubview(button)
        let imgV = UIImageView(frame: CGRect(x: 10, y: 5, width: 80, height: 80))
        imgV.image = #imageLiteral(resourceName: "shield")
        imgV.contentMode = .scaleAspectFill
           
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold("SRAA3", size: 18)
                .normal(" KHUSHIYON KI GUARANTEE", size: 18)
            
            
        let titleHeight = getLabelHeight(formattedString.string, withWidth: self.view.frame.size.width - imgV.frame.size.width - 15, withFont: 18, fontName: KMainFont) + 5
            
        let titleLbl = UILabel(frame: CGRect(x: imgV.frame.size.width + 20, y: 15, width: self.view.frame.size.width - (imgV.frame.size.width + 20), height: titleHeight))
        titleLbl.numberOfLines = 0
        titleLbl.attributedText = formattedString
       // titleLbl.font = UIFont(name: KMainFont, size: 18)
        titleLbl.textColor = UIColor.black
        titleLbl.sizeToFit()
            
        let desLbl = UILabel(frame: CGRect(x: titleLbl.frame.origin.x, y: titleHeight + 5, width: self.view.frame.size.width - 66, height: 30))
        desLbl.text = "Know More"
        desLbl.numberOfLines = 0
        desLbl.font = UIFont(name: KMainFontSemiBold, size: 13)
        desLbl.textColor = UIColor.black
        footerView.backgroundColor = UIColor.white
       
        footerView.addSubview(titleLbl)
        footerView.addSubview(desLbl)
        footerView.addSubview(imgV)
        return footerView
            
        }
        
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0))
        footerView.backgroundColor = UIColor.white
        return footerView
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == subcategoryTableV || tableView == citiesTableV {
            return UITableViewAutomaticDimension
        }
        
        let dic = self.arrayReponse.object(at: indexPath.section)as! NSDictionary
        
        if (dic.value(forKey: "type")as! String == "category") {
           
            let dataArray = dic.value(forKey: "data")as! NSArray
            let i = Float(dataArray.count)
            let f: Float = Float(i/3)
            let valueRounded = Int(f.rounded(.up))
            let cellWidth = Int(tableV.frame.size.width / 3)
            return (CGFloat(valueRounded * cellWidth) - CGFloat((valueRounded)))
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == citiesTableV {
            let dic = self.citiesArray.object(at: indexPath.row)as! NSDictionary
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            if cell.isEqual(nil)
            {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            
            cell.textLabel?.font = UIFont(name: KMainFont, size: 15)
            cell.textLabel?.text = dic.value(forKey: "name")as? String
            //     cell.accessoryType = .disclosureIndicator
            
            cell.selectionStyle = .none
            return cell
        }
        
        if tableView == subcategoryTableV {
          
             let dic = self.sortedSubCategories.object(at: indexPath.row)as! NSDictionary
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            if cell.isEqual(nil)
            {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            
            cell.textLabel?.font = UIFont(name: KMainFont, size: 15)
            cell.textLabel?.text = dic.value(forKey: "category_title")as? String
       //     cell.accessoryType = .disclosureIndicator
           
            cell.selectionStyle = .none
            return cell
            
        }
        
        let dic = self.arrayReponse.object(at: indexPath.section)as! NSDictionary
        
        if (dic.value(forKey: "type")as! String == "offers") {
        let identifier = "BannersCell"
        
        var cell: BannersCell! = tableView.dequeueReusableCell(withIdentifier: identifier)as? BannersCell
        if cell == nil {
            var nib = Bundle.main.loadNibNamed("BannersCell", owner: self, options: nil)
            cell = nib![0] as? BannersCell
        }
        cell.selectionStyle = .none
            
        let dataArray = dic.value(forKey: "data")as! NSArray
            
        cell.pageControllerV.numberOfPages = dataArray.count
        cell.pageControllerV.currentPage = current_bannerIndex
        cell.pageControllerV.addTarget(self, action: #selector(self.pageChanged(sender:)), for: UIControl.Event.valueChanged)
        cell.carousel.type = .custom
        cell.carousel.tag = indexPath.section
        cell.carousel.isPagingEnabled = true
        cell.carousel.decelerationRate = 0.99
          
        cell.carousel.bounceDistance = 0.3
        cell.carousel.delegate = self
        cell.carousel.dataSource = self
        cell.carousel.reloadData()
        return cell
        }
        
        if (dic.value(forKey: "type")as! String == "category") {
            let identifier = "CategoriesTableCell"
            var cell: CategoriesTableCell! = tableView.dequeueReusableCell(withIdentifier: identifier)as? CategoriesTableCell
            if cell == nil {
                var nib = Bundle.main.loadNibNamed("CategoriesTableCell", owner: self, options: nil)
                cell = nib![0] as? CategoriesTableCell
            }
            cell.selectionStyle = .none
            cell.collectionV.register(UINib.init(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
            cell.collectionV.tag = indexPath.section
            cell.collectionV.delegate = self
            cell.collectionV.dataSource = self
            cell.collectionV.reloadData()
            return cell
        }
        else{
        let identifier = "SubCategoryCell"
        var cell: SubCategoryCell! = tableView.dequeueReusableCell(withIdentifier: identifier)as? SubCategoryCell
        if cell == nil {
            var nib = Bundle.main.loadNibNamed("SubCategoryCell", owner: self, options: nil)
            cell = nib![0] as? SubCategoryCell
        }
        cell.selectionStyle = .none
            
        let dataArray = dic.value(forKey: "data")as! NSArray
        let dataDic = dataArray[indexPath.row] as! NSDictionary
            
       // Utilities.shadowLayerToCollectionCell(viewLayer: cell.backV.layer, shadow: true)
        //    cell.backV.layer.cornerRadius = 3
       // let imageUrl = URL(string: BASE_IMAGE_URL + KCategory_Api + "/" + (dataDic["category_photo"]as! String))
       let imageUrl = URL(string: BASE_IMAGE_URL + KCategory_Api + "/" + (dataDic["category_photo"]as! String))
        cell.imgV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_item"), options: .refreshCached, completed: nil)
        cell.imgV.layer.cornerRadius = 5
        cell.imgV.clipsToBounds = true
        cell.titleLbl.text = dataDic.value(forKey: "category_title") as? String
        cell.desLbl.text = dataDic.value(forKey: "description") as? String
        return cell
        }
    }
    
    @objc func pageChanged(sender:AnyObject)
    {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        let cell = self.tableV.cellForRow(at: indexPath as IndexPath) as! BannersCell
        cell.carousel.currentItemIndex = cell.pageControllerV.currentPage
        print(cell.pageControllerV.currentPage)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         if tableView == citiesTableV {
            
            let dataDic = self.citiesArray.object(at: indexPath.row)as! NSDictionary
            
            let activeStr = CommonClass.checkForNull(string: dataDic.value(forKey: "active") as AnyObject)
            
            if(activeStr == "0")
            {
                self.noDataV.isHidden = false
                self.tableV.isHidden = true
            }
            else{
                self.noDataV.isHidden = true
                self.tableV.isHidden = false
                UserDefaults.standard.setValue((dataDic.value(forKey: "name") as! String), forKey: "selectedCity")
                UserDefaults.standard.setValue(CommonClass.checkForNull(string: dataDic.value(forKey: "city_id") as AnyObject), forKey: "city_id")
            }
            
            self.headerLocationLbl.text = (dataDic.value(forKey: "name") as! String)
            city_id = CommonClass.checkForNull(string: dataDic.value(forKey: "city_id") as AnyObject)
            self.citiesBackV.isHidden = true
            self.getBannersDataApiCall()
         }
        
        if tableView == subcategoryTableV {
            
            self.subCategoryBackV.isHidden = true
            self.searchTxtF.resignFirstResponder()
            let dataDic = self.sortedSubCategories.object(at: indexPath.row)as! NSDictionary
//            let formIdStr = CommonClass.checkForNull(string:  dataDic.value(forKey: "form_id") as AnyObject)
//
//            if (formIdStr == "0") {
//                KFormId = ""
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemsVC") as! ItemsVC
//                vc.category_id = CommonClass.checkForNull(string:dataDic.value(forKey: "category_id")as AnyObject)
//                vc.category_title = CommonClass.checkForNull(string:dataDic.value(forKey: "category_title")as AnyObject)
//                vc.category_photo = CommonClass.checkForNull(string:dataDic.value(forKey: "category_photo")as AnyObject)
//                self.navigationController?.pushViewController(vc, animated: false)
//            }
//            else
//            {
//                KFormId = formIdStr
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "QuestionAnswerVC") as! QuestionAnswerVC
//                vc.category_id = CommonClass.checkForNull(string:dataDic.value(forKey: "category_id")as AnyObject)
//                vc.category_title = CommonClass.checkForNull(string:dataDic.value(forKey: "category_title")as AnyObject)
//                vc.category_photo = CommonClass.checkForNull(string:dataDic.value(forKey: "category_photo")as AnyObject)
//                self.navigationController?.pushViewController(vc, animated: false)
//            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServiceDescriptionVC") as! ServiceDescriptionVC
            print(dataDic)
            vc.categoryDic = dataDic
            vc.directService = true
            vc.currentServiceName = (dataDic.value(forKey: "category_title") as? String)!
            self.navigationController?.pushViewController(vc, animated: false)
            
        }
        
        if indexPath.section == 2 {
            
          let dic = self.arrayReponse.object(at: indexPath.section)as! NSDictionary
            
            let dataArray = dic.value(forKey: "data")as! NSArray
            
            let dataDic = dataArray.object(at: indexPath.row)as! NSDictionary
            
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServiceDescriptionVC") as! ServiceDescriptionVC
            print(dataDic)
            vc.categoryDic = dataDic
            vc.directService = true
            vc.currentServiceName = (dataDic.value(forKey: "category_title") as? String)!
            self.navigationController?.pushViewController(vc, animated: false)
            
            
//            let formIdStr = CommonClass.checkForNull(string:  dataDic.value(forKey: "form_id") as AnyObject)
//            
//            if (formIdStr == "0") {
//                KFormId = ""
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemsVC") as! ItemsVC
//                vc.category_id = CommonClass.checkForNull(string:dataDic.value(forKey: "category_id")as AnyObject)
//                vc.category_title = CommonClass.checkForNull(string:dataDic.value(forKey: "category_title")as AnyObject)
//                vc.category_photo = CommonClass.checkForNull(string:dataDic.value(forKey: "category_photo")as AnyObject)
//                self.navigationController?.pushViewController(vc, animated: false)
//            }
//            else
//            {
//                KFormId = formIdStr
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "QuestionAnswerVC") as! QuestionAnswerVC
//                vc.category_id = CommonClass.checkForNull(string:dataDic.value(forKey: "category_id")as AnyObject)
//                vc.category_title = CommonClass.checkForNull(string:dataDic.value(forKey: "category_title")as AnyObject)
//                vc.category_photo = CommonClass.checkForNull(string:dataDic.value(forKey: "category_photo")as AnyObject)
//                self.navigationController?.pushViewController(vc, animated: false)
//            }
        }
    }
    
   // MARK: - CollectionVoew Delegate and datasource ---------- //
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let dic = self.arrayReponse.object(at: collectionView.tag)as! NSDictionary
        
        let type = dic.value(forKey: "type")as! String
        
        if (type == "category") {
        
        let dataArray = dic.value(forKey: "data")as! NSArray
        
        return dataArray.count
            
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CategoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        let dic = self.arrayReponse.object(at: collectionView.tag) as! NSDictionary
        
        let dataArray = dic.value(forKey: "data")as! NSArray
        
        let dataDic = dataArray.object(at: indexPath.row)as! NSDictionary
        
        cell.titleLbl.text = dataDic.value(forKey: "category_title") as? String
        //  cell.titleLbl.sizeToFit()
        //  cell.titleLbl.textAlignment = .center
        let imageUrl = URL(string: BASE_IMAGE_URL + KCategory_Api + "/" + (dataDic["category_photo"]as! String))
        
        cell.imgV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_item"), options: .refreshCached, completed: nil)
        
      //  Utilities.shadowLayerWithLightColor(viewLayer: cell.backV.layer, shadow: true)
        
      //  cell.backV.layer.cornerRadius = 3
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cellWidth = (tableV.frame.size.width / 3 ) - 2
        
        return CGSize(width: cellWidth + 1, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dic = self.arrayReponse.object(at: collectionView.tag)as! NSDictionary
        
        let dataArray = dic.value(forKey: "data")as! NSArray
        
        let dataDic = dataArray.object(at: indexPath.row)as! NSDictionary
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServiceDescriptionVC") as! ServiceDescriptionVC
        print(dataDic)
        vc.categoryDic = dataDic
        vc.directService = false
        vc.currentServiceName = (dataDic.value(forKey: "category_title") as? String)!
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    // MARK: - CAROUSAL Delegate and datasource ---------- //
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        
        let dic = self.arrayReponse.object(at: carousel.tag)as! NSDictionary
        let dataArray = dic.value(forKey: "data")as! NSArray
        return dataArray.count
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.01
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
      //  print(index)
    }
    
    func carouselDidScroll(_ carousel: iCarousel) {
       let indexPath = IndexPath(row: carousel.tag, section: 0)
       
        guard let cell = self.tableV.cellForRow(at: indexPath) as? BannersCell else {
            
            return }
        
        cell.pageControllerV.currentPage = carousel.currentItemIndex
        current_bannerIndex = carousel.currentItemIndex
        
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let dic = self.arrayReponse.object(at: carousel.tag)as! NSDictionary
        
        let dataArray = dic.value(forKey: "data")as! NSArray
        
        let dataDic = dataArray.object(at: index)as! NSDictionary
        
        var cardV = BannerView()
        
        cardV = Bundle.main.loadNibNamed("BannerView", owner: self, options: nil)?.first as! BannerView
        
        cardV.frame = CGRect(x: 0, y: 0, width: carousel.frame.size.width - 30 , height: carousel.frame.size.height)
        
        let imageUrl = URL(string: BASE_IMAGE_URL + KBanners_Api + "/" + (dataDic["photo"]as! String))
        
        cardV.imgV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .cacheMemoryOnly, completed: nil)
        
        cardV.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.12).cgColor
        cardV.layer.cornerRadius = 8
        cardV.layer.borderWidth = 1.5
        cardV.imgV.contentMode = .scaleToFill
        cardV.clipsToBounds = true
        return cardV
    }
    
    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        
        let centerItemZoom: CGFloat = 1.1
        let centerItemSpacing: CGFloat = 1.12
        
        let spacing: CGFloat = self.carousel(carousel, valueFor: .spacing, withDefault: 0.95)
        let absClampedOffset = min(1.0, fabs(offset))
        let clampedOffset = min(1.0, max(-1.0, offset))
        let scaleFactor = 1.0 + absClampedOffset * (1.0/centerItemZoom - 1.0)
        let offset = (scaleFactor * offset + scaleFactor * (centerItemSpacing - 1.0) * clampedOffset) * carousel.itemWidth * spacing
        var transform = CATransform3DTranslate(transform, offset, 0.0, -absClampedOffset)
        transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0)
        
        return transform;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Api Call
    
    func getCitiesDataApiCall() {
        
        WebService.requestGetUrl(strURL: "api/v1/" + KCity_Api, is_loader_required: false, success: { (response) in
         
            print(response)
            if (response.value(forKey: "status_code")as! NSNumber) == 1
            {
                print("cities response----------------")
                let dataDic = (response.value(forKey: "data")as! NSDictionary)
                
                self.citiesArray = dataDic.value(forKey: "data")as! NSArray
                let selectedCity_Id = CommonClass.checkForNull(string: UserDefaults.standard.value(forKey: "city_id") as AnyObject)
                
                city_id = selectedCity_Id.isEmpty ? CommonClass.checkForNull(string: (self.citiesArray[0] as! NSDictionary)["city_id"] as AnyObject) : selectedCity_Id
//                city_id = CommonClass.checkForNull(string: (self.citiesArray[0] as! NSDictionary)["city_id"] as AnyObject)
                self.citiesTableV.reloadData()
                self.getBannersDataApiCall()
            }
            else
            {
               // COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
            }
        }) { (failure) in
            
        }
    }
    
    func getBannersDataApiCall() {
        
        WebService.requestGetUrl(strURL: RBanners_Api + "?type=mobile&per_page=20", is_loader_required: false, success: { (response) in
            print(response)
            
            self.jsonArray = NSMutableArray.init()
            if (response.value(forKey: "status_code")as! NSNumber) == 1
            {
                print(self.jsonArray.count)
                self.notificationCount = CommonClass.checkForNull(string: response["notification_count"]  as AnyObject)
                print("Banners response----------------")
                let dataDic = response["data"] as! NSDictionary
                let array = (dataDic["data"]as! NSArray)
                
                if(dataDic["data"] != nil)
                {
                    
                   // print("Banner Data: \(array)")
                    
                    self.jsonArray.add(NSDictionary(dictionaryLiteral: ("data",array),("title","Offers"),("type", "offers")))
                    print("Json offers: \(self.jsonArray)")
                    
                }
                self.getCategoriesDataApiCall()
//                self.getSubCategoryDataApiCall()
               // self.tableV.reloadData()
                DispatchQueue.main.async {
                    if self.notificationCount.isEmpty || self.notificationCount == "0"
                    {
                        self.notificationBadgeLbl.isHidden = true
                        self.notificationBadgeButton.isUserInteractionEnabled = true
                    }
                    else
                    {
                        self.notificationBadgeLbl.text = self.notificationCount
                        self.notificationBadgeLbl.isHidden = false
                        self.notificationBadgeButton.isUserInteractionEnabled = true
                    }
                }
            }
            else
            {
                COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
            }
        }) { (failure) in
            
        }
    }
    
    func getCategoriesDataApiCall() {
        print(city_id)
        self.allSubCategories.removeAllObjects()
        self.sortedSubCategories = NSArray.init()
        WebService.requestGetUrl(strURL: RCategories_Api + "?city_id=\(city_id)", is_loader_required: false) { (response) in
            print(response)
            if (response.value(forKey: "status_code")as! NSNumber) == 1
            {
                let array = (response["data"]as! NSArray)
                print("Sub category response----------------")
                
                self.noDataV.isHidden = array.count > 0 ? true : false
            
                self.jsonArray.add(NSDictionary(dictionaryLiteral: ("data",(response["data"]as! NSArray)),("title","Categories"),("type", "category")))
                
                 print("Json : \(self.jsonArray)")
                
                 DispatchQueue.main.async {

                    for (_,dataDic) in (array.enumerated()) {

                let subcategoryArray  = (dataDic as! NSDictionary).value(forKey: "r_subcategory")as! NSArray

                    for (_,dic) in (subcategoryArray.enumerated()) {
                        self.allSubCategories.add(dic)
                    }
                }
                    self.sortedSubCategories = self.allSubCategories
                    print(self.sortedSubCategories.count)
                  //  print("Subcategories count-----\(self.allSubCategories.count)")

                }
                print(self.jsonArray.count)
                self.getCategoryTagsDataApiCall()
            }
            else
            {
                self.noDataV.isHidden = false
            }
        } failure: { (error) in
            print(error)
        }

    }
    
//    func getSubCategoryDataApiCall() {
//        self.allSubCategories.removeAllObjects()
//        WebService.requestGetUrl(strURL: "api/v1/" + KSub_Category_Api + "?" + "include_subcategories=true" , is_loader_required: false, success: { (response) in
//           // print(response)
//
//            if (response.value(forKey: "status_code")as! NSNumber) == 1
//            {
//                let array = (response["data"]as! NSArray)
//                print("Sub category response----------------")
//
//                self.jsonArray.add(NSDictionary(dictionaryLiteral: ("data",(response["data"]as! NSArray)),("title","Categories"),("type", "category")))
//
//                 print("Json : \(self.jsonArray)")
//
//                 DispatchQueue.main.async {
//
//                    for (_,dataDic) in (array.enumerated()) {
//
//                let subcategoryArray  = (dataDic as! NSDictionary).value(forKey: "subcategories")as! NSArray
//
//                    for (_,dic) in (subcategoryArray.enumerated()) {
//                        self.allSubCategories.add(dic)
//                    }
//                }
//                    self.sortedSubCategories = self.allSubCategories
//                  //  print("Subcategories count-----\(self.allSubCategories.count)")
//
//                }
//
//                self.getCategoryTagsDataApiCall()
//               // self.tableV.reloadData()
//            }
//            else
//            {
//                COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
//            }
//        }) { (failure) in
//
//        }
//    }
    
    func getCategoryTagsDataApiCall() {
        WebService.requestGetUrl(strURL: RSubcategories_Api + "?tags=featured&city_id=\(city_id)&per_page=3" , is_loader_required: false, success: { (response) in
            print(response)
            self.refreshControl.endRefreshing()
            CommonClass.StopLoader()
            if (response.value(forKey: "status_code")as! NSNumber) == 1
            {
                print("Category response----------------")
                
                let dataArray = response["data"] as! NSArray
               // print("Data: \(dataDic)")
                
                self.jsonArray.add(NSDictionary(dictionaryLiteral: ("data",dataArray),("title","Category Featured"),("type", "category_featured")))
                let userDefaults = UserDefaults.standard
                let arrayData = NSKeyedArchiver.archivedData(withRootObject: self.jsonArray)
                userDefaults.set(arrayData, forKey: "HomePageInitialData")
                DispatchQueue.main.async {
                    
                if userDefaults.object(forKey: "HomePageInitialData") != nil {
                    
                    let retriveArrayData = UserDefaults.standard.object(forKey:  "HomePageInitialData") as? NSData
                    
                    let arr = NSKeyedUnarchiver.unarchiveObject(with: retriveArrayData! as Data) as? NSArray
                    self.arrayReponse = NSMutableArray.init()
                    self.arrayReponse = (arr)?.mutableCopy() as! NSMutableArray
                    
                    print("arrray :=====\(self.arrayReponse)")
                    
                    self.tableV.reloadData()
                }
                    
                }
            }
            else
            {
                print(self.jsonArray.count)
                let userDefaults = UserDefaults.standard
                let arrayData = NSKeyedArchiver.archivedData(withRootObject: self.jsonArray)
                userDefaults.set(arrayData, forKey: "HomePageInitialData")
                if userDefaults.object(forKey: "HomePageInitialData") != nil {
                    
                    let retriveArrayData = UserDefaults.standard.object(forKey:  "HomePageInitialData") as? NSData
                    
                    let arr = NSKeyedUnarchiver.unarchiveObject(with: retriveArrayData! as Data) as? NSArray
                    self.arrayReponse = NSMutableArray.init()
                    self.arrayReponse = (arr)?.mutableCopy() as! NSMutableArray
                    
                    print("arrray :=====\(self.arrayReponse)")
                    
                    self.tableV.reloadData()
                }
                DispatchQueue.main.async {
                    self.tableV.reloadData()
                }
                COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
            }
        }) { (failure) in
            
        }
    }
    
    // MARK: - TextField Delegate
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        print(newString)
        
        var subArray = NSArray.init()
//        for item in jsonArray {
//            if (item as! NSDictionary)["type"] as! String == "category_featured" {
//                subArray = (item as! NSDictionary)["data"] as! NSArray
//            }
//        }
        if(newString.isEmpty)
        {
            self.sortedSubCategories = self.allSubCategories
            self.subcategoryTableV.isHidden = false
            self.subCategoryBackV.isHidden = true
            self.serviceNotAvailableV.isHidden = true
        }
        else
        {
          let pre:NSPredicate = NSPredicate(format: "category_title contains[c] %@", newString)
          sortedSubCategories = allSubCategories.filtered(using: pre) as NSArray
          self.subcategoryTableV.reloadData()
        
            if(sortedSubCategories.count == 0)
            {
                self.subCategoryBackV.isHidden = false
                self.serviceNotAvailableV.isHidden = false
                self.subcategoryTableV.isHidden = true
            }
         else
            {
                self.serviceNotAvailableV.isHidden = true
                self.subcategoryTableV.isHidden = false
                self.subCategoryBackV.isHidden = false
            }
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.searchTxtF.text = ""
        self.subCategoryBackV.isHidden = true
        self.citiesBackV.isHidden = true
        self.serviceNotAvailableV.isHidden = true
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //self.subCategoryBackV.isHidden = false
        self.subCategoryBackV.isHidden = true
        self.sortedSubCategories = NSArray.init()
//        self.subcategoryTableV.isHidden = false
        self.serviceNotAvailableV.isHidden = true
        self.subcategoryTableV.reloadData()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            if touch.view == self.subCategoryBackV  {
                self.subCategoryBackV.isHidden = true
                self.searchTxtF.text = ""
                self.sortedSubCategories = allSubCategories
            }
            if touch.view == self.citiesBackV {
                self.citiesBackV.isHidden = true
            }
            else
            {
                 self.subCategoryBackV.isHidden = true
                 self.citiesBackV.isHidden = true
            }
        }
        super.touchesBegan(touches, with: event)
    }
}

extension String {
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes:[.font: font])
    }
}
