//
//  TermsVC.swift
//  Call Me Out
//
//  Created by B S on 4/3/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import WebKit

class TermsVC: UIViewController {

    @IBOutlet weak var navHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.load(URLRequest(url: URL(string: "http://callmeout.com/call_me_out/terms.htm")!))
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Utils.isIPhoneX() {
            navHeightConstraint.constant = 84
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
