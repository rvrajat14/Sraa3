//
//  ServiceGuaranteeVC.swift
//  SRAA3
//
//  Created by Apple on 21/08/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ServiceGuaranteeVC: UIViewController {
 @IBOutlet weak var tableV: UITableView!
    @IBAction func popVC(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    var dataArray = [Dictionary<String, Any>]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableV.register(UINib(nibName: "ServiceGuaranteeTableCell", bundle: nil), forCellReuseIdentifier: "ServiceGuaranteeTableCell")
        dataArray.append(Dictionary(dictionaryLiteral: ("title","Verified Experts"),("info","We have registered and verified professionals who will passionately render your required services. Every service provider experts go through rounds of a background check."),("image",UIImage(named: "verified experts copy")!)))
         dataArray.append(Dictionary(dictionaryLiteral: ("title","High Quality Standards"),("info","Sraa3 believes in providing high quality and original products to deliver services as per schedule."),("image",UIImage(named: "quality standard copy")!)))
         dataArray.append(Dictionary(dictionaryLiteral: ("title","On-time completion"),("info","We offer personalized service with a smile from our experts and dedicated service providers on time as per schedule."),("image",UIImage(named: "one time completion")!)))
         dataArray.append(Dictionary(dictionaryLiteral: ("title","Hassle-free service"),("info","Sraa3 ensures a hassle-free and fairly priced service to the customers without any bother and problems. We believe in customer’s happiness."),("image",UIImage(named: "hassle free service")!)))
         dataArray.append(Dictionary(dictionaryLiteral: ("title","Re-work assurance"),("info","Sraa3  strives to offer top quality services for you and your home every time. If you're not satisfied with the quality of the service, we'll get a rework done to your satisfaction at no extra charge."),("image",UIImage(named: "rewok assurance")!)))
         dataArray.append(Dictionary(dictionaryLiteral: ("title","Professional Support"),("info","Customers can reach our support team anytime for queries. You can chat with us, email us and call us to get through to our support team."),("image",UIImage(named: "professional support")!)))
        tableV.tableFooterView = UIView(frame: .zero)
    }
 
}


extension ServiceGuaranteeVC : UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableV.dequeueReusableCell(withIdentifier: "ServiceGuaranteeTableCell", for: indexPath) as! ServiceGuaranteeTableCell
        let dataDict = dataArray[indexPath.row]
        cell.titleLbl.text = (dataDict["title"] as! String)
        cell.descriptionLbl.text = (dataDict["info"] as! String)
        cell.imgView.image = (dataDict["image"] as! UIImage)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
       let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 180))
       
        let backView = UIView(frame: CGRect(x: 10, y: 10, width: footerView.frame.size.width - 20, height: footerView.frame.size.height - 20))
//        backView.backgroundColor = UIColor(red: 185/255.0, green: 199/255.0, blue: 201/255.0, alpha: 1)
        backView.backgroundColor = hexStringToUIColor(hex: "#B1C6CA")
        backView.layer.cornerRadius = 6
        footerView.addSubview(backView)
        let imgV = UIImageView(frame: CGRect(x: 25, y: 50, width: 80, height: 80))
        imgV.image = #imageLiteral(resourceName: "shield")
        imgV.contentMode = .scaleAspectFill
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .normal("KHUSHIYON KI GUARANTEE", size: 18)
        
        
        let titleHeight = getLabelHeight(formattedString.string, withWidth: self.view.frame.size.width - imgV.frame.size.width - 25, withFont: 18, fontName: KMainFont) + 5
        
        let titleLbl = UILabel(frame: CGRect(x: imgV.frame.size.width + 40, y: imgV.frame.origin.y + 15, width: self.view.frame.size.width - (imgV.frame.size.width + 40), height: titleHeight))
        titleLbl.numberOfLines = 0
        titleLbl.attributedText = formattedString
        // titleLbl.font = UIFont(name: KMainFont, size: 18)
        titleLbl.textColor = UIColor.black
        titleLbl.sizeToFit()
        
        let desLbl = UILabel(frame: CGRect(x: titleLbl.frame.origin.x, y: titleLbl.frame.origin.y + titleHeight - 10, width: titleLbl.frame.size.width, height: 30))
        desLbl.text = "STAY AT HOME, CARE AT HOME"
        desLbl.numberOfLines = 2
        desLbl.font = UIFont(name: KMainFont, size: 13)
        desLbl.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.70)
        footerView.backgroundColor = UIColor.white
        
        footerView.addSubview(titleLbl)
        footerView.addSubview(desLbl)
        footerView.addSubview(imgV)
        return footerView
        
    }
    
}

