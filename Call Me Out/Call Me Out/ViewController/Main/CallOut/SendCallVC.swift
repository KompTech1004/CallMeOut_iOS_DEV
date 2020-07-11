//
//  SendCallVC.swift
//  Call Me Out
//
//  Created by B S on 4/5/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import ProgressHUD
import ActionSheetPicker_3_0
import MediaPlayer

class SendCallVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var imgViCallOutThumb: UIImageView!
    @IBOutlet weak var lblCallOutName: UILabel!
    
    @IBOutlet weak var viThumb: UIView!
    @IBOutlet weak var lblCategories: UILabel!
    @IBOutlet weak var iconCallOutType: UIImageView!
    @IBOutlet weak var btnCreateGroup: UIButton!
    @IBOutlet weak var viSelectGroup: UIView!
    @IBOutlet weak var btnSelectGroup: UIButton!
    @IBOutlet weak var viInviteFriends: UIView!
    @IBOutlet weak var btnInviteFriends: UIButton!
    @IBOutlet weak var btnPublish: UIButton!
    @IBOutlet weak var viLoading: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblLoading: UILabel!
    @IBOutlet weak var btnEditGroup: UIButton!
    var nSelectedGroupIdx = 0
    
    var imgThumb:UIImage?
    var keyword = ""
    var calloutname = ""
    var calloutcategory = ""
    var imageData:Data?
    var videoData:Data?
    var duration = 0
    var nCallOutType:CALL_TYPE = .CALLOUT_TYPE_VIDEO
    var audioItem:MPMediaItem?
    var audioItemUrl: URL?
    
    var groups = [Group]()
    var groupsNames = [String]()
    var invitedUsers = [User]()
    
    var selectAll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nSelectedGroupIdx = 0
        
        viLoading.layer.masksToBounds = true
        viLoading.layer.cornerRadius = 6.0
        
        viThumb.layer.masksToBounds = true
        viThumb.layer.cornerRadius = 6.0
        
        viSelectGroup.layer.masksToBounds = true
        viSelectGroup.layer.cornerRadius = 6.0
        
        viInviteFriends.layer.masksToBounds = true
        viInviteFriends.layer.cornerRadius = 6.0
        
        btnPublish.layer.masksToBounds = true
        btnPublish.layer.cornerRadius = 6.0
        
        btnCreateGroup.layer.masksToBounds = true
        btnCreateGroup.layer.cornerRadius = 6.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(notification(_:)), name: NSNotification.Name(rawValue: "peoples"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createGroup(_:)), name: NSNotification.Name(rawValue: "create_group"), object: nil)
    }
    @objc func createGroup(_ notification:Notification)
    {
        let userinfo = notification.userInfo
        let groupname = userinfo!["group"] as! String
        btnCreateGroup.setTitle(groupname, for: .normal)
        btnCreateGroup.alpha = 1.0
    }
    @objc func notification(_ notification:Notification)
    {
//        btnInviteFriends.alpha = 1.0
//        let userinfo = notification.userInfo
//        invitedUsers = userinfo!["data"] as! [User]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        progressBar.setProgress(0, animated: true)
        
        if nCallOutType != .CALLOUT_TYPE_AUDIO
        {
            imgViCallOutThumb.image = UIImage(data: imageData!)
        }
        else
        {
            imgViCallOutThumb.image = #imageLiteral(resourceName: "iconAudioGray.png")
        }
        lblCallOutName.text = calloutname
        lblCategories.text = calloutcategory
        
        Global.shared.getGroup(userid: String((Global.getUserDataFromLocal()?.id)!)) { (result) in
            self.groups = result
            self.groupsNames = [String]()
            for group in self.groups{
                self.groupsNames.append(group.name)
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onInviteFriends(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InviteCallVC") as! InviteCallVC
        vc.invitedUsers = invitedUsers
        present(vc, animated: true, completion: nil)
    }
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onCreateGroup(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateGroupVC") as! CreateGroupVC
        vc.invitedUsers = invitedUsers
        present(vc, animated: true, completion: nil)
    }
    @IBAction func onSelectGroup(_ sender: Any) {
        if groups.count == 0
        {
            self.view.makeToast("No Group, Please create group")
            return
        }
        ActionSheetStringPicker.show(withTitle: "Select Group", rows: groupsNames, initialSelection: nSelectedGroupIdx, doneBlock: { (picker, index, value) in
            self.nSelectedGroupIdx = index
            self.btnSelectGroup.alpha = 1.0
            self.btnSelectGroup.setTitle(self.groupsNames[self.nSelectedGroupIdx], for: .normal)
            self.btnEditGroup.alpha = 1.0
        }, cancel: { (picker) in
            self.btnSelectGroup.setTitle("Select Group",for:.normal)
            self.btnSelectGroup.alpha = 0.5
            self.btnEditGroup.alpha = 0.5
        }, origin: sender)
    }
    @IBAction func onEditGroup(_ sender: Any) {
        if btnSelectGroup.title(for: .normal) == "Select Group"
        {
            return
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateGroupVC") as! CreateGroupVC
        vc.invitedUsers = invitedUsers
        vc.isCreate = false
        vc.group = groups[self.nSelectedGroupIdx]
        present(vc, animated: true, completion: nil)
    }
    @IBAction func onPublish(_ sender: Any) {
        var group = ""
        if btnSelectGroup.title(for: .normal) == "Select Group"// || invitedUsers.count == 0)
        {
//            self.view.makeToast("Please select group or invite some peoples for  your private call out")
//            return
            group = ""
        }
        else
            {
            group = self.groups[self.nSelectedGroupIdx].id
        }
        var peoples = ""
        if selectAll || invitedUsers.count == 0 {
            peoples = ""
        }
        else{
            for user in invitedUsers{
                if peoples == "" {
                    peoples = "\(user.id)"
                } else {
                    peoples = "\(peoples), \(user.id)"
                }
            }
        }
        var format = ""
        switch nCallOutType {
        case .CALLOUT_TYPE_PHOTO:
            format = "photo"
        case .CALLOUT_TYPE_VIDEO:
            format = "video"
        case .CALLOUT_TYPE_AUDIO:
            format = "audio"
        default:
            break
        }
        ProgressHUD.show("Uploading...", interaction: false)
        if nCallOutType == .CALLOUT_TYPE_AUDIO
        {
            Global.getData(audioItemUrl, mediaItem: audioItem) { (audioData) in
                Global.shared.post(posterID: (Global.getUserDataFromLocal()?.id)!, title: self.calloutname, category: self.calloutcategory, duration: self.duration, type: "1", video: audioData, image: nil,group: group,people: peoples, keyword: self.keyword, format: format) { (flag, result) in
                    ProgressHUD.dismiss()
                    if flag
                    {
                        self.view.makeToast("success")
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                            self.presentingViewController?.dismiss(animated: false, completion: nil)
                        })
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Callout_Update"), object: nil)
                    }
                    else
                    {
                        self.view.makeToast(result)
                    }
                }
            }
        }
        else
        {
            Global.shared.post(posterID: (Global.getUserDataFromLocal()?.id)!, title: calloutname, category: calloutcategory, duration: duration, type: "1", video: videoData, image: imageData!,group: group,people: peoples, keyword: keyword, format: format) { (flag, result) in
                ProgressHUD.dismiss()
                if flag
                {
                    self.view.makeToast("success")
                    self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                        self.presentingViewController?.dismiss(animated: false, completion: nil)
                    })
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Callout_Update"), object: nil)
                }
                else
                {
                    self.view.makeToast(result)
                }
            }
        }
        
    }
}
