//
//  AcceptCallVC.swift
//  Call Me Out
//
//  Created by B S on 4/5/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import SDWebImage

class AcceptCallVC: UIViewController {

    @IBOutlet weak var imgViAvatar: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var viThumb: UIView!
    @IBOutlet weak var imgViCallOutThumb: UIImageView!
    @IBOutlet weak var iconCallOutType: UIImageView!
    @IBOutlet weak var lblCallOutName: UILabel!
    @IBOutlet weak var lblCallOutCategories: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    
    var callout:CallOut?
    
    var isChallenged: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viThumb.layer.masksToBounds = true
        viThumb.layer.cornerRadius = 6.0
        
        btnAccept.layer.masksToBounds = true
        btnAccept.layer.cornerRadius = 6.0
        
        btnDecline.layer.masksToBounds = true
        btnDecline.layer.cornerRadius = 6.0
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imgViAvatar.layer.masksToBounds = true
        imgViAvatar.layer.cornerRadius = imgViAvatar.frame.size.width / 2.0;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print (callout)
        imgViAvatar.sd_setImage(with: URL(string: callout?.poster.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
        lblUserName.text = callout?.poster.username
        if callout?.format == "video"
        {
            imgViCallOutThumb.sd_setImage(with: URL(string: callout?.thumb ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
            iconCallOutType.image = #imageLiteral(resourceName: "iconVideoGray.png")
        }
        else if callout?.format == "photo"{
            imgViCallOutThumb.sd_setImage(with: URL(string: callout?.thumb ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
            iconCallOutType.image = #imageLiteral(resourceName: "iconPhotoGray.png")
        }
        else
        {
            imgViCallOutThumb.image = #imageLiteral(resourceName: "iconAudioGray.png")
            iconCallOutType.image = #imageLiteral(resourceName: "iconAudioGray.png")
        }
        
        lblCallOutName.text = callout?.title
        lblCallOutCategories.text = callout?.category
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onDecline(_ sender: Any) {
        if isChallenged {
            self.view.makeToast("You have already accepted this Call Out")
            return
        }
        
        Global.shared.declineCallout(userId: "\((Global.getUserDataFromLocal()?.id)!)", post_id: (callout?.post_id)!) { (success) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onAccept(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReplyVC") as! ReplyVC
        vc.callout = callout
        vc.isNotification = true
        vc.direct = "N"
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
