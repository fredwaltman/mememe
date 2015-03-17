//
//  TableViewController.swift
//  MemeMe
//
//  Created by Fred Waltman on 3/11/15.
//  Copyright (c) 2015 Fred Waltman. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var memes : [Meme]!     //local copy of the global memes array
    var thisMeme : Meme!    // meme to pass to viewer
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        self.navigationItem.title = "Sent Memes"

        let applicationDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        memes = applicationDelegate.memes
        
        if memes.count == 0 {
        // First time in, go see if any stored
            Meme.load()
            memes = applicationDelegate.memes
            
            if memes.count == 0 {
            // none saved, go directly editor
                performSegueWithIdentifier("addMemeTable", sender: self)
            }
        }
    }

    override func viewDidAppear(animated: Bool) {

        //May have added a meme
        let applicationDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        memes = applicationDelegate.memes

        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "addMemeTable" {
            let destVC = segue.destinationViewController as EditMemeViewController
            destVC.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "memeDetailTable" {
            let destVC = segue.destinationViewController as MemeViewController
            destVC.meme = thisMeme
        }
    }
    
    //MARK: - UITableViewSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("memeTableCell") as MemeTableViewCell
        
        var meme = memes[indexPath.row]
        
        cell.cellText.text = meme.text!
        cell.cellImage.image = meme.thumbImage
        
        return cell
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        thisMeme = memes[indexPath.row]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            memes[indexPath.row].delete(indexPath.row) // delete the saved image, global array, etc
            memes.removeAtIndex(indexPath.row) // this is the local memes array
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}

