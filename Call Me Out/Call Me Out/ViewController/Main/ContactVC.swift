//
//  ContactVC.swift
//  Call Me Out
//
//  Created by B S on 5/22/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import Contacts
import ProgressHUD
import Messages
import MessageUI

protocol ContactVCDelegate {
    func messageSent()
}

class ContactVC: UIViewController {
    var delegate: ContactVCDelegate?
    
    var challengeName: String?
    
    @IBOutlet weak var searchBar: UISearchBar!
    var contacts = [CNContact]()
    
    var filteredcontacts = [CNContact]()
    
    var selectedContacts = [CNContact]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "cell")
        getContacts()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func sendAction(_ sender: Any) {
        if selectedContacts.count == 0
        {
            self.view.makeToast("Please select contact")
            return
        }
        var phonnumbers = [String]()
        for contact in selectedContacts
        {
            if contact.phoneNumbers.count != 0
            {
                let phonenumber = contact.phoneNumbers[0].value.value(forKey: "digits") as! String
                phonnumbers.append(phonenumber)
            }
        }
        if MFMessageComposeViewController.canSendText(){
            let messageVC = MFMessageComposeViewController()
            
            let singleMessage = "It is on! You have been called out by \((Global.getUserDataFromLocal()?.username)!) on the CallMeOut.com. You have 48 hours to accept the challenge. If you are not already a user, then join in on the fun and download the CallMeOut.com App from the App Store. Then respond to the challenge by going to \((Global.getUserDataFromLocal()?.username)!)'s profile and looking for \(challengeName ?? ""), and click challenge. (Android coming soon!)"
            
            let multiMessage = "It is on! You and a few other users have been called out by \((Global.getUserDataFromLocal()?.username)!) on the CallMeOut.com. You have 48 hours to accept the challenge. If you are not already a user, then join in on the fun and download the CallMeOut.com App from the App Store. Then respond to the challenge by going to \((Global.getUserDataFromLocal()?.username)!)'s profile and looking for \(challengeName ?? ""), and click challenge. (Android coming soon!)"
            
            messageVC.body = phonnumbers.count > 1 ? multiMessage : singleMessage
            messageVC.recipients = phonnumbers
            messageVC.messageComposeDelegate = self
            self.present(messageVC, animated: true, completion: nil)
        }
        else{
            self.view.makeToast("You can't sent sms because of some problem.")
        }
    }
    func getContacts()
    {
        let contactStore = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
        case .authorized:
            getContact()
            break
        case .denied,.notDetermined:
            contactStore.requestAccess(for: .contacts) { (access, error) in
                if access{
                    self.getContact()
                }
                else{
                    
                }
            }
        default:
            break
        }
    }
    func getContact()
    {
        let contactStore = CNContactStore()
        let keyToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey] as! [CNKeyDescriptor]
        var allContainers:[CNContainer] = []
        do{
            allContainers = try contactStore.containers(matching: nil)
        }catch{
            
        }
        for container in allContainers{
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do{
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keyToFetch )
                contacts.append(contentsOf: containerResults)
            }catch{
                
            }
        }
        
        contacts.sort { (contact1, contact2) -> Bool in
            return CNContactFormatter.string(from: contact1, style: .fullName) ?? "" < CNContactFormatter.string(from: contact2, style: .fullName) ?? ""
        }
        
        filteredcontacts = contacts
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
}

extension ContactVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0 {
            filteredcontacts = contacts
        } else {
            filteredcontacts = contacts.filter({ (contact) -> Bool in
                if let fullname = CNContactFormatter.string(from: contact, style: .fullName) {
                    if (contact.phoneNumbers.count != 0) {
                        if let phone = (contact.phoneNumbers[0].value.value(forKey: "digits") as? String) {
                            if fullname.contains(searchText) || phone.contains(searchText) {
                                return true
                            } else {
                                return false
                            }
                        } else {
                            if fullname.contains(searchText) {
                                return true
                            }
                            
                            return false
                        }
                    } else{
                        return false
                    }
                } else {
                    return false
                }
            })
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ContactVC:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredcontacts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        let contact = filteredcontacts[indexPath.row]
        cell.lblName.text = CNContactFormatter.string(from: contact, style: .fullName)
        cell.lblPhonenumber.text = (contact.phoneNumbers.count != 0) ?contact.phoneNumbers[0].value.value(forKey: "digits") as? String:""
        if selectedContacts.contains(contact)
        {
            cell.btnAdd.setImage(#imageLiteral(resourceName: "iconMinus.png"), for: .normal)
        }
        else
        {
            cell.btnAdd.setImage(#imageLiteral(resourceName: "iconPlus.png"), for: .normal)
        }
        cell.btnAdd.tag = indexPath.row
        cell.btnAdd.addTarget(self, action: #selector(addAction(_:)), for: .touchUpInside)
        return cell
    }
    @objc func addAction(_ sender:UIButton)
    {
        let tag = sender.tag
        let contact = filteredcontacts[tag]
        if selectedContacts.contains(contact)
        {
            var index = 0
            index = selectedContacts.index(of: contact)!
            selectedContacts.remove(at: index)
        }
        else
        {
            selectedContacts.append(contact)
        }
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension ContactVC:MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate{
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
            
            delegate?.messageSent()
            dismiss(animated: false, completion: nil)
            
        default:
            break
        }
    }
    
}
