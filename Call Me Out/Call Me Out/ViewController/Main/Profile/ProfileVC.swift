//
//  ProfileVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import ProgressHUD

class ProfileVC: UIViewController, EditProfileDelegate {

    @IBOutlet weak var imgViAvatar: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var btnFollowers: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnFollowing: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var clvChallenge: UICollectionView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblFollwers: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    var isMe = true
    var user:User?
    var callouts = [CallOut]()
    var calloutsChallenge = [CallOut]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnEdit.layer.masksToBounds = true
        btnEdit.layer.cornerRadius = 5
        
        btnFollow.layer.masksToBounds = true
        btnFollow.layer.cornerRadius = btnFollow.frame.size.height / 2.0;
        
        btnFollowers.layer.masksToBounds = true
        btnFollowers.layer.cornerRadius = btnFollowers.frame.size.height / 2.0;
        
        btnFollowing.layer.masksToBounds = true
        btnFollowing.layer.cornerRadius = btnFollowing.frame.size.height / 2.0;
        
        imgViAvatar.layer.masksToBounds = true
        imgViAvatar.layer.cornerRadius = imgViAvatar.frame.size.width / 2.0;
        imgViAvatar.layer.borderColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6).cgColor
        imgViAvatar.layer.borderWidth = 1.0
        
        collectionView.register(UINib(nibName: "ProfileCallout", bundle: nil), forCellWithReuseIdentifier: "cell")
        clvChallenge.register(UINib(nibName: "ProfileCallout", bundle: nil), forCellWithReuseIdentifier: "cell")
    }

    func profileUpdated() {
        let user = Global.getUserDataFromLocal()
        imgViAvatar.image = nil
        imgViAvatar.sd_setImage(with: URL(string: user?.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        
        lblUserName.text = "\(user?.first_name ?? "") \(user?.last_name ?? "")"
        
        if let bio = user?.bio {
            lblBio.text = bio
        } else {
        }
    }
    
    @IBAction func onEdit(_ sender: Any) {
        let storyboard = self.storyboard
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func onSetting(_ sender: Any) {
        let storyboard = self.storyboard
        let vc = storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.present(vc, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: 730)
        if isMe {
            btnFollow.isHidden = true
            
            btnMenu.setImage(UIImage(named: "btnLeftMenu.png"), for: .normal)
            
            let user = Global.getUserDataFromLocal()
            imgViAvatar.sd_setImage(with: URL(string: user?.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
            lblUserName.text = user?.username
            lblEmail.text = user?.email
            lblBirthday.text = user?.birthday
            
            Global.shared.getFollower(userid: String((Global.getUserDataFromLocal()?.id)!), callerid: String((Global.getUserDataFromLocal()?.id)!)) { (flag, result) in
                if let r = result, flag
                {
                    self.lblFollowing.text = "\(r.count)"
                }
            }
            
            Global.shared.getFollowing(userid: String((Global.getUserDataFromLocal()?.id)!), callerid: String((Global.getUserDataFromLocal()?.id)!)) { (flag, result) in
                if let r = result, flag
                {
                    self.lblFollwers.text = "\(r.count)"
                }
            }
            
            if let bio = user?.bio {
                lblBio.text = bio
            } else {
            }
            
            
            Global.shared.getPostItems(userid: String((Global.getUserDataFromLocal()?.id)!), caller: String((Global.getUserDataFromLocal()?.id)!)) { (result) in
                /*
                var privateCallouts = [CallOut]()
                
                for callout in result.reversed() {
                    if callout.type == 1 {
                        privateCallouts.append(callout)
                    } else {
                        self.callouts.append(callout)
                    }
                }
                
                for privatecallout in privateCallouts.reversed() {
                    self.callouts.insert(privatecallout, at: 0)
                }
                */
                self.callouts = result.reversed()
                
                self.collectionView.reloadData()
            }
            Global.shared.getChallengeItems(userid: String((Global.getUserDataFromLocal()?.id)!)) { (result) in
                /*
                var privateChallenges = [CallOut]()
                
                for challenge in result {
                    if challenge.type == 1 {
                        privateChallenges.append(challenge)
                    } else {
                        self.calloutsChallenge.append(challenge)
                    }
                }
                
                for privatecallout in privateChallenges {
                    self.calloutsChallenge.insert(privatecallout, at: 0)
                }
                */
                self.calloutsChallenge = result
                
                self.clvChallenge.reloadData()
            }
        }
        else {
            
            reloadFollowButton()
            
            if user?.id == Global.getUserDataFromLocal()?.id{
                btnFollow.isHidden = true
                //btnFollowers.frame = CGRect(x: (self.view.frame.size.width - btnFollowers.frame.size.width)/2.0, y: btnFollowers.frame.origin.y, width: btnFollowers.frame.size.width, height: btnFollowers.frame.size.height)
            }
            else{
                //btnFollowers.frame = CGRect(x: self.view.frame.size.width - btnFollowers.frame.size.width - btnFollow.frame.origin.x, y: btnFollowers.frame.origin.y, width: btnFollowers.frame.size.width, height: btnFollowers.frame.size.height)
                btnSetting.isHidden = true
                btnEdit.isHidden = true
                btnFollow.isHidden = false
                if user?.isFollow == "1"
                {
                    btnFollow.setTitle("UNFOLLOW", for: .normal)
                    btnFollow.setTitleColor(UIColor.red, for: .normal)
                    btnFollow.backgroundColor = UIColor.white
                }
            }
            lblFollwers.text = user?.countFollowers
            lblFollowing.text = user?.countFollowings
//            btnFollowers.setTitle((user?.countFollowers)! + " FOLLOWERS", for: .normal)
//            btnFollowing.setTitle((user?.countFollowings)! + " FOLLOWING" , for: .normal)
            lblBio.text = user?.bio
            btnMenu.setImage(UIImage(named: "btnClose.png"), for: .normal)
            
//            let user = Global.getUserDataFromLocal()
//            imgViAvatar.af_setImage(withURL: URL.init(string: (self.user?.avatar)!)!,placeholderImage:#imageLiteral(resourceName: "avatarEmpty.png"))
            imgViAvatar.sd_setImage(with: URL(string: user?.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
            lblUserName.text = self.user?.username
            lblEmail.text = self.user?.email
            lblBirthday.text = self.user?.birthday
            
//            Global.shared.getPostItems(userid: String((Global.getUserDataFromLocal()?.id)!), caller: String((Global.getUserDataFromLocal()?.id)!)) { (result) in
//                self.callouts = result.reversed()
//                self.collectionView.reloadData()
//            }
//            Global.shared.getChallengeItems(userid: String((Global.getUserDataFromLocal()?.id)!)) { (result) in
//                self.calloutsChallenge = result
//                self.clvChallenge.reloadData()
//            }
            Global.shared.getUserPostedItems(userid: "\((self.user?.id)!)", caller: String((Global.getUserDataFromLocal()?.id)!), requestid: String((Global.getUserDataFromLocal()?.id)!)) { (result) in
                /*
                var privateCallouts = [CallOut]()
                
                for callout in result.reversed() {
                    if callout.type == 1 {
                        privateCallouts.append(callout)
                    } else {
                        self.callouts.append(callout)
                    }
                }
                
                for privatecallout in privateCallouts.reversed() {
                    self.callouts.insert(privatecallout, at: 0)
                }*/
                
                self.callouts = result.reversed()
                self.collectionView.reloadData()
            }
            
            Global.shared.getUserChallengeItems(userid: "\((self.user?.id)!)", requestid: String((Global.getUserDataFromLocal()?.id)!)) { (result) in
                /*
                var privateChallenges = [CallOut]()
                
                for challenge in result {
                    if challenge.type == 1 {
                        privateChallenges.append(challenge)
                    } else {
                        self.calloutsChallenge.append(challenge)
                    }
                }
                
                for privatecallout in privateChallenges.reversed() {
                    self.calloutsChallenge.insert(privatecallout, at: 0)
                }
                */
                self.calloutsChallenge = result
                
                self.clvChallenge.reloadData()
            }
        }
    }
    func reloadFollowButton()
    {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func inviteAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InviteVC")
        self.present(vc!, animated: true, completion: nil)
    }
    @IBAction func termsAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Signin", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TermsVC")
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func onFollowings(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        vc.user = user
        vc.type = 1
        present(vc, animated: true, completion: nil)
    }
    @IBAction func onShowLeftMenu(_ sender: Any) {
        if isMe
        {
            SlideNavigationController.sharedInstance().open(MenuLeft, withCompletion: nil)
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func onFollowers(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        vc.user = user
        vc.type = 0
        present(vc, animated: true, completion: nil)
    }
    @IBAction func onFollow(_ sender: Any) {
        ProgressHUD.show("", interaction: false)
        if user?.isFollow == "0"
        {
            
            Global.shared.follow(follower: String((user?.id)!), following: String((Global.getUserDataFromLocal()?.id)!), value: "1") { (flag, result) in
                ProgressHUD.dismiss()
                if flag{
                    self.view.makeToast("Success")
                    self.btnFollow.setTitle("UNFOLLOW", for: .normal)
                    self.btnFollow.setTitleColor(UIColor.red, for: .normal)
                    self.btnFollow.backgroundColor = UIColor.white
                    self.user?.isFollow = "1"
                    self.user?.countFollowers = String(Int((self.user?.countFollowers)!)! + 1)
                    self.lblFollwers.text = self.user?.countFollowers
                }
                else{
//                    self.view.makeToast(result)
                }
            }
        }
        else
        {
            Global.shared.follow(follower: String((user?.id)!), following: String((Global.getUserDataFromLocal()?.id)!), value: "0") { (flag, result) in
                ProgressHUD.dismiss()
                if flag{
                    self.view.makeToast("Success")
                    self.btnFollow.setTitle("FOLLOW", for: .normal)
                    self.user?.isFollow = "0"
                    self.user?.countFollowers = String(Int((self.user?.countFollowers)!)! - 1)
                    self.lblFollwers.text = self.user?.countFollowers
                }
                else{
//                    self.view.makeToast(result)
                }
            }
        }
    }
}

extension ProfileVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clvChallenge
        {
            return calloutsChallenge.count
        }
        return callouts.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height - 10, height: collectionView.frame.size.height - 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfileCallout
        var callout:CallOut?
        if collectionView == clvChallenge
        {
            callout = calloutsChallenge[indexPath.row]
        }
        else
        {
            callout = callouts[indexPath.row]
        }
        if callout?.format == "video"
        {
            cell.imgType.image = #imageLiteral(resourceName: "iconVideoGray.png")
            cell.img.sd_setImage(with: URL(string: callout?.thumb ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
            
        }
        else if callout?.format == "photo"
        {
            cell.imgType.image = #imageLiteral(resourceName: "iconPhotoGray.png")
            cell.img.sd_setImage(with: URL(string: callout?.thumb ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        }
        else if callout?.format == "audio"
        {
            cell.imgType.image = #imageLiteral(resourceName: "iconAudioGray.png")
            cell.img.image = #imageLiteral(resourceName: "audio-wave.png")
        }
        cell.lblName.text = callout?.title
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
        if collectionView == clvChallenge
        {
            Global.shared.updateViewCount(id: calloutsChallenge[indexPath.row].id) {
                ProgressHUD.show("")
                
                var userId: Int
                if self.isMe {
                    userId = (Global.getUserDataFromLocal()?.id)!
                } else {
                    userId = (self.user?.id)!
                }
                
                Global.shared.getChallengeItem(userid: String(userId), id: self.calloutsChallenge[indexPath.row].id, handler: { (callout) in
                    ProgressHUD.dismiss()
                    
                    if let co = callout {
                        vc.callout = co
                        self.present(vc, animated: true, completion: nil)
                    }
                })
            }
        }
        else
        {
            
            vc.callout = self.callouts[indexPath.row]
            ProgressHUD.show()
            
            var userId: Int
            if self.isMe {
                userId = (Global.getUserDataFromLocal()?.id)!
            } else {
                userId = (self.user?.id)!
            }
            
            Global.shared.getPost(userID: userId, last_id: "0", type: "0", category: "All", duration: "0",keyword: "") { (flag, results) in
                ProgressHUD.dismiss()
                if flag && results != nil{
                    
                    let selectedPostId = self.callouts[indexPath.row].post_id
                    var selectedCallout: CallOut?
                    
                    for result in results! {
                        if result.post_id == selectedPostId {
                            selectedCallout = result
                            break
                        }
                    }
                    
                    if selectedCallout != nil {
                    } else {
                        selectedCallout = self.callouts[indexPath.row];
                    }

                    vc.callout = selectedCallout

                    Global.shared.updateViewCount(id: selectedCallout!.id) {
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
            
        }
    }
}
