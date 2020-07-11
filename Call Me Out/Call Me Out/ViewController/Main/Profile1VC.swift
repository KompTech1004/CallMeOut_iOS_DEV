//
//  Profile1VC.swift
//  Call Me Out
//
//  Created by B S on 5/21/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import ProgressHUD

class Profile1VC: UIViewController {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblFbname: UILabel!
    @IBOutlet weak var lblInname: UILabel!
    @IBOutlet weak var lblTwname: UILabel!
    
    @IBOutlet weak var bioHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblCntFollower: UILabel!
    @IBOutlet weak var lblCntFollowing: UILabel!
    @IBOutlet weak var lblCntVictory: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var clgCollectionView: UICollectionView!
    @IBOutlet weak var btnFollow: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var user:User?
    
    var callouts = [CallOut]()
    var calloutsChallenge = [CallOut]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnFollow.layer.masksToBounds = true
        btnFollow.layer.cornerRadius = btnFollow.frame.size.height / 2.0;
        
        imgAvatar.layer.masksToBounds = true
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width / 2.0;
        imgAvatar.layer.borderColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6).cgColor
        imgAvatar.layer.borderWidth = 1.0
        
        if user?.isFollow == "1"
        {
            btnFollow.setTitle("UNFOLLOW", for: .normal)
            btnFollow.setTitleColor(UIColor.red, for: .normal)
            btnFollow.backgroundColor = UIColor.white
        }
        else
        {
            btnFollow.setTitle("FOLLOW", for: .normal)
            btnFollow.setTitleColor(UIColor.red, for: .normal)
            btnFollow.backgroundColor = UIColor.white
        }
        
        lblUsername.text = user?.username
        lblCntFollower.text =  user?.countFollowers
        lblCntFollowing.text = user?.countFollowings

        imgAvatar.sd_setImage(with: URL(string: self.user?.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        
        
        if user?.bio == ""
        {
            bioHeight.constant = 0
        }
        else
        {
            lblBio.text = user?.bio
        }
        
        if let fbName = user?.fb_username, fbName.count > 0 {
            lblFbname.text = "Facebook: \(fbName)"
        }

        if let inName = user?.in_username, inName.count > 0 {
            lblInname.text = "Instagram: \(inName)"
        }
        
        if let twName = user?.tw_username, twName.count > 0 {
            lblTwname.text = "Twitter: \(twName)"
        }
        
        lblCntVictory.text = "0"
        Global.shared.getVicCount(userid: "\((user?.id)!)") { (vicCount) in
            self.lblCntVictory.text = "\(vicCount)"
        }
        
        collectionView.register(UINib(nibName: "ProfileCallout", bundle: nil), forCellWithReuseIdentifier: "cell")
        clgCollectionView.register(UINib(nibName: "ProfileCallout", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        Global.shared.getUserPostedItems(userid: "\((self.user?.id)!)", caller: String((Global.getUserDataFromLocal()?.id)!), requestid: String((Global.getUserDataFromLocal()?.id)!)) { (result) in
            self.callouts = result.reversed()
            
            self.collectionView.reloadData()
        }
        
        Global.shared.getUserChallengeItems(userid: "\((self.user?.id)!)", requestid: String((Global.getUserDataFromLocal()?.id)!)) { (result) in
            self.calloutsChallenge = result//.reversed()
            
            self.clgCollectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onFollowings(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        vc.user = user
        vc.type = 1
        present(vc, animated: true, completion: nil)
    }
    @IBAction func onFollowers(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        vc.user = user
        vc.type = 0
        present(vc, animated: true, completion: nil)
    }
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func FollowAction(_ sender: Any) {
//        ProgressHUD.show("", interaction: false)
        if user?.isFollow == "0"
        {
            Global.shared.follow(follower: String((user?.id)!), following: String((Global.getUserDataFromLocal()?.id)!), value: "1") { (flag, result) in
//                ProgressHUD.dismiss()
                if flag{
                    self.view.makeToast("Success")
                    self.btnFollow.setTitle("UNFOLLOW", for: .normal)
                    self.btnFollow.setTitleColor(UIColor.red, for: .normal)
                    self.btnFollow.backgroundColor = UIColor.white
                    self.user?.isFollow = "1"
                    self.user?.countFollowers = String(Int((self.user?.countFollowers)!)! + 1)
                    self.lblCntFollower.text = (self.user?.countFollowers)!
                    
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
                    //                    self.btnFollow.setTitleColor(UIColor.white, for: .normal)
                    //                    self.btnFollow.backgroundColor = UIColor.red
                    self.user?.isFollow = "0"
                    self.user?.countFollowers = String(Int((self.user?.countFollowers)!)! - 1)
                    self.lblCntFollower.text = (self.user?.countFollowers)!
                }
                else{
//                    self.view.makeToast(result)
                }
            }
        }
    }
}

extension Profile1VC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clgCollectionView
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
        var callout:CallOut
        if collectionView == clgCollectionView
        {
            callout = calloutsChallenge[indexPath.row]
        }
        else
        {
            callout = callouts[indexPath.row]
        }
        
        cell.imgType.image = nil
        cell.img.image = nil
        
        if callout.format == "video"
        {
            cell.imgType.image = #imageLiteral(resourceName: "iconVideoGray.png")

            cell.img.sd_setImage(with: URL(string: callout.thumb), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
            
        }
        else if callout.format == "photo"
        {
            cell.imgType.image = #imageLiteral(resourceName: "iconPhotoGray.png")

            cell.img.sd_setImage(with: URL(string: callout.thumb), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        }
        else if callout.format == "audio"
        {
            cell.imgType.image = #imageLiteral(resourceName: "iconAudioGray.png")
            cell.img.image = #imageLiteral(resourceName: "audio-wave.png")
        }
        cell.lblName.text = callout.title
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clgCollectionView {
            Global.shared.updateViewCount(id: calloutsChallenge[indexPath.row].id) {
                ProgressHUD.show("")
                
                Global.shared.getChallengeItems(userid: String(self.user!.id), handler: { (results) in
                    ProgressHUD.dismiss()
                    
                    let selectedChallengeId = self.calloutsChallenge[indexPath.row].id
                    var selectedCallout: CallOut?
                    
                    for result in results {
                        if result.id == selectedChallengeId {
                            selectedCallout = result
                            break
                        }
                    }
                    
                    if selectedCallout != nil {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                        vc.callout = selectedCallout
                        vc.fromOtherProfile = true
                        self.present(vc, animated: true, completion: nil)
                    }
                })
            }
        } else {
            ProgressHUD.show()
            Global.shared.getPost(userID: (user?.id)!, last_id: "0", type: "0", category: "All", duration: "0",keyword: "") { (flag, results) in
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
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC

                    if selectedCallout != nil {
                    } else {
                        selectedCallout = self.callouts[indexPath.row];
                    }
                    
                    vc.callout = selectedCallout
                    vc.fromOtherProfile = true
                    Global.shared.updateViewCount(id: selectedCallout!.id) {
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
