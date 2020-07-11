//
//  CEVC.swift
//  Call Me Out
//
//  Created by B S on 5/21/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import ProgressHUD

class CEVC: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
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
        if tfEmail.text == ""
        {
            self.view.makeToast("Please enter new email address")
            return
        }
        if tfEmail.text! == Global.getUserDataFromLocal()?.email
        {
            self.view.makeToast("Same as current email address")
            return
        }
        ProgressHUD.show("Updating Email", interaction: false)
        Global.shared.changeEmail(userid: String((Global.getUserDataFromLocal()?.id)!), email: tfEmail.text!) { (flag) in
            ProgressHUD.dismiss()
            if flag
            {
                self.view.makeToast("Success!")
                let user = Global.getUserDataFromLocal()
                user?.email = self.tfEmail.text!
                Global.saveUserData(user: user!)
            }
            else
            {
                self.view.makeToast("Error!")
            }
        }
    }
}
