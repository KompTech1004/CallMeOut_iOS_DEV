//
//  SlideMenuVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class SlideMenuVC: UIViewController {

    @IBOutlet weak var tblViMenu: UITableView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgViAvatar: UIImageView!
    
    @IBOutlet weak var btnCreateCallOut: UIButton!
    
    var arrayMenuItems = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arrayMenuItems =
            [["title":"Home (Active Call Outs)","thumb":"menuIconHome.png"],
             ["title":"Search", "thumb":"menuIconSearch.png"],
             ["title":"Profile","thumb":"iconUserCyan.png"],
             ["title":"Notifications", "thumb":"iconNotification.png"],
             ["title":"Call Out Archives", "thumb":"menuIconArchives.png"],
             ["title":"Call Out Rank Board", "thumb":"menuIconRank.png"],
             ["title":"Invite Friends", "thumb":"iconInviteFriends.png"],
             ["title":"Settings", "thumb":"menuIconSettings.png"],
             ["title":"Sign Out", "thumb":"menuIconLogout.png"]];
        
        btnCreateCallOut.layer.cornerRadius = 6
        btnCreateCallOut.clipsToBounds = true
        
        tblViMenu.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name(rawValue: "update_menu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotification), name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotification), name: NSNotification.Name(rawValue: "receive_notification1"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imgViAvatar.layer.masksToBounds = true
        imgViAvatar.layer.cornerRadius = imgViAvatar.frame.size.width / 2.0
        imgViAvatar.layer.borderColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6).cgColor
        imgViAvatar.layer.borderWidth = 1.0
        
    }
    
    @objc func updateNotification()
    {
        tblViMenu.reloadData()
    }
    
    @objc func updateProfile()
    {
        let user = Global.getUserDataFromLocal()
//        imgViAvatar.af_setImage(withURL: URL.init(string: (user?.avatar)!)!,placeholderImage:#imageLiteral(resourceName: "avatarEmpty.png"))
        
        imgViAvatar.sd_setImage(with: URL(string: user?.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        
        lblUserName.text = "\(user?.first_name ?? "") \(user?.last_name ?? "")"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let user = Global.getUserDataFromLocal()
        
        imgViAvatar.sd_setImage(with: URL(string: user?.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        
        lblUserName.text = "\(user?.first_name ?? "") \(user?.last_name ?? "")"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onProfile(_ sender: UIButton) {
        SlideNavigationController.sharedInstance().closeMenu {
            Global.shared.tabbar?.selectedIndex = 4
        }
    }
    @IBAction func onCreateCallout(_ sender: UIButton) {
        SlideNavigationController.sharedInstance().closeMenu {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateCallVC")
            Global.shared.tabbar?.present(vc!, animated: false, completion: nil)
        }
    }
}
extension SlideMenuVC:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenuItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuCell
        cell.lblMenuTitle.text = arrayMenuItems[indexPath.row]["title"]
        cell.imgViThumb.image = UIImage(named: arrayMenuItems[indexPath.row]["thumb"]!)
        
        
        let count = UIApplication.shared.applicationIconBadgeNumber
        if indexPath.row == 3 && count > 0
        {
            cell.lblCounts.layer.masksToBounds = true
            cell.lblCounts.layer.cornerRadius = cell.lblCounts.frame.size.width / 2.0

            cell.lblCounts.isHidden = false
            cell.lblCounts.text = String(count)
        }
        else{
            cell.lblCounts.isHidden = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            SlideNavigationController.sharedInstance().closeMenu {
                Global.shared.tabbar?.selectedIndex = 0
            }
            break
        case 1:
            SlideNavigationController.sharedInstance().closeMenu {
                Global.shared.tabbar?.selectedIndex = 1
            }
            break
        case 2:
            SlideNavigationController.sharedInstance().closeMenu {
                Global.shared.tabbar?.selectedIndex = 4
            }
            break
        case 3:
            SlideNavigationController.sharedInstance().closeMenu {
                Global.shared.tabbar?.selectedIndex = 3
            }
            break
        case 4:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ArchiveVC")
            SlideNavigationController.sharedInstance().closeMenu(completion: nil)
            Global.shared.tabbar?.present(vc!, animated: false, completion: nil)
            break
        case 5:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RankingVC")
            SlideNavigationController.sharedInstance().closeMenu(completion: nil)
            Global.shared.tabbar?.present(vc!, animated: false, completion: nil)
            break
        case 6:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "InviteVC")
            SlideNavigationController.sharedInstance().closeMenu(completion: nil)
            Global.shared.tabbar?.present(vc!, animated: false, completion: nil)
            break
        case 7:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC")
            SlideNavigationController.sharedInstance().closeMenu(completion: nil)
            Global.shared.tabbar?.present(vc!, animated: false, completion: nil)
//            SlideNavigationController.sharedInstance().closeMenu {
//                Global.shared.tabbar?.present(vc!, animated: false, completion: nil)
//            }
            break
        case 8:
            Global.shared.logout(userId: (Global.getUserDataFromLocal()?.id)!) {
                let storybord = UIStoryboard(name: "Signin", bundle: nil)
                let vc = storybord.instantiateViewController(withIdentifier: "LandingVC")
                SlideNavigationController.sharedInstance().popAllAndSwitch(to: vc, withSlideOutAnimation: true, andCompletion: nil)
                UserDefaults.standard.set(nil, forKey: "User")
                UserDefaults.standard.synchronize()
            }
            break
        default:
            break
        }
    }
}
