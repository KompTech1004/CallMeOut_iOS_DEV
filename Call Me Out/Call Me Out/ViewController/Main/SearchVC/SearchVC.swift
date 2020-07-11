//
//  SearchVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Player

class SearchVC: UIViewController {

    @IBOutlet weak var cltViSearch: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var active_callouts = [CallOut]()
    var archive_callouts = [CallOut]()
    var users = [User]()

    var searchType: String = "active"
    var searchKeyword: String = ""
    
    var selectedIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        tableView.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
        cltViSearch.register(UINib(nibName: "CallCell", bundle: nil), forCellWithReuseIdentifier: "CallCell")
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let font: [AnyHashable : Any] = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10
            )]
        segmentControl.setTitleTextAttributes(font, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for subView in searchBar.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    var bounds: CGRect
                    bounds = textField.frame
                    bounds.size.height = 30 //(set height whatever you want)
                    textField.frame = bounds
                    textField.backgroundColor = UIColor.black
                    textField.textColor = UIColor.white
                    textField.font = UIFont.systemFont(ofSize: 12.0)
                    
//                    textField.delegate = self
                }
            }
        }

        let font = UIFont.systemFont(ofSize: 12.0)
        segmentControl.setTitleTextAttributes([NSAttributedStringKey.font: font],
                                                for: .normal)
    }

    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
        switch sender.selectedSegmentIndex
        {
        case 0:
            cltViSearch.isHidden = false
            tableView.isHidden = true
            break
        case 1:
            cltViSearch.isHidden = false
            tableView.isHidden = true
            break
        case 2:
            cltViSearch.isHidden = true
            tableView.isHidden = false
            break
        case 3:
            cltViSearch.isHidden = false
            tableView.isHidden = true
        default:
            break
        }
        
        self.users = [User]()
        self.active_callouts = [CallOut]()
        self.archive_callouts = [CallOut]()
        tableView.reloadData()
        cltViSearch.reloadData()
        
        if searchBar.text == "" {
            return
        }
        
        if selectedIndex == 2 {
            search(type: "user", keyword: searchBar.text!)
        } else if selectedIndex == 1 {
            search(type: "archive", keyword: searchBar.text!)
        } else if selectedIndex == 0 {
            search(type: "active", keyword: searchBar.text!)
        } else {
            search(type: "content", keyword: searchBar.text!)
        }
    }
    
    @IBAction func onFilter(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilterVC")
        self.present(vc!, animated: true, completion: nil)
    }
    @IBAction func onShowLeftMenu(_ sender: Any) {
        SlideNavigationController.sharedInstance().open(MenuLeft, withCompletion: nil)
    }
}
extension SearchVC:UISearchBarDelegate
{
/*    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        self.users = [User]()
        self.active_callouts = [CallOut]()
        self.archive_callouts = [CallOut]()
        tableView.reloadData()
        cltViSearch.reloadData()
        return true
    }*/
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        self.users = [User]()
        self.active_callouts = [CallOut]()
        self.archive_callouts = [CallOut]()
        tableView.reloadData()
        cltViSearch.reloadData()
    }
    
    func search(type: String, keyword: String) {
        searchType = type
        searchKeyword = keyword
        
        Global.shared.search(userid: String((Global.getUserDataFromLocal()?.id)!), type: type, key: keyword) { (flag, result) in
            if result == nil {
                return
            }
            
            if type == "user" {
                var sortedUsers = [User]()
                for user in result as! [User] {
                    if user.username.lowercased() == keyword.lowercased() || user.username.lowercased().hasPrefix(keyword.lowercased()){
                        sortedUsers.insert(user, at: 0)
                    } else {
                        sortedUsers.append(user)
                    }
                }
                
                self.users = sortedUsers
                self.tableView.reloadData()
            } else if type == "archive" {
                self.archive_callouts = result as! [CallOut]
                self.cltViSearch.reloadData()
            } else if type == "active" {
                self.active_callouts = result as! [CallOut]
                self.cltViSearch.reloadData()
            } else { // content
                self.active_callouts = result as! [CallOut]
                self.cltViSearch.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == ""
        {
            view.endEditing(true)
            
            self.users = [User]()
            self.active_callouts = [CallOut]()
            self.archive_callouts = [CallOut]()

            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: nil)

            tableView.reloadData()
            cltViSearch.reloadData()
        }
        else
        {
            searchKeyword = searchText

            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: nil)
            self.perform(#selector(reload), with: nil, afterDelay: 0.75)
        }
    }
    
    @objc func reload() {
        if selectedIndex == 2 {
            search(type: "user", keyword: searchKeyword)
        } else if selectedIndex == 1 {
            search(type: "archive", keyword: searchKeyword)
        } else if selectedIndex == 0 {
            search(type: "active", keyword: searchKeyword)
        } else {
            search(type: "content", keyword: searchKeyword)
        }
    }
}
extension SearchVC:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var callout:CallOut?
        if selectedIndex == 0 || selectedIndex == 3
        {
            callout = active_callouts[indexPath.row]
        }
        else
        {
            callout = archive_callouts[indexPath.row]
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CallCell", for: indexPath) as! CallCell
        cell.imgViThumb1.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        cell.imgViThumb2.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        if selectedIndex == 0
        {
            cell.lblVote.isHidden = false
        }
        else{
            cell.lblVote.isHidden = true
        }
        cell.imgViAvatar1.layer.masksToBounds = true
        cell.imgViAvatar1.layer.cornerRadius = cell.imgViAvatar1.layer.frame.size.width / 2.0
        cell.imgViAvatar1.layer.borderColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6).cgColor
        
        if let challenger = callout?.challenger{
            if callout?.format == "audio"
            {
                cell.imgViThumb1.image = #imageLiteral(resourceName: "audio-wave.png")
                cell.leftViewController = nil
            }
            else if callout?.format == "video"
            {
//                DispatchQueue.main.async {
//                    cell.leftPlayer = Player()
//                    cell.leftPlayer?.url = URL(string: (callout?.challenge_video)!)!
//                    cell.leftPlayer?.muted = true
//                    cell.leftPlayer?.view.frame = cell.imgViThumb1.bounds
//                    cell.imgViThumb1.addSubview((cell.leftPlayer?.view)!)
//                    cell.leftPlayer?.playFromBeginning()
//                    cell.leftPlayer?.playbackLoops = true
//                    cell.leftPlayer?.fillMode = PlayerFillMode.resizeAspectFill.avFoundationType
//                }
                cell.imgViThumb1.sd_setImage(with: URL(string: callout?.challenge_thumb ?? ""), completed: nil)
            }
            else
            {
                cell.imgViThumb1.sd_setImage(with: URL(string: callout?.challenge_thumb ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
                cell.leftViewController = nil
            }

            cell.imgViAvatar1.sd_setImage(with: URL(string: challenger.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
            
            cell.lblUser1.text = challenger.username
            cell.imgViAvatar1.isHidden = false
            cell.lblUser1.isHidden = false
        }
        else{
            cell.imgViThumb1.image = #imageLiteral(resourceName: "avatarEmpty.png")
            cell.imgViAvatar1.isHidden = true
            cell.lblUser1.isHidden = true
        }

        if callout?.challenger == nil || selectedIndex == 0
        {
            cell.lblWinner.isHidden = true
            cell.lblWinnerRight.isHidden = true
        }
        else
        {
            if Int((callout?.cnt_vote_poster)!)! > Int((callout?.cnt_vote_challneger)!)!
            {
                cell.lblWinnerRight.isHidden = false
                cell.lblWinner.isHidden = true
            }
            else
            {
                cell.lblWinner.isHidden = false
                cell.lblWinnerRight.isHidden = true
            }
        }
        
        cell.imgViAvatar1.layer.borderWidth = 0.8
        
        cell.imgViAvatar2.layer.masksToBounds = true
        cell.imgViAvatar2.layer.cornerRadius = cell.imgViAvatar1.layer.frame.size.width / 2.0
        cell.imgViAvatar2.layer.borderColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6).cgColor
        cell.imgViAvatar2.layer.borderWidth = 0.8
        
        cell.imgViAvatar2.sd_setImage(with: URL(string: callout?.poster.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        cell.imgViThumb2.sd_setImage(with: URL(string: callout?.thumb ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        
        cell.lblUser1.layer.masksToBounds = true
        cell.lblUser1.layer.cornerRadius = cell.lblUser1.layer.frame.size.height / 2.0;
        
        cell.lblUser2.layer.masksToBounds = true
        cell.lblUser2.layer.cornerRadius = cell.lblUser2.layer.frame.size.height / 2.0;
        cell.lblUser2.text = callout?.poster.username
        cell.lblCallOutName.text = callout?.title
        cell.lblViewCnt.text = "Views:" + (callout?.views)!
        if callout?.format == "video"
        {
            cell.iconCallOutType.image = #imageLiteral(resourceName: "iconVideoGray.png")
//            DispatchQueue.main.async {
//                cell.rightPlayer = Player()
//                cell.rightPlayer?.url = URL(string: (callout?.video)!)!
//                cell.rightPlayer?.muted = true
//                cell.rightPlayer?.view.frame = cell.imgViThumb2.bounds
//                cell.imgViThumb2.addSubview((cell.rightPlayer?.view)!)
//                cell.rightPlayer?.playbackLoops = true
//                cell.rightPlayer?.playFromBeginning()
//                cell.rightPlayer?.fillMode = PlayerFillMode.resizeAspectFill.avFoundationType
//            }
        }
        else if callout?.format == "photo"
        {
            cell.iconCallOutType.image = #imageLiteral(resourceName: "iconPhotoGray.png")
        }
        else if callout?.format == "audio"
        {
            cell.iconCallOutType.image = #imageLiteral(resourceName: "iconAudioGray.png")
            cell.imgViThumb2.image = #imageLiteral(resourceName: "audio-wave.png")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        view.endEditing(true)
        if selectedIndex == 0
        {
            let callout = active_callouts[indexPath.row]
            if callout.poster.isBlocked {
                self.view.makeToast("Sorry, you are unable to view \(callout.poster.username)'s content")
                return
            }
            
            if callout.challenger!.isBlocked {
                self.view.makeToast("Sorry, you are unable to view \(callout.challenger!.username)'s content")
                return
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
            vc.callout = active_callouts[indexPath.row]
            self.present(vc, animated: true, completion: nil)
            Global.shared.updateViewCount(id: active_callouts[indexPath.row].id) {
                self.search(type: self.searchType, keyword: self.searchKeyword)
            }
            
        }
        else if selectedIndex == 1
        {
            let callout = archive_callouts[indexPath.row]
            if callout.poster.isBlocked {
                self.view.makeToast("Sorry, you are unable to view \(callout.poster.username)'s content")
                return
            }
            
            if callout.challenger!.isBlocked {
                self.view.makeToast("Sorry, you are unable to view \(callout.challenger!.username)'s content")
                return
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
            vc.isActive = false
            vc.callout = archive_callouts[indexPath.row]
            self.present(vc, animated: true, completion: nil)
            
            Global.shared.updateViewCount(id: archive_callouts[indexPath.row].id) {
                self.search(type: self.searchType, keyword: self.searchKeyword)
            }
        }
        else
        {
            let callout = active_callouts[indexPath.row]
            if callout.poster.isBlocked {
                self.view.makeToast("Sorry, you are unable to view \(callout.poster.username)'s content")
                return
            }
            
            if (callout.challenger?.isBlocked)! {
                self.view.makeToast("Sorry, you are unable to view \(callout.challenger!.username)'s content")
                return
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
            vc.isActive = active_callouts[indexPath.row].isActive!
            vc.callout = active_callouts[indexPath.row]
            self.present(vc, animated: true, completion: nil)
            
            Global.shared.updateViewCount(id: active_callouts[indexPath.row].id) {
                self.search(type: self.searchType, keyword: self.searchKeyword)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedIndex == 0 || selectedIndex == 3
        {
            return active_callouts.count
        }
        else
        {
            return archive_callouts.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 10) / 2, height: (collectionView.frame.size.width - 10) / 2)
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 6.0
//    }
}
extension SearchVC:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserCell
        
        cell.lblUserName.text = users[indexPath.row].username
        
        cell.imgAvatar.sd_setImage(with: URL(string: users[indexPath.row].avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        
        cell.btnAdd.isHidden = true
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        
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
        else{
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
