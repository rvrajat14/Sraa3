//
//  SubCategoryVC.swift
//  SRAA3
//
//  Created by Apple on 21/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class SubCategoryVC: UIViewController   {
    let kHorizontalInsets: CGFloat = 10.0
    let kVerticalInsets: CGFloat = 10.0
    @IBOutlet weak var headerTitleLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var categoryDic = NSDictionary.init()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        print("Category: \(categoryDic)")
        
       tableView.estimatedRowHeight = 220
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "SubCategoryTableCell", bundle: Bundle.main), forCellReuseIdentifier: "SubCategoryTableCell")
        headerTitleLbl.text = categoryDic.value(forKey: "category_title") as? String
    }

    override func viewWillAppear(_ animated: Bool) {
        productCartArray.removeAllObjects()
        questionAnswerCartArray = NSMutableArray.init()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    
    @IBAction func popVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SubCategoryVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (categoryDic.value(forKey: "r_subcategory")as! NSArray).count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubCategoryTableCell", for: indexPath) as! SubCategoryTableCell
      
        let dic = (categoryDic.value(forKey: "r_subcategory")as! NSArray)[indexPath.row]as! NSDictionary
         cell.configCell(title: dic.value(forKey: "category_title")as! String, content: dic.value(forKey: "description")as! String, imageName: (dic["category_photo"]as! String))
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let subcategoriesArray = categoryDic.value(forKey: "r_subcategory")as! NSArray
        let dic = subcategoriesArray[indexPath.row]as! NSDictionary
        
        let formIdStr = CommonClass.checkForNull(string:  dic.value(forKey: "form_id") as AnyObject)
        
        if (formIdStr == "0") {
            KFormId = ""
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemsVC") as! ItemsVC
            print(CommonClass.checkForNull(string:dic.value(forKey: "category_id")as AnyObject))
            vc.category_id = CommonClass.checkForNull(string:dic.value(forKey: "category_id")as AnyObject)
            vc.category_title = CommonClass.checkForNull(string:dic.value(forKey: "category_title")as AnyObject)
            vc.category_photo = CommonClass.checkForNull(string:dic.value(forKey: "category_photo")as AnyObject)
            self.navigationController?.pushViewController(vc, animated: false)
        }
        else
        {
            KFormId = formIdStr
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "QuestionAnswerVC") as! QuestionAnswerVC
            vc.category_id = CommonClass.checkForNull(string:dic.value(forKey: "category_id")as AnyObject)
            vc.category_title = CommonClass.checkForNull(string:dic.value(forKey: "category_title")as AnyObject)
            vc.category_photo = CommonClass.checkForNull(string:dic.value(forKey: "category_photo")as AnyObject)
            vc.descriptionStr = CommonClass.checkForNull(string: dic.value(forKey: "term_and_condition") as AnyObject)
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
}

extension SubCategoryVC : UITableViewDataSourcePrefetching
{
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
   
        for indexPath in indexPaths {
            if (tableView.indexPathsForVisibleRows?.contains(indexPath))!
            {
                 guard let cell = tableView.cellForRow(at: indexPath) as? SubCategoryTableCell else { return  }
                 let dic = (categoryDic.value(forKey: "subcategories")as! NSArray)[indexPath.row]as! NSDictionary
                 cell.configCell(title: dic.value(forKey: "category_title")as! String, content: dic.value(forKey: "description")as! String, imageName: (dic["category_photo"]as! String))
            }
        }
        
    }
    
    
}
