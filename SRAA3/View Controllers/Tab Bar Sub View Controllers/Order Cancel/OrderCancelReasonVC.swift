//
//  OrderCancelReasonVC.swift
//  My MM
//
//  Created by Kishore on 16/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import IQKeyboardManager

class OrderCancelReasonVC: UIViewController {

    @IBOutlet weak var serverErrorView: UIView!
    var order_id = ""
    var cancel_reason = ""
    var user_id = ""
    var cancelReasonDataArray = NSMutableArray.init()
    var isTxtBoxHidden = true
    @IBOutlet weak var backView: UIView!
    @IBAction func cancelOrderButton(_ sender: UIButton) {
        
        if cancel_reason.isEmpty {
            if isTxtBoxHidden
            {
                self.view.makeToast("Select cancel reason")
            }
            else
            {
            self.view.makeToast("Enter Cancel Reason")
            }
            self.view.clearToastQueue()
        }
        else
        {
            orderCancelAPI()
        }
    }
    
    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var orderNumberLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backView.layer.masksToBounds = true
        self.backView.layer.cornerRadius = 10
        self.orderNumberLbl.text = "#\(order_id)"
        if cancelReasonDataArray.count > 0
        {
            if (cancelReasonDataArray[0] as! NSDictionary)["title"] as! String == "Other"
            {
                cancelReasonDataArray.removeObject(at: 0)
            }
        }
        self.cancelReasonDataArray.add(NSDictionary(dictionaryLiteral: ("title","Other"),("isSelected","0")))
        self.cancelOrderButton.layer.cornerRadius = 10
        self.cancelOrderButton.layer.masksToBounds = true
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 90))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    //MARK: Order Cancel API
    func orderCancelAPI()  {
        let param =  ["user_id":user_id,"linked_id":order_id,"user_type":"customer","reason":cancel_reason,"type":"order"]
        print(param)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestPostUrl(strURL: ROrder_Cancel_API + "?class_identifier=sraa3", params: param as NSDictionary, is_loader_required: true, success: { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                
                DispatchQueue.main.async {
                    if response["status_code"] as! NSNumber == 1
                    {
                        NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil, userInfo: ["toastMsg":(response["message"] as! String)])
                        NotificationCenter.default.post(name: NSNotification.Name("OrderListUpdated"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                    else
                    {
                        self.view.makeToast((response["message"] as! String))
                        self.view.clearToastQueue()
                    }
                }
                
               
                
            }) { (error) in
                
            }
        }
    }
    
    //MARK: Selector
    
    @objc func checkBoxButtonAction(sender: UIButton,event:AnyObject?)
    {
        let touches : Set<UITouch>
        touches = (event?.allTouches)!
        let touchPoint = touches.first?.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: touchPoint!)!
        let cell = self.tableView.cellForRow(at: indexPath) as! RadioTableCell
        let tmpArray = (cancelReasonDataArray as! [NSDictionary])
        
        for (index,value) in tmpArray.enumerated() {
            let dataDic = value.mutableCopy() as! NSMutableDictionary
            
            if index == indexPath.row
            {
                dataDic.setObject("1", forKey: "isSelected" as NSCopying )
            }
            else
            {
                dataDic.setObject("0", forKey: "isSelected" as NSCopying )
            }
            cancelReasonDataArray.replaceObject(at: index, with: dataDic)
        }
        if cell.variantsNameLbl.text == "Other" {
             isTxtBoxHidden = false
            cancel_reason = ""
        }
        else
        {
            isTxtBoxHidden = true
            cancel_reason = cell.variantsNameLbl.text!
        }
     self.tableView.reloadData()
    }
    
}

extension OrderCancelReasonVC : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cancelReasonDataArray.count
}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nib:UINib = UINib(nibName: "RadioTableCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "RadioTableCell")
        
        let cell:RadioTableCell = tableView.dequeueReusableCell(withIdentifier: "RadioTableCell", for: indexPath) as! RadioTableCell
        cell.variantsNameLbl.text = ((cancelReasonDataArray[indexPath.row] as! NSDictionary)["title"] as! String)
        cell.checkBoxButton.tag = indexPath.row
        let isSelected = (cancelReasonDataArray[indexPath.row] as! NSDictionary)["isSelected"] as! String
        if isSelected == "1" {
             cell.variantsNameLbl.textColor = UIColor.KMainColorCode
            cell.checkBoxButton.setImage(#imageLiteral(resourceName: "round-checked"), for: .normal)
        }
        else
        {
            cell.variantsNameLbl.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.63)
            cell.checkBoxButton.setImage(#imageLiteral(resourceName: "radio_off"), for: .normal)
        }
        cell.checkBoxButton.addTarget(self, action: #selector(checkBoxButtonAction(sender:event:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isTxtBoxHidden {
            return 0
        }
        else
        {
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isTxtBoxHidden {
            return UIView(frame: .zero)
        }
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 150))
        let subFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        subFooterView.backgroundColor = .white
        footerView.backgroundColor = UIColor.groupTableViewBackground
        let txtView = IQTextView(frame: CGRect(x: 30, y: 0, width: self.view.frame.size.width - 60, height: 80))
        txtView.layer.cornerRadius = 2
        txtView.layer.borderWidth = 1
        txtView.layer.borderColor = UIColor.lightGray.cgColor
        txtView.font = UIFont(name: KMainFont, size: 16)
        txtView.placeholder = "Type reason here..."
        txtView.textColor = .black
        txtView.delegate = self
        
        subFooterView.addSubview(txtView)
        footerView.addSubview(subFooterView)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        headerView.backgroundColor = UIColor.groupTableViewBackground
        let titleLbl = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.size.width - 32, height: 20))
        titleLbl.font = UIFont(name: KMainFont, size: 16)
        titleLbl.textColor = UIColor.darkGray
        titleLbl.text = "Choose Cancellation Reason"
        headerView.addSubview(titleLbl)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! RadioTableCell
        let tmpArray = (cancelReasonDataArray as! [NSDictionary])
        
        for (index,value) in tmpArray.enumerated() {
            let dataDic = value.mutableCopy() as! NSMutableDictionary
            
            if index == indexPath.row
            {
                dataDic.setObject("1", forKey: "isSelected" as NSCopying )
            }
            else
            {
                dataDic.setObject("0", forKey: "isSelected" as NSCopying )
            }
            cancelReasonDataArray.replaceObject(at: index, with: dataDic)
        }
        if cell.variantsNameLbl.text == "Other" {
            isTxtBoxHidden = false
            cancel_reason = ""
        }
        else
        {
            isTxtBoxHidden = true
            cancel_reason = cell.variantsNameLbl.text!
        }
        self.tableView.reloadData()
    }
    
}

extension OrderCancelReasonVC : UITextViewDelegate
{
    public func textViewDidEndEditing(_ textView: UITextView)
    {
        self.cancel_reason = textView.text
    }
}


