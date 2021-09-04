//
//  HelpAndFAQVC.swift
//  TaxiApp
//
//  Created by Apple on 15/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class HelpAndFAQVC: UIViewController {

    @IBOutlet weak var noDataV: UIView!
    var headerDataArray = NSMutableArray.init()
    var selectedHeader = ""
    var tmpHelpFaqDataArray = NSMutableArray.init()
    var headerCollectionView : UICollectionView!
    @IBOutlet weak var okayButton: UIButton!
    @IBAction func okayButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var noDataView: UIView!
    
    private let refreshControl = UIRefreshControl()
    
    var allFAQDataArray = NSMutableArray.init()
    var allDataDictionary:NSMutableDictionary!
    var currentPage:Int = 1
    var maxPage:Int = 1
    var nextUrl = ""
    
    @IBOutlet weak var tableV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        okayButton.layer.borderWidth = 1
        okayButton.layer.borderColor = UIColor.KMainColorCode.cgColor
        okayButton.layer.cornerRadius = 2
        
        allFAQDataArray = NSMutableArray.init()
        allDataDictionary = NSMutableDictionary.init()
        getFAQAPIData(loader: true, page: 1)
        
        self.tableV.separatorStyle = .none
        
        self.tableV.rowHeight = UITableViewAutomaticDimension
        self.tableV.estimatedRowHeight = 50
        self.tableV!.tableFooterView = UIView()
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        if #available(iOS 10.0, *) {
            tableV.refreshControl = refreshControl
        } else {
            tableV.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
      //  Utilities.shadowLayer1(viewLayer: noDataV.layer, shadow: true)
        tableV.tableHeaderView = getTableViewHeader()
        // Do any additional setup after loading the view.
    }
    
    @objc private func refreshData(_ sender: Any) {
        self.currentPage = 1
       self.getFAQAPIData(loader: false, page: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black]
        
        self.navigationItem.title = "Help & FAQ"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTableViewHeader() -> UIView {
        
        let headerMainView = UIView(frame: CGRect(x: 0, y: 0.0, width: Double(self.view.frame.size.width - 20), height: 140 ))
        
        headerMainView.backgroundColor = .white
        
        let topV = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        
        topV.backgroundColor = UIColor.groupTableViewBackground
        
        headerMainView.addSubview(topV)
        
        let topLbl = UILabel(frame: CGRect(x: 20, y: 20, width: Double(self.view.frame.size.width - 20), height: 24))
        topLbl.font = UIFont(name: KMainFontSemiBold, size: 18)
        topLbl.text = "Top Questions"
        headerMainView.addSubview(topLbl)
        //Collection View Coding
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        headerCollectionView = UICollectionView(frame: CGRect(x: 0, y: 50, width: Double(self.view.frame.size.width), height: 80.0 ), collectionViewLayout: flowLayout)
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        headerCollectionView.showsHorizontalScrollIndicator = false
        headerCollectionView.backgroundColor = UIColor.white
        let nib = UINib(nibName: "SelectionCollectionCell", bundle: nil)
        headerCollectionView.register(nib, forCellWithReuseIdentifier: "SelectionCollectionCell")
        
        headerCollectionView.reloadData()
        
        //if allBannersListData.count > 0 {
        headerMainView.addSubview(headerCollectionView)
        
        //}
        
        return headerMainView
    }
    
    //MARK: - Selector Methods//////////
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Call API
    
    func getFAQAPIData(loader:Bool,page:Int) {
       
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestGetUrl(strURL: RFAQ_Api + "?user_type=1" , is_loader_required: loader, success: { (response) in
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                self.refreshControl.endRefreshing()
                if response["status_code"] as! NSNumber == 1
                {
                    self.tableV.isUserInteractionEnabled = true
                    
                    self.noDataView.isHidden = true
                    if page == 1
                    {
                        self.allFAQDataArray .removeAllObjects()
                        self.currentPage = 1
                    }
                    
                    self.allFAQDataArray .addObjects(from: (( (response["data"] as! NSDictionary).object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray) as! [Any])
                    if self.headerDataArray.count == 0
                    {
                        self.headerDataArray = ((response["header"] as! NSArray).mutableCopy() as! NSMutableArray)
                        for (index,value) in (self.headerDataArray as! [NSDictionary]).enumerated()
                        {
                            let dataDic = value.mutableCopy() as! NSMutableDictionary
                            dataDic["isSelected"] = "0"
                            self.headerDataArray.replaceObject(at: index, with: dataDic)
                        }
                        let newObj = NSDictionary(dictionaryLiteral: ("isSelected", "1"),("title","All"),("type","all"))
                        self.selectedHeader = "all"
                        self.headerDataArray.insert(newObj, at: 0)
                    }
                    
                    if self.allFAQDataArray.count == 0
                    {
                        self.noDataView.isHidden = false
                      
                        return
                    }
                    
                    self.nextUrl = CommonClass.checkForNull(string: ((response["data"] as! NSDictionary).value(forKey: "next_page_url")as AnyObject))
                    self.currentPage = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "current_page") as! NSNumber)
                    self.maxPage = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "last_page") as! NSNumber)
                    
                    self.getFilterData()
                    DispatchQueue.main.async {
                       
                        self.tableV.reloadData()
                    }
                    
                    self.noDataView.isHidden = true
                    
                }else
                {
                    self.tableV.isUserInteractionEnabled = true
                    
                    self.noDataView.isHidden = false
                }
               
            }) { (failure) in
                self.tableV.isUserInteractionEnabled = true
               
            }
        }
       
    }
    
    //MARK: Get Filter Data
    
    func getFilterData()  {
        
        self.tmpHelpFaqDataArray.removeAllObjects()
        if selectedHeader == "all" {
            noDataV.isHidden = true
            self.tmpHelpFaqDataArray = NSMutableArray(array: self.allFAQDataArray)
            self.tableV.reloadData()
            self.headerCollectionView.reloadData()
            return
        }
        for value in self.allFAQDataArray as!  [NSDictionary] {
            
            if value["type"] as! String == selectedHeader
            {
                tmpHelpFaqDataArray.add(value)
            }
        }
        if tmpHelpFaqDataArray.count == 0 {
            self.noDataV.isHidden = false
            
        }
        else
        {
            noDataV.isHidden = true
        }
        self.tableV.reloadData()
        self.headerCollectionView.reloadData()
    }
}

