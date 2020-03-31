//
//  CreatePostsViewController.swift
//  social_project
//
//  Created by Saeed Ali on 12/28/17.
//  Copyright © 2017 Saeed Ali. All rights reserved.
//

import UIKit

class CreatePostsViewController: UIViewController {
    typealias  CompletionHandler = (_ success: Bool) -> Void

    static let sharedWebClient = WebClient.init(baseUrl: "http://46.101.1.128/api")
    static let createProfilePostPath = "/createProfilePost/"

    var MyPostsTasks: URLSessionDataTask!

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        
    }

    
    
    func fetchPost() {
        
        let URLParams = [
            "start": "0",
            "limit": "10",
            ]
        MyPostsTasks = FeedViewController.sharedWebClient.load(path: "/timeline", method: .get, params: URLParams) { (data, error) in
            
           // self.Post = Feed.modelsFromDictionaryArray(array: data!["feed"] as! NSArray )
        }
        
    }

    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    
    }

    @IBAction func postButtonPressed(_ sender: Any) {
        if textView.text != nil && textView.text != "Type something here......"{
        
        postButton.isEnabled = false
            uploadText(textToUpload: textView.text) { (isComplete) in
                if isComplete {
                    self.postButton.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    self.postButton.isEnabled = true
                    print("There was an error posting your content")
                }
                }
  
        }
    }
    
    
    
    //This is the function for uploading texts
    func uploadText( textToUpload: String, completionHandler: @escaping CompletionHandler )
    {
        let bodyObject: [String : Any] = [
            "announcement": "0",
            "deleted": "",
            "": "",
            "files": "",
            "text": textToUpload
        ]
        
        MyPostsTasks = CreatePostsViewController.sharedWebClient.load(path: CreatePostsViewController.createProfilePostPath, method: .post, params: bodyObject) { (data, error) in
            
            // Was the Post successfully posted? 
            guard (error == nil) else {
                print(error?.errorDescription as Any)
                completionHandler(false)
                return
            }
            
            completionHandler(true)
            
            
        
        }
    }
}
// extension to clear the textView when the user starts typing

extension CreatePostsViewController: UITextViewDelegate    {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
}
