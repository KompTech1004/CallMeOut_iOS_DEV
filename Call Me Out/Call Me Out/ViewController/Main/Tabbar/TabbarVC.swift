//
//  TabbarVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class TabbarVC: UITabBarController,SlideNavigationControllerDelegate,UITabBarControllerDelegate {
    
    let button = UIButton.init(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 0
        
        button.setImage(UIImage(named: "btnAddRed.png"), for: .normal)
        button.layer.cornerRadius = self.tabBar.frame.size.height / 2
        button.layer.borderWidth = 0
        self.view.insertSubview(button, aboveSubview: tabBar)
        button.addTarget(self, action: #selector(add), for: .touchUpInside)
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificaion), name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificaion), name: NSNotification.Name(rawValue: "receive_notification1"), object: nil)
        
        updateNotificaion()
        
        for tabBarItem in self.tabBar.items! {
            tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -5)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateNotificaion()
//        Global.shared.getUnreadNotificationCount(userid: (Global.getUserDataFromLocal()?.id)!) { (count) in
//            if count == 0
//            {
//                self.tabBar.items?[3].badgeValue = nil
//            }
//            else{
//                self.tabBar.items?[3].badgeValue = String(count)
//            }
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.frame = CGRect(x: self.tabBar.center.x - (self.tabBar.frame.size.height - (Utils.isIPhoneX() ? 34 : 0)) / 2, y: self.view.bounds.height - self.tabBar.frame.size.height, width: self.tabBar.frame.size.height - (Utils.isIPhoneX() ? 34 : 0), height: self.tabBar.frame.size.height - (Utils.isIPhoneX() ? 34 : 0))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func slideNavigationControllerShouldDisplayLeftMenu() -> Bool {
        return true
    }
    @objc func updateNotificaion()
    {
        let count = UIApplication.shared.applicationIconBadgeNumber
        
        if count == 0
        {
            tabBar.items?[3].badgeValue = nil
        }
        else{
            tabBar.items?[3].badgeValue = String(count)
        }
    }
    
    @objc func add()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateCallVC")
        present(vc!, animated: true, completion: nil)
    }
}
