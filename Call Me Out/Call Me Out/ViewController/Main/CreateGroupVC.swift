//
//  CreateGroupVC.swift
//  Call Me Out
//
//  Created by B S on 4/5/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import TagListView
import ProgressHUD

class CreateGroupVC: UIViewController {

    @IBOutlet weak var viGroupName: UIView!
    @IBOutlet weak var tfGroupName: UITextField!
    @IBOutlet weak var viLoading: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblLoading: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblViUsers: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tagView: TagListView!
    
    var users = [User]()
    var selectedUsers = [String]()
    var selectedUserNames = [String]()
    var isCreate = true
    var group:Group?
    var invitedUsers = [User]()
    
    var searchKeyword: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viGroupName.layer.masksToBounds = true
        viGroupName.layer.cornerRadius = 6.0
        
        viLoading.layer.masksToBounds = true
        viLoading.layer.cornerRadius = 6.0
        
        tfGroupName.attributedPlaceholder = NSAttributedString(string: "Enter Group Name here", attributes: [NSAttributedStringKey.foregroundColor:UIColor(displayP3Red: 255.0, green: 255.0, blue: 255.0, alpha: 0.5)])
        if !isCreate
        {
            tfGroupName.text = group?.name
        }else
        {
            tfGroupName.text = ""
        }
        if group != nil{
            Global.shared.getGroupInfo(groupid: (group?.id)!) { (ids, names) in
                self.selectedUsers = ids.components(separatedBy: ",")
                self.selectedUserNames = names.components(separatedBy: ",")
                self.selectedUserNames.removeLast()
                self.selectedUsers = self.selectedUsers.filter{$0 != String((Global.getUserDataFromLocal()?.id)!)}
                self.selectedUserNames = self.selectedUserNames.filter{$0 != (Global.getUserDataFromLocal()?.username)!}
                
                for user in self.invitedUsers {
                    self.addGroup(id: "\(user.id)", username: user.username)
                }

                self.addData()
            }
        } else {
            for user in self.invitedUsers {
                self.addGroup(id: "\(user.id)", username: user.username)
            }
        }
        
        tblViUsers.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "cell")
