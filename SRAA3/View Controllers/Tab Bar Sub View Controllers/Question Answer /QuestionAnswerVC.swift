//
//  QuestionAnswerVC.swift
//  SRAA3
//
//  Created by Apple on 22/02/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class QuestionAnswerVC: UIViewController ,UITableViewDataSource , UITableViewDelegate {
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableV: UITableView!
    
    var category_id = ""
    var category_title = ""
    var category_photo = ""
    var descriptionStr = ""
    var selectedIndex = 0
    var selectedDic = NSMutableDictionary.init()
    
    var formFieldsArray = NSMutableArray.init()
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tabBarController?.tabBar.isHidden = true
        self.titleLbl.text = category_title
        self.tableV.rowHeight = UITableViewAutomaticDimension
        self.tableV.estimatedRowHeight = 50
        self.tableV.tableFooterView = UIView(frame: .zero)
        self.tableV.isHidden = true
        self.nextBtn.isHidden = true
        self.cancelBtn.isHidden = true
        getFormsApiCall()
       // orderCancel
         NotificationCenter.default.addObserver(self, selector: #selector(orderUpdated), name: NSNotification.Name("orderCancel"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        self.nextBtn.layer.cornerRadius = 10
        self.nextBtn.layer.masksToBounds = true
        Utilities.setButtonGradiantColor(button: self.nextBtn)
    }
    
    @objc func orderUpdated()  {
        
        selectedIndex = 0
        selectedDic = NSMutableDictionary.init()
        formFieldsArray = NSMutableArray.init()
        getFormsApiCall()
        
    }
    
    
    @IBAction func popVC(_ sender: Any) {
        
        if selectedIndex == 0 {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            selectedIndex = selectedIndex - 1
            if selectedIndex == (formFieldsArray.count - 1) {
                self.nextBtn.setTitle("PROCEED", for: .normal)
                self.selectedDic = ((formFieldsArray[selectedIndex]as! NSDictionary).mutableCopy())as! NSMutableDictionary
                self.tableV.reloadData()
            }
            else
            {
                self.nextBtn.setTitle("NEXT", for: .normal)
                self.selectedDic = ((formFieldsArray[selectedIndex]as! NSDictionary).mutableCopy())as! NSMutableDictionary
                self.tableV.reloadData()
            }
            calculateProgressBar()
        }
    }
    
    @IBAction func nextBtnTaped(_ sender: Any) {
        selectedOptionsIdsArray.removeAll()
        selectedOptionsTitleArray.removeAll()
        if(self.nextBtn.titleLabel?.text == "PROCEED")
        {
            let boolV = checkForValueIsSelected()
            calculateProgressBar()
            if(boolV)
            {
                COMMON_ALERT.showAlert(title: "" , msg: "Please answer the following Question", onView: self)
                return;
            }
            else
            {
                
                if formFieldsArray.count > 0 {
                    for item in formFieldsArray {
                        let array = (item as! NSDictionary)["form_field_option"] as! [NSDictionary]
                        for item2 in array {
                            let id = CommonClass.checkForNull(string: item2["id"] as AnyObject)
                            let title = CommonClass.checkForNull(string: item2["title"] as AnyObject)
                            if CommonClass.checkForNull(string: item2["isSelected"] as AnyObject) == "1" {
                                selectedOptionsIdsArray.append(id)
                                selectedOptionsTitleArray.append(title)
                            }
                        }
                    }
                }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemsVC") as! ItemsVC
                vc.isFromQuesAnsVC = true
                print(self.category_id)
                print(descriptionStr)
                vc.descriptionStr = descriptionStr
                vc.category_id = self.category_id
                vc.category_title = self.category_title
                self.navigationController?.pushViewController(vc, animated: false)
                
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DescriptionVC") as! DescriptionVC
//                questionAnswerCartArray = self.formFieldsArray
//                vc.category_id = self.category_id
//                vc.category_title = self.category_title
//                vc.descriptionStr = descriptionStr
//                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        else
        {
            print(selectedIndex)
            
            let boolV = checkForValueIsSelected()
            if(boolV)
            {
                COMMON_ALERT.showAlert(title: "" , msg: "Please answer the following Question", onView: self)
                return;
            }
            else
            {
                
        self.selectedIndex = selectedIndex + 1
            calculateProgressBar()
        if selectedIndex == (formFieldsArray.count - 1) {
            self.nextBtn.setTitle("PROCEED", for: .normal)
            selectedDic = ((formFieldsArray[selectedIndex] as! NSDictionary).mutableCopy()) as! NSMutableDictionary
            self.tableV.reloadData()
        }
        else
        {
            self.nextBtn.setTitle("NEXT", for: .normal)
            selectedDic = ((formFieldsArray[selectedIndex] as! NSDictionary).mutableCopy()) as! NSMutableDictionary
            self.tableV.reloadData()
        }
        }
        }
    }
    
    @IBAction func cancelBtnTaped(_ sender: Any) {
        
        formFieldsArray = NSMutableArray.init(); self.navigationController?.popViewController(animated: true)
    }
    
    func checkForValueIsSelected() -> Bool {
        
        var boolV: Bool = false
        
        for (index,value) in formFieldsArray.enumerated()
        {
            let subDic = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
            
            print(subDic)
            
            let value = subDic.value(forKey: "value")as! String
            
            if index == selectedIndex
            {
            if (value.isEmpty)
            {
                boolV = true
                break
            }
                boolV = false
            }
        }
       return boolV
    }
    
    func calculateProgressBar()   {

        let progressFloat = ((100 / Float(self.formFieldsArray.count)) * Float(selectedIndex))
        let progressPer = (progressFloat / 100.0)
        print(progressFloat)
        progressBar.setProgress(progressPer, animated: false)
        
    }
    
    //MARK: ----- Tableview Delegate And DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else
        {
            if (self.formFieldsArray.count > 0)
            {
                self.selectedDic = (formFieldsArray[selectedIndex]as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        let form_field_optionArray = self.selectedDic.value(forKey: "form_field_option") as! NSArray
        
        return form_field_optionArray.count
            }
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 90
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let footerV = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 90))
            footerV.backgroundColor = tableView.backgroundColor
            return footerV
        }
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         if section == 1 {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0))
        headerView.backgroundColor = tableView.backgroundColor
        return headerView
        }
        
        return UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if formFieldsArray.count > 0 {
          
        self.selectedDic = (formFieldsArray[selectedIndex]as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        if indexPath.section == 0 {
            
            let identifier = "QuestionCell"
            var cell: QuestionCell! = tableView.dequeueReusableCell(withIdentifier: identifier)as? QuestionCell
            if cell == nil {
                var nib = Bundle.main.loadNibNamed("QuestionCell", owner: self, options: nil)
                cell = nib![0] as? QuestionCell
            }
            
            cell.selectionStyle = .none
            
            cell.titleLbl.text = (self.selectedDic.value(forKey: "field_name")as! String)
            
            return cell
            
        }
            
        else
        {
        let form_field_optionArray = self.selectedDic.value(forKey: "form_field_option") as! NSArray
        
            let identifier = "SelectionCell"
            var cell: SelectionCell! = tableView.dequeueReusableCell(withIdentifier: identifier)as? SelectionCell
            if cell == nil {
                var nib = Bundle.main.loadNibNamed("SelectionCell", owner: self, options: nil)
                cell = nib![0] as? SelectionCell
            }
            
            cell.selectionStyle = .none
            
            // Utilities.shadowLayer1(viewLayer: cell.backV.layer, shadow: true)
        
            let dic = form_field_optionArray[indexPath.row]as! NSDictionary
        
            let isSelected = dic.value(forKey: "isSelected")as! String
            
            if(isSelected == "1")
            {
                 cell.checkBoxImgV.image = #imageLiteral(resourceName: "tick-inside-circle")
                 cell.titleLbl.textColor = UIColor.black
            }
            else
            {
               //  cell.checkBoxImgV.image = #imageLiteral(resourceName: "empty-circle")
                 cell.checkBoxImgV.isHidden = true
                 cell.titleLbl.textColor = UIColor.gray
            }
            
            cell.titleLbl.text = dic.value(forKey: "title")as? String
        
            return cell
        }
        }
         return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            setSelectedRow(indexPath: indexPath as IndexPath)
            
            if selectedIndex == (formFieldsArray.count - 1) {
                self.nextBtn.setTitle("PROCEED", for: .normal)
            }
            else
            {
                self.nextBtn.setTitle("NEXT", for: .normal)
                selectedDic = ((formFieldsArray[selectedIndex] as! NSDictionary).mutableCopy()) as! NSMutableDictionary
                self.tableV.reloadData()
            }
        }
    }
    
    //MARK: Set Selected Row
    
    func setSelectedRow(indexPath: IndexPath) {
        
        let mainDic = (self.formFieldsArray.object(at: selectedIndex) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let form_field_optionArray = ((mainDic.object(forKey: "form_field_option") as! NSArray).mutableCopy() as! NSMutableArray)
        
        for (index,value) in form_field_optionArray.enumerated()
        {
            let subDic = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
           
            if indexPath.row == index
            {
                subDic.setObject("1", forKey: "isSelected" as NSCopying)
                form_field_optionArray.replaceObject(at: index, with: subDic)
                let value = subDic.object(forKey: "title") as! String
                mainDic.setObject(value, forKey: "value" as NSCopying)
            }
            else
            {
                subDic.setObject("0", forKey: "isSelected" as NSCopying)
                form_field_optionArray.replaceObject(at: index, with: subDic)
            }
        }
        
        mainDic.setObject(form_field_optionArray, forKey: "form_field_option" as NSCopying)
        self.formFieldsArray.replaceObject(at: selectedIndex, with: mainDic)
        
        print(self.formFieldsArray)
        
        self.tableV.reloadData()
    }
    
    func getFormsApiCall() {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestGetUrl(strURL: RForms_Api + "/\(KFormId)" , is_loader_required: true, success: { (response) in
                print(response)
                self.tableV.isHidden = false
                self.nextBtn.isHidden = false
                self.cancelBtn.isHidden = false
                let allMetaDataFieldsArray = (response["form_fields"] as! NSArray).mutableCopy() as! NSMutableArray
    //            self.descriptionStr = CommonClass.checkForNull(string: (response["description"] as AnyObject))
                for subValue in allMetaDataFieldsArray
                {
                    let dataDic = (subValue as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
                        let fieldsArray = (dataDic.object(forKey: "form_field_option") as! NSArray).mutableCopy() as! NSMutableArray
                        
                        for (index,value) in fieldsArray.enumerated()
                        {
                            let value1 = (value as! NSDictionary).mutableCopy() as! NSMutableDictionary
                            value1.setObject("0", forKey: "isSelected" as NSCopying)
                            fieldsArray.replaceObject(at: index, with: value1)
                        }
                        dataDic.setObject(fieldsArray, forKey: "form_field_option" as NSCopying)
                      self.formFieldsArray.add(dataDic)
                }
                print(self.formFieldsArray)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                self.tableV.reloadData()
               
              //  self.formFieldsArray = (response["form_fields"] as! NSArray).mutableCopy() as! NSMutableArray
               
            }) { (failure) in
                
            }
        }
     
    }
}
