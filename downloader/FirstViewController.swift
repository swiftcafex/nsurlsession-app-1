//
//  FirstViewController.swift
//  downloader
//
//  Created by icafe on 12/22/15.
//  Copyright © 2015 swiftcafe. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var mainTableView: UITableView?
    
    private var taskList: [DownloadTask]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "正在下载"
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addTask"))
        
        self.mainTableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        self.mainTableView?.delegate = self
        self.mainTableView?.dataSource = self
        self.view.addSubview(self.mainTableView!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadData"), name: DownloadTaskNotification.Finish.rawValue, object: nil)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        self.reloadData()
        
    }
    
    func reloadData() {
        
        taskList = TaskManager.sharedInstance.unFinishedTask()
        self.mainTableView?.reloadData()
        
    }
    
    func addTask() {
        
        let viewController = NewTaskViewController()
        let navController = UINavigationController(rootViewController: viewController)
        self.presentViewController(navController, animated: true, completion: nil)
        
    }

    //:MARK UITableView Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 70.0
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.taskList == nil ? 0 : self.taskList!.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? DownloadTaskCell
        
        if cell == nil {
            
            cell = DownloadTaskCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            
        }
        
        cell?.updateData((self.taskList?[indexPath.row])!)
        return cell!
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

