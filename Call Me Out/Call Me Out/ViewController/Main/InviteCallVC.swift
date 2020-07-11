//
//  InviteCallVC.swift
//  Call Me Out
//
//  Created by B S on 4/18/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import TagListView

class InviteCallVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchedUsers = [User]()
    var invitedUsers = [User]()
    
    var searchKeyword: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tagListView.delegate = self
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tagListView.frame = CGRect(x: 0, y: tagListView.frame.origin.y, width: scrollView.frame.width, height: tagListView.frame.height)
        scrollView.alwaysBounceHorizontal = true
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height)
        if invitedUsers.count != 0
        {
            for user in invitedUsers
            {
                let tag = tagListView.addTag(user.username)
                tagListView.frame = CGRect(x: tagListView.frame.origin.x, y: tagListView.frame.origin.y, width: tagListView.frame.width + tag.frame.width, height: tagListView.frame.height)
                scrollView.contentSize = CGSize(width: tagListView.frame.width, height: scrollView.frame.height)
                scrollView.setContentOffset(CGPoint(x: tagListView.frame.width - scrollView.frame.width - tag.frame.width, y: 0), animated: true)
            }
        }
    }
    @IBAction func selectall(_ sender: Any) {
        self.view.makeToast("You select All people.")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Select All People"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    func checkExist(_ userlist:[User],_ user:User)->Bool{
        for u in userlist
        {
            if u.id == user.id
            {
                return true
            }
        }
        return false
    }
    @objc func add(_ sender:UIButton)
    {
        let user = searchedUsers[sender.tag]
        if checkExist(invitedUsers,user)
        {
            removeInvite(user)
        }
        else{
            addInvite(user)
        }
        tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
    }
    func removeInvite(_ user:User)
    {
        var i = 0
        for u in invitedUsers{
            if u.id == user.id
            {
                invitedUsers.remove(at: i)
                tagListView.removeTag(user.username)
                let tag = TagView(title: user.username)
                tagListView.frame = CGRect(x: 20, y: tagListView.frame.origin.y, width: tagListView.frame.width - tag.frame.width, height: tagListView.frame.height)
                scrollView.contentSize = CGSize(width: tagListView.frame.width , height: scrollView.frame.height)
                scrollView.setContentOffset(CGPoint(x: tagListView.frame.width - scrollView.frame.width - tag.frame.width, y: 0), animated: true)
            }
            i = i+1
        }
//        if let i = invitedUsers.index(of: user)
//        {
//            invitedUsers.remove(at: i)
//            tagListView.removeTag(user.username)
//            let tag = TagView(title: user.username)
//            tagListView.frame = CGRect(x: 20, y: tagListView.frame.origin.y, width: tagListView.frame.width - tag.frame.width, height: tagListView.frame.height)
//            scrollView.contentSize = CGSize(width: tagListView.frame.width , height: scrollView.frame.height)
//            scrollView.setContentOffset(CGPoint(x: tagListView.frame.width - scrollView.frame.width - tag.frame.width, y: 0), animated: true)
//        }
    }
    func addInvite(_ user:User)
    {
        invitedUsers.append(user)
        let tag = tagListView.addTag(user.username)
        tagListView.frame = CGRect(x: tagListView.frame.origin.x, y: tagListView.frame.origin.y, width: tagListView.frame.width + tag.frame.width, height: tagListView.frame.height)
        scrollView.contentSize = CGSize(width: tagListView.frame.width, height: scrollView.frame.height)
        scrollView.setContentOffset(CGPoint(x: tagListView.frame.width - scrollView.frame.width - tag.frame.width, y: 0), animated: true)
    }

    @IBAction func btnDoneTapped(_ sender: Any) {
        if invitedUsers.count == 0
        {
//            self.view.makeToast("Please select members")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Select All People"), object: nil)
            self.dismiss(animated: true, completion: nil)
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "peoples"), object: nil, userInfo: ["data":invitedUsers])
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension InviteCallVC:UITableViewDataSource,UITableViewDelegate,TagListViewDelegate,UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == ""
        {
            view.endEditing(true)
            self.searchedUsers.removeAll()
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: nil)
            self.tableView.reloadData()
        }
        else
        {
            searchKeyword = searchText
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: nil)
            self.perform(#selector(reload), with: nil, afterDelay: 0.75)
        }
    }
    
    @objc func reload() {
        Global.shared.search(userid: String((Global.getUserDataFromLocal()?.id)!), type: "user", key: searchKeyword) { (flag, result) in
            if result == nil{
                return
            }
            
            var sortedUsers = [User]()
            for user in result as! [User] {
                if user.username.lowercased() == self.searchKeyword.lowercased() || user.username.lowercased().hasPrefix(self.searchKeyword.lowercased()) {
                    sortedUsers.insert(user, at: 0)
                } else {
                    sortedUsers.append(user)
                }
            }
            
            self.searchedUsers = sortedUsers
//            let user = Global.getUserDataFromLocal()
//            if (user?.username.contains(self.searchKeyword))!
//            {
//                self.searchedUsers.append(user!)
//            }
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserCell
        
        cell.lblUserName.text = searchedUsers[indexPath.row].username

        cell.imgAvatar.sd_setImage(with: URL(string: searchedUsers[indexPath.row].avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        
        if checkExist(invitedUsers, searchedUsers[indexPath.row])
        {
            cell.btnAdd.setImage(#imageLiteral(resourceName: "iconMinus.png"), for: .normal)
        }
        else{
            cell.btnAdd.setImage(#imageLiteral(resourceName: "iconPlus.png"), for: .normal)
        }
        cell.btnAdd.tag = indexPath.row
        cell.btnAdd.addTarget(self, action: #selector(add(_:)), for: .touchUpInside)
        return cell
    }
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagListView.removeTagView(tagView)
        var index = 0
        for user in invitedUsers
        {
            if user.username == title
            {
                break
            }
            index = index + 1
        }
        invitedUsers.remove(at: index)
        //        self.tagListView.frame = CGRect(x: 20, y: self.tagListView.frame.origin.y, width: self.tagListView.frame.width - tagView.frame.width, height: tagView.frame.height)
        //        scrollView.contentSize = CGSize(width: tagView.frame.width , height: scrollView.frame.height)
        //        scrollView.setContentOffset(CGPoint(x: self.tagListView.frame.width - scrollView.frame.width - tagView.frame.width, y: 0), animated: true)
        
        let tag = TagView(title: title)
        tagListView.frame = CGRect(x: 20, y: tagListView.frame.origin.y, width: tagListView.frame.width - tag.frame.width, height: tagListView.frame.height)
        scrollView.contentSize = CGSize(width: tagListView.frame.width , height: scrollView.frame.height)
        scrollView.setContentOffset(CGPoint(x: tagListView.frame.width - scrollView.frame.width - tag.frame.width, y: 0), animated: true)
        
        if searchedUsers.count != 0
        {
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagListView.removeTagView(tagView)
        var index = 0
        for user in invitedUsers
        {
            if user.username == title
            {
                break
            }
            index = index + 1
        }
        invitedUsers.remove(at: index)
//        self.tagListView.frame = CGRect(x: 20, y: self.tagListView.frame.origin.y, width: self.tagListView.frame.width - tagView.frame.width, height: tagView.frame.height)
//        scrollView.contentSize = CGSize(width: tagView.frame.width , height: scrollView.frame.height)
//        scrollView.setContentOffset(CGPoint(x: self.tagListView.frame.width - scrollView.frame.width - tagView.frame.width, y: 0), animated: true)
        
        let tag = TagView(title: title)
        tagListView.frame = CGRect(x: 20, y: tagListView.frame.origin.y, width: tagListView.frame.width - tag.frame.width, height: tagListView.frame.height)
        scrollView.contentSize = CGSize(width: tagListView.frame.width , height: scrollView.frame.height)
        scrollView.setContentOffset(CGPoint(x: tagListView.frame.width - scrollView.frame.width - tag.frame.width, y: 0), animated: true)
        
        if searchedUsers.count != 0
        {
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
