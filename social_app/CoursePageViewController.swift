//
//  CoursePageViewController.swift
//  social_project
//
//  Created by Saeed Ali on 1/8/18.
//  Copyright © 2018 Saeed Ali. All rights reserved.
//

import UIKit

class CoursePageViewController: UIViewController {
    
    var views: [UIView]!
    var courseDetail: Courses! //we have the course id in here 
    var studentProfile: Records!

    
    
    
    // this is a lazy object declaration of the coursefeedViewController
    lazy var coursefeedViewController: CourseFeedViewController  = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(withIdentifier: "CourseFeedViewController") as!CourseFeedViewController
        return viewController
    }()
    
    // this is a lazy object declaration of the announcementFeedViewController
    lazy var announcementViewController: AnnouncementViewController  = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "AnnouncementViewController") as!AnnouncementViewController
        return viewController
    }()
    
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the title of the navigation bar to the course name
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.00, green: 0.22, blue: 0.47, alpha: 1.00)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationItem.title = courseDetail.code
        
        views = [UIView]()

        
        coursefeedViewController.courseDetail = self.courseDetail
        coursefeedViewController.studentProfile = self.studentProfile
        
        views.append(coursefeedViewController.view)
        views.append(announcementViewController.view)
        
        for v in views {
            viewContainer.addSubview(v)
        }
        
        //  Make the annoucementview the initial view
        viewContainer.bringSubviewToFront(views[0])
    }
    
    
    @IBAction func returnToCourses(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func segmentSwitch(_ sender: UISegmentedControl) {
        self.viewContainer.bringSubviewToFront(views[sender.selectedSegmentIndex])
    }
}
