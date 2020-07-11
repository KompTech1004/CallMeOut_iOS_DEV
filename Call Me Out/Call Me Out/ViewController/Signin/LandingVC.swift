//
//  LandingVC.swift
//  Call Me Out
//
//  Created by B S on 4/2/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class LandingVC: UIViewController {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    
    @IBOutlet weak var viTemp1: UIView!
    @IBOutlet weak var viTemp2: UIView!
    var birthdaySelected:Date!
    
    var offsetX1:Float = 0.0
    var offsetX2:Float = 0.0
    var flTotalContentWidth:Float = 0.0
    
    var timer1:Timer?
    var timer2:Timer = Timer()
    
    @IBOutlet weak var topListCollectionView: UICollectionView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var arrPopularCallOuts = [[String:String]]()
    
    var currentContentOffset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnLogin.layer.masksToBounds = true
        btnLogin.layer.cornerRadius = 6.0
        
        btnSignup.layer.masksToBounds = true
        btnSignup.layer.cornerRadius = 6.0
        
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        
        Global.shared.getTopList(id: "0") { (result) in
            self.indicator.stopAnimating()
            if result.count != 0
            {
                self.arrPopularCallOuts = result
                if self.arrPopularCallOuts.count < 5
                {
                    var index = 0
                    while(self.arrPopularCallOuts.count != 5)
                    {
                        if index >= result.count
                        {
                            index = 0
                        }
                        self.arrPopularCallOuts.append(result[index])
                        index = index + 1
                    }
                }
//                self.draw()
                self.topListCollectionView.reloadData()
                
                self.timer1 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.onTimer1), userInfo: nil, repeats: true)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        currentContentOffset = 0
        topListCollectionView.setContentOffset(CGPoint(x: currentContentOffset, y: topListCollectionView.contentOffset.y), animated: true)
        
        if arrPopularCallOuts.count != 0 && timer1 == nil {
            self.timer1 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.onTimer1), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.timer1?.invalidate()
        self.timer1 = nil
    }
