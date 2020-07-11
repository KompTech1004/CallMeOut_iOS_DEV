//
//  VoteVC.swift
//  Call Me Out
//
//  Created by B S on 4/5/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Player
import ProgressHUD
//import HCSStarRatingView
import ImageSlideshow
import GoogleMobileAds

class VoteVC: UIViewController {

    var callout:CallOut?
    var isActive = true
    var reportType = 0 //if 0, poster. if 1, challenger.
    
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var btnPlayPoster: UIButton!
    @IBOutlet weak var btnMutePoster: UIButton!
    @IBOutlet weak var btnFullscreenPoster: UIButton!
    @IBOutlet weak var viRightUser: UIView!
    @IBOutlet weak var imgPosterProfile: UIImageView!
    @IBOutlet weak var lblPosterUsername: PaddedLabel!
    
    var playerPoster = AVPlayerViewController()
    
    @IBOutlet weak var imgChallenger: UIImageView!
    @IBOutlet weak var btnPlayChallenger: UIButton!
    @IBOutlet weak var btnMuteChallenger: UIButton!
    @IBOutlet weak var btnFullscreenChallenger: UIButton!
    @IBOutlet weak var viLeftUser: UIView!
    @IBOutlet weak var imgChallProfile: UIImageView!
    @IBOutlet weak var lblChallUsername: PaddedLabel!
    
    var playerChallenger : Player?
    var player : Player?
    var button = UIButton()
    var imgFullscreen:UIImageView?
    
    @IBOutlet weak var lblCalloutName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var btnChallenge: UIButton!
    
    @IBOutlet weak var postImgsView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tf_comment: UITextField!
//    @IBOutlet weak var leftRating: HCSStarRatingView!
//    @IBOutlet weak var rightRating: HCSStarRatingView!
    @IBOutlet weak var viLeftRating: UIView!
    @IBOutlet weak var viRightRating: UIView!
//    @IBOutlet weak var rightRatingView: HCSStarRatingView!
//    @IBOutlet weak var leftRatingView: HCSStarRatingView!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var imgFormat: UIImageView!
    
    
    @IBOutlet weak var btnLeftvote: UIButton!
    @IBOutlet weak var btnRightvote: UIButton!
    @IBOutlet weak var lblRightcntvote: UILabel!
    @IBOutlet weak var lblLeftcntvote: UILabel!
    
    @IBOutlet weak var vwReport: UIView!
    @IBOutlet weak var tvReport: UITextView!
    
    @IBOutlet weak var vwComment: UIView!
//    @IBOutlet weak var imageSlide: ImageSlideshow!
//    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var btnChallengeReport: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
    
    //logo profile left
    @IBOutlet weak var imgLogoProfileLeft: UIImageView!
    @IBOutlet weak var imgLogoProfileRight: UIImageView!
    
    @IBOutlet weak var lblKeywords: UILabel!
    var type = 0
    var comments = [Comment]()
    
    var fromRankingVC: Bool = false
    
    
    var fromArchive: Bool = false
    var fromOtherProfile: Bool = false
    
    @IBOutlet weak var adCollectionView: UICollectionView!
    
    @IBOutlet weak var chatTblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var adHeightConstraint: NSLayoutConstraint!
    
    var timer: Timer!
    
