//
//  QuestionAndAnswerVC.swift
//  My MM
//
//  Created by Kishore on 25/02/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class FAQQuestionAnswerVC: UIViewController {
    
    var questionDataDic = NSDictionary.init()
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var tableV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableV.register(UINib(nibName: "FAQQuestionAndAnswerCell", bundle: nil), forCellReuseIdentifier: "FAQQuestionAndAnswerCell")
        tableV.tableFooterView = UIView(frame: .zero)
    }
    
    //MARK: Selector
    @objc func noButton(_ sender: UIButton)
    {
        likeAPI(string: "/dislike/\(questionDataDic["id"] as! NSNumber)")
    }
    
    @objc func yesButton(_ sender: UIButton)
    {
        likeAPI(string: "/like/\(questionDataDic["id"] as! NSNumber)")
    }
    
    //MARK: Dislike API
    
    func likeAPI(string:String)   {
      
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        self.present(vc, animated: false) {
            WebService.requestGetUrl(strURL: RFAQ_Api + (string) , is_loader_required: true, success: { (response) in
                print(response)
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                if response["status_code"] as! NSNumber == 1
                {
                    self.view.makeToast("Thank you for your feedback")
                }
                
               
            }) { (error) in
                
            }
        }
     
    }
}

extension FAQQuestionAnswerVC : UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        headerView.backgroundColor = UIColor.groupTableViewBackground
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQQuestionAndAnswerCell", for: indexPath) as! FAQQuestionAndAnswerCell
        cell.questionLbl.text = (questionDataDic["question"] as! String)
        //cell.answerLbl.text = (questionDataDic["answer"] as! String)
        cell.txtView.text = (questionDataDic["answer"] as! String)
        cell.yesButton.layer.cornerRadius = cell.yesButton.frame.size.height/2
        cell.noButton.layer.cornerRadius = cell.noButton.frame.size.height/2
        cell.yesButton.layer.borderWidth = 1
        cell.noButton.layer.borderWidth = 1
        cell.yesButton.addTarget(self, action: #selector(yesButton(_:)), for: .touchUpInside)
        cell.noButton.addTarget(self, action: #selector(noButton(_:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        v.backgroundColor = .white
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
}
