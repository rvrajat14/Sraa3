//
//  ServiceDescriptionVC.swift
//  SRAA3
//
//  Created by Apple on 22/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ServiceDescriptionVC: UIViewController {

    var currentServiceName = ""
    var categoryDic = NSDictionary()

    var directService = false
    
    @IBOutlet weak var gradiantView: UIView!
    @IBOutlet weak var viewServiceButton: UIButton!
    @IBAction func viewServiceButton(_ sender: UIButton) {
        
        if directService {
            let formIdStr = CommonClass.checkForNull(string:  categoryDic.value(forKey: "form_id") as AnyObject)
            
            if (formIdStr == "0") {
                KFormId = ""
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemsVC") as! ItemsVC
                vc.category_id = CommonClass.checkForNull(string:categoryDic.value(forKey: "category_id")as AnyObject)
                vc.category_title = CommonClass.checkForNull(string:categoryDic.value(forKey: "category_title")as AnyObject)
                vc.category_photo = CommonClass.checkForNull(string:categoryDic.value(forKey: "category_photo")as AnyObject)
                self.navigationController?.pushViewController(vc, animated: false)
            }
            else
            {
                KFormId = formIdStr
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "QuestionAnswerVC") as! QuestionAnswerVC
                vc.category_id = CommonClass.checkForNull(string:categoryDic.value(forKey: "category_id")as AnyObject)
                vc.category_title = CommonClass.checkForNull(string:categoryDic.value(forKey: "category_title")as AnyObject)
                vc.category_photo = CommonClass.checkForNull(string:categoryDic.value(forKey: "category_photo")as AnyObject)
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        
        else {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoryVC") as! SubCategoryVC
        vc.categoryDic = categoryDic
        self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    @IBOutlet weak var tableView: UITableView!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewServiceButton.backgroundColor = .clear
        self.gradiantView.layer.cornerRadius = 10
        self.gradiantView.layer.masksToBounds = true
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidLayoutSubviews() {
        let gradientColor = CAGradientLayer()
         gradientColor.frame = gradiantView.bounds
         gradientColor.colors = [#colorLiteral(red: 0.1596659124, green: 0.1958044171, blue: 0.31693542, alpha: 1).cgColor,#colorLiteral(red: 0.107250981, green: 0.2097327709, blue: 0.316868335, alpha: 1).cgColor,#colorLiteral(red: 0.107250981, green: 0.2097327709, blue: 0.316868335, alpha: 1).cgColor,#colorLiteral(red: 0.06091438412, green: 0.2911201571, blue: 0.3817982692, alpha: 1).cgColor]
         gradientColor.startPoint = CGPoint(x: 0.0, y: 0.0)
         gradientColor.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradiantView.layer.insertSublayer(gradientColor, at: 0)
        
//        Utilities.setButtonGradiantColor(button: self.viewServiceButton)
    }
 

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
}

extension ServiceDescriptionVC : UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else if section == 1
        {
            return 3
        }
        else
        {
        return 2
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        var headerV : UIView!
        
        if section == 0 {
            headerV = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 2))
            headerV.backgroundColor = .white
            return headerV
        }
        else
        {
             headerV = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 60))
             headerV.backgroundColor = .white
            let titleLbl = UILabel(frame: CGRect(x: 20, y: 20, width: self.view.frame.size.width - 40, height: 25))
            
            if section == 1
            {
                titleLbl.text = "SRAA3 Promise"
                titleLbl.font = UIFont(name: KMainFontSemiBold, size: 15)
            }
            else
            {
                titleLbl.text = "What users are saying about SRAA3"
                 titleLbl.font = UIFont(name: KMainFont, size: 15)
            }
            headerV.addSubview(titleLbl)
             return headerV
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let  headerV = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 15))
        headerV.backgroundColor = section == 2 ? .white : .groupTableViewBackground
        return headerV
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 2
        }
        else
        {
        return 60
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 2 ? 90 : 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FirstSDTableViewCell", for: indexPath) as! FirstSDTableViewCell
            cell.selectionStyle = .none
            cell.categoryLbl.text = currentServiceName
            return cell
        }
        else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SecondSDTableViewCell", for: indexPath) as! SecondSDTableViewCell
            
            if indexPath.row == 0
            {
                cell.titleLbl.text = "On-Time & Hassle-free Experience"
                cell.subtitleLbl.text = "Fixed deadlines and hassle-free completion of services."
                cell.imgV.image = #imageLiteral(resourceName: "thumb")
            }
            else if indexPath.row == 1
            {
                cell.titleLbl.text = "Top Quality and Transparent Costs"
                cell.subtitleLbl.text = "Branded and all inclusive-pricing with no hidden chanrges."
                cell.imgV.image = #imageLiteral(resourceName: "certified")
            }
            else
            {
                cell.titleLbl.text = "Service Guarantee"
                cell.subtitleLbl.text = "Free re-work and touch-ups in case of any damages and faults."
                cell.imgV.image = #imageLiteral(resourceName: "hassle_free")
            }
            cell.selectionStyle = .none
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SecondSDTableViewCell", for: indexPath) as! SecondSDTableViewCell
            if indexPath.row == 0
            {
                cell.titleLbl.text = "4.8 out of 5 Stars"
                cell.subtitleLbl.text = "Average Rating of SRAA3"
                cell.imgV.image = #imageLiteral(resourceName: "rating")
            }
            else
            {
                cell.titleLbl.text = "500+ Reviews"
                cell.subtitleLbl.text = "of the SRAA3 by Users"
                cell.imgV.image = #imageLiteral(resourceName: "review")
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    
}
