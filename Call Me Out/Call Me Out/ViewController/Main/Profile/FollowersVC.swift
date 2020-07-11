//
//  FollowersVC.swift
//  Call Me Out
//
//  Created by B S on 4/17/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class FollowersVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var user:User?
    var type = 0 //if 0, follower and if 1, following
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if type == 0
        {
            lblTitle.text = "Followers"
        }
        else
        {
            lblTitle.text = "Following"
        }
        
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "cell")
        if let u = user{
            if type == 1
            {
                Global.shared.getFollower(userid: String(u.id), callerid: String((Global.getUserDataFromLocal()?.id)!)) { (flag, result) in
                    if let r = result, flag
                    {
                        self.users = r
                        self.tableView.reloadData()
                    }
                }
            }
            else
            {
                Global.shared.getFollowing(userid: String(u.id), callerid: String((Global.getUserDataFromLocal()?.id)!)) { (flag, result) in
                    if let r = result, flag
                    {
                        self.users = r
                        self.tableView.reloadData()
                    }
                }
            }
        }
        else
        {
            if type == 1{
                Global.shared.getFollower(userid: String((Global.getUserDataFromLocal()?.id)!), callerid: String((Global.getUserDataFromLocal()?.id)!)) { (flag, result) in
                    if let r = result, flag
                    {
                        self.users = r
                        self.tableView.reloadData()
                    }
                }
            }
            else
            {
                Global.shared.getFollowing(userid: String((Global.getUserDataFromLocal()?.id)!), callerid: String((Global.getUserDataFromLocal()?.id)!)) { (flag, result) in
                    if let r = result, flag
                    {
                        self.users = r
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}

extension FollowersVC:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserCell
        let u = users[indexPath.row]
        if let url = URL(string: u.avatar)
        {
            cell.imgAvatar.sd_setImage(with: URL(string: u.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        }
        else
        {
            cell.imgAvatar.image = #imageLiteral(resourceName: "avatarEmpty.png")
        }
        cell.lblUserName.text = u.username
        cell.btnAdd.isHidden = true
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if users[indexPath.row].id == Global.getUserDataFromLocal()?.id
        {
            let user = users[indexPath.row]
            if user.isBlocked {
                self.view.makeToast("Sorry, you are unable to view \(user.username)'s content")
                return
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            vc.user = users[indexPath.row]
            vc.isMe = false
            self.present(vc, animated: true, completion: nil)
        }
        else
        {
            let user = users[indexPath.row]
            if user.isBlocked {
                self.view.makeToast("Sorry, you are unable to view \(user.username)'s content")
                return
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Profile1VC") as! Profile1VC
            vc.user = users[indexPath.row]
            self.present(vc, animated: true, completion: nil)
        }
    }
}
