//
//  ArchiveVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Player
import CRRefresh

class ArchiveVC: UIViewController {

    @IBOutlet weak var cltViArchives: UICollectionView!
    
    var callouts = [CallOut]()
    let refreshControl = UIRefreshControl()
    
    var filterType = 0
    var filterCategory = "All"
    var filterDuration = 0
    var category = 0
    var subcategory = 0
    var keyword = ""
    var filterUsername = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cltViArchives.register(UINib(nibName: "CallCell", bundle: nil), forCellWithReuseIdentifier: "CallCell")
//        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        cltViArchives.addSubview(refreshControl)
//        refresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeFilter(_:)), name: NSNotification.Name(rawValue: "Update_Filter_archive"), object: nil)
        
        cltViArchives.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.refresh()
        }
        /// manual refresh
        cltViArchives.cr.beginHeaderRefresh()
    }
    
    @objc func changeFilter(_ notification:Notification)
    {
        let data = notification.userInfo!["data"] as! [String:Any]
        filterType = data["type"]! as! Int
        filterCategory = data["category"]! as! String
        filterDuration = data["duration"]! as! Int
        category = data["cat"]! as! Int
        subcategory = data["subcat"]! as! Int
        keyword = data["keyword"]! as! String
        filterUsername = data["username"] as? String ?? ""
        
        filterUsername = filterUsername.trimmingCharacters(in: CharacterSet.whitespaces)
        
        print(data)
        callouts.removeAll()
        cltViArchives.reloadData()
        refresh()
    }
    
    @objc func refresh()
    {
//        DispatchQueue.main.async {
//            self.refreshControl.beginRefreshing()
//        }
//
        Global.shared.getArchive(userID: (Global.getUserDataFromLocal()?.id)!, last_id: "0",type: String(filterType), category: filterCategory, duration: String(filterDuration),keyword:keyword) { (flag, result) in
            
            if flag && result != nil{
                if self.filterUsername == "" {
                    self.callouts = result!
                } else {
                    self.callouts.removeAll()
                    for callout in result! {
                        if callout.challenger == nil {
                            continue
                        }

                        if callout.poster.username.lowercased().contains(self.filterUsername.lowercased()) ||
                            callout.poster.first_name.lowercased().contains(self.filterUsername.lowercased()) ||
                            callout.poster.last_name.lowercased().contains(self.filterUsername.lowercased()) ||
                            callout.challenger!.username.lowercased().contains(self.filterUsername.lowercased()) ||
                            callout.challenger!.first_name.lowercased().contains(self.filterUsername.lowercased()) ||
                            callout.challenger!.last_name.lowercased().contains(self.filterUsername.lowercased()) {
                        
                            self.callouts.append(callout)
                        }
                    }
                }
                
            }
            else
            {
                
            }
            
            DispatchQueue.main.async {
                /// Stop refresh when your job finished, it will reset refresh footer if completion is true
                self.cltViArchives.reloadData()
                self.cltViArchives.cr.endHeaderRefresh()
            }
        }
    }