//        tagView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tagView.frame = CGRect(x: 0, y: tagView.frame.origin.y, width: scrollView.frame.width, height: tagView.frame.height)
        scrollView.alwaysBounceHorizontal = true
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onDone(_ sender: Any) {
        if tfGroupName.text == "" {
            let alertController = UIAlertController(title: nil, message: "Please add group title", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(confirm)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if (selectedUsers.count == 0) {
            let alertController = UIAlertController(title: nil, message: "Please add member to group", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(confirm)
            self.present(alertController, animated: true, completion: nil)
            return
        }

        var group = ""
//        for member in selectedUsers {
//            if member == String((Global.getUserDataFromLocal()?.id)!)
//            {
//                continue
//            }
//            group = group  + member + ","
//        }
        
        group = selectedUsers.joined(separator: ",")
//        group = group + String((Global.getUserDataFromLocal()?.id)!)
        ProgressHUD.show("Create Group...", interaction: false)
        Global.shared.createGroup(creator: String((Global.getUserDataFromLocal()?.id)!), name: tfGroupName.text!, member: group,groupid:(self.group != nil) ? (self.group?.id)!:"0") { (flag, result) in
            ProgressHUD.dismiss()
            if flag
            {
                self.view.makeToast("Success")
                NotificationCenter.default.post(name: NSNotification.Name("create_group"), object: nil, userInfo: ["group":self.tfGroupName.text!])
                self.dismiss(animated: false, completion: nil   )
            }
            else
            {
                self.view.makeToast(result)
            }
        }
    }
    @objc func add(_ sender:UIButton)
    {
        let user = users[sender.tag]
        if selectedUsers.contains(String(user.id))
        {
            removeGroup(id: String(user.id), username: user.username)
        }
        else{
            addGroup(id: String(user.id), username: user.username)
        }
        tblViUsers.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
    }
    func removeGroup(id:String,username:String)
    {
        if let i = selectedUsers.index(of: id)
        {
            selectedUsers.remove(at: i)
            selectedUserNames.remove(at: i)
            tagView.removeTag(username)
            let tag = TagView(title: username)
            tagView.frame = CGRect(x: 20, y: tagView.frame.origin.y, width: tagView.frame.width - tag.frame.width, height: tagView.frame.height)
            scrollView.contentSize = CGSize(width: tagView.frame.width , height: scrollView.frame.height)
            scrollView.setContentOffset(CGPoint(x: tagView.frame.width - scrollView.frame.width - tag.frame.width, y: 0), animated: true)
        }
    }
    func addData()
    {
//        var index = 0
        for username in selectedUserNames
        {
            let tag = tagView.addTag(username)
            tagView.frame = CGRect(x: tagView.frame.origin.x, y: tagView.frame.origin.y, width: tagView.frame.width + tag.frame.width, height: tagView.frame.height)
            scrollView.contentSize = CGSize(width: tagView.frame.width, height: scrollView.frame.height)
            scrollView.setContentOffset(CGPoint(x: tagView.frame.width - scrollView.frame.width - tag.frame.width, y: 0), animated: true)
//            index = index + 1
        }
    }
    func addGroup(id:String,username:String)
    {
        selectedUsers.append(id)
        selectedUserNames.append(username)
        let tag = tagView.addTag(username)
        tagView.frame = CGRect(x: tagView.frame.origin.x, y: tagView.frame.origin.y, width: tagView.frame.width + tag.frame.width, height: tagView.frame.height)
        scrollView.contentSize = CGSize(width: tagView.frame.width, height: scrollView.frame.height)
        scrollView.setContentOffset(CGPoint(x: tagView.frame.width - scrollView.frame.width - tag.frame.width, y: 0), animated: true)
    }
}
extension CreateGroupVC:UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,TagListViewDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == ""
        {
            view.endEditing(true)
            self.users.removeAll()
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: nil)
            self.tblViUsers.reloadData()
        }
        else
        {
            searchKeyword = searchText
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: nil)
            self.perform(#selector(reload), with: nil, afterDelay: 0.75)
            
            Global.shared.search(userid: String((Global.getUserDataFromLocal()?.id)!), type: "user", key: searchText) { (flag, result) in
                self.users = result as! [User]
                self.tblViUsers.reloadData()
            }
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
            
            self.users = sortedUsers
            self.tblViUsers.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        users.removeAll()
        tblViUsers.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserCell
        
        cell.lblUserName.text = users[indexPath.row].username

        cell.imgAvatar.sd_setImage(with: URL(string: users[indexPath.row].avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        
        if selectedUsers.contains(String(users[indexPath.row].id))
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
        if let i = selectedUserNames.index(of: title)
        {
            selectedUsers.remove(at: i)
            selectedUserNames.remove(at: i)
            let tag = TagView(title: title)
            self.tagView.frame = CGRect(x: 20, y: self.tagView.frame.origin.y, width: self.tagView.frame.width - tag.frame.width, height: self.tagView.frame.height)
            scrollView.contentSize = CGSize(width: self.tagView.frame.width , height: scrollView.frame.height)
            scrollView.setContentOffset(CGPoint(x: self.tagView.frame.width - scrollView.frame.width - tag.frame.width, y: 0), animated: true)
            if users.count != 0
            {
                tblViUsers.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
            }
        }
    }
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
        if let i = selectedUserNames.index(of: title)
        {
            selectedUsers.remove(at: i)
            selectedUserNames.remove(at: i)
            let tag = TagView(title: title)
            self.tagView.frame = CGRect(x: 20, y: self.tagView.frame.origin.y, width: self.tagView.frame.width - tag.frame.width, height: self.tagView.frame.height)
            scrollView.contentSize = CGSize(width: self.tagView.frame.width , height: scrollView.frame.height)
            scrollView.setContentOffset(CGPoint(x: self.tagView.frame.width - scrollView.frame.width - tag.frame.width, y: 0), animated: true)
            if users.count != 0
            {
                tblViUsers.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
            }
        }
    }
}