extension HelpAndFAQVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tmpHelpFaqDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "HelpAndFaqCell", bundle: nil), forCellReuseIdentifier: "HelpAndFaqCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpAndFaqCell", for: indexPath) as! HelpAndFaqCell
        cell.titleLbl.text = ((tmpHelpFaqDataArray[indexPath.row] as! NSDictionary)["question"] as! String)
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorV.isHidden = true
        }
        else
        {
            cell.separatorV.isHidden = false
        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if currentPage == maxPage
        {}
        else
        {
            if (indexPath.row == self.allFAQDataArray.count-1)
            {
                if(!nextUrl.isEmpty)
                {
                    currentPage = currentPage + 1
                    self.getFAQAPIData(loader: false, page: (self.currentPage))
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let fieldOptionsDic = (tmpHelpFaqDataArray[indexPath.row] as! NSDictionary)
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FAQQuestionAnswerVC") as! FAQQuestionAnswerVC
        viewController.questionDataDic = fieldOptionsDic
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension HelpAndFAQVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return headerDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "SelectionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SelectionCollectionCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectionCollectionCell", for: indexPath) as! SelectionCollectionCell
        
        let fieldOptionsDic = (headerDataArray[indexPath.row] as! NSDictionary)
        print(fieldOptionsDic)
        if fieldOptionsDic.object(forKey: "isSelected") as! String == "0"
        {
            cell.backV.layer.borderColor = UIColor.lightGray.cgColor
            cell.selectionTypeLbl.textColor = UIColor.lightGray
            cell.backV.backgroundColor = .clear
            
        }
        else
        {
            self.selectedHeader = (fieldOptionsDic["type"] as! String)
            cell.backV.backgroundColor = UIColor.KMainColorCode
            cell.selectionTypeLbl.textColor = .white
            cell.backV.layer.borderColor = UIColor.KMainColorCode.cgColor
            
        }
        cell.imageV.isHidden = true
        cell.selectionTypeLbl.text = (fieldOptionsDic.object(forKey: "title") as! String)
        cell.backV.layer.cornerRadius = 20
        cell.backV.layer.borderWidth = 1
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for (index,value) in (self.headerDataArray as! [NSDictionary]).enumerated() {
            let dataDic = (value.mutableCopy() as! NSMutableDictionary)
            if index == indexPath.row
            {
                dataDic["isSelected"] = "1"
                self.selectedHeader = (dataDic["type"] as! String)
            }
            else
            {
                dataDic["isSelected"] = "0"
            }
            self.headerDataArray.replaceObject(at: index, with: dataDic)
        }
        collectionView.reloadData()
        getFilterData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: 120, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
}

