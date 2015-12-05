//
//  tableViewController.swift
//  On The Map
//
//  Created by Manish Sharma on 12/3/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import UIKit

class tableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var students = [UdacityStudent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parentViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutButtonAction")
        let pin = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "updateStudentLocation")
        let refresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "updateStudentsData")
        
        self.parentViewController?.navigationItem.rightBarButtonItems = [refresh, pin]
        
        // Do any additional setup after loading the view.
        updateStudentsData()


        print("Student Data is here:\(students.count)")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
//    override func viewWillAppear(animated: Bool) {
//        self.tableView.reloadData()
//    }
    
    //Logout function
    func logoutButtonAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateStudentLocation() {
        print("Update student location in table View")
    }
    
    //Function to get or update Student Data
    func updateStudentsData() {
        UdacityParseClient.sharedInstance().getStudentData(100) {data, success, error in
            if success {
                print("Got Student Data")
                if let data = data {
                    self.students = data
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                } else {
                    print("No data from get student data task")
                }
            } else {
                print("Unable to retrive Student Data:\(error)")
            }
        }
    }
    
}

extension tableViewController: UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let url = students[indexPath.row].mediaURL
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
        
}