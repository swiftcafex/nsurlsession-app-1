//
//  NewTaskViewController.swift
//  downloader
//
//  Created by icafe on 12/23/15.
//  Copyright © 2015 swiftcafe. All rights reserved.
//

import UIKit

class NewTaskViewController: UIViewController {

    var textView:UITextView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "添加任务"
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "下载", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("add"))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("close"))
        
        self.textView = UITextView(frame: CGRectMake(10, 10, self.view.frame.size.width - 20, 250))
        self.textView?.layer.borderWidth = 1
        self.textView?.layer.borderColor = UIColor.grayColor().CGColor
        self.textView?.layer.cornerRadius = 5
        self.textView?.font = UIFont.systemFontOfSize(14)
        self.view.addSubview(self.textView!)

    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.textView?.becomeFirstResponder()
        
    }
    
    func close() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func add() {
        
        print("new task")
        TaskManager.sharedInstance.newTask(self.textView!.text)
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
  
    }
  
}
