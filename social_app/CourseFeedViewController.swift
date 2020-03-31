//
//  CourseFeedViewController.swift
//  social_project
//
//  Created by Saeed Ali on 1/9/18.
//  Copyright © 2018 Saeed Ali. All rights reserved.
//

import UIKit

class CourseFeedViewController: UIViewController, CourseFeedTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var courseFeedTableView: UITableView!
    
    static let sharedWebClient = WebClient.init(baseUrl: "http://46.101.1.128/api")
    static let LikePostPath = "/likePost/"
    static let UnlikePostPath = "/dislikePost/"
    static let courseTimelinePath = "/course/getTimeline/"
    static let cellIdentifier = "CourseFeedTableViewCell"
    
    
    var courseDetail: Courses! //we have the course id in here
    var studentProfile: Records!
    var coursePosts: [Posts] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.courseFeedTableView.estimatedRowHeight = self.courseFeedTableView.rowHeight
        self.courseFeedTableView.rowHeight = UITableViewAutomaticDimension
        fetchPost()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        fetchPost()
        
    }
    
    // MARK: - get the posts to display on the feed
    func fetchPost(){
        let page_id = String(describing: courseDetail.id!)
        print("the page id is \(page_id)")
        let URLParams = ["page_id": "35", "start": "0", "limit": "10"]
        let _ = ProfileViewController.sharedWebClient.load(path: CourseFeedViewController.courseTimelinePath, method: .get, params: URLParams){(data, error) in
            
            /* GUARD: was there an error */
            
            guard (error == nil) else {
                print(error?.errorDescription! as Any)
                return
            }
            
            print(data)
            
            /*  Get posts from parsed Data */
            guard let posts = data?["posts"] as? NSArray else {
                print("There was an error parsing the data")
                return
            }
            
            self.coursePosts = Posts.modelsFromDictionaryArray(array: posts )
            DispatchQueue.main.async {
                self.courseFeedTableView.reloadData()
            }
        }
    }
    
    
    func likeButtonPressed(_ sender: CourseFeedViewTableViewCell) {
        guard let Indexpath = courseFeedTableView.indexPath(for: sender) else { return }
        
        let post_id = String(describing: coursePosts[Indexpath.row].id!)
        let URLParams = ["post_id": post_id]
        
        
        /* check if already liked */
        if sender.liked ==  false {
            let _   = CourseFeedViewController.sharedWebClient.load(path: ProfileViewController.LikePostPath, method: .post, params: URLParams){(data, error) in
                guard (error == nil) else {
                    print(error?.errorDescription!)
                    return
                }
                
                /*  Get records from parsed Data */
                guard let records = data?["count"] as? Int else {
                    print("There was an error parsing the comment data")
                    return
                }
                
                DispatchQueue.main.async {
                    //  if the like was successful change the icon
                    if records == 1 {
                        let image = UIImage(named: "icon-likeSelected")!
                        sender.likeButton.setImage(image, for: .normal)
                        sender.liked = true
                    }
                        // if the like was not successul leave the icon as it was
                    else {
                        let image = UIImage(named: "icon-like")!
                        sender.likeButton.setImage(image, for: .normal)
                        sender.liked = false
                    }
                    
                    self.fetchPost()
                    
                }
            }
        }
            // Unlike a post
        else {
            let _   = ProfileViewController.sharedWebClient.load(path: ProfileViewController.UnlikePostPath, method: .post, params: URLParams){(data, error) in
                guard (error == nil) else {
                    print(error?.errorDescription!)
                    return
                }
                
                /*  Get records from parsed Data */
                guard let records = data?["count"] as? Int else {
                    print("There was an error parsing the comment data")
                    return
                }
                
                DispatchQueue.main.async {
                    //  if the like was successful change the icon
                    if records == 0 {
                        let image = UIImage(named: "icon-like")!
                        sender.likeButton.setImage(image, for: .normal)
                        sender.liked = false
                    }
                        // if the like was not successul leave the icon as it was
                    else {
                        let image = UIImage(named: "icon-likeSelected")!
                        sender.likeButton.setImage(image, for: .normal)
                        sender.liked = true
                    }
                    
                    self.fetchPost()
                    
                }
            }
            
        }
        
    }
    
    func commentButtonPressed(_ sender: CourseFeedViewTableViewCell) {
        guard let Indexpath = courseFeedTableView.indexPath(for: sender) else { return }

    let commenViewController: CommentViewController  = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let commentViewController = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            commentViewController.Mypost = coursePosts[Indexpath.row]
            return commentViewController

            
        }()
       
        self.present(commenViewController, animated: true, completion: nil)


        
    }
    
}


extension CourseFeedViewController{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  coursePosts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = courseFeedTableView.dequeueReusableCell(withIdentifier: CourseFeedViewController.cellIdentifier, for: indexPath) as! CourseFeedViewTableViewCell
        
        cell.delegate = self
        cell.nameLabel.text = coursePosts[indexPath.row].user?.data?.fullName()
        cell.statusMessage.text = coursePosts[indexPath.row].text
        
        
        //check if they already like the pictures
        let likes_list = coursePosts[indexPath.row].likes!
        
        for currentlikes in likes_list
        {
            if(currentlikes.user_id == studentProfile.profile?.id ){
                let image = UIImage(named: "icon-likeSelected")!
                cell.likeButton.setImage(image, for: .normal)
                cell.liked = true
            }
            else{
                let image = UIImage(named: "icon-like")!
                cell.likeButton.setImage(image, for: .normal)
                cell.liked = false
            }
            
        }
        if (likes_list.count == 0)
        {
            let image = UIImage(named: "icon-like")!
            cell.likeButton.setImage(image, for: .normal)
            cell.liked = false
            
        }
        
        if(coursePosts[indexPath.row].images != nil){
            let link =  "http://46.101.1.128/" + (coursePosts[indexPath.row].images?.first?.link)!
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
        
        
        
        let created_date = coursePosts[indexPath.row].updated_at?.toDateTime()
        let currentDate = Date()
        cell.timeAgoLabel.text = currentDate.offsetFrom(date: created_date! as Date)
        cell.likeandcommentsLabel.text = coursePosts[indexPath.row].likesandComments()
        
        cell.selectionStyle = .none
        return cell
    }
    
    
}
