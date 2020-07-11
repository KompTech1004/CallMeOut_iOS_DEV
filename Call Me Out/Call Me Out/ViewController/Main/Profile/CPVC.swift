//
//  CPVC.swift
//  Call Me Out
//
//  Created by B S on 5/21/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import ProgressHUD

class CPVC: UIViewController {

    @IBOutlet weak var tfCurrent: UITextField!
    @IBOutlet weak var tfNew: UITextField!
    @IBOutlet weak var tfConfirm: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneAction(_ sender: Any) {
        if tfCurrent.text! != Global.getUserDataFromLocal()?.password
        {
//            self.view.makeToast("Current Password is not matched")
            self.view.makeToast("Current Password is not matched")
            return
        }
        if tfNew.text != tfConfirm.text
        {
//            self.view.makeToast("Don't match password!")
            self.view.makeToast("Don't match password!")
            return
        }
        ProgressHUD.show("Change password", interaction: false)
        Global.shared.changePassword(userid: String((Global.getUserDataFromLocal()?.id)!), password: tfNew.text!) { (flag) in
            ProgressHUD.dismiss()
            if flag{
                self.view.makeToast("Success!")
                let user = Global.getUserDataFromLocal()
                user?.password = self.tfNew.text!
                Global.saveUserData(user: user!)
            }
            else
            {
                self.view.makeToast("Failed!")
            }
        }
    }
}
