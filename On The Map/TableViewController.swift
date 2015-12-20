//
//  tableViewController.swift
//  On The Map
//
//  Created by Manish Sharma on 12/3/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class TableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var students = [UdacityStudent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Do any additional setup after loading the view.
        ShareStudentData.sharedInstance().studentData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.students = ShareStudentData.sharedInstance().sharedStudentsData
        print("TableView first student: \(students[0])")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    //Logout Button Function
    @IBAction func logout(sender: AnyObject) {
        //Delete session ID at Udacity
        UdacityParseClient.sharedInstance().deleteSession() {success, error in
            if error != nil {
                print("Error during logout:\(error?.localizedDescription)")
            }
        }
        //Check if user login via facebook
        if FBSDKAccessToken.currentAccessToken() != nil {
            let logoutTask = FBSDKLoginManager()
            logoutTask.logOut()
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Refresh Button Function
    @IBAction func refreshData(sender: AnyObject) {
        ShareStudentData.sharedInstance().studentData()
        tableView.reloadData()

    }
    
    //Function connected to pin Button
    @IBAction func updateStudentData(sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
       
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    
    //This function provide the row count to the table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    //This function provides reuseable cells to table view
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = students[indexPath.row].firstName + " " + students[indexPath.row].lastName
     
        return cell
    }
    //Open the media URL when user click on a table row
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = students[indexPath.row].mediaURL
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
        
}