/*
    func draw()
    {
        offsetX1 = 0.0
        offsetX2 = 0.0
        
        flTotalContentWidth = Float(240 * arrPopularCallOuts.count)
        
        viTemp1.frame = CGRect(x: 0.0, y: Double(viTemp1.frame.origin.y), width: Double(flTotalContentWidth), height: Double(viTemp1.frame.height))
        viTemp2.frame = CGRect(x: view.frame.size.width, y: viTemp2.frame.origin.y, width: CGFloat(flTotalContentWidth), height: viTemp1.frame.height)
        var i = 0
        for item in arrPopularCallOuts {
            let viTemp = UIView(frame: CGRect(x: i*240, y: 0, width: 240, height: Int(viTemp1.frame.height)))
            let viThumb1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: viTemp1.frame.height))
//            viThumb1.image = UIImage(named: item["thumb1"]!)
//            viThumb1.af_setImage(withURL: URL(string: item["thumb1"]!)!)
            if item["format"] == "audio"
            {
                viThumb1.image = #imageLiteral(resourceName: "audio-wave.png")
            }else{
                Global.setImage(viThumb1, item["thumb1"]!, #imageLiteral(resourceName: "avatarEmpty.png"))
            }
            viThumb1.contentMode = .scaleAspectFill
            viThumb1.clipsToBounds = true
            
            let viThumb2 = UIImageView(frame: CGRect(x: 120, y: 0, width: 120, height: viTemp1.frame.height))
//            viThumb2.image = UIImage(named: item["thumb2"]!)
//            viThumb2.af_setImage(withURL: URL(string: item["thumb2"]!)!)
            if item["format"] == "audio"
            {
                viThumb2.image = #imageLiteral(resourceName: "audio-wave.png")
            }else{
                Global.setImage(viThumb2, item["thumb2"]!, #imageLiteral(resourceName: "avatarEmpty.png"))
            }
            viThumb2.contentMode = .scaleAspectFill
            viThumb2.clipsToBounds = true
            
            viTemp.addSubview(viThumb1)
            viTemp.addSubview(viThumb2)
            
            let lblName = UILabel(frame: CGRect(x: 40, y: viTemp1.frame.height - 30, width: 160, height: 20))
            lblName.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
            lblName.textColor = UIColor.white
            lblName.text = item["name"]
            lblName.textAlignment = .center
            lblName.font = UIFont.systemFont(ofSize: 12.0)
            lblName.layer.masksToBounds = true
            lblName.layer.cornerRadius = lblName.frame.size.height / 2
            
            viTemp.addSubview(lblName)
            viTemp.layer.borderColor = UIColor.red.cgColor
            viTemp.layer.borderWidth = 0.5
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 240, height: viTemp1.frame.height))
            button.tag = i
            button.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
            viTemp.addSubview(button)
            
            viTemp1.addSubview(viTemp)
            
            i += 1
        }
        i = 0
        for item in arrPopularCallOuts {
            let viTemp = UIView(frame: CGRect(x: i*240, y: 0, width: 240, height: Int(viTemp1.frame.height)))
            let viThumb1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: viTemp1.frame.height))
//            viThumb1.image = UIImage(named: item["thumb1"]!)
//            viThumb1.af_setImage(withURL: URL(string: item["thumb1"]!)!)
            
            if item["format"] == "audio"
            {
                viThumb1.image = #imageLiteral(resourceName: "audio-wave.png")
            }else{
                Global.setImage(viThumb1, item["thumb1"]!, #imageLiteral(resourceName: "avatarEmpty.png"))
            }
            viThumb1.contentMode = .scaleAspectFill
            viThumb1.clipsToBounds = true
            
            let viThumb2 = UIImageView(frame: CGRect(x: 120, y: 0, width: 120, height: viTemp1.frame.height))

            if item["format"] == "audio"
            {
                viThumb2.image = #imageLiteral(resourceName: "audio-wave.png")
            }else{
                Global.setImage(viThumb2, item["thumb2"]!, #imageLiteral(resourceName: "avatarEmpty.png"))
            }
            viThumb2.contentMode = .scaleAspectFill
            viThumb2.clipsToBounds = true
            
            viTemp.addSubview(viThumb1)
            viTemp.addSubview(viThumb2)
            
            let lblName = UILabel(frame: CGRect(x: 40, y: viTemp1.frame.height - 30, width: 160, height: 20))
            lblName.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
            lblName.textColor = UIColor.white
            lblName.text = item["name"]
            lblName.textAlignment = .center
            lblName.font = UIFont.systemFont(ofSize: 12.0)
            lblName.layer.masksToBounds = true
            lblName.layer.cornerRadius = lblName.frame.size.height / 2
            
            viTemp.addSubview(lblName)
            viTemp.layer.borderColor = UIColor.red.cgColor
            viTemp.layer.borderWidth = 0.5
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 240, height: viTemp1.frame.height))
            button.tag = i
            button.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
            viTemp.addSubview(button)
            
            viTemp2.addSubview(viTemp)
            
            i += 1
        }
        timer1 = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(onTimer1), userInfo: nil, repeats: true)
        timer2 = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(onTimer2), userInfo: nil, repeats: true)
    }
 */
    @objc func click(_ sender:UIButton)
    {
        let tag = sender.tag
//        print(arrPopularCallOuts[tag]["name"])
        Global.shared.selected_challenge_id = Int(arrPopularCallOuts[tag]["id"]!)!
        let storyboard = UIStoryboard(name: "Signin", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onTimer1()
    {
        currentContentOffset += 2.0
        
        if currentContentOffset > (topListCollectionView.contentSize.width - topListCollectionView.frame.size.width) {
            currentContentOffset = 0
        }
        topListCollectionView.setContentOffset(CGPoint(x: currentContentOffset, y: topListCollectionView.contentOffset.y), animated: true)
    }
    @objc func onTimer2()
    {
        viTemp2.frame = CGRect(x: viTemp2.frame.origin.x - 2, y: viTemp2.frame.origin.y, width: CGFloat(flTotalContentWidth), height: CGFloat(viTemp1.frame.height))
        offsetX2 = Float(viTemp2.frame.origin.x)
        if CGFloat(offsetX2) < self.view.frame.size.width - CGFloat(flTotalContentWidth)
        {
            if viTemp1.isHidden
            {
                viTemp1.isHidden = false
                viTemp1.frame = CGRect(x: self.view.frame.size.width, y: viTemp1.frame.origin.y, width: CGFloat(flTotalContentWidth), height: CGFloat(viTemp1.frame.height))
            }
        }
        
        if offsetX2 < -flTotalContentWidth
        {
            viTemp2.isHidden = true
            viTemp2.frame = CGRect(x: self.view.frame.size.width, y: viTemp2.frame.origin.y, width: CGFloat(flTotalContentWidth), height: CGFloat(viTemp1.frame.height))
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func btnRegisterTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Signin", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Signin", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnTermsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Signin", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TermsVC")
        self.present(vc, animated: true, completion: nil)
    }
}

extension LandingVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPopularCallOuts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TopListCell
        
        let callout = arrPopularCallOuts[indexPath.row]
        
        cell.imgThumb1.af_setImage(withURL: URL(string: callout["thumb1"]!)!)
        cell.imgThumb2.af_setImage(withURL: URL(string: callout["thumb2"]!)!)
        cell.lblName.text = callout["name"]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height * 1.2, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        Global.shared.selected_challenge_id = Int(arrPopularCallOuts[indexPath.row]["id"]!)!
        let storyboard = UIStoryboard(name: "Signin", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
