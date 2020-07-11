//
//  CreateCallVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos
import MobileCoreServices
import ActionSheetPicker_3_0
import ProgressHUD
import MediaPlayer

class CreateCallVC: UIViewController {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var scrlViFields: UIScrollView!
    @IBOutlet weak var viContentsTitle: UIView!
    @IBOutlet weak var tfKeyword: UITextField!
    @IBOutlet weak var viDuration: UIView!
    @IBOutlet weak var btnSelectDuration: UIButton!
    @IBOutlet weak var viCallOutName: UIView!
    @IBOutlet weak var tfCallOutName: UITextField!
    @IBOutlet weak var viCategory: UIView!
    @IBOutlet weak var btnSelectCategory: UIButton!
    @IBOutlet weak var btnPrivateViewingCheck: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var viContents: UIView!
    @IBOutlet weak var imgViVideoThumb: UIImageView!
    @IBOutlet weak var viSubcategory: UIView!
    @IBOutlet weak var viMember: UIView!
    @IBOutlet weak var btnSubcategory: UIButton!
    
    @IBOutlet weak var viTypeSelection: UIView!
    @IBOutlet weak var viCallOutType: UIView!
    @IBOutlet weak var iconCallOutType: UIImageView!
    @IBOutlet weak var lblCallOutType: UILabel!
    
    @IBOutlet weak var viLoading: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblLoading: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnInviteFriends: UIButton!
    @IBOutlet weak var btnNonUserInvite: UIButton!
    
    var invitedUsers = [User]()
    
    var isPrivateViewing = false
    var nCallOutType:CALL_TYPE = .CALLOUT_TYPE_VIDEO
    var nSelectedCategoryIdx = 0
    var nSelectedSubCategoryIdx = 0
    var nSelectedDurationIdx = 0
    var arrCategoryTitles = [String]()
    var arrDurationTitles = [String]()
    var playerViewController:AVPlayerViewController!
    var videoURL:URL!
    var keywords = ""
    var audioItem:MPMediaItem?
    var audioItemUrl: URL?
    var selectAll = false
    
    @IBOutlet weak var typeSelectionViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoURL = URL(string: "")
        nCallOutType = .CALLOUT_TYPE_VIDEO
        arrDurationTitles = /*["24 hours", "1 Week", "2 Weeks", "3 Weeks", "4 Weeks", "5 Weeks", "6 Weeks", "7 Weeks", "8 Weeks", "9 Weeks", "10 Weeks"]*/["24 hours", "48 hours"]
        
//        scrlViFields.contentSize = CGSize(width: self.view.frame.size.width, height: 1036.0)
        
        viLoading.layer.masksToBounds = true
        viLoading.layer.cornerRadius = 6.0
        
        btnNext.layer.masksToBounds = true
        btnNext.layer.cornerRadius = 6.0
        
        viCallOutType.layer.masksToBounds = true
        viCallOutType.layer.cornerRadius = 6.0
        
        viContentsTitle.layer.masksToBounds = true
        viContentsTitle.layer.cornerRadius = 6.0
        
        viCallOutName.layer.masksToBounds = true
        viCallOutName.layer.cornerRadius = 6.0
        
        viCategory.layer.masksToBounds = true
        viCategory.layer.cornerRadius = 6.0
        
        viDuration.layer.masksToBounds = true
        viDuration.layer.cornerRadius = 6.0
        
        viMember.layer.masksToBounds = true
        viMember.layer.cornerRadius = 6.0
        
        viSubcategory.layer.masksToBounds = true
        viSubcategory.layer.cornerRadius = 6.0
        
        tfKeyword.attributedPlaceholder = NSAttributedString(string: "keywords(optional)", attributes: [NSAttributedStringKey.foregroundColor:UIColor(white: 1.0, alpha: 0.5)])
        tfCallOutName.attributedPlaceholder = NSAttributedString(string: "Call Out Name", attributes: [NSAttributedStringKey.foregroundColor:UIColor(white: 1.0, alpha: 0.5)])
        
