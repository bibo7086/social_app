//
//  FeedViewController.swift
//  social_project
//
//  Created by Saeed Ali on 10/6/17.
//  Copyright © 2017 Saeed Ali. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, FeedTableViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    static let sharedWebClient = WebClient.init(baseUrl: "http://46.101.1.128/api")
    static let UserTimelinePath = "/home/userTimeline/"
    static let cellIdentifier = "feedCell"
    
    
    var FeedTask: URLSessionDataTask!
    var FeedPosts: [Posts] = [] // for storing posts in the timeline
    
    @IBOutlet weak var feedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        //Get the required post
        self.feedTableView.estimatedRowHeight = self.feedTableView.rowHeight
        self.feedTableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchPost()
    }
    
    //  Function for fetching posts
    func fetchPost() {
        
        let URLParams = ["start": "0", "limit": "30"] //parameters for userTimeline
        let _ = FeedViewController.sharedWebClient.load(path: FeedViewController.UserTimelinePath, method: .get, params: URLParams){(data, error) in
            
            /* GUARD: was there an error */
            
            guard (error == nil) else {
                print(error?.errorDescription! as Any)
                return
            }
            
            /*  Get posts from parsed Data */
            guard let posts = data?["posts"] as? NSArray else {
                print("There was an error parsing the data")
                return
            }
            self.FeedPosts = Posts.modelsFromDictionaryArray(array: posts )
            
            DispatchQueue.main.async {
                self.feedTableView.reloadData()
            }
        }
    }
    
    // Function for handling the likeButton
    func likeButtonPressed(_ sender: FeedTableViewCell) {
        
        
    }
    
    
    // Function for handling the commentButton Being pressed
    func commentButtonPressed(_ sender: FeedTableViewCell){
        
    }
}




// Extension for the tableViewController
extension FeedViewController{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FeedPosts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCell(withIdentifier: FeedViewController.cellIdentifier, for: indexPath) as! FeedTableViewCell
        
        cell.delegate = self
        cell.nameLabel.text = FeedPosts[indexPath.row].user?.data?.fullName()
        cell.statusMessage.text = FeedPosts[indexPath.row].text
        //       cell.profileImageView.getImage(from: myPost[indexPath.row].profilePic)
        
        if(FeedPosts[indexPath.row].images != nil){
            let link =  "http://46.101.1.128/" + (FeedPosts[indexPath.row].images?.first?.link)!
            cell.postImageView.getImage(from: link)
        }
            
            //if  there is no image adjust the cell height
        else {
            cell.postImageView.image = nil
            if (cell.postImageView.image == nil || cell.postImageView == nil){
                cell.defaultPostImageViewHeightConstraint = cell.postHeightConstraint.constant
                cell.postHeightConstraint.constant = 0;
                cell.layoutIfNeeded()
            }
        }
        
        
        
        let created_date = FeedPosts[indexPath.row].updated_at?.toDateTime()
        let currentDate = Date()
        cell.timeAgoLabel.text = currentDate.offsetFrom(date: created_date! as Date)
        cell.likeandcommentsLabel.text = FeedPosts[indexPath.row].likesandComments()
        
        cell.selectionStyle = .none
        return cell
    }
    
    
}


public extension UIImageView {
    func getImage(from data2: String?){
        //  Ensure there is an image
        guard let data2 = data2 else {
            self.image = nil
            return
        }
        let imageClient = WebClient.init(baseUrl: data2)
        _ = imageClient.taskForGetImage(from: data2){ (data, error) in
            
            DispatchQueue.main.async {
                if let imagedata = data {
                    self.image = UIImage(data: imagedata)
                }
                else {
                    self.image = nil
                }
            }
        }
    }
    
    
}
