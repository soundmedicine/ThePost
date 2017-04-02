//
//  ActivityViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/25/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase
import DateToolsSwift

class ActivityViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    private var ref: FIRDatabaseReference!
    private var socialRef: FIRDatabaseReference?
    private var socialPosts: [SocialPost]!
        
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.dataSource = self
        ref = FIRDatabase.database().reference()
        self.socialPosts = []
        
        if socialRef == nil {
            socialRef = ref.child("social-posts")
            
            let query = socialRef!.queryOrdered(byChild: "datePosted").queryLimited(toLast: 200)
            query.observe(.childAdded, with: { snapshot in
                if let socialDict = snapshot.value as? [String: AnyObject] {
                    var socialPost: SocialPost!
                    
                    let date = Date.init(timeIntervalSince1970: Double(socialDict["datePosted"] as! NSNumber) / 1000)
                    
                    socialPost = SocialPost.init(withUsername: socialDict["name"] as! String, imageUrl: socialDict["image"] as! String, likeCount: 0, userid: socialDict["userid"] as! String, date:date)
                    
                    self.socialPosts.insert(socialPost, at: 0)
                    self.tableView.reloadData()
                }
            })
            
            socialRef!.observe(.childRemoved, with: { snapshot in
                if let socialDict = snapshot.value as? [String: AnyObject] {
                    print(socialDict)
                }
            })
        }

    }
    
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socialPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let socialCell = tableView.dequeueReusableCell(withIdentifier: "socialCell", for: indexPath) as! JeepSocialTableViewCell
        
        print(socialPosts[indexPath.row])
        
        socialCell.likeCountLabel.text = socialPosts[indexPath.row].likeCount.description
        socialCell.postNameLabel.text = socialPosts[indexPath.row].username
        
        let url = URL(string: socialPosts[indexPath.row].imageUrl)
//        socialCell.profileImageView.sd_setImage(with: url)
        socialCell.timeLabel.text = socialPosts[indexPath.row].datePosted.timeAgoSinceNow
        socialCell.postImageView.sd_setImage(with: url)
    
//        socialCell.likeCountLabel.text = "125,857,323 likes"
//        socialCell.postNameLabel.text = "Ethan Andrews"
//        socialCell.profileImageView.image = #imageLiteral(resourceName: "DefaultProfilePicture")
//        socialCell.timeLabel.text = "5 hours ago"
//        socialCell.postImageView.image = #imageLiteral(resourceName: "jeepImage")
        
        return socialCell
    }

}
