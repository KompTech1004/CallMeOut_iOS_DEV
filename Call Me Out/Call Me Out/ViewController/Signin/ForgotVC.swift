//
//  ForgotVC.swift
//  Call Me Out
//
//  Created by B S on 6/3/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import ProgressHUD

class ForgotVC: UIViewController {

    @IBOutlet weak var navHeightconstraint: NSLayoutConstraint!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfCode: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfComfirm: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnVerify: UIButton!
    
    var code = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Utils.isIPhoneX() {
            navHeightconstraint.constant = 84
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func sendAction(_ sender: Any) {
        if tfEmail.text == ""
        {
            self.view.makeToast("Please enter your email!")
            return
        }
        ProgressHUD.show("Sending Email", interaction: false)
        Global.shared.verifyEmail(email: tfEmail.text!) { (result, code) in
            ProgressHUD.dismiss()
            if result
            {
                self.code = code
                self.view.makeToast("Please check your email for verification code")
            }
            else
            {
                self.view.makeToast("Your email is not registered on our system. Please try with correct email")
            }
        }
    }
    
    @IBAction func verifyAction(_ sender: Any) {
        if tfCode.text! == code{
            lblEmail.alpha = 0.2
            lblCode.alpha = 0.2
            btnSend.alpha = 0.2
            btnSend.isEnabled = false
            btnVerify.alpha = 0.2
            btnVerify.isEnabled = false
            tfEmail.alpha = 0.2
            tfEmail.isEnabled = false
            tfCode.alpha = 0.2
            tfCode.isEnabled = false
            
            self.view.makeToast("Now please reset your password")
        }
        else
        {
            self.view.makeToast("Please enter correct Code")
        }
    }
    @IBAction func resetAction(_ sender: Any) {
        if tfPassword.text! == "" || tfPassword.text != tfComfirm.text
        {
            self.view.makeToast("Please enter correct password")
            return
        }
        ProgressHUD.show("Reset Password...", interaction: false)
        Global.shared.resetPassword(email: tfEmail.text!, password: tfPassword.text!) { (result) in
            ProgressHUD.dismiss()
            if result
            {
                self.view.makeToast("Success")
            }
            else
            {
                self.view.makeToast("Reset Password Failed.")
            }
        }
    }
}