    var adurls = [String]()
    var adImages = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UIDevice.current.userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == 2436 ||
                UIScreen.main.nativeBounds.height == 2688 ||
                UIScreen.main.nativeBounds.height == 1792 {
                adHeightConstraint.constant = 64
            }
        }
        
        Global.shared.getAds { (ads) in
            if let ads = ads {
                for ad in ads {
                    self.adurls.append(ad["adurl"].stringValue)
                    self.adImages.append(ad["image"].stringValue)
                }
                
                self.adCollectionView.reloadData()
            }
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.onTimer), userInfo: nil, repeats: true)
        
        tableView.tableFooterView = UIView()
        
        if let keywords = callout?.keyword {
            lblKeywords.text = "Keywords: \(keywords)"
        }

        if let url = URL(string: callout?.challenge_thumb ?? ""){
            imgChallenger.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        }

        imgPoster.sd_setImage(with: URL(string: callout?.thumb ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        if !isActive
        {
            vwComment.isHidden = true
        }
        else
        {
            vwComment.isHidden = false
        }
        if /*callout?.poster.id == Global.getUserDataFromLocal()?.id ||*/ !isActive || (callout?.isExpired != nil && (callout?.isExpired)!)
        {
            btnChallenge.isHidden = true
            btnChallenge.isEnabled = false
        }
        
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "cell")
        Global.shared.getComment(feedid: (callout?.id)!) { (flag, result) in
            if flag
            {
                self.comments = result!
                
                if self.comments.count > 0 {
                    DispatchQueue.main.async {
                        self.chatTblHeightConstraint.constant = 120
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        
        lblViews.text = "Views:" + (callout?.views)!
        if callout?.format == "photo"
        {
            btnMutePoster.isHidden = true
            btnPlayPoster.isHidden = true
            btnMuteChallenger.isHidden = true
            btnPlayChallenger.isHidden = true
            imgFormat.image = #imageLiteral(resourceName: "iconPhotoGray.png")
        }
        else if callout?.format == "audio"
        {
            btnFullscreenPoster.isHidden = true
            btnFullscreenChallenger.isHidden = true
            imgFormat.image = #imageLiteral(resourceName: "iconAudioGray.png")
        }
        else if callout?.format == "video"
        {
            imgFormat.image = #imageLiteral(resourceName: "iconVideo.png")
        }
        lblLeftcntvote.text = (callout?.cnt_vote_challneger)!
        lblRightcntvote.text = (callout?.cnt_vote_poster)!

        if callout?.challenger != nil{
            viLeftUser.isHidden = false
            btnChallengeReport.isHidden = false
            if callout?.your_vote == "0"
            {
                btnLeftvote.setBackgroundImage(#imageLiteral(resourceName: "btnOptionSelected.png"), for: .normal)
            }
            else if callout?.your_vote == "1"
            {
                btnRightvote.setBackgroundImage(#imageLiteral(resourceName: "btnOptionSelected.png"), for: .normal)
            }
        } else {
            viLeftUser.backgroundColor = UIColor.clear
            lblChallUsername.isHidden = true
            btnChallengeReport.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            self.timer.invalidate()
        }
    }
    @objc func onTimer() {
        let visibleItems = adCollectionView.indexPathsForVisibleItems
        if (visibleItems.count > 0) {
            let currentVisibleIndex = visibleItems[0]
            
            var nextIndex: IndexPath
            if (currentVisibleIndex.row == adurls.count - 1) {
                nextIndex = IndexPath(row: 0, section: 0)
            } else {
                nextIndex = IndexPath(row: currentVisibleIndex.row + 1, section: 0)
            }
            
            adCollectionView.scrollToItem(at: nextIndex, at: .right, animated: true)
        }
    }
    
    @IBAction func onVoteRight(_ sender: Any) {
        if /*callout?.challenger?.id == Global.getUserDataFromLocal()?.id || callout?.poster.id == Global.getUserDataFromLocal()?.id ||*/ isActive == false
        {
            return
        }
        if callout?.challenger == nil{
            self.view.makeToast("Sorry! You can’t vote yet!")
            return
        }
        
        if fromRankingVC {
            self.view.makeToast("Sorry, you can’t vote on videos from the Rank Board")
            return
        }
        
        if fromOtherProfile {
            return
        }
        
        if !isActive {
            self.view.makeToast("Sorry, you can’t vote the archived videos")
            return
        }
        
        if btnRightvote.hasImage(named: "btnOption.png", for: .normal){
            self.view.makeToast("Voting!")
            Global.shared.vote(postid: (callout?.post_id)!, challenge_id: (callout?.id)!, userid: String((Global.getUserDataFromLocal()?.id)!), voteid: String((callout?.poster.id)!),toPoster: "1") { (result) in
                ProgressHUD.dismiss()
                if result
                {
                    self.view.makeToast("Success")
                    if self.callout?.your_vote == "-1"
                    {
                        self.callout?.cnt_vote_poster = String(Int((self.callout?.cnt_vote_poster)!)! + 1)
                    }
                    else
                    {
                        self.callout?.cnt_vote_poster = String(Int((self.callout?.cnt_vote_poster)!)! + 1)
                        self.callout?.cnt_vote_challneger = String(Int((self.callout?.cnt_vote_challneger)!)! - 1)
                    }
                    self.callout?.your_vote = "1"
                    self.btnRightvote.setBackgroundImage(#imageLiteral(resourceName: "btnOptionSelected.png"), for: .normal)
                    self.btnLeftvote.setBackgroundImage(#imageLiteral(resourceName: "btnOption.png"), for: .normal)
                    self.lblLeftcntvote.text = (self.callout?.cnt_vote_challneger)!
                    self.lblRightcntvote.text = (self.callout?.cnt_vote_poster)!
                }
                else
                {
                    self.view.makeToast("Error occured")
                }
            }
        }
    }
    
    @IBAction func onVoteLeft(_ sender: Any) {
        if callout?.challenger == nil{
            self.view.makeToast("Sorry! You can’t vote yet!")
            return
        }
        
        if fromRankingVC {
            self.view.makeToast("Sorry, you can’t vote on videos from the Rank Board")
            return
        }
        
        if fromOtherProfile {
            return
        }
        
        if !isActive {
            self.view.makeToast("Sorry, you can’t vote the archived videos")
            return
        }
        
        if /*callout?.challenger?.id == Global.getUserDataFromLocal()?.id || callout?.poster.id == Global.getUserDataFromLocal()?.id ||*/ isActive == false
        {
            return
        }
        if btnLeftvote.hasImage(named: "btnOption.png", for: .normal){
//            ProgressHUD.show("Voting!", interaction: false)
            Global.shared.vote(postid: (callout?.post_id)!, challenge_id: (callout?.id)!, userid: String((Global.getUserDataFromLocal()?.id)!), voteid: String((callout?.challenger?.id)!),toPoster: "0") { (result) in
//                ProgressHUD.dismiss()
                if result
                {
                    self.view.makeToast("Success")
                    self.btnLeftvote.setBackgroundImage(#imageLiteral(resourceName: "btnOptionSelected.png"), for: .normal)
                    self.btnRightvote.setBackgroundImage(#imageLiteral(resourceName: "btnOption.png"), for: .normal)
                    if self.callout?.your_vote == "-1"
                    {
                        self.callout?.cnt_vote_challneger = String(Int((self.callout?.cnt_vote_challneger)!)! + 1)
                    }
                    else
                    {
                        self.callout?.cnt_vote_challneger = String(Int((self.callout?.cnt_vote_challneger)!)! + 1)
                        self.callout?.cnt_vote_poster = String(Int((self.callout?.cnt_vote_poster)!)! - 1)
                    }
                    self.callout?.your_vote = "0"
                    self.lblLeftcntvote.text = (self.callout?.cnt_vote_challneger)!
                    self.lblRightcntvote.text = (self.callout?.cnt_vote_poster)!
                }
                else
                {
                    self.view.makeToast("Error occured")
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        player?.stop()
        player = nil
        
        playerChallenger?.stop()
        playerChallenger = nil
        print ("view did disappear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if player == nil {
            player = Player()
        }
//        if callout?.format == "video" {
        player?.view.frame = imgPoster.bounds
        imgPoster.addSubview((player?.view)!)
        
        let url = URL(string: (callout?.video)!)
        
        if let url = url {
            player?.url = url
        }
        
        player?.playbackLoops = true
        player?.playFromBeginning()
        player?.fillMode = PlayerFillMode.resizeAspectFill.avFoundationType
        
        if playerChallenger == nil {
            playerChallenger = Player()
        }
        
        playerChallenger?.view.frame = imgChallenger.bounds
        imgChallenger.addSubview((playerChallenger?.view)!)
        
        let challengeUrl = URL(string: (callout?.challenge_video)!)
        
        if let chalUrl = challengeUrl {
            playerChallenger?.url = chalUrl
        }
        
        playerChallenger?.playbackLoops = true
        playerChallenger?.playFromBeginning()
        playerChallenger?.fillMode = PlayerFillMode.resizeAspectFill.avFoundationType
//        }
        
        imgFullscreen = UIImageView(frame: self.view.bounds)
        imgFullscreen?.contentMode = .scaleAspectFill
        imgFullscreen?.backgroundColor = UIColor.black
        self.view.addSubview(imgFullscreen!)
        imgFullscreen?.isHidden = true
        
        button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        button.addTarget(self, action: #selector(self.fullscreen(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        button.isEnabled = false
        button.isHidden = true
        
        lblCategory.text = callout?.category
        lblCalloutName.text = callout?.title
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viLeftUser.layer.cornerRadius = viLeftUser.frame.height / 2
        viRightUser.layer.cornerRadius = viRightUser.frame.height / 2
        imgPosterProfile.layer.cornerRadius = imgPosterProfile.frame.width / 2
        imgChallProfile.layer.cornerRadius = imgChallProfile.frame.width / 2
        
        lblPosterUsername.layer.cornerRadius = 15
        lblChallUsername.layer.cornerRadius = 15
        
        imgPosterProfile.sd_setImage(with: URL(string: callout?.poster.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        
        lblPosterUsername.text = "\(   callout?.poster.username    ?? "")"
        if let challenge = callout?.challenger{
            imgChallProfile.sd_setImage(with: URL(string: challenge.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
            lblChallUsername.text = "\(   challenge.username   )"
        }
        
        // load logo profile image
        imgLogoProfileLeft.layer.cornerRadius = 17.5
        imgLogoProfileRight.layer.cornerRadius = 17.5
        imgLogoProfileLeft.clipsToBounds = true
        imgLogoProfileRight.clipsToBounds = true
        
        imgLogoProfileRight.sd_setImage(with: URL(string: callout?.poster.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        
        if let challenge = callout?.challenger{
            imgLogoProfileLeft.sd_setImage(with: URL(string: challenge.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        }
        
        btnChallenge.layer.cornerRadius = 6.0
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object as? AVPlayer == playerPoster.player && keyPath == "status"
        {
            playerPoster.view.isHidden = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnPlayPosterTapped(_ sender: Any) {
        if player?.playbackState == .playing{
            player?.pause()
            btnPlayPoster.setImage(#imageLiteral(resourceName: "playIcon.png"), for: .normal)
        }
        else
        {
            player?.playFromCurrentTime()
            btnPlayPoster.setImage(#imageLiteral(resourceName: "pauseIcon.png"), for: .normal)
        }
    }
    
    @IBAction func btnChallengeTapped(_ sender: Any) {
//        if callout?.isChallenge == "1"
//        {
//            self.view.makeToast("You have already challenged this call out")
//            return
//        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReplyVC") as! ReplyVC
        vc.callout = callout
        vc.isNotification = false
        vc.direct = "Y"
        present(vc, animated: true, completion: nil)
    }
    @IBAction func btnMutePosterTapped(_ sender: Any) {
        if player!.muted
        {
            player?.muted = false
            btnMutePoster.setImage(#imageLiteral(resourceName: "muteIcon.png"), for: .normal)
        }
        else
        {
            player?.muted = true
            btnMutePoster.setImage(#imageLiteral(resourceName: "unmuteIcon.png"), for: .normal)
        }
    }
    
    @IBAction func btnFullscreenTapped(_ sender: Any) {
        if callout?.format == "video"
        {
            self.player?.view.removeFromSuperview()
            self.player?.view.frame = self.view.frame
            self.view.addSubview(self.player!.view)
            type = 0
            
            playerChallenger?.pause()
        }
        else if callout?.format == "photo"
        {
            imgFullscreen?.image = imgPoster.image
            imgFullscreen?.isHidden = false
            imgFullscreen?.isUserInteractionEnabled = true
        }
        button.removeFromSuperview()
        self.view.addSubview(button)
        button.isEnabled = true
        button.isHidden = false
    }
    @objc func fullscreen(_ sender:UIButton)
    {
        if callout?.format == "video"
        {
            if type == 0{
                self.player!.view.frame = self.imgPoster.bounds
                self.imgPoster.addSubview(self.player!.view)
                
                self.playerChallenger?.playFromCurrentTime()
                self.player?.playFromCurrentTime()
            }
            else
            {
                self.playerChallenger!.view.frame = self.imgChallenger.bounds
                self.imgChallenger.addSubview(self.playerChallenger!.view)
                
                self.playerChallenger?.playFromCurrentTime()
                self.player?.playFromCurrentTime()
            }
        }
        else if callout?.format == "photo"
        {
            imgFullscreen?.isHidden = true
            imgFullscreen?.isUserInteractionEnabled = false
        }
        button.isEnabled = false
        button.isHidden = true
    }
    @IBAction func btnFullscreenChalTapped(_ sender: Any) {
        if callout?.challenger == nil
        {
            return
        }
        if callout?.format == "video"
        {
            self.playerChallenger!.view.removeFromSuperview()
            self.playerChallenger!.view.frame = self.view.frame
            self.view.addSubview(self.playerChallenger!.view)
            type = 1
            
            self.player?.pause()
        }
        else if callout?.format == "photo"
        {
            imgFullscreen?.image = imgChallenger.image
            imgFullscreen?.isHidden = false
            imgFullscreen?.isUserInteractionEnabled = true
        }
        button.removeFromSuperview()
        self.view.addSubview(button)
        button.isEnabled = true
        button.isHidden = false
    }
    
    @IBAction func btnMuteChalTapped(_ sender: Any) {
        if callout?.challenger == nil
        {
            return
        }
        if playerChallenger!.muted
        {
            playerChallenger!.muted = false
            btnMuteChallenger.setImage(#imageLiteral(resourceName: "muteIcon.png"), for: .normal)
        }
        else
        {
            playerChallenger!.muted = true
            btnMuteChallenger.setImage(#imageLiteral(resourceName: "unmuteIcon.png"), for: .normal)
        }
    }
    
    @IBAction func btnPlayChalTapped(_ sender: Any) {
        if callout?.challenger == nil
        {
            return
        }
        if playerChallenger?.playbackState == .playing{
            playerChallenger?.pause()
            btnPlayChallenger.setImage(#imageLiteral(resourceName: "playIcon.png"), for: .normal)
        }
        else
        {
            playerChallenger?.playFromCurrentTime()
            btnPlayChallenger.setImage(#imageLiteral(resourceName: "pauseIcon.png"), for: .normal)
        }
    }
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnCommentTapped(_ sender: Any) {
        if tf_comment.text == ""
        {
            return
        }

        Global.shared.postComment(feedid: (callout?.id)!, comment: tf_comment.text!, userid: String((Global.getUserDataFromLocal()?.id)!)) { (flag, comment, commentid) in
            if flag
            {
                let comment = Comment(comment: self.tf_comment.text!, avatar: (Global.getUserDataFromLocal()?.avatar)!, username: (Global.getUserDataFromLocal()?.username)!, userid: (Global.getUserDataFromLocal()?.id)!, commentid: commentid)
                self.tf_comment.text = ""
                self.comments.insert(comment, at: 0)
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.chatTblHeightConstraint.constant = 120
                    })
                }
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            else
            {
                self.view.makeToast(comment)
            }
        }
    }
    @IBAction func btnRightRatingTapped(_ sender: Any) {
        if callout?.poster.id == Global.getUserDataFromLocal()?.id || (!isActive && !(callout?.enableVote)!)
        {
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.viRightRating.isHidden = false
        }
    }
    @IBAction func btnLeftRatingTapped(_ sender: Any) {
        if callout?.challenger == nil || callout?.challenger?.id == Global.getUserDataFromLocal()?.id || (!isActive && !(callout?.enableVote)!){
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.viLeftRating.isHidden = false
        }
        
    }
    @IBAction func onRateLeft(_ sender: Any) {
//        if leftRatingView.value == 0.0 || leftRatingView.value == callout?.your_rating_chall
//        {
//            self.viLeftRating.isHidden = true
//            return
//        }
//        ProgressHUD.show("Rating...", interaction: false)
//        Global.shared.rating(feedid: (callout?.id)!, postid: (callout?.post_id)!, to: String((callout?.challenger?.id)!), userid: String((Global.getUserDataFromLocal()?.id)!), rating: "\(leftRatingView.value)") { (flag, result) in
//            ProgressHUD.dismiss()
//            self.viLeftRating.isHidden = true
//            if flag
//            {
//                self.callout?.your_rating_chall = self.leftRatingView.value
//            }
//            else{
//                ProgressHUD.showError(result)
//            }
//        }
    }
    @IBAction func onRateRight(_ sender: Any) {
//        if rightRatingView.value == 0.0 || rightRatingView.value == callout?.your_rating_poster
//        {
//            self.viRightRating.isHidden = true
//            return
//        }
//        ProgressHUD.show("Rating...", interaction: false)
//        Global.shared.rating(feedid: (callout?.id)!, postid: (callout?.post_id)!, to: String((callout?.poster.id)!), userid: String((Global.getUserDataFromLocal()?.id)!), rating: "\(rightRatingView.value)") { (flag, result) in
//            ProgressHUD.dismiss()
//            self.viRightRating.isHidden = true
//            if flag
//            {
//                self.callout?.your_rating_poster = self.rightRatingView.value
//            }
//            else{
//                ProgressHUD.showError(result)
//            }
//        }
    }
    @IBAction func onViewRightProfile(_ sender: UIButton) {
        if callout?.poster.id == Global.getUserDataFromLocal()?.id
        {
            let user = callout?.poster
            
            if user!.isBlocked {
                self.view.makeToast("Sorry, you are unable to view \(user!.username)'s content")
                return
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            vc.user = callout?.poster
            vc.isMe = false
            self.present(vc, animated: true, completion: nil)
        }
        else{
            let user = callout?.poster
            
            if user!.isBlocked {
                self.view.makeToast("Sorry, you are unable to view \(user!.username)'s content")
                return
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Profile1VC") as! Profile1VC
            vc.user = callout?.poster
            self.present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func onViewLeftProfile(_ sender: Any) {
        if callout?.challenger != nil
        {
            if callout?.challenger?.id == Global.getUserDataFromLocal()?.id
            {
                let user = callout?.challenger
                
                if user!.isBlocked {
                    self.view.makeToast("Sorry, you are unable to view \(user!.username)'s content")
                    return
                }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.user = callout?.challenger
                vc.isMe = false
                self.present(vc, animated: true, completion: nil)
            }
            else
            {
                let user = callout?.challenger
                
                if user!.isBlocked {
                    self.view.makeToast("Sorry, you are unable to view \(user!.username)'s content")
                    return
                }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Profile1VC") as! Profile1VC
                vc.user = callout?.challenger
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func posterReport(_ sender: Any) {
        reportType = 0
//        UIView.animate(withDuration: 0.5) {
//            self.vwReport.isHidden = false
//        }
        let alertController = UIAlertController(title: "Report", message: "", preferredStyle: .actionSheet)
        let spamAction = UIAlertAction(title: "Spam", style: .default) { (_) in
            self.tvReport.text = "Spam"
            
            self.reportAction(nil)
        }
        let inappropriateAction = UIAlertAction(title: "Inappropriate Content", style: .default) { (_) in
            self.tvReport.text = "Inappropriate Content"
            
            self.reportAction(nil)
        }
        
        let inappropriateComment = UIAlertAction(title: "Inappropriate Comment", style: .default) { (_) in
            self.tvReport.text = "Inappropriate Comment"
            
            self.reportAction(nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(inappropriateAction)
        alertController.addAction(spamAction)
        alertController.addAction(inappropriateComment)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func challengerReport(_ sender: Any) {
        reportType = 1
        if callout?.challenger == nil
        {
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.vwReport.isHidden = false
        }
        /*
        let alertController = UIAlertController(title: "Report", message: "", preferredStyle: .actionSheet)
        let spamAction = UIAlertAction(title: "Spam", style: .default) { (_) in
            
            self.tvReport.text = "Spam"
            
            self.reportAction(nil)
        }
        let inappropriateAction = UIAlertAction(title: "Inappropriate", style: .default) { (_) in
            self.tvReport.text = "Inappropriate"
            
            self.reportAction(nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(spamAction)
        alertController.addAction(inappropriateAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)*/
    }
    @IBAction func reportAction(_ sender: Any?) {
        if tvReport.text == ""
        {
            return
        }
        if reportType == 0 // type == 0
        {
            ProgressHUD.show("Uploading...", interaction: false)
            Global.shared.reportContent(userid: String((Global.getUserDataFromLocal()?.id)!), type: "0", postid: (callout?.post_id)!, content: tvReport.text) { (result) in
                ProgressHUD.dismiss()
                if result
                {
                    self.view.makeToast("Success!")
                    UIView.animate(withDuration: 0.5, animations: {
                        self.vwReport.isHidden = true
                    })
                }
                else
                {
                    self.view.makeToast("Failed")
                }
            }
        }
        else
        {
            ProgressHUD.show("Uploading...", interaction: false)
            Global.shared.reportContent(userid: String((Global.getUserDataFromLocal()?.id)!), type: "1", postid: (callout?.id)!, content: tvReport.text) { (result) in
                ProgressHUD.dismiss()
                if result
                {
                    self.view.makeToast("Success!")
                    UIView.animate(withDuration: 0.5, animations: {
                        self.vwReport.isHidden = true
                    })
                }
                else
                {
                    self.view.makeToast("Failed")
                }
            }
        }
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5) {
            self.vwReport.isHidden = true
        }
    }
    
    @IBAction func onDownload(_ sender: Any) {
        if callout?.format == "photo" {
            let image = postImgsView.toImage()
            
            
            let activityItems: [Any] = [image]
            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            
            activityController.popoverPresentationController?.sourceView = self.view
            activityController.popoverPresentationController?.sourceRect = self.view.frame
            
            self.present(activityController, animated: true, completion: nil)
            
            //            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else if callout?.format == "video" {
            // download videos first
            
            let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let calloutVideoPath = documentsDirectory2.appendingPathComponent("callout_\(callout!.post_id).mp4")
            let challengeVideoPath = documentsDirectory2.appendingPathComponent("challenge_\(callout!.id).mp4")
            
            var calloutDownloaded: Bool = false
            var challengeDownloaded: Bool = false
            
            if FileManager.default.fileExists(atPath: calloutVideoPath.relativePath) {
                calloutDownloaded = true
            }
            
            if FileManager.default.fileExists(atPath: challengeVideoPath.relativePath) {
                challengeDownloaded = true
            }
            
            DispatchQueue.main.async {
                ProgressHUD.show()
            }
            
            if !calloutDownloaded {
                
                DispatchQueue.global(qos: .background).async {
                    let postURL = URL(string: self.callout!.video)
                    let urlData = NSData(contentsOf: postURL!)
                    
                    DispatchQueue.main.async {
                        urlData?.write(to: calloutVideoPath, atomically: true)
                        
                        calloutDownloaded = true
                        
                        if !challengeDownloaded {
                            
                            let challengeURL = URL(string: self.callout!.challenge_video)
                            let challengeData = NSData(contentsOf: challengeURL!)
                            
                            DispatchQueue.main.async {
                                challengeData?.write(to: challengeVideoPath, atomically: true)
                                
                                challengeDownloaded = true
                                
                                self.mergeVideo(url1: challengeVideoPath, url2: calloutVideoPath)
                            }
                        } else {
                            self.mergeVideo(url1: challengeVideoPath, url2: calloutVideoPath)
                        }
                    }
                }
            } else {
                if !challengeDownloaded {
                    let challengeURL = URL(string: self.callout!.challenge_video)
                    let challengeData = NSData(contentsOf: challengeURL!)
                    
                    
                    DispatchQueue.main.async {
                        challengeData?.write(to: challengeVideoPath, atomically: true)
                        
                        challengeDownloaded = true
                        
                        self.mergeVideo(url1: challengeVideoPath, url2: calloutVideoPath)
                    }
                } else {
                    // both downloaded
                    self.mergeVideo(url1: challengeVideoPath, url2: calloutVideoPath)
                }
            }
        } else {
            // audio
        }
    }
    
    func mergeVideo(url1: URL, url2: URL) {
        print (url1.relativePath)
        print (url2.relativePath)
        
        let firstAsset = AVAsset(url: url1)
        let secondAsset = AVAsset(url: url2)
        
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        
        // 2 - Create two video tracks
        guard let firstTrack = mixComposition.addMutableTrack(withMediaType: .video,
                                                              preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration),
                                           of: firstAsset.tracks(withMediaType: .video)[0],
                                           at: kCMTimeZero)
        } catch {
            print("Failed to load first track")
            
            ProgressHUD.dismiss()
            self.present(Utils.alertWithText(errorText: "Failed to download video"), animated: true, completion: nil)
            return
        }
        
        guard let secondTrack = mixComposition.addMutableTrack(withMediaType: .video,
                                                               preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        do {
            try secondTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration),
                                            of: secondAsset.tracks(withMediaType: .video)[0],
                                            at: firstAsset.duration)
        } catch {
            print("Failed to load second track")
            ProgressHUD.dismiss()
            return
        }
        
        // 2.1
//        CGAffineTransform txf = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform];
        var firstAssetW: CGFloat = 0.0
        var firstAssetH: CGFloat = 0.0
        var isFirstPortrat: Bool = false
        
        let firstSize = firstAsset.tracks(withMediaType: .video).first?.naturalSize
        let txf = firstAsset.tracks(withMediaType: .video).first?.preferredTransform
        if (firstSize?.width == txf?.tx && firstSize?.height == txf?.ty) || (txf?.tx == 0 && txf?.ty == 0) {
            firstAssetW = firstSize?.width ?? 0.0
            firstAssetH = firstSize?.height ?? 0.0
        } else {
            firstAssetW = firstSize?.height ?? 0.0
            firstAssetH = firstSize?.width ?? 0.0
        }
        
        if txf?.a == 0 && txf?.b == 1.0 && txf?.c == -1.0 && txf?.d == 0 {
            isFirstPortrat = true
        } else if txf?.a == 0 && txf?.b == -1.0 && txf?.c == 1.0 && txf?.d == 0 {
            isFirstPortrat = true
        }
        
        
//        CGAffineTransform firstTransform = FirstAssetTrack.preferredTransform;
//        if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)  {FirstAssetOrientation_= UIImageOrientationRight; isFirstAssetPortrait_ = YES;}
//        if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)  {FirstAssetOrientation_ =  UIImageOrientationLeft; isFirstAssetPortrait_ = YES;}
//        if(firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0)   {FirstAssetOrientation_ =  UIImageOrientationUp;}
//        if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {FirstAssetOrientation_ = UIImageOrientationDown;}
//
        
        var secondAssetW: CGFloat = 0.0
        var secondAssetH: CGFloat = 0.0
        
        let secondSize = secondAsset.tracks(withMediaType: .video).first?.naturalSize
        let txf2 = secondAsset.tracks(withMediaType: .video).first?.preferredTransform
        if (secondSize?.width == txf2?.tx && secondSize?.height == txf2?.ty) || (txf2?.tx == 0 && txf2?.ty == 0) {
            secondAssetW = secondSize?.width ?? 0.0
            secondAssetH = secondSize?.height ?? 0.0
        } else {
            secondAssetW = secondSize?.height ?? 0.0
            secondAssetH = secondSize?.width ?? 0.0
        }
        
//        firstTrack.preferredTransform = firstAsset.preferredTransform
//        secondTrack.preferredTransform = secondAsset.preferredTransform
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration))
        
        // 2.2
        let firstInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack)
        let secondInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: secondTrack)
        let renderSize = CGSize(width: firstAssetW + secondAssetW, height: min(firstAssetH, secondAssetH))
        
        
        
        firstInstruction.setTransform(txf!, at: kCMTimeZero)
        
        let moveTrans = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: firstAssetW, ty: 0)
        
//        let secondTrans = moveTrans.concatenating(txf2!)
        
//        print(secondTrans)
        secondInstruction.setTransform(txf2!.concatenating(moveTrans), at: kCMTimeZero)
        
        // 2.3
        mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = renderSize
        
        // audio
        guard let firstAudioTrack = mixComposition.addMutableTrack(withMediaType: .audio,
                                                                   preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        
        do {
            if let audioTrack = firstAsset.tracks(withMediaType: .audio).first {
                try firstAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration),
                                                    of: audioTrack,
                                                    at: kCMTimeZero)
            }
            
        } catch {
            print("Failed to load first track")
            self.present(Utils.alertWithText(errorText: "Failed to download video"), animated: true, completion: nil)
            ProgressHUD.dismiss()
            return
        }
        
        do {
            if let audioTrack = secondAsset.tracks(withMediaType: .audio).first {
                try firstAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration),
                                                    of: audioTrack,
                                                    at: firstAsset.duration)
            }
            
        } catch {
            print("Failed to load second track")
            self.present(Utils.alertWithText(errorText: "Failed to download video"), animated: true, completion: nil)
            ProgressHUD.dismiss()
            return
        }
        
        // 4 - Get path
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
        
        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition
        
        // 6 - Perform the Export
        exporter.exportAsynchronously() {
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                if exporter.status == .completed {
                    print ("exported at \(url.absoluteString)")
                    
                    print(url)
                    let activityItems: [Any] = [url, "Check this out!"]
                    let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    
                    activityController.popoverPresentationController?.sourceView = self.view
                    activityController.popoverPresentationController?.sourceRect = self.view.frame
                    
                    self.present(activityController, animated: true, completion: nil)
                }
                
                
                //                PHPhotoLibrary.shared().performChanges({
                //                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                //                }, completionHandler: { (saved, error) in
                //                    if saved {
                //                        let alertController = UIAlertController(title: "Video downloaded successfully", message: nil, preferredStyle: .alert)
                //                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                //                        alertController.addAction(defaultAction)
                //                        self.present(alertController, animated: true, completion: nil)
                //                    } else {
                //                        let alertController = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .alert)
                //                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                //                        alertController.addAction(defaultAction)
                //                        self.present(alertController, animated: true, completion: nil)
                //                    }
                //                })
            }
        }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Callout has been saved to your photos.")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

extension VoteVC:UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        cell.lblComment.text = comment.comment
        cell.lblUsername.text = comment.username
        if let url = URL(string: comment.avatar)
        {
            cell.imgAvatar.sd_setImage(with: URL(string: comment.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        }
        else
        {
            cell.imgAvatar.image = #imageLiteral(resourceName: "avatarEmpty.png")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width - 81, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = comments[indexPath.row].comment
        label.sizeToFit()
        
        return (label.frame.height + 48 > 61) ? label.frame.height + 48 + 19:80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let comment = comments[indexPath.row]
        if comment.userId == Global.getUserDataFromLocal()?.id || Global.getUserDataFromLocal()?.id == callout?.poster.id{
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let comment = comments[indexPath.row]
            Global.shared.deleteComment(commentId: comment.commentId, handler: {
                self.comments.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
        }
    }
    
}
extension UIButton {
    func hasImage(named imageName: String, for state: UIControlState) -> Bool {
        guard let buttonImage = backgroundImage(for: state), let namedImage = UIImage(named: imageName) else {
            return false
        }
        
        return UIImagePNGRepresentation(buttonImage) == UIImagePNGRepresentation(namedImage)
    }
}

extension VoteVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adurls.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AdCell
        
        let url = URL(string: adImages[indexPath.row])
        cell.imgAd.sd_setImage(with: url, placeholderImage: nil, options: .lowPriority, completed: nil)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let url = URL(string: adurls[indexPath.row]) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
