//
//  BlockVC.swift
//  Call Me Out
//
//  Created by B S on 5/22/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import ProgressHUD

class BlockVC: UIViewController {
    var blockedUsers = [User]()
    var searchUsers = [User]()
    var type = 0
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "BlockUserCell", bundle: nil), forCellReuseIdentifier: "cell")
        Global.shared.getuserBlockList(userid: String((Global.getUserDataFromLocal()?.id)!)) { (result) in
            self.blockedUsers = result
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func checkBlock(_ user:User)->Bool
    {
        for u in blockedUsers
        {
            if u.id == user.id
            {
                return true
            }
        }
        return false
    }
    @objc func blockAction(_ sender:UIButton)
    {
        print(sender.tag)
        var user:User?
        if type == 0
        {
            user = blockedUsers[sender.tag]
        }
        else
        {
            user = searchUsers[sender.tag]
        }
        ProgressHUD.show("", interaction: false)
        let isBlock = (checkBlock(user!)) ? "0":"1"
        Global.shared.blockUser(userid: String((Global.getUserDataFromLocal()?.id)!), blocked_id: String((user?.id)!), value: (checkBlock(user!)) ? "0":"1") { (flag) in
            ProgressHUD.dismiss()
            if flag
            {
                self.view.makeToast("Success")
                if isBlock == "1"
                {
                    self.blockedUsers.append(user!)
                    self.searchUsers[sender.tag].isBlocked = true
                }
                else if isBlock == "0"
                {
                    var index = 0
                    for u in self.blockedUsers
                    {
                        if u.id == user?.id
                        {
                            self.blockedUsers.remove(at: index)
                            if self.searchUsers.count != 0
                            {
                                self.searchUsers[sender.tag].isBlocked = false
                            }
                            break
                        }
                        index = index + 1
                    }
                }
//                if self.blockedUsers.contains(user!)
//                {
//                    if let index = self.blockedUsers.index(of: user!)
//                    {
//                        self.blockedUsers.remove(at: index)
//                    }
//                    user?.isBlocked = false
//                }
//                else
//                {
//                    self.blockedUsers.append(user!)
//                    user?.isBlocked = true
//                }
                self.tableView.reloadData()
            }
            else
            {
                self.view.makeToast("Error occured")
            }
        }
    }
}
extension BlockVC:UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate
{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == ""
        {
            view.endEditing(true)
            type = 0
            self.searchUsers.removeAll()
            tableView.reloadData()
        }
        else
        {
            type = 1
            Global.shared.search(userid: String((Global.getUserDataFromLocal()?.id)!), type: "user", key: searchText) { (flag, result) in
                if result == nil{
                    return
                }
                
                var sortedUsers = [User]()
                for user in result as! [User] {
                    if user.username.lowercased() == searchText.lowercased() || user.username.lowercased().hasPrefix(searchText.lowercased()) {
                        sortedUsers.insert(user, at: 0)
                    } else {
                        sortedUsers.append(user)
                    }
                }
                
                self.searchUsers = sortedUsers
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == 0{
            return blockedUsers.count
        }
        else
        {
            return searchUsers.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BlockUserCell
        var user:User?
        if type == 0
        {
            user = blockedUsers[indexPath.row]
        }
        else
        {
            user = searchUsers[indexPath.row]
        }
//        cell.imgAvatar.af_setImage(withURL: URL(string: (user?.avatar)!)!,placeholderImage:#imageLiteral(resourceName: "avatarEmpty.png"))
        cell.imgAvatar.sd_setImage(with: URL(string: user?.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        cell.lblUsername.text = user?.username
        cell.btnBlock.tag = indexPath.row
        if (user?.isBlocked)!
        {
            cell.btnBlock.backgroundColor = UIColor.white
            cell.btnBlock.setTitle("UnBlock", for: .normal)
            cell.btnBlock.setTitleColor(UIColor(displayP3Red: 0, green: 122/255, blue: 1, alpha: 1), for: .normal)
        }
        else
        {
            cell.btnBlock.backgroundColor = UIColor(displayP3Red: 0, green: 122/255, blue: 1, alpha: 1)
            cell.btnBlock.setTitle("Block", for: .normal)
            cell.btnBlock.setTitleColor(UIColor.white, for: .normal)
        }
        cell.btnBlock.addTarget(self, action: #selector(blockAction(_:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
