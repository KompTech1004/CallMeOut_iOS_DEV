//
//  SettingsVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Signout(_ sender: Any) {
        let storybord = UIStoryboard(name: "Signin", bundle: nil)
        let vc = storybord.instantiateViewController(withIdentifier: "LandingVC")
        SlideNavigationController.sharedInstance().popAllAndSwitch(to: vc, withSlideOutAnimation: true, andCompletion: nil)
        UserDefaults.standard.set(nil, forKey: "User")
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BlockUser(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BlockVC")
        self.present(vc!, animated: true, completion: nil)
    }
    @IBAction func ChangeEmail(_ sender: Any) {
        let storyboard = self.storyboard
        let vc = storyboard?.instantiateViewController(withIdentifier: "CEVC") as! CEVC
        present(vc, animated: true, completion: nil)
    }
    @IBAction func ChangePassword(_ sender: Any) {
        let storyboard = self.storyboard
        let vc = storyboard?.instantiateViewController(withIdentifier: "CPVC") as! CPVC
        present(vc, animated: true, completion: nil)
    }
}
