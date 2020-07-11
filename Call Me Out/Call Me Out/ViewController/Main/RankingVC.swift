//
//  RankingVC.swift
//  Call Me Out
//
//  Created by B S on 4/4/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit

class RankingVC: UIViewController {

    @IBOutlet weak var tblViRankBoard: UITableView!
    var callouts:[CallOut]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblViRankBoard.register(UINib(nibName: "RankingCell", bundle: nil), forCellReuseIdentifier: "RankingCell")
        
        self.callouts = [CallOut]()
        self.tblViRankBoard.reloadData()
        Global.shared.getRanking(userid: String((Global.getUserDataFromLocal()?.id)!)) { (result) in
            self.callouts = result
            if self.callouts == nil{
                return
            }
            self.tblViRankBoard.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension RankingVC:UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if callouts == nil
        {
            return 0
        }
        return (callouts?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rankCell = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath) as! RankingCell
        
        let callout = callouts![indexPath.row]
        
        if (indexPath.row % 2 == 0) {
            rankCell.contentView.backgroundColor = UIColor(displayP3Red: 32.0/255.0, green: 33.0/255.0, blue: 35.0/255.0, alpha: 1.0)
        }
        else {
            rankCell.contentView.backgroundColor = UIColor(displayP3Red: 25.0/255.0, green: 26.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        }
        
        if (indexPath.row == 0) {
            rankCell.imgViTrophy.image = UIImage(named: "goldTrophy.png")
            rankCell.imgViTrophy.isHidden = false
        }
        else if (indexPath.row == 1) {
            rankCell.imgViTrophy.image = UIImage(named: "silverTrophy.png")
            rankCell.imgViTrophy.isHidden = false
        }
        else if (indexPath.row == 2) {
            rankCell.imgViTrophy.image = UIImage(named: "bronzeTrophy.png")
            rankCell.imgViTrophy.isHidden = false
        }
        else {
            rankCell.imgViTrophy.isHidden = true
        }
        
        rankCell.lblRank.text = String(indexPath.row + 1)
        
        rankCell.imgViWinner.layer.masksToBounds = true
        rankCell.imgViWinner.layer.cornerRadius = rankCell.imgViWinner.layer.frame.size.width / 2.0;
        rankCell.imgViWinner.layer.borderColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6).cgColor
        rankCell.imgViWinner.layer.borderWidth = 0.8
        
        rankCell.imgViInitator.layer.masksToBounds = true
        rankCell.imgViInitator.layer.cornerRadius = rankCell.imgViInitator.layer.frame.size.width / 2.0;
        rankCell.imgViInitator.layer.borderColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6).cgColor
        rankCell.imgViInitator.layer.borderWidth = 0.8
        
        rankCell.imgViThumb2.image = nil
        rankCell.imgViThumb1.image = nil
        
        if callout.format == "audio"
        {
            rankCell.imgViThumb2.image = #imageLiteral(resourceName: "audio-wave.png")
            rankCell.imgViThumb1.image = #imageLiteral(resourceName: "audio-wave.png")
        }
        else{
            print(callout.thumb)
            print(callout.challenge_thumb)
            if !callout.isWinnerPoster!{
                rankCell.imgViThumb1.sd_setImage(with: URL(string: callout.thumb), completed: nil)
                rankCell.imgViThumb2.sd_setImage(with: URL(string: callout.challenge_thumb), completed: nil)
            }
            else
            {
                rankCell.imgViThumb1.sd_setImage(with: URL(string: callout.challenge_thumb), completed: nil)
                rankCell.imgViThumb2.sd_setImage(with: URL(string: callout.thumb), completed: nil)
                
            }
        }
        rankCell.lblTitle.text = callout.title
        rankCell.lblCategories.text = "Categories: " + callout.category
        rankCell.lblParticipants.text = callout.participants! + " participants"
        rankCell.lblInitatorName.text = callout.poster.username
        if callout.isWinnerPoster!{
            rankCell.lblWinnerName.text = callout.poster.username
        }
        else
        {
            rankCell.lblWinnerName.text = callout.challenger?.username
        }

        rankCell.imgViInitator.sd_setImage(with: URL(string: callout.poster.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .highPriority, completed: nil)
        
        if callout.challenger != nil{
            if callout.isWinnerPoster!
            {
                rankCell.imgViWinner.sd_setImage(with: URL(string: callout.poster.avatar), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .highPriority, completed: nil)
            }
            else
            {
                rankCell.imgViWinner.sd_setImage(with: URL(string: callout.challenger?.avatar ?? ""), placeholderImage: #imageLiteral(resourceName: "avatarEmpty.png"), options: .highPriority, completed: nil)
            }
            
        }
        
        return rankCell;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let callout = callouts?[indexPath.row]
        
        if callout!.poster.isBlocked {
            self.view.makeToast("Sorry, you are unable to view \(callout!.poster.username)'s content")
            return
        }
        
        if (callout!.challenger?.isBlocked)! {
            self.view.makeToast("Sorry, you are unable to view \(callout!.challenger!.username)'s content")
            return
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
        vc.callout = callouts?[indexPath.row]
//        vc.fromRankingVC = true
        self.present(vc, animated: true, completion: nil)
        Global.shared.updateViewCount(id: callouts![indexPath.row].id) {
            
        }
    }
}