        playerViewController = AVPlayerViewController()
        playerViewController.view.frame = viContents.bounds;
        playerViewController.showsPlaybackControls = true
        viContents.addSubview(playerViewController.view)
        viContents.sendSubview(toBack: playerViewController.view)
        playerViewController.view.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(notification(_:)), name: NSNotification.Name(rawValue: "peoples"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(allNotification(_:)), name: NSNotification.Name(rawValue: "Select All People"), object: nil)
    }
    @IBAction func inviteAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InviteVC") as! InviteVC
        vc.challengeName = tfCallOutName.text
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    @objc func allNotification(_ notification:Notification)
    {
        btnInviteFriends.alpha = 1.0
        btnInviteFriends.setTitle("All", for: .normal)
        selectAll = true
    }
    @objc func notification(_ notification:Notification)
    {
        btnInviteFriends.alpha = 1.0
        let userinfo = notification.userInfo
        invitedUsers = userinfo!["data"] as! [User]
        
        if invitedUsers.count == 0 {
            selectAll = true
        } else {
            if invitedUsers.count == 1
            {
                let user = invitedUsers[0]
                btnInviteFriends.setTitle(user.username, for: .normal)
            }
            else
            {
                btnInviteFriends.setTitle("Multiple users called out", for: .normal)
            }
            selectAll = false

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isPrivateViewing = false
        arrCategoryTitles = ["Fitness","Beauty","Music" ,"Sports","Martial Arts","Arts","Gaming","Design"]
        nSelectedCategoryIdx = 0
        nSelectedSubCategoryIdx = 0
        nSelectedDurationIdx = 0
        progressBar.setProgress(0, animated: false)
        
        if isPrivateViewing {
            btnPrivateViewingCheck.setImage(UIImage(named: "btnOptionSelected.png"), for: .normal)
            btnNext.setTitle("NEXT", for: .normal)
        }
        else {
            btnPrivateViewingCheck.setImage(UIImage(named: "btnOption.png"), for: .normal)
            btnNext.setTitle("PUBLISH", for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onCheckPrivateViewing(_ sender: Any) {
        isPrivateViewing = !isPrivateViewing
        
        if isPrivateViewing {
            btnPrivateViewingCheck.setImage(UIImage(named: "btnOptionSelected.png"), for: .normal)
            btnNext.setTitle("NEXT", for: .normal)
            
        }
        else {
            btnPrivateViewingCheck.setImage(UIImage(named: "btnOption.png"), for: .normal)
            btnNext.setTitle("PUBLISH", for: .normal)
        }
    }
    @IBAction func btnCloseTapped(_ sender: Any) {
        playerViewController.player?.pause()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onReset(_ sender: Any) {
        
    }
    
    @IBAction func onTakeMedia(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        if nCallOutType == .CALLOUT_TYPE_VIDEO{
            actionSheet.addAction(UIAlertAction(title: "Capture Video", style: .default, handler: { (alert) in
                actionSheet.dismiss(animated: true, completion: nil)
                let videoPicker = UIImagePickerController()
                videoPicker.sourceType = .camera
                videoPicker.mediaTypes = [kUTTypeMovie as String, kUTTypeAVIMovie as String, kUTTypeVideo as String, kUTTypeMPEG4 as String]
                videoPicker.videoQuality = .typeHigh
                videoPicker.allowsEditing = false
                videoPicker.delegate = self
                self.present(videoPicker, animated: true, completion: nil)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Choose Existing", style: .default, handler: { (action) in
                actionSheet.dismiss(animated: true, completion: nil)
                let videoPicker = UIImagePickerController()
                videoPicker.delegate = self
                videoPicker.modalPresentationStyle = .currentContext
                videoPicker.mediaTypes = [kUTTypeMovie as String, kUTTypeAVIMovie as String, kUTTypeVideo as String, kUTTypeMPEG4 as String]
                videoPicker.videoQuality = .typeMedium
                self.present(videoPicker, animated: true, completion: nil)
            }))
        }
        else if nCallOutType == .CALLOUT_TYPE_PHOTO
        {
            actionSheet.addAction(UIAlertAction(title: "Capture Photo", style: .default, handler: { (alert) in
                actionSheet.dismiss(animated: true, completion: nil)
                let videoPicker = UIImagePickerController()
                videoPicker.sourceType = .camera
//                videoPicker.mediaTypes = [kUTTypeMovie as String, kUTTypeAVIMovie as String, kUTTypeVideo as String, kUTTypeMPEG4 as String]
//                videoPicker.videoQuality = .typeMedium
                videoPicker.allowsEditing = true
                videoPicker.delegate = self
                self.present(videoPicker, animated: true, completion: nil)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Choose Existing", style: .default, handler: { (action) in
                actionSheet.dismiss(animated: true, completion: nil)
                let videoPicker = UIImagePickerController()
                videoPicker.delegate = self
                videoPicker.sourceType = .photoLibrary
                videoPicker.modalPresentationStyle = .currentContext
                self.present(videoPicker, animated: true, completion: nil)
            }))
        }
        else if nCallOutType == .CALLOUT_TYPE_AUDIO
        {
            actionSheet.addAction(UIAlertAction(title: "Record Audio", style: .default, handler: { (action) in
                actionSheet.dismiss(animated: true, completion: nil)
                let controller = AudioRecorderViewController()
                controller.audioRecorderDelegate = self
                self.present(controller, animated: true, completion: nil)
            }))
//            actionSheet.addAction(UIAlertAction(title: "Select Audio", style: .default, handler: { (action) in
//                actionSheet.dismiss(animated: true, completion: nil)
//                let mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.music)
//                mediaPicker.delegate = self
//                mediaPicker.allowsPickingMultipleItems = false
//                mediaPicker.showsCloudItems = false
//                self.present(mediaPicker, animated: true, completion: nil)
//            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func onTypeVideo(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.typeSelectionViewHeightConstraint.constant = 0.0
        }) { (finish) in
            self.lblCallOutType.text = "Video Call Out"
            self.iconCallOutType.image = UIImage(named: "iconVideoGray.png")
            self.nCallOutType = .CALLOUT_TYPE_VIDEO
        }
    }
    @IBAction func onTypeLive(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.typeSelectionViewHeightConstraint.constant = 0.0
        }) { (finish) in
            self.lblCallOutType.text = "Live Call Out"
            self.iconCallOutType.image = UIImage(named: "iconLiveGray")
            self.nCallOutType = .CALLOUT_TYPE_LIVE
        }
    }
    @IBAction func onTypePhoto(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.typeSelectionViewHeightConstraint.constant = 0.0
        }) { (finish) in
            self.lblCallOutType.text = "Photo Call Out"
            self.iconCallOutType.image = UIImage(named: "iconPhotoGray.png")
            self.nCallOutType = .CALLOUT_TYPE_PHOTO
        }
    }
    @IBAction func onTypeAudio(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.typeSelectionViewHeightConstraint.constant = 0.0
        }) { (finish) in
            self.lblCallOutType.text = "Audio Call Out"
            self.iconCallOutType.image = UIImage(named: "iconAudioGray.png")
            self.nCallOutType = .CALLOUT_TYPE_AUDIO
        }
    }
    @IBAction func onSelectCalloutType(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.typeSelectionViewHeightConstraint.constant = 136.0
        }) { (finish) in

        }
    }
    @IBAction func onSelectDuration(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Select duration", rows: arrDurationTitles, initialSelection: nSelectedDurationIdx, doneBlock: { (picker, index, value) in
            self.nSelectedDurationIdx = index
            self.btnSelectDuration.alpha = 1.0
            self.btnSelectDuration.setTitle(self.arrDurationTitles[self.nSelectedDurationIdx], for: .normal)
        }, cancel: { (picker) in
            
        }, origin: sender)
    }
    @IBAction func onSelectSubCategory(_ sender: Any) {
        if btnSelectCategory.title(for: .normal) == "Select Categories"
        {
            return
        }
        let valueArray = Array(Global.shared.AllCategory.values)
        ActionSheetStringPicker.show(withTitle: "Sub Category", rows: valueArray[self.nSelectedCategoryIdx], initialSelection: self.nSelectedSubCategoryIdx, doneBlock: { (picker, index, value) in
            self.nSelectedSubCategoryIdx = index
            if valueArray[self.nSelectedCategoryIdx].count > index {
                self.btnSubcategory.setTitle(valueArray[self.nSelectedCategoryIdx][index], for: .normal)
                self.btnSubcategory.alpha = 1.0
            }
            
        }, cancel: { (picker) in
//            self.nSelectedCategoryIdx = 0
//            self.btnSelectCategory.alpha = 0.5
//            self.btnSelectCategory.setTitle("Select Categories", for: .normal)
        }, origin: sender)
    }
    @IBAction func onSelectCategory(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Select Category", rows: Array(Global.shared.AllCategory.keys) , initialSelection: nSelectedCategoryIdx, doneBlock: { (picker, index, value) in
            self.nSelectedCategoryIdx = index
            self.btnSelectCategory.alpha = 1.0
            let list = Array(Global.shared.AllCategory.keys) 
            self.btnSelectCategory.setTitle(list[self.nSelectedCategoryIdx], for: .normal)
        }, cancel: { (picker) in
            
        }, origin: sender)
    }
    @IBAction func onSelectUsers(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InviteCallVC") as! InviteCallVC
        vc.invitedUsers = invitedUsers
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onNext(_ sender: Any) {
//        if invitedUsers.count == 0 && !selectAll
//        {
//            showAlert(alert: "Please select Users")
//            return
//        }
        if audioItemUrl == nil && audioItem == nil && nCallOutType == .CALLOUT_TYPE_AUDIO
        {
            showAlert(alert: "Please select Audio")
            return
        }
        if videoURL == URL(string: "") && nCallOutType == .CALLOUT_TYPE_VIDEO
        {
            showAlert(alert: "Please select Video")
            return
        }
        if imgViVideoThumb.image == UIImage(named: "") && nCallOutType == .CALLOUT_TYPE_PHOTO
        {
            showAlert(alert: "Please select Image")
            return
        }
        if tfCallOutName.text == ""
        {
            showAlert(alert: "Please enter call out name")
            return
        }

        if btnSelectCategory.title(for: .normal) == "Select Categories"
        {
            showAlert(alert: "Please select category")
            return
        }
        if isPrivateViewing
        {
            
            do{
                
                
                var imageData = (nCallOutType != .CALLOUT_TYPE_AUDIO) ? UIImagePNGRepresentation((imgViVideoThumb.image?.resizeWith(width: 200))!):nil
                var videoData:Data?
                if nCallOutType == .CALLOUT_TYPE_VIDEO
                {
                    
                    videoData = try Data.init(contentsOf: videoURL)
                }
                else if nCallOutType == .CALLOUT_TYPE_AUDIO
                {
                    imageData = nil
//                    videoData = try Data.init(contentsOf:(audioItem?.value(forProperty: MPMediaItemPropertyAssetURL) as? URL)!)
                }
                else{
                    videoData = nil
                }
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SendCallVC") as! SendCallVC
                vc.calloutname = tfCallOutName.text!
                vc.calloutcategory = (btnSubcategory.title(for: .normal)! == "Select Sub Categories") ?btnSelectCategory.title(for: .normal)!:btnSelectCategory.title(for: .normal)! + "," + btnSubcategory.title(for: .normal)!
                vc.duration = nSelectedDurationIdx
                vc.videoData = videoData
                vc.imageData = imageData
                vc.keyword = tfKeyword.text!
                vc.nCallOutType = nCallOutType
                vc.invitedUsers = self.invitedUsers
                vc.audioItemUrl = self.audioItemUrl
                vc.audioItem = self.audioItem
                vc.selectAll = self.selectAll
                self.present(vc, animated: true, completion: nil)
            }
            catch{
                
            }
        }
        else{
            do{
                ProgressHUD.show("Uploading...", interaction: false)
                var imageData = (nCallOutType != .CALLOUT_TYPE_AUDIO) ? UIImageJPEGRepresentation(imgViVideoThumb.image!, 0.8):nil
                var format = ""
                var videoData:Data?
                switch nCallOutType{
                    case .CALLOUT_TYPE_PHOTO:
                        format = "photo"
                        videoData = nil
                        break
                    case .CALLOUT_TYPE_AUDIO:
                        format = "audio"
                        imageData = nil
                        break
                    default:
                        break
                }
                
                var peoples = ""
                if selectAll || invitedUsers.count == 0 {
                    peoples = ""
                }
                else
                {
                    for user in invitedUsers{
                        if peoples == "" {
                            peoples = "\(user.id)"
                        } else {
                            peoples = "\(peoples), \(user.id)"
                        }
                    }
                }
                
                if nCallOutType == .CALLOUT_TYPE_AUDIO
                {
                    Global.getData(audioItemUrl, mediaItem: audioItem) { (audioData) in
                        DispatchQueue.main.async {
                            if (audioData == nil) {
                                self.showAlert(alert: "Selected audio is not able to upload")
                                return
                            }
                            Global.shared.post(posterID: (Global.getUserDataFromLocal()?.id)!, title: self.tfCallOutName.text!, category: (self.btnSubcategory.title(for: .normal)! == "Select Sub Categories") ?self.btnSelectCategory.title(for: .normal)!:self.btnSelectCategory.title(for: .normal)! + "," + self.btnSubcategory.title(for: .normal)!, duration: self.nSelectedDurationIdx, type: "0", video: audioData, image: nil,group: "",people: peoples,keyword: self.tfKeyword.text!, format: format) { (flag, result) in
                                ProgressHUD.dismiss()
                                if flag
                                {
                                    self.view.makeToast("success")
                                    self.dismiss(animated: true, completion: nil)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Callout_Update"), object: nil)
                                }
                                else
                                {
                                    self.view.makeToast(result)
                                }
                            }
                        }
                    }
                } else if nCallOutType == .CALLOUT_TYPE_PHOTO {
                    Global.shared.post(posterID: (Global.getUserDataFromLocal()?.id)!, title: tfCallOutName.text!, category: (btnSubcategory.title(for: .normal)! == "Select Sub Categories") ?btnSelectCategory.title(for: .normal)!:btnSelectCategory.title(for: .normal)! + "," + btnSubcategory.title(for: .normal)!, duration: nSelectedDurationIdx, type: "0", video: videoData, image: imageData!,group: "",people: peoples,keyword: tfKeyword.text!, format: format) { (flag, result) in
                        ProgressHUD.dismiss()
                        if flag
                        {
                            self.view.makeToast("success")
                            self.dismiss(animated: true, completion: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Callout_Update"), object: nil)
                        }
                        else
                        {
                            self.view.makeToast(result)
                        }
                    }
                }
                
                if nCallOutType == .CALLOUT_TYPE_VIDEO {
                    ProgressHUD.show("Video compressing...")
                    self.compressVideo(url: videoURL) { (compressed) in
                        if let url = compressed {
                            ProgressHUD.show("Uploading...")

                            format = "video"
                            do {
                                videoData = try Data(contentsOf: url)
                            } catch {
                                
                            }
                            
                            DispatchQueue.main.async {
                                var category: String = ""
                                category = (self.btnSubcategory.title(for: .normal)! == "Select Sub Categories") ? self.btnSelectCategory.title(for: .normal)!:self.btnSelectCategory.title(for: .normal)! + "," + self.btnSubcategory.title(for: .normal)!
                                
                                let keyword = self.tfKeyword.text ?? ""
                                let title = self.tfCallOutName.text ?? ""
                                
                                Global.shared.post(posterID: (Global.getUserDataFromLocal()?.id)!, title: title, category: category, duration: self.nSelectedDurationIdx, type: "0", video: videoData, image: imageData!,group: "",people: peoples,keyword: keyword, format: format) { (flag, result) in
                                    ProgressHUD.dismiss()
                                    if flag
                                    {
                                        self.view.makeToast("success")
                                        self.dismiss(animated: true, completion: nil)
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Callout_Update"), object: nil)
                                    }
                                    else
                                    {
                                        self.view.makeToast(result)
                                    }
                                }
                            }
                        } else {
                            ProgressHUD.dismiss()

                            self.showAlert(alert: "Video compress failed. Please try again")
                        }
                    }

                }
            }
            catch{
                
            }
        }
    }
    @IBAction func EditingChanged(_ sender: UITextField) {
        if keywords == ""
        {
            sender.text = "#" + sender.text!
        }
        else{
            if keywords.last! == " " && sender.text?.last != " " && (sender.text?.count)! >= keywords.count
            {
                sender.text = keywords + String("#") + String((sender.text?.last!)!)
            }
        }
        keywords = sender.text!
    }
    func showAlert(alert:String)
    {
        let alert = UIAlertController(title: "Alert", message: alert, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func compressVideo(url: URL, completion:@escaping (_ compressedURL: URL?)->Void) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let outputPath = documentsPath.appendingPathComponent("compressed.mov")
        
        
        let compressURL = URL(fileURLWithPath: outputPath)
        
        try? FileManager.default.removeItem(at: compressURL)
        
        let videoAsset: AVAsset = AVURLAsset(url: url, options: nil)
        let videoTrack: AVAssetTrack = videoAsset.tracks(withMediaType: .video).first!
        let videoSize = videoTrack.naturalSize
        
        let encoder = SDAVAssetExportSession(asset: AVAsset(url: url))!
        encoder.outputURL = compressURL
        encoder.outputFileType = AVFileType.mp4.rawValue
        encoder.shouldOptimizeForNetworkUse = true
        encoder.videoSettings = [ // 1280, 720
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 320,
            AVVideoHeightKey:videoSize.width / (videoSize.height / 320),
            
            AVVideoCompressionPropertiesKey: [
                
                AVVideoAverageBitRateKey: 725000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264Baseline30,
            ],
        ]
        
        encoder.audioSettings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 1, // Mono
            AVSampleRateKey: 44100,
            AVEncoderBitRateKey: 64000,
        ]
        
        encoder.exportAsynchronously {
            let status = encoder.status
            
            if status == .completed {
                completion(compressURL)
            } else {
                print("compressing failed = \(encoder.error.localizedDescription)")
                completion(nil)
            }
        }
    }
}

extension CreateCallVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate,AudioRecorderViewControllerDelegate, MPMediaPickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if nCallOutType == .CALLOUT_TYPE_VIDEO {
            videoURL = info[UIImagePickerControllerMediaURL] as! URL
            let thumbImage = UIImage(cgImage: Global.getThumbImageFromVideoFile(fileURL: videoURL)!)
            imgViVideoThumb.image = thumbImage.imageWithImage(sourceImage: thumbImage, scaledToWidth: 300)
            playerViewController.player = AVPlayer(url: videoURL)
    //        UIImage *thumbImage= [[UIImage alloc] initWithCGImage:[dataKeeper getThumbImageFromVideoFile:_videoURL]];
            viContents.bringSubview(toFront: playerViewController.view)
            playerViewController.view.isHidden = false
        }
        else
        {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            imgViVideoThumb.image = image.imageWithImage(sourceImage: image, scaledToWidth: 300)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let mediaItem = mediaItemCollection.items[0]
        
        if let url = mediaItem.assetURL{
            Global.getData(audioItemUrl, mediaItem: mediaItem) { (data) in
                if data == nil {
                    self.showAlert(alert: "Select audio is not able to upload")
                } else {
                    self.audioItem = mediaItem
                    self.playerViewController.player = AVPlayer(url: url)
                    self.viContents.bringSubview(toFront: self.playerViewController.view)
                    self.playerViewController.view.isHidden = false
                }
            }
        } else {
            showAlert(alert: "Only offline downloaded content can be uploaded")
        }
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }

    func audioRecorderViewControllerDismissed(withFileURL fileURL: URL?) {
        dismiss(animated: true, completion: nil)
        
        if fileURL != nil {
            audioItemUrl = fileURL
            playerViewController.player = AVPlayer(url: audioItemUrl!)
            viContents.bringSubview(toFront: playerViewController.view)
            playerViewController.view.isHidden = false
        }
    }
}

extension UIImage {
    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension CreateCallVC: InviteVCDelegate {
    func userSelected() {
        btnNonUserInvite.setTitle("User selected", for: .normal)
    }
}
