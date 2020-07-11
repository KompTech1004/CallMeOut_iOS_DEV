//
//  ReplyVC.swift
//  Call Me Out
//
//  Created by B S on 4/5/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AVKit
import ProgressHUD
import MediaPlayer

class ReplyVC: UIViewController {

    @IBOutlet weak var viContents: UIView!
    @IBOutlet weak var imgViChallenger: UIImageView!
    @IBOutlet weak var imgViInitator: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCallOutName: UILabel!
    @IBOutlet weak var lblCallOutCategories: UILabel!
    @IBOutlet weak var iconCallOutType: UIImageView!
    @IBOutlet weak var btnPublish: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var viLoading: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblLoading: UILabel!
    
    var videoURL:URL?
    var videoDownloadURL:URL?
    var thumbnailImageDownloadURL:URL?
    
    var videoPlayerInitator:AVPlayerViewController!
    var playerViewController:AVPlayerViewController!
    
    var callout:CallOut?
    var isNotification = true
    var audioItem:MPMediaItem?
    var audioItemUrl: URL?
    
    var direct: String = "N"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoURL = URL(string: "")
        videoDownloadURL = URL(string: "")
        thumbnailImageDownloadURL = URL(string: "")
        
        btnPublish.layer.masksToBounds = true
        btnPublish.layer.cornerRadius = 6.0
        
        viLoading.layer.masksToBounds = true
        viLoading.layer.cornerRadius = 6.0
        
        videoPlayerInitator = AVPlayerViewController()
        videoPlayerInitator?.view.frame = imgViInitator.bounds
        videoPlayerInitator?.showsPlaybackControls = false
        imgViInitator.addSubview((videoPlayerInitator?.view)!)
        
        playerViewController = AVPlayerViewController()
        playerViewController?.view.frame = imgViChallenger.bounds
        playerViewController?.showsPlaybackControls = false
        playerViewController?.view.isHidden = true
        
