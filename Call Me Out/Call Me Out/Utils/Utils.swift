//
//  Utils.swift
//  Bucket
//
//  Created by gstream on 6/26/18.
//  Copyright © 2018 Bucket. All rights reserved.
//

import UIKit

class Utils {
    
    static let shared = Utils()
    
    static func getStoryboardName(_ name: String) -> String {
        return isPad() ? "\(name)_iPad" : name
    }
    
    /* Get ViewCtonroller From Storyboard */
    static func viewControllerWith(_ vcIdentifier: String, storyboardName: String = "Main") -> UIViewController? {
        let storyboard = UIStoryboard.init(name: getStoryboardName(storyboardName), bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: vcIdentifier)
    }
    
    static func isPhone4() -> Bool {
        return UIScreen.main.bounds.size.equalTo(CGSize.init(width: 320.0, height: 480.0))
    }
    
    /* Check if device is iPhoneX */
    static func isIPhoneX() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            if (UIScreen.main.nativeBounds.height == 2436) {
                return true
            }
        }
        
        return false
    }
    
    /* Check Pad */
    static func isPad() -> Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }
    
    // MARK: - Validators
    
    class func isValidEmail(email: String?) -> Bool {
        
        if email == nil { return false }
        
        let emailRegEx = "[A-Za-z0-9._\\-\\+]+@[A-Za-z0-9._-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    class func isValidPass(password: String) -> Bool {
        return !password.isEmpty
    }
    
    class func alertWithText(errorText: String?,
                             title: String                        = "Error",
                             cancelTitle: String                  = "OK",
                             cancelAction: (() -> Void)?          = nil,
                             otherButtonTitle: String?            = nil,
                             otherButtonStyle: UIAlertActionStyle = .default,
                             otherButtonAction: (() -> Void)?     = nil) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: errorText, preferredStyle: .alert)
        
        let handler = cancelAction == nil ? { () -> Void in } : cancelAction
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (alertAction: UIAlertAction!) in handler!() })
        alertController.addAction(cancelAction)
        
        if otherButtonTitle != nil && !otherButtonTitle!.isEmpty &&
            otherButtonAction != nil {
            let otherAction = UIAlertAction(title: otherButtonTitle!, style: otherButtonStyle, handler: { (alertAction: UIAlertAction!) in otherButtonAction!() })
            alertController.addAction(otherAction)
        }
        
        return alertController
    }
}