/*
    @objc func loadMore()
    {
        Global.shared.getArchive(userID: (Global.getUserDataFromLocal()?.id)!, last_id: (callouts.last?.id)!,type: String(filterType), category: filterCategory, duration: String(filterDuration),keyword:keyword) { (flag, result) in
            if flag && result != nil{
                self.callouts.append(contentsOf: result!)
                self.cltViArchives.reloadData()
            }
            else
            {
                
            }
        }
    }
*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func filterAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        vc.nSelectedDurationIdx = filterDuration
        vc.nSelectedType = filterType
        vc.category = filterCategory
        vc.nSelectedCategoryIdx = category
        vc.nSelectedSubCategoryIdx = subcategory
        vc.keyword = keyword
        vc.type = 1
        vc.filteredUsername = filterUsername
        self.present(vc, animated: true, completion: nil)
    }
}

extension ArchiveVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let callout = callouts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CallCell", for: indexPath) as! CallCell
        cell.imgViAvatar1.layer.masksToBounds = true
        cell.imgViAvatar1.layer.cornerRadius = cell.imgViAvatar1.layer.frame.size.width / 2.0
        cell.imgViAvatar1.layer.borderColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6).cgColor
        cell.lblVote.isHidden = true
        cell.leftViewController = nil
        cell.imgViThumb1.image = nil
        cell.imgViThumb2.image = nil
        
        cell.imgViThumb1.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        cell.imgViThumb2.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        if let challenger = callout.challenger{
            if callout.format == "audio"
            {
                cell.imgViThumb1.image = #imageLiteral(resourceName: "audio-wave.png")
            }
            else if callout.format == "video"
            {
//                DispatchQueue.main.async {
//                    cell.leftPlayer = Player()
//                    cell.leftPlayer?.url = URL(string: callout.challenge_video)!
//                    cell.leftPlayer?.muted = true
//                    cell.leftPlayer?.view.frame = cell.imgViThumb1.bounds
//                    cell.imgViThumb1.addSubview((cell.leftPlayer?.view)!)
//                    cell.leftPlayer?.playFromBeginning()
//                    cell.leftPlayer?.playbackLoops = true
//                    cell.leftPlayer?.fillMode = PlayerFillMode.resizeAspectFill.avFoundationType
//                }

                cell.imgViThumb1.sd_setImage(with: URL(string: callout.challenge_thumb), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .highPriority, completed: nil)
                
            }
            else
            {
                cell.imgViThumb1.sd_setImage(with: URL(string: callout.challenge_thumb), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .highPriority, completed: nil)
            }
            cell.lblUser1.text = challenger.username.capitalized
            cell.imgViAvatar1.isHidden = false
            cell.lblUser1.isHidden = false
            cell.imgViAvatar1.sd_setImage(with: URL(string: challenger.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .highPriority, completed: nil)
        }
        else{
            cell.imgViThumb1.image = #imageLiteral(resourceName: "avatarEmpty.png")
            cell.imgViAvatar1.isHidden = true
            cell.lblUser1.isHidden = true
        }
        
        if callout.challenger == nil
        {
            cell.lblWinner.isHidden = true
            cell.lblWinnerRight.isHidden = true
        }
        else
        {
            if Int(callout.cnt_vote_poster)! > Int(callout.cnt_vote_challneger)!
            {
                cell.lblWinnerRight.isHidden = false
                cell.lblWinner.isHidden = true
            }
            else
            {
                cell.lblWinner.isHidden = false
                cell.lblWinnerRight.isHidden = true
            }
            if Int(callout.cnt_vote_poster)! == 0 && Int(callout.cnt_vote_challneger)! == 0
            {
                cell.lblWinner.isHidden = true
                cell.lblWinnerRight.isHidden = true
            }
        }
        
        cell.imgViAvatar1.layer.borderWidth = 0.8
        
        cell.imgViAvatar2.layer.masksToBounds = true
        cell.imgViAvatar2.layer.cornerRadius = cell.imgViAvatar1.layer.frame.size.width / 2.0
        cell.imgViAvatar2.layer.borderColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6).cgColor
        cell.imgViAvatar2.layer.borderWidth = 0.8

        cell.imgViAvatar2.sd_setImage(with: URL(string: callout.poster.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .highPriority, completed: nil)
        
        cell.lblUser1.layer.masksToBounds = true
        cell.lblUser1.layer.cornerRadius = cell.lblUser1.layer.frame.size.height / 2.0;
        
        cell.lblUser2.layer.masksToBounds = true
        cell.lblUser2.layer.cornerRadius = cell.lblUser2.layer.frame.size.height / 2.0;
        cell.lblUser2.text = callout.poster.username
        cell.lblCallOutName.text = callout.title
        cell.lblViewCnt.text = "Views:" + callout.views!
        
        cell.rightViewController = nil
        if callout.format == "video"
        {
            cell.iconCallOutType.image = #imageLiteral(resourceName: "iconVideoGray.png")
//            DispatchQueue.main.async {
//                cell.rightPlayer = Player()
//                cell.rightPlayer?.url = URL(string: callout.video)!
//                cell.rightPlayer?.muted = true
//                cell.rightPlayer?.view.frame = cell.imgViThumb2.bounds
//                cell.imgViThumb2.addSubview((cell.rightPlayer?.view)!)
//                cell.rightPlayer?.playbackLoops = true
//                cell.rightPlayer?.playFromBeginning()
//                cell.rightPlayer?.fillMode = PlayerFillMode.resizeAspectFill.avFoundationType
//            }
            cell.imgViThumb2.sd_setImage(with: URL(string: callout.thumb), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .highPriority, completed: nil)
        }
        else if callout.format == "photo"
        {
            cell.iconCallOutType.image = #imageLiteral(resourceName: "iconPhotoGray.png")
            cell.imgViThumb2.sd_setImage(with: URL(string: callout.thumb), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .highPriority, completed: nil)
        }
        else if callout.format == "audio"
        {
            cell.iconCallOutType.image = #imageLiteral(resourceName: "iconAudioGray.png")
            cell.imgViThumb2.image = #imageLiteral(resourceName: "audio-wave.png")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return callouts.count
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let callout = callouts[indexPath.row]
        if callout.poster.isBlocked {
            self.view.makeToast("Sorry, you are unable to view \(callout.poster.username)'s content")
            return
        }
        
        if (callout.challenger?.isBlocked)! {
            self.view.makeToast("Sorry, you are unable to view \(callout.challenger!.username)'s content")
            return
        }
        
        Global.shared.updateViewCount(id: callouts[indexPath.row].id) {
            Global.shared.getChallengeItem(userid: String(Global.getUserDataFromLocal()!.id), id: self.callouts[indexPath.row].id, handler: { (co) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                vc.isActive = false
                vc.callout = co!
//                vc.callout?.views = String(Int((vc.callout?.views)!)! + 1)
                collectionView.reloadItems(at: [indexPath])
                self.present(vc, animated: true, completion: nil)
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.item % 3 == 0 {
//            loadMore()
//        }
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//        print("offsetY:\(offsetY) contentHeight:\(contentHeight) height:\(cltViArchives.frame.size.height)")
//        if offsetY > contentHeight - cltViArchives.frame.size.height - 10 {
//            if callouts.count != 0
//            {
//                loadMore()
//            }
//        }
//    }
}

