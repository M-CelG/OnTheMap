//
//  tableViewController.swift
//  On The Map
//
//  Created by Manish Sharma on 12/3/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import UIKit

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
        self.tableView.reloadData()
    }
    
    //Logout Button Function
    @IBAction func logout(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Refresh Button Function
    @IBAction func refreshData(sender: AnyObject) {
        ShareStudentData.sharedInstance().studentData()

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
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let url = students[indexPath.row].mediaURL
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
        
}