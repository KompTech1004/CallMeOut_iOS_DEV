//
//  RegisterVC.swift
//  Call Me Out
//
//  Created by B S on 4/2/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import BABCropperView
import ActionSheetPicker_3_0
import ProgressHUD
import Firebase

class RegisterVC: UIViewController,UINavigationControllerDelegate {

    @IBOutlet weak var viCropper: UIView!
    @IBOutlet weak var cropperView: BABCropperView!
    @IBOutlet weak var croppedImageView: UIImageView!
    @IBOutlet weak var cropButton: UIButton!
    
    @IBOutlet weak var scrlViSignUp: UIScrollView!
    @IBOutlet weak var viFields: UIView!
    @IBOutlet weak var imgViAvatar: UIImageView!
    @IBOutlet weak var btnAvatar: UIButton!
    
    @IBOutlet weak var viLoading: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblLoading: UILabel!
    
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    @IBOutlet weak var tfConfirmPwd: UITextField!
    @IBOutlet weak var tfPhoneNo: UITextField!
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var tfEmail: UITextField!
    
    @IBOutlet weak var viBirthday: UIView!
    @IBOutlet weak var tfBirthday: UITextField!
    @IBOutlet weak var tfFB: UITextField!
    @IBOutlet weak var tfTW: UITextField!
    @IBOutlet weak var tfIN: UITextField!
    
    var actShtPhoto:UIActionSheet!
    var imagePicker:UIImagePickerController!
    var birthdaySelected:Date!
    var isAvatarPhotoTaken = false
    var strUserAvatarPhotoURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viLoading.layer.masksToBounds = true;
        viLoading.layer.cornerRadius = 6.0;
        
        viFields.layer.masksToBounds = true;
        viFields.layer.cornerRadius = 6.0;
        
        viBirthday.layer.masksToBounds = true;
        viBirthday.layer.cornerRadius = 6.0;
        
        btnCreate.layer.masksToBounds = true;
        btnCreate.layer.cornerRadius = 6.0;
        
        imgViAvatar.layer.borderColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6).cgColor
        imgViAvatar.layer.borderWidth = 1.0;
        
        birthdaySelected = Date()
        isAvatarPhotoTaken = false;
        strUserAvatarPhotoURL = "";
        
        
        actShtPhoto = UIActionSheet(title: "Select photo from", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Camera", "Photo library")
//            [[UIActionSheet alloc] initWithTitle:@"Select photo from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo library", nil];
        
        self.cropperView.cropsImageToCircle = false
        
        // If there is a camera, then display the world throught the viewfinder
        if(UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo;
            imagePicker.cameraDevice = .rear
            imagePicker.showsCameraControls = true
            imagePicker.isNavigationBarHidden = true
            imagePicker.isToolbarHidden = true
            
        }
            // Otherwise, do nothing.
        else
        {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.isNavigationBarHidden = true
            imagePicker.isToolbarHidden = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        imgViAvatar.layer.masksToBounds = true;
        imgViAvatar.layer.cornerRadius = imgViAvatar.frame.size.width / 2.0;

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        scrlViSignUp.contentSize = CGSize(width: scrlViSignUp.frame.size.width, height: 850)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onShowPwd(_ sender: Any) {
        tfPassword.isSecureTextEntry = !tfPassword.isSecureTextEntry
        tfConfirmPwd.isSecureTextEntry = !tfConfirmPwd.isSecureTextEntry
    }
    
    @IBAction func btnSignupTapped(_ sender: UIButton) {
        if tfUsername.text == "" {
            self.view.makeToast("Please add username")
            return
        } else if tfFirstName.text == "" {
            self.view.makeToast("Please add first name")
            return
        } else if tfLastName.text == "" {
            self.view.makeToast("Please add last name")
            return
        } else if tfEmail.text == "" {
            self.view.makeToast("Please add email")
            return
        } else if tfPassword.text == "" {
            self.view.makeToast("Please add password")
            return
        } else if tfBirthday.text == "" {
            self.view.makeToast("Please add birthday")
            return
        } else if tfPassword.text != tfConfirmPwd.text {
            self.view.makeToast("Password does not match")
            return
        }

        ProgressHUD.show("Register...", interaction: false)
        Global.shared.register(email: tfEmail.text!, password: tfPassword.text!, first_name: tfFirstName.text!, last_name: tfLastName.text!, birthday: tfBirthday.text!, username: tfUsername.text!, phone: tfPhoneNo.text, image: UIImagePNGRepresentation((imgViAvatar.image?.resizeWith(width: 100))!),fb:tfFB.text!,ins:tfIN.text!,tw:tfTW.text! ) { (flag, result) in
            ProgressHUD.dismiss()
            if flag
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_menu"), object: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let main = storyboard.instantiateViewController(withIdentifier: "TabbarVC")
                Global.shared.tabbar = main as? TabbarVC
                SlideNavigationController.sharedInstance().popToRootAndSwitch(to: main, withSlideOutAnimation: false, andCompletion: nil)
                
                if let token = InstanceID.instanceID().token()
                {
                    print(token)
                    if let user = Global.getUserDataFromLocal(){
                        Global.shared.updateFcm(userid: String(user.id), token: token) { (flag, result) in
                            print(result)
                        }
                    }
                }
                
            }
            else
            {
                self.view.makeToast(result)
            }
        }
    }
    
    @IBAction func onAvatar(_ sender: UIButton) {
        cropperView.cropSize = CGSize(width: 1024.0, height: 1024.0)
        actShtPhoto.show(in: self.view)
    }
    
    @IBAction func onCropImage(_ sender: UIButton) {
        if cropperView.isHidden
        {
            cropperView.isHidden = false
            croppedImageView.isHidden = true
            self.present(imagePicker, animated: false, completion: nil)
        }
        else{
            cropperView.renderCroppedImage { (croppedImage, cropRect) in
                self.cropperView.isHidden = true
                self.croppedImageView.isHidden = false
                self.croppedImageView.image = croppedImage
                self.cropButton.setTitle("Retake", for: .normal)
            }
        }
    }
    
    
    @IBAction func onCropDone(_ sender: UIButton) {
        if croppedImageView.image == nil{
            self.view.makeToast("Please crop image first")
            return
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.viCropper.alpha = 0.0
            self.imgViAvatar.image = self.croppedImageView.image
            self.isAvatarPhotoTaken = true
        }) { (finish) in
            self.viCropper.isHidden = true
        }
    }
    
    @IBAction func onBirthday(_ sender: UIButton) {
        ActionSheetDatePicker.show(withTitle: "Select your birthday", datePickerMode: .date, selectedDate: birthdaySelected, target: self, action: #selector(dateSelected(date:)), origin: sender, cancelAction: #selector(canceled))
    }
    @objc func dateSelected(date:Date)
    {
        birthdaySelected = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        tfBirthday.text = dateFormatter.string(from: birthdaySelected)
    }
    @objc func canceled()
    {
        
    }
}

extension RegisterVC:UIActionSheetDelegate
{
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet == actShtPhoto
        {
            if buttonIndex == 1
            {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            else if buttonIndex == 2
            {
                imagePicker.sourceType = .photoLibrary
                present(imagePicker, animated: true, completion: nil)
            }
            else{
                actionSheet.dismiss(withClickedButtonIndex: 3, animated: true)
            }
        }
    }
}
extension RegisterVC:UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imgViAvatar.image = image
//        viCropper.alpha = 1.0
//        viCropper.isHidden = false
//        cropButton.setTitle("Crop Image", for: .normal)
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