        if callout != nil
        {
            lblCallOutCategories.text = callout?.category
            lblCallOutName.text = callout?.title
            if callout?.format == "video"
            {
                imgViInitator.sd_setImage(with: URL(string: callout?.thumb ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
                lblCallOutName.text = callout?.title
                lblCallOutCategories.text = callout?.category
                videoPlayerInitator?.player = AVPlayer(url: URL(string: (callout?.video)!)!)
                videoPlayerInitator?.player?.play()
            }
            else if callout?.format == "photo"
            {
                imgViInitator.sd_setImage(with: URL(string: callout?.thumb ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
                lblCallOutName.text = callout?.title
                lblCallOutCategories.text = callout?.category
                videoPlayerInitator?.view.isHidden = true
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onTakeMedia(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        if callout?.format == "video"
        {
            actionSheet.addAction(UIAlertAction(title: "Capture Video", style: .default, handler: { (action) in
                let videoPicker = UIImagePickerController()
                videoPicker.sourceType = .camera
                videoPicker.mediaTypes = [kUTTypeMovie as String, kUTTypeAVIMovie as String, kUTTypeVideo as String, kUTTypeMPEG4 as String]
                videoPicker.allowsEditing = false
                videoPicker.videoQuality = .typeMedium
                
                self.videoPlayerInitator.player?.isMuted = true
                
                videoPicker.delegate = self
                
                
                self.present(videoPicker, animated: true, completion: nil)
            }))
            actionSheet.addAction(UIAlertAction(title: "Choose Existing", style: .default, handler: { (action) in
                let videoPicker = UIImagePickerController()
                videoPicker.sourceType = .photoLibrary
                videoPicker.modalPresentationStyle = .currentContext
                videoPicker.mediaTypes = [kUTTypeMovie as String, kUTTypeAVIMovie as String, kUTTypeVideo as String, kUTTypeMPEG4 as String]
                videoPicker.allowsEditing = false
                videoPicker.videoQuality = .typeMedium
                videoPicker.delegate = self
                self.present(videoPicker, animated: true, completion: nil)
            }))
        }
        else if callout?.format == "photo"
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
        else if callout?.format == "audio"
        {
            actionSheet.addAction(UIAlertAction(title: "Record Audio", style: .default, handler: { (action) in
                actionSheet.dismiss(animated: true, completion: nil)
                let controller = AudioRecorderViewController()
                controller.audioRecorderDelegate = self
                self.videoPlayerInitator.player?.isMuted = true
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
    @IBAction func onClose(_ sender: Any) {
//        if isNotification{
        if isNotification{
//            self.dismiss(animated: true, completion: nil)
            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                self.presentingViewController?.dismiss(animated: false, completion: nil)
            })
        }
        else
        {
            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                self.presentingViewController?.dismiss(animated: false, completion: nil)
            })
        }
//        }
//        else
//        {
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    @IBAction func onPublish(_ sender: Any) {
        if videoURL == URL(string:"") && callout?.format == "video"
        {
            self.view.makeToast("Select video for challenge!")
            return
        }
        else if imgViChallenger.image == UIImage(named: "") && callout?.format == "photo"
        {
            self.view.makeToast("select photo for challenge!")
            return
        }
        else if callout?.format == "audio" && audioItemUrl == nil && audioItem == nil
        {
            self.view.makeToast("Select Audio for challenge!")
            return
        }
        do{
            ProgressHUD.show("Uploading...", interaction: false)
            let image = (callout?.format != "audio") ?UIImageJPEGRepresentation(imgViChallenger.image!, 0.8):nil
            var video:Data?
            if callout?.format == "video"{
                video = try Data(contentsOf: videoURL!)
            }
            else if callout?.format == "photo"
            {
                video = nil
            }
            if callout?.format == "audio"
            {
                let challenger = self.callout?.challenger
                
                var isFirst: String = "0"
                if challenger == nil || challenger?.id != Global.getUserDataFromLocal()?.id {
                    isFirst = "1"
                }
                
                Global.getData(audioItemUrl, mediaItem: audioItem) { (audioData) in
                    Global.shared.challenge(challengeID: (Global.getUserDataFromLocal()?.id)!, id: (self.callout?.id)!, post_id: (self.callout?.post_id)!, image: image, first: isFirst, video: audioData,type:(self.callout?.format)!, direct: self.direct) { (flag, result) in
                        ProgressHUD.dismiss()
                        if flag
                        {
                            self.view.makeToast("success")
                            if self.isNotification{
                                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                                    self.presentingViewController?.dismiss(animated: false, completion: nil)
                                })
                                //                                self.dismiss(animated: false, completion: {
                                //                                    Global.shared.tabbar?.selectedIndex = 0
                                //                                })
                            }else
                            {
                                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                                    self.presentingViewController?.dismiss(animated: false, completion: nil)
                                })
                            }
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Callout_Update"), object: nil)
                        }
                        else
                        {
                            self.view.makeToast(result)
                        }
                    }
                }
            }
            else if callout?.format == "photo"
            {
                
                
                let challenger = self.callout?.challenger
                
                var isFirst: String = "0"
                if challenger == nil || challenger?.id != Global.getUserDataFromLocal()?.id {
                    isFirst = "1"
                }
                
                Global.shared.challenge(challengeID: (Global.getUserDataFromLocal()?.id)!, id: (callout?.id)!, post_id: (callout?.post_id)!, image: image, first: isFirst, video: video,type:(callout?.format)!, direct: direct) { (flag, result) in
                    ProgressHUD.dismiss()
                    if flag
                    {
                        self.view.makeToast("success")
                        if self.isNotification{
//                            self.dismiss(animated: false, completion: {
//                                Global.shared.tabbar?.selectedIndex = 0
//                            })
                            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                                self.presentingViewController?.dismiss(animated: false, completion: nil)
                            })
                        }else
                        {
                            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                                self.presentingViewController?.dismiss(animated: false, completion: nil)
                            })
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Callout_Update"), object: nil)
                    }
                    else
                    {
                        self.view.makeToast(result)
                    }
                }
            } else {
                ProgressHUD.show("Compressing video...")
                self.compressVideo(url: videoURL!) { (compressedURL) in
                    
                    if let url = compressedURL {
                        ProgressHUD.show("Uploading...")

                        do {
                            video = try Data(contentsOf: url)
                        } catch {
                            
                        }
                        
                        
                        let challenger = self.callout?.challenger
                        
                        var isFirst: String = "0"
                        if challenger == nil || challenger?.id != Global.getUserDataFromLocal()?.id {
                            isFirst = "1"
                        }
                        
                        Global.shared.challenge(challengeID: (Global.getUserDataFromLocal()?.id)!, id: (self.callout?.id)!, post_id: (self.callout?.post_id)!, image: image, first: isFirst, video: video,type:(self.callout?.format)!, direct: self.direct) { (flag, result) in
                            ProgressHUD.dismiss()
                            if flag
                            {
                                self.view.makeToast("success")
                                if self.isNotification{
                                    self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                                        self.presentingViewController?.dismiss(animated: false, completion: nil)
                                    })
                                }else
                                {
                                    self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                                        self.presentingViewController?.dismiss(animated: false, completion: nil)
                                    })
                                }
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Callout_Update"), object: nil)
                            }
                            else
                            {
                                self.view.makeToast(result)
                            }
                        }
                    } else {
                        ProgressHUD.dismiss()

                        self.showAlert(alert: "Video compression failed. please try again")
                    }
                }
            }
        }catch{
            
        }
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
            AVVideoWidthKey: 180,
            AVVideoHeightKey:videoSize.width / (videoSize.height / 180),
            
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
                completion(nil)
            }
        }
    }
}
extension ReplyVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate,AudioRecorderViewControllerDelegate, MPMediaPickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if callout?.format == "video"
        {
            videoURL = info[UIImagePickerControllerMediaURL] as? URL
            let thumbImage = UIImage(cgImage: Global.getThumbImageFromVideoFile(fileURL: videoURL!)!)
            imgViChallenger.image = thumbImage.imageWithImage(sourceImage: thumbImage, scaledToWidth: 300)
            
            playerViewController = AVPlayerViewController()
            playerViewController?.view.frame = imgViChallenger.bounds
            playerViewController?.showsPlaybackControls = false
            viContents.addSubview((playerViewController?.view)!)
            viContents.sendSubview(toBack: (playerViewController?.view)!)
            
            playerViewController?.player = AVPlayer(url: videoURL!)
            viContents.bringSubview(toFront: (playerViewController?.view)!)
            self.videoPlayerInitator.player?.isMuted = false
            playerViewController?.view.isHidden = false
            playerViewController?.player?.play()
        }
        else if callout?.format == "photo"
        {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            imgViChallenger.image = image.imageWithImage(sourceImage: image, scaledToWidth: 300)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.videoPlayerInitator.player?.isMuted = false
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(alert:String)
    {
        let alert = UIAlertController(title: "Alert", message: alert, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let mediaItem = mediaItemCollection.items[0]
        
        if let url = (mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as? URL) {
            audioItem = mediaItem
            playerViewController?.player = AVPlayer(url: url)
            viContents.bringSubview(toFront: (playerViewController?.view)!)
            playerViewController?.view.isHidden = false
            playerViewController?.player?.play()
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
            
            viContents.addSubview((playerViewController?.view)!)
//            viContents.sendSubview(toBack: (playerViewController?.view)!)
//
//            viContents.bringSubview(toFront: playerViewController.view)
            playerViewController.view.isHidden = false
            self.videoPlayerInitator.player?.isMuted = false
            
            playerViewController?.player?.play()
        }
    }
}
