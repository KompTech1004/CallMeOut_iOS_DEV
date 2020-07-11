//
//  InviteVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookShare
import FBSDKShareKit
import MessageUI

protocol InviteVCDelegate {
    func userSelected()
}

class InviteVC: UIViewController ,FBSDKAppInviteDialogDelegate,MFMailComposeViewControllerDelegate{
    var challengeName: String?
    
    var delegate: InviteVCDelegate?
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        let resultObject = NSDictionary(dictionary: results)
        
        if let didCancel = resultObject.value(forKey: "completeionGesture")
        {
            
        }
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print(error)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        if error == nil{
            delegate?.userSelected()
            dismiss(animated: false, completion: nil)
            print("success")
        }
        else
        {
            print("error")
        }
    }
    @IBAction func emailInvite(_ sender: Any) {
        if MFMailComposeViewController.canSendMail()
        {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setMessageBody("It is on! You have been called out by \((Global.getUserDataFromLocal()?.username)!) on the CallMeOut.com. You have 48 hours to accept the challenge. If you are not already a user, then join in on the fun and download the CallMeOut.com App from the App Store. Then respond to the challenge by going to \((Global.getUserDataFromLocal()?.username)!)'s profile and looking for \(challengeName ?? ""), and click challenge. (Android coming soon!)", isHTML: true)
            present(mail, animated: true, completion: nil)
        }
        else
        {
            self.view.makeToast("Please setup your email account on your phone.")
        }
    }
    
    @IBAction func phoneInvite(_ sender: Any) {
        if MFMessageComposeViewController.canSendText(){
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "It is on! You have been called out by \((Global.getUserDataFromLocal()?.username)!) on the CallMeOut.com. You have 48 hours to accept the challenge. If you are not already a user, then join in on the fun and download the CallMeOut.com App from the App Store. Then respond to the challenge by going to \((Global.getUserDataFromLocal()?.username)!)'s profile and looking for \(challengeName ?? ""), and click challenge. (Android coming soon!)"
            messageVC.messageComposeDelegate = self
            self.present(messageVC, animated: true, completion: nil)
        }
        else
        {
            self.view.makeToast("You can't sent sms because of some problem.")
        }
    }
    @IBAction func contactInvite(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactVC") as! ContactVC
        vc.challengeName = challengeName
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func fbInvite(_ sender: Any) {
//        let inviteDialog = FBSDKAppInviteDialog()
//        if(inviteDialog.canShow())
//        {
//            let appLink = URL(string: "http://callmeout.com")
//            let inviteContent = FBSDKAppInviteContent()
//            inviteContent.appLinkURL = appLink!
//            inviteContent.promotionText = "You have been invited to join the exciting competition app CallMeOut.com. Download the app to join in on the fun. View competitions, join in on the challenges, or call out a friend and start your own challenge. Download the app from the App Store, android version coming soon."
//            inviteDialog.fromViewController = self
//            inviteDialog.content = inviteContent
//            inviteDialog.delegate = self
//            inviteDialog.show()
//        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension InviteVC:MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result{
        case MessageComposeResult.cancelled:
            self.view.makeToast("You canceled sending invite")
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed:
            self.view.makeToast("Sending Failed. Please try again")
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent:
            controller.dismiss(animated: true, completion: nil)
            
            delegate?.userSelected()
            dismiss(animated: false, completion: nil)
            
        default:
            break
        }
    }
    
}

extension InviteVC: ContactVCDelegate {
    func messageSent() {
        delegate?.userSelected()
        dismiss(animated: false, completion: nil)
    }
}
