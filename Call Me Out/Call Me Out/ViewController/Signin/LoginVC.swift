//
//  LoginVC.swift
//  Call Me Out
//
//  Created by B S on 4/2/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import ProgressHUD
import Toast_Swift
import Firebase
import GoogleSignIn
import FacebookLogin
import FacebookCore

class LoginVC: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    @IBOutlet weak var viLoading: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblLoading: UILabel!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var viLogin: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viLoading.layer.masksToBounds = true;
        viLoading.layer.cornerRadius = 6.0;
        
        btnLogin.layer.masksToBounds = true;
        btnLogin.layer.cornerRadius = 6.0;
        
        GIDSignIn.sharedInstance().clientID = "844385867151-u2trg3t01fuspk360hd92silhgjev75b.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
//        let tapBg = UITapGestureRecognizer(target: self, action: #selector())
//        self.view.addGestureRecognizer(tapBg)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.scrlLogin.contentSize = CGSize(width: self.view.frame.size.width, height: self.viLogin.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnSignupTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Signin", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        if tfEmail.text == "" || !Utils.isValidEmail(email: tfEmail.text)
        {
            present(Utils.alertWithText(errorText: "Please enter valid email", title: "Error", cancelTitle: "Ok", cancelAction: nil, otherButtonTitle: nil, otherButtonStyle: .cancel, otherButtonAction: nil), animated: true, completion: nil)
            return 
        } else if tfPassword.text == "" || tfPassword.text == nil {
            present(Utils.alertWithText(errorText: "Please enter valid password", title: "Error", cancelTitle: "Ok", cancelAction: nil, otherButtonTitle: nil, otherButtonStyle: .cancel, otherButtonAction: nil), animated: true, completion: nil)
            return
        }
        
        ProgressHUD.show("Loading...",interaction:false)
        Global.shared.login(email: tfEmail.text!, password: tfPassword.text!) { (flag, result) in
            ProgressHUD.dismiss()
            if flag
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let main = storyboard.instantiateViewController(withIdentifier: "TabbarVC")
                Global.shared.tabbar = main as? TabbarVC
                SlideNavigationController.sharedInstance().popToRootAndSwitch(to: main, withSlideOutAnimation: false, andCompletion: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_menu"), object: nil)
                if let token = InstanceID.instanceID().token()
                {
                    print(token)
                    if let user = Global.getUserDataFromLocal(){
                        Global.shared.updateFcm(userid: String(user.id), token: token) { (flag, result) in
                            print(result)
                        }
                        
                        Global.shared.getUnreadNotificationCount(userid: user.id, handler: { (count) in
                            UIApplication.shared.applicationIconBadgeNumber = count
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
                        })
                    }
                }
                
            }
            else{
//                ProgressHUD.showError(result)
                self.view.makeToast(result)
            }
        }
    }
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotVC") as! ForgotVC
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func facebookSignin(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile,.email], viewController: self) { (result) in
            switch result
            {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(grantedPermissions: let grantedPermission, declinedPermissions: let declinedPermission, token: let accessToken):
                    ProgressHUD.show("Getting information", interaction: false)
                    GraphRequest(graphPath: "/me",parameters:["fields":" email, name, picture.width(480).height(480),first_name, last_name"]).start({ (response, result1) in
                        ProgressHUD.dismiss()
                        switch result1
                        {
                        case .success(response: let response):
                            print (response.dictionaryValue)
                            let email = response.dictionaryValue!["email"] as? String ?? ""
                            let name = response.dictionaryValue!["name"] as? String ?? ""
                            let first_name = response.dictionaryValue!["first_name"] as? String ?? ""
                            let last_name = response.dictionaryValue!["last_name"] as? String ?? ""
                            let picure = ((response.dictionaryValue!["picture"] as? NSDictionary)?.value(forKey: "data") as? NSDictionary)?.value(forKey: "url") as? String ?? ""
                            Global.shared.socialRegister(email: email, username: name, password: "facebook", first_name: first_name, last_name: last_name, path: picure ,type:"facebook") { (flag, result) in
                                if flag{
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let main = storyboard.instantiateViewController(withIdentifier: "TabbarVC")
                                    Global.shared.tabbar = main as? TabbarVC
                                    SlideNavigationController.sharedInstance().popToRootAndSwitch(to: main, withSlideOutAnimation: false, andCompletion: nil)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_menu"), object: nil)
                                    if let token = InstanceID.instanceID().token()
                                    {
                                        print(token)
                                        if let user = Global.getUserDataFromLocal(){
                                            Global.shared.updateFcm(userid: String(user.id), token: token) { (flag, result) in
                                                print(result)
                                            }
                                            
                                            Global.shared.getUnreadNotificationCount(userid: user.id, handler: { (count) in
                                                UIApplication.shared.applicationIconBadgeNumber = count
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
                                            })
                                        }
                                    }
                                }
                                else{
                                    self.view.makeToast(result)
                                }
                            }
                            print("success")
                        case .failed(let error):
                            print(error)
                        }
                    })
                    print("login success")
            }
        }
    }
    @IBAction func googleSignin(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance().signIn()
    }
}
extension LoginVC:GIDSignInDelegate,GIDSignInUIDelegate
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil)
        {
            let email = user.profile.email
            let username = email?.components(separatedBy: "@")[0]
            Global.shared.socialRegister(email: email!, username: username!, password: "google", first_name: user.profile.familyName, last_name: user.profile.givenName, path: user.profile.imageURL(withDimension: 400).absoluteString,type:"Google") { (flag, result) in
                if flag{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let main = storyboard.instantiateViewController(withIdentifier: "TabbarVC")
                    Global.shared.tabbar = main as? TabbarVC
                    SlideNavigationController.sharedInstance().popToRootAndSwitch(to: main, withSlideOutAnimation: false, andCompletion: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_menu"), object: nil)
                    if let token = InstanceID.instanceID().token()
                    {
                        print(token)
                        if let user = Global.getUserDataFromLocal(){
                            Global.shared.updateFcm(userid: String(user.id), token: token) { (flag, result) in
                                print(result)
                            }
                            
                            Global.shared.getUnreadNotificationCount(userid: user.id, handler: { (count) in
                                UIApplication.shared.applicationIconBadgeNumber = count
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
                            })
                        }
                    }
                }
                else{
                    self.view.makeToast(result)
                }
            }
        }
        else
        {
            
        }
    }
    
    
}
