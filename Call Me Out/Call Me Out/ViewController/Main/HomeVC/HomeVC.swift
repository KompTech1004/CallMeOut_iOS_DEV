//
//  HomeVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import AlamofireImage
import ProgressHUD
import AVKit
import AVFoundation
import Player

class HomeVC: UIViewController, JPScrollViewPlayVideoDelegate {

    @IBOutlet weak var viLoading: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblLoading: UILabel!
    
    @IBOutlet weak var cltViLiveCallOuts: UICollectionView!
    let refreshControl = UIRefreshControl()
    
    var callouts = [CallOut]()
    var filterType = 0
    var filterCategory = "All"
    var filterDuration = 0
    var category = 0
    var subcategory = 0
    var keyword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cltViLiveCallOuts.delegate = self
        cltViLiveCallOuts.dataSource = self
        
        cltViLiveCallOuts.register(UINib(nibName: "CallCell", bundle: nil), forCellWithReuseIdentifier: "CallCell")

//        cltViLiveCallOuts.jp_delegate = self
//        cltViLiveCallOuts.jp_scrollPlayStrategyType = .bestVideoView
//        cltViLiveCallOuts.jp_debugScrollViewVisibleFrame = false
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        cltViLiveCallOuts.addSubview(refreshControl)
        refresh()
        print (Global.shared.selected_challenge_id)
        if Global.shared.selected_challenge_id != 0
        {
            ProgressHUD.show("", interaction: false)
            Global.shared.getItem(userid: String((Global.getUserDataFromLocal()?.id)!), id: String(Global.shared.selected_challenge_id)) { (callout) in
                ProgressHUD.dismiss()
                Global.shared.selected_challenge_id = 0
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                vc.callout = callout!
                self.present(vc, animated: true, completion: nil)
                Global.shared.updateViewCount(id: (callout?.id)!, completionHandler: {
                    
                })
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "Callout_Update"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeFilter(_:)), name: NSNotification.Name(rawValue: "Update_Filter"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.cltViLiveCallOuts.jp_handleCellUnreachableTypeInVisibleCellsAfterReloadData()
//        self.cltViLiveCallOuts.jp_playVideoInVisibleCellsIfNeed()
//
//        self.cltViLiveCallOuts.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        self.cltViLiveCallOuts.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        let scrollViewVisibleFrame = self.cltViLiveCallOuts.frame
//        self.cltViLiveCallOuts.jp_scrollViewVisibleFrame = scrollViewVisibleFrame
    }
    
    @objc func changeFilter(_ notification:Notification)
    {
        let data = notification.userInfo!["data"] as! [String:Any]
        filterType = data["type"]! as! Int
        filterCategory = data["category"]! as! String
        filterDuration = data["duration"]! as! Int
        category = data["cat"]! as! Int
        subcategory = data["subcat"]! as! Int
        keyword = data["keyword"] as! String
        callouts.removeAll()
        cltViLiveCallOuts.reloadData()
        refresh()
    }
    
    @objc func refresh()
    {
        refreshControl.beginRefreshing()
//        let userid = Global.getUserDataFromLocal()?.id
        
        Global.shared.getPost(userID: (Global.getUserDataFromLocal()?.id)!, last_id: "0", type: String(filterType), category: filterCategory, duration: String(filterDuration),keyword: keyword) { (flag, result) in
            self.refreshControl.endRefreshing()
            self.refreshControl.isHidden = true
            if flag && result != nil{
                self.callouts = result!

                self.cltViLiveCallOuts.reloadData()
            }
            else
            {
                
            }
        }
    }
    
    @objc func loadMore()
    {
        Global.shared.getPost(userID: (Global.getUserDataFromLocal()?.id)!, last_id: (callouts.last?.id)!,type: String(filterType), category: String(filterCategory), duration: String(filterDuration),keyword: keyword) { (flag, result) in
            if flag && result != nil{
                self.callouts.append(contentsOf: result!)
                self.cltViLiveCallOuts.reloadData()
            }
            else
            {
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onFilter(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        vc.nSelectedDurationIdx = filterDuration
        vc.nSelectedType = filterType
        vc.category = filterCategory
        vc.nSelectedCategoryIdx = category
        vc.nSelectedSubCategoryIdx = subcategory
        vc.keyword = keyword
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func onShowLeftMenu(_ sender: Any) {
        SlideNavigationController.sharedInstance().open(MenuLeft, withCompletion: nil)
    }
}
extension HomeVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let callout = callouts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CallCell", for: indexPath) as! CallCell
        cell.imgViAvatar1.layer.masksToBounds = true
        cell.imgViAvatar1.layer.cornerRadius = cell.imgViAvatar1.layer.frame.size.width / 2.0
        cell.imgViAvatar1.layer.borderColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6).cgColor
//        cell.rightViewController = nil
        
        if callout.format == "video"
        {
            cell.iconCallOutType.image = #imageLiteral(resourceName: "iconVideoGray.png")
            DispatchQueue.main.async {
                cell.rightPlayer = Player()
                cell.rightPlayer?.url = URL(string: callout.video)!
                cell.rightPlayer?.muted = true
                cell.rightPlayer?.view.frame = cell.imgViThumb2.bounds
                cell.imgViThumb2.addSubview((cell.rightPlayer?.view)!)
                cell.rightPlayer?.playbackLoops = true
                cell.rightPlayer?.playFromBeginning()
                cell.rightPlayer?.fillMode = PlayerFillMode.resizeAspectFill.avFoundationType
            }
            
        }
        else if callout.format == "photo"
        {
            cell.iconCallOutType.image = #imageLiteral(resourceName: "iconPhotoGray.png")
        }
        else if callout.format == "audio"
        {
            cell.iconCallOutType.image = #imageLiteral(resourceName: "iconAudioGray.png")
        }
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
//                cell.leftViewController = nil
            }
            else if callout.format == "video"
            {
                DispatchQueue.main.async {
                    cell.leftPlayer = Player()
                    cell.leftPlayer?.url = URL(string: callout.challenge_video)!
                    cell.leftPlayer?.muted = true
                    cell.leftPlayer?.view.frame = cell.imgViThumb1.bounds
                    cell.imgViThumb1.addSubview((cell.leftPlayer?.view)!)
                    cell.leftPlayer?.playFromBeginning()
                    cell.leftPlayer?.playbackLoops = true
                    cell.leftPlayer?.fillMode = PlayerFillMode.resizeAspectFill.avFoundationType
                }
                
                cell.imgViThumb1.af_setImage(withURL: URL(string: callout.challenge_thumb)!)
            }
            else
            {
                cell.imgViThumb1.af_setImage(withURL: URL(string: callout.challenge_thumb)!)
//                cell.leftViewController = nil
            }
            cell.lblUser1.text = challenger.username.capitalized
            cell.imgViAvatar1.isHidden = false
            cell.lblUser1.isHidden = false
            
            cell.imgViAvatar1.sd_setImage(with: URL(string: challenger.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
            
        }
        else{
//            cell.imgViThumb1.image = #imageLiteral(resourceName: "w_sample9.jpg")
            cell.imgViAvatar1.isHidden = true
            cell.lblUser1.isHidden = true
//            cell.leftViewController = nil
        }
        
        cell.lblViewCnt.text = "Views:" + callout.views!
        cell.lblWinner.isHidden = true
        cell.lblWinnerRight.isHidden = true
        cell.imgViAvatar1.layer.borderWidth = 0.8
        
        cell.imgViAvatar2.layer.masksToBounds = true
        cell.imgViAvatar2.layer.cornerRadius = cell.imgViAvatar1.layer.frame.size.width / 2.0
        cell.imgViAvatar2.layer.borderColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6).cgColor
        cell.imgViAvatar2.layer.borderWidth = 0.8
        
        cell.imgViAvatar2.sd_setImage(with: URL(string: callout.poster.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        
        if callout.format == "audio"
        {
            cell.imgViThumb2.image = #imageLiteral(resourceName: "audio-wave.png")
        }
        else
        {
            cell.imgViThumb2.af_setImage(withURL: URL(string: callout.thumb)!)
        }
        
        cell.lblUser1.layer.masksToBounds = true
        cell.lblUser1.layer.cornerRadius = cell.lblUser1.layer.frame.size.height / 2.0;
        
        cell.lblUser2.layer.masksToBounds = true
        cell.lblUser2.layer.cornerRadius = cell.lblUser2.layer.frame.size.height / 2.0;
        cell.lblUser2.text = callout.poster.username.capitalized
        cell.lblCallOutName.text = callout.title.capitalized
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return callouts.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.width * 1.2)
    }

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
        
        ProgressHUD.show()
        Global.shared.updateViewCount(id: callouts[indexPath.row].id) {
            Global.shared.getChallengeItem(userid: "\((Global.getUserDataFromLocal()?.id)!)", id: self.callouts[indexPath.row].id, handler: { (callout) in
                ProgressHUD.dismiss()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                vc.callout = callout
                collectionView.reloadItems(at: [indexPath])
                self.present(vc, animated: true, completion: nil)
            })
        }
        
    }

//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        self.cltViLiveCallOuts.jp_scrollViewDidEndDraggingWillDecelerate(decelerate)
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        self.cltViLiveCallOuts.jp_scrollViewDidEndDecelerating()
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.cltViLiveCallOuts.jp_scrollViewDidScroll()
//    }
//
//    func scrollView(_ scrollView: UIScrollView & JPVideoPlayerScrollViewProtocol, willPlayVideoOnCell cell: UIView & JPVideoPlayerCellProtocol) {
//
//        if let videoURL = cell.jp_videoURL {
//            print("****** resume playing")
//            cell.jp_videoPlayView?.jp_resumeMutePlay(with: videoURL, bufferingIndicator: nil, progressView: nil, configuration: nil)
//        }
//
//    }
}
