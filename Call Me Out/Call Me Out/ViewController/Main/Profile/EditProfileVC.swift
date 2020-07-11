//
//  EditProfileVC.swift
//  Call Me Out
//
//  Created by B S on 4/30/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import ProgressHUD

protocol EditProfileDelegate {
    func profileUpdated();
}

class EditProfileVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblUsername: UITextField!
    @IBOutlet weak var lblFirstname: UITextField!
    @IBOutlet weak var lblLastname: UITextField!
    @IBOutlet weak var lblEmail: UITextField!
    @IBOutlet weak var lblPhonenumber: UITextField!
    @IBOutlet weak var lblBirthday: UITextField!
    @IBOutlet weak var tvBio: UITextView!
    @IBOutlet weak var tfBio: UITextField!
    @IBOutlet weak var tfTwitter: UITextField!
    @IBOutlet weak var tfInstagram: UITextField!
    @IBOutlet weak var tfFacebook: UITextField!
    
    var birthdaySelected:Date!
    
    var delegate: EditProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        birthdaySelected = Date()
//        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 820)
        if let user = Global.getUserDataFromLocal()
        {
//            imgAvatar.af_setImage(withURL: URL(string: user.avatar)!,placeholderImage:#imageLiteral(resourceName: "avatarEmpty.png"))
            imgAvatar.sd_setImage(with: URL(string: user.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .refreshCached, completed: nil)
            lblUsername.text = user.username.capitalized
            lblFirstname.text = user.first_name.capitalized
            lblLastname.text = user.last_name.capitalized
            lblEmail.text = user.email.capitalized
            lblPhonenumber.text = user.phone.capitalized
            lblBirthday.text = user.birthday
            tvBio.text = user.bio
            if user.bio.isEmpty || user.bio.count == 0 {
                tfBio.placeholder = "Bio"
            } else {
                tfBio.placeholder = ""
            }
            tfTwitter.text = user.tw_username
            tfFacebook.text = user.fb_username
            tfInstagram.text = user.in_username
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imgAvatar.layer.masksToBounds = true
        imgAvatar.layer.cornerRadius = imgAvatar.frame.height / 2
        
        imgAvatar.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imgAvatar.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnDoneTapped(_ sender: Any) {
        if lblUsername.text == "" {
            self.view.makeToast("Please add username")
            return
        } else if lblFirstname.text == "" {
            self.view.makeToast("Please add first name")
            return
        } else if lblLastname.text == "" {
            self.view.makeToast("Please add last name")
            return
        } else if lblEmail.text == "" {
            self.view.makeToast("Please add email")
            return
        } else if lblBirthday.text == "" {
            self.view.makeToast("Please add your birthday")
            return
        }

        self.view.endEditing(true)
        
        ProgressHUD.show("Update Profile...", interaction: false)
        let user = Global.getUserDataFromLocal()
        
        Global.shared.updateProfile(id: String((user?.id)!), email: lblEmail.text!, first_name: lblFirstname.text!, last_name: lblLastname.text!, birthday: lblBirthday.text!, username: lblUsername.text!, phone: lblPhonenumber.text!, bio: tvBio.text, image: UIImagePNGRepresentation((imgAvatar.image!).resizeWith(width: 100)!)!, fb: tfFacebook.text!,ins:tfInstagram.text!,tw: tfTwitter.text!) { (flag, photo) in
            ProgressHUD.dismiss()
            if flag{
                self.view.makeToast("Update Success")
                self.delegate?.profileUpdated()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_menu"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }else{
                self.view.makeToast(photo)
            }
        }
    }
    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onChangeProfile(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Photo selection", message: "Please select photo", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Capture a Photo", style: .default, handler: { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "From Library", style: .default, handler: { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func onBirthday(_ sender: UIButton) {
        ActionSheetDatePicker.show(withTitle: "Select your birthday", datePickerMode: .date, selectedDate: birthdaySelected, target: self, action: #selector(dateSelected(date:)), origin: sender, cancelAction: #selector(canceled))
    }
    @objc func dateSelected(date:Date)
    {
        birthdaySelected = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        lblBirthday.text = dateFormatter.string(from: birthdaySelected)
    }
    @objc func canceled()
    {
        
    }
}

extension EditProfileVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imgAvatar.image = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
extension EditProfileVC:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let linesAfterChange = existingLines.count + newLines.count - 1
        let font = UIFont.systemFont(ofSize: 14)
        let str = NSString(string: (textView.text + text))
        let size = str.boundingRect(with: CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude), options: .usesFontLeading, attributes: [NSAttributedStringKey.font: font], context: nil)
        return linesAfterChange <= 2 && textView.text.count + text.count <= 100 && size.height / font.lineHeight <= 2.0
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count != 0 {
            tfBio.placeholder = ""
        } else {
            tfBio.placeholder = "Bio"
        }
    }
}
