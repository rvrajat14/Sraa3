//
//  SelectTimeVC.swift
//  Dry Clean City
//
//  Created by Kishore on 24/01/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class SelectTimeVC: UIViewController,UITableViewDelegate,UITableViewDataSource , UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var tableV: UITableView!
    @IBOutlet weak var collectionV: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBAction func backButton(_ sender: UIButton) {
     self.navigationController?.popViewController(animated: true)
    }
    
    var tableCategoryArray:NSMutableArray!
    var tableViewArray:NSMutableArray?
    var allItemsDataArray: NSMutableArray!
    var selectedDateIndex:Int!
    var selectedCategoryId : String?
    var selectedCategoryName : String?
    var isForDeliveryTime = false
    var pickupDateForJson = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.allItemsDataArray = NSMutableArray.init()
        self.tableV.rowHeight = UITableViewAutomaticDimension
        self.tableV.estimatedRowHeight = 50
        self.tableV.tableFooterView = UIView(frame: CGRect.zero)
        selectedDateIndex = 0
        
        CallApi()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return self.allItemsDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: SelectDateCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectDateCollectionCell", for: indexPath) as! SelectDateCollectionCell
        
        let dataDic = self.allItemsDataArray.object(at: indexPath.row)as! NSDictionary
        
        cell.date_nameLbl.text = dataDic.value(forKey: "date_name") as? String
        
        cell.datelbl.text = dataDic.value(forKey: "date") as? String
        
        if(selectedDateIndex == indexPath.item)
        {
            cell.backV.backgroundColor = UIColor.black
            cell.datelbl.textColor = UIColor.white
            cell.date_nameLbl.textColor = UIColor.white
        }
        else
        {
            cell.datelbl.textColor = UIColor.darkGray
            cell.date_nameLbl.textColor = UIColor.darkGray
            cell.backV.backgroundColor = UIColor.white
            cell.backV.layer.borderWidth = 1
            cell.backV.layer.borderColor = UIColor.darkGray.cgColor
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cellWidth = 72.0
        return CGSize(width: cellWidth, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       // let cell = collectionView.cellForItem(at: indexPath) as! SelectDateCollectionCell
        selectedDateIndex = indexPath.item
        
        self.collectionV.reloadData()
        
        self.tableV.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if allItemsDataArray.count > 0 {
            return ((allItemsDataArray.object(at: selectedDateIndex) as! NSDictionary).object(forKey: "slots") as! NSArray).count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nib:UINib = UINib(nibName: "SelectTimeTableCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "SelectTimeTableCell")
        
        let cell:SelectTimeTableCell = tableView.dequeueReusableCell(withIdentifier: "SelectTimeTableCell") as! SelectTimeTableCell
        
        cell.selectionStyle = .none
        
        let dataDic = (((allItemsDataArray.object(at: selectedDateIndex) as! NSDictionary).object(forKey: "slots") as! NSArray).object(at: indexPath.row) as! NSDictionary)
        
       // cell.selectDateLbl?.text = (dataDic["show_time"] as! String)
        
        cell.fromTimeLbl.text = (dataDic["show_time"] as! String) 
        
       // cell.toTimeLbl.text = (dataDic["to_time"] as! String)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataDic = allItemsDataArray.object(at: selectedDateIndex) as! NSDictionary
        
        let cell:SelectTimeTableCell = tableView.cellForRow(at: indexPath) as! SelectTimeTableCell
        
        let slotDataArray = dataDic.value(forKey: "slots")as! NSArray
        
        let seletedDic = slotDataArray[indexPath.row] as! NSDictionary
        
        if isForDeliveryTime {
             selectedDeliveryDate =  (dataDic.object(forKey: "date_name") as! String) + " " + (dataDic.object(forKey: "date") as! String) + ", " + (seletedDic.value(forKey: "show_time") as! String)
            selectedTimeForDelivery = cell.selectDateLbl.text!
        }
        else
        {
            selectedDeliveryDate = ""
            selectedTimeForDelivery = ""
            selectedPickupDate =  (dataDic.object(forKey: "date_name") as! String) + " " + (dataDic.object(forKey: "date") as! String) + ", " + (seletedDic.value(forKey: "show_time") as! String)
            selectedPickupDateForJSON = (dataDic.object(forKey: "date") as! String)
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    //MARK: -Call API
    func CallApi() -> Void{
    
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy"
        var date = ""
        if isForDeliveryTime {
            date = selectedPickupDateForJSON
        }
        else
        {
            date = dateFormat.string(from: Date())
        }
        
        let apiName = RGetTimeSlots_Api + "?from_date=\(date)&include_empty_date=false&timezone=\(localTimeZoneName)"
        
        self.tableCategoryArray = NSMutableArray.init()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false, completion: {
            WebService.requestGetUrl(strURL: apiName, is_loader_required: true, success: { (response) in
                print(response)
              
                self.presentedViewController?.dismiss(animated: false, completion: nil)
               if response["status_code"] as! NSNumber == 0
               {
                DispatchQueue.main.async {
                    COMMON_ALERT.showAlert(title: response["message"] as! String , msg: "", onView: self) }
                self.navigationController?.popViewController(animated: true)
                }
                else
               {
                self.allItemsDataArray = ((response["data"] as! NSArray).mutableCopy() as! NSMutableArray)
                
                for value in self.allItemsDataArray as! [NSDictionary] {
                     self.tableCategoryArray.add((value.object(forKey: "date_name") as! String) + "\n" + (value.object(forKey: "date") as! String))
                   
                }
                print("Titles\(self.tableCategoryArray!)")
                
                print("array is ",self.allItemsDataArray)
                }
                
                self.collectionV.register(UINib.init(nibName: "SelectDateCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SelectDateCollectionCell")
                
                self.collectionV.reloadData()
                self.tableV.reloadData()
                
               
            }) { (failure) in
             //  COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: false, option: .transitionCurlDown)
            }
        })
      
    }
}

