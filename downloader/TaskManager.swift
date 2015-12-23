//
//  TaskManager.swift
//  downloader
//
//  Created by icafe on 12/22/15.
//  Copyright © 2015 swiftcafe. All rights reserved.
//

import UIKit

enum DownloadTaskNotification: String {
    
    case Progress = "downloadNotificationProgress"
    case Finish = "downloadNotificationFinish"
    
}

struct DownloadTask {
    
    var url: NSURL
    var localURL:NSURL?
    var taskIdentifier: Int
    var finished:Bool = false
    
    init(url:NSURL, taskIdentifier: Int) {
        
        self.url = url
        self.taskIdentifier = taskIdentifier
        
    }
    
}

class TaskManager: NSObject, NSURLSessionDownloadDelegate {

    private var session:NSURLSession?
    
    var taskList:[DownloadTask] = [DownloadTask]()
    
    static var sharedInstance:TaskManager = TaskManager()
    
    override init() {
        
        super.init()
        
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("downloadSession")
        self.session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        self.taskList = [DownloadTask]()
        self.loadTaskList()

    }
    
    func unFinishedTask() -> [DownloadTask] {
        
        return taskList.filter{ task in
            
            return task.finished == false
            
        }
        
    }
    
    func finishedTask() -> [DownloadTask] {
        
        return taskList.filter { task in
            
            return task.finished
            
        }
        
    }
    
    func saveTaskList() {
        
        let jsonArray = NSMutableArray()

        for task in taskList {
            
            let jsonItem = NSMutableDictionary()
            jsonItem["url"] = task.url.absoluteString
            jsonItem["taskIdentifier"] = NSNumber(long: task.taskIdentifier)
            jsonItem["finished"] = NSNumber(bool: task.finished)
            
            jsonArray.addObject(jsonItem)
            
        }

        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonArray, options: NSJSONWritingOptions.PrettyPrinted)
            NSUserDefaults.standardUserDefaults().setObject(jsonData, forKey: "taskList")
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }catch {
            
        }
        
    }
    
    func loadTaskList() {
        
        if let jsonData:NSData = NSUserDefaults.standardUserDefaults().objectForKey("taskList") as? NSData {
            
            do {
                
                guard let jsonArray:NSArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as? NSArray else { return }
                
                for jsonItem in jsonArray {
                    
                    if let item:NSDictionary = jsonItem as? NSDictionary {
                        
                        guard let urlstring = item["url"] as? String else { return }
                        guard let taskIdentifier = item["taskIdentifier"]?.longValue else { return }
                        guard let finished = item["finished"]?.boolValue else { return }
                        
                        let downloadTask = DownloadTask(url: NSURL(string: urlstring)!, taskIdentifier: taskIdentifier)
                        self.taskList.append(downloadTask)
                        
                    }
                    
                }
                
            } catch {
                
            }
            
        }
        
    }
    
    func newTask(url: String) {

        print("task cout: \(TaskManager.sharedInstance.unFinishedTask().count)")
        
        if let url = NSURL(string: url) {
            
            let downloadTask = self.session?.downloadTaskWithURL(url)
            downloadTask?.resume()
            
            let task = DownloadTask(url: url, taskIdentifier: downloadTask!.taskIdentifier)
            self.taskList.append(task)
            
            

            self.saveTaskList()
            
        }

            
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        var fileName = ""
        
        for var i = 0;i < self.taskList.count;i++ {
            
            if self.taskList[i].taskIdentifier == downloadTask.taskIdentifier {

                self.taskList[i].finished = true
                fileName = self.taskList[i].url.lastPathComponent!
                
            }
            
        }
        
        if let documentURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first {
            
            let destURL = documentURL.URLByAppendingPathComponent(fileName)
            do {

                try NSFileManager.defaultManager().moveItemAtURL(location, toURL: destURL)
                
            } catch {
                
            }

            
        }

        
        print(location)
        
        self.saveTaskList()
        
        NSNotificationCenter.defaultCenter().postNotificationName(DownloadTaskNotification.Finish.rawValue, object: downloadTask.taskIdentifier)
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {

        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progressInfo = ["taskIdentifier": downloadTask.taskIdentifier,
                            "totalBytesWritten": NSNumber(longLong: totalBytesWritten),
                            "totalBytesExpectedToWrite": NSNumber(longLong: totalBytesExpectedToWrite)]

        NSNotificationCenter.defaultCenter().postNotificationName(DownloadTaskNotification.Progress.rawValue, object: progressInfo)

    }
    
}
