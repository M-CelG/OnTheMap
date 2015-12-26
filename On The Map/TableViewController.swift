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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        loadData()
        tableView.reloadData()
    }
    
    
    //Logout Button Function
    @IBAction func logout(sender: AnyObject) {
        ShareStudentData.sharedInstance().logout(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Refresh Button Function
    @IBAction func refreshData(sender: AnyObject) {
        loadData()
        tableView.reloadData()
    }
    
    //Function connected to pin Button
    @IBAction func updateStudentData(sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    func loadData() {
        ShareStudentData.sharedInstance().studentData(){error in
            if error != nil {
                UdacityParseClient.alertUser(self, title: "Student Data", message: "Unable to fetch Student Data", dismissButton: "ok")
            }
        }
    }
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    
    //This function provide the row count to the table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ShareStudentData.sharedInstance().sharedStudentsData.count
    }
    
    //This function provides reuseable cells to table view
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = ShareStudentData.sharedInstance().sharedStudentsData[indexPath.row].firstName + " " + ShareStudentData.sharedInstance().sharedStudentsData[indexPath.row].lastName
        cell.detailTextLabel?.text = ShareStudentData.sharedInstance().sharedStudentsData[indexPath.row].mapString
     
        return cell
    }
    //Open the media URL when user click on a table row
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = ShareStudentData.sharedInstance().sharedStudentsData[indexPath.row].mediaURL
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
        
}