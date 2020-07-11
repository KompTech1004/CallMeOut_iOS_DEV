//
//  FilterVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class FilterVC: UIViewController {

    @IBOutlet weak var viSubcategory: UIView!
    @IBOutlet weak var viCategorySelection: UIView!
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var btnSelDuration: UIButton!
    @IBOutlet weak var btnSelCategory: UIButton!
    @IBOutlet weak var tfKeyword: UITextField!
    
    @IBOutlet weak var txtUsername: UITextField!
    
    @IBOutlet weak var userNameTxtHeightConstraint: NSLayoutConstraint!
    
    var type = 0
    
    var nSelectedCategoryIdx = 0
    var nSelectedSubCategoryIdx = 0
    var nSelectedDurationIdx = 0
    var nSelectedType = 0
    var arrCategoryTitles = [String]()
    var arrDurationTitles = [String]()
    var category = "Select Category"
    var keyword = ""
    var array = Array(Global.shared.AllCategory.keys)
    var filteredUsername: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        array.insert("No Filter", at: 0)
        arrDurationTitles = ["All","24 hours", "1 Week", "2 Weeks", "3 Weeks", "4 Weeks", "5 Weeks", "6 Weeks", "7 Weeks", "8 Weeks", "9 Weeks", "10 Weeks"]
        arrCategoryTitles = ["All","Fitness","Beauty","Music" ,"Sports","Martial Arts","Arts","Gaming","Design"]
        
        segment.selectedSegmentIndex = nSelectedType
        
        if self.type == 0 {
            userNameTxtHeightConstraint.constant = 0
        }
        
        if category != "All"
        {
            let list = Array(Global.shared.AllCategory.keys)
            btnSelCategory.setTitle(list[self.nSelectedCategoryIdx], for: .normal)
            if category.contains(",")
            {
                
                let valueArray = Array(Global.shared.AllCategory.values)
                self.btnSelDuration.setTitle(valueArray[self.nSelectedCategoryIdx][self.nSelectedSubCategoryIdx], for: .normal)
            }
        }
        if nSelectedDurationIdx != 0
        {
            btnSelDuration.setTitle(arrDurationTitles[nSelectedDurationIdx], for: .normal)
        }
        tfKeyword.text = keyword
        txtUsername.text = filteredUsername
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnSelDurationTapped(_ sender: Any) {
//        ActionSheetStringPicker.show(withTitle: "Select Sub category", rows: arrDurationTitles, initialSelection: nSelectedDurationIdx, doneBlock: { (picker, index, value) in
//            self.nSelectedDurationIdx = index
//            self.btnSelDuration.alpha = 1.0
//            self.btnSelDuration.setTitle(self.arrDurationTitles[self.nSelectedDurationIdx], for: .normal)
//        }, cancel: { (picker) in
//
//        }, origin: sender)
        if btnSelCategory.title(for: .normal) == "Select Category"
        {
            return
        }
        var valueArray = Array(Global.shared.AllCategory.values)
        if valueArray[self.nSelectedCategoryIdx].count == 0
        {
            return
        }
        var subarray = valueArray[self.nSelectedCategoryIdx]
        subarray.insert("No Filter", at: 0)
        ActionSheetStringPicker.show(withTitle: "Sub Category", rows: subarray, initialSelection: self.nSelectedSubCategoryIdx, doneBlock: { (picker, index, value) in
            self.nSelectedSubCategoryIdx = index - 1
            self.btnSelDuration.alpha = 1.0
            if index == 0
            {
                self.nSelectedSubCategoryIdx = 0
                self.btnSelDuration.alpha = 0.5
                self.btnSelDuration.setTitle("Select Sub Category", for: .normal)
            }
            else
            {
                self.btnSelDuration.setTitle(subarray[index], for: .normal)
            }
            
        }, cancel: { (picker) in
            self.nSelectedSubCategoryIdx = 0
            self.btnSelDuration.alpha = 0.5
            self.btnSelDuration.setTitle("Select Sub Category", for: .normal)
        }, origin: sender)
    }
    @IBAction func btnSelCategoryTapped(_ sender: Any) {
        
        ActionSheetStringPicker.show(withTitle: "Select Category", rows: array , initialSelection: nSelectedCategoryIdx, doneBlock: { (picker, index, value) in
            self.nSelectedCategoryIdx = index - 1
            self.btnSelCategory.alpha = 1.0
            if index == 0
            {
                self.nSelectedCategoryIdx = 0
                self.btnSelCategory.alpha = 0.5
                self.btnSelCategory.setTitle("Select Category", for: .normal)
                self.nSelectedSubCategoryIdx = 0
                self.btnSelDuration.alpha = 0.5
                self.btnSelDuration.setTitle("Select Sub Category", for: .normal)
            }
            else
            {
                let list = Array(Global.shared.AllCategory.keys)
                self.btnSelCategory.setTitle(list[self.nSelectedCategoryIdx], for: .normal)
                self.nSelectedSubCategoryIdx = 0
                self.btnSelDuration.alpha = 0.5
                self.btnSelDuration.setTitle("Select Sub Category", for: .normal)
            }
        }, cancel: { (picker) in
            self.nSelectedCategoryIdx = 0
            self.btnSelCategory.alpha = 0.5
            self.btnSelCategory.setTitle("Select Category", for: .normal)
            self.nSelectedSubCategoryIdx = 0
            self.btnSelDuration.alpha = 0.5
            self.btnSelDuration.setTitle("Select Sub Category", for: .normal)
        }, origin: sender)
        
        
    }
    @IBAction func onDone(_ sender: UIButton) {
        if type == 0{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Update_Filter"), object: nil, userInfo: ["data":["username": txtUsername.text, "type":nSelectedType,"category":(btnSelCategory.title(for: .normal)=="Select Category") ? "All":((btnSelDuration.title(for: .normal) == "Select Sub Category") ?btnSelCategory.title(for: .normal):btnSelCategory.title(for: .normal)! +  "," + btnSelDuration.title(for: .normal)!) ?? "","duration":nSelectedDurationIdx,"cat":nSelectedCategoryIdx,"subcat":nSelectedSubCategoryIdx,"keyword":tfKeyword.text!]])
        }
        else
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Update_Filter_archive"), object: nil, userInfo: ["data":["username": txtUsername.text, "type":nSelectedType,"category":(btnSelCategory.title(for: .normal)=="Select Category") ? "All":((btnSelDuration.title(for: .normal) == "Select Sub Category") ?btnSelCategory.title(for: .normal):btnSelCategory.title(for: .normal)! +  "," + btnSelDuration.title(for: .normal)!) ?? "","duration":nSelectedDurationIdx,"cat":nSelectedCategoryIdx,"subcat":nSelectedSubCategoryIdx,"keyword":tfKeyword.text!]])
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onChange(_ sender: UISegmentedControl) {
        nSelectedType = sender.selectedSegmentIndex
    }
}
