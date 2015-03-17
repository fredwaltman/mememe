//
//  SettingsViewController.swift
//  MemeMe
//
//  Created by Fred Waltman on 3/14/15.
//  Copyright (c) 2015 Fred Waltman. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITableViewDelegate {
    // User settings
    
    var rowSelected = [-1, -1]
    var sizeIndex = -1
    var lengthIndex = -1

    let defaults = NSUserDefaults.standardUserDefaults()
    let keys = [[1,2,3], [1,7,30]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if var dict = defaults.dictionaryForKey(Meme.settingsKey) {
            if let sz = dict[Meme.sizeKey] as? Int {
                if let si = find(keys[0], sz) {
                    sizeIndex = si
                    rowSelected[0] = sizeIndex
                }
            }
            
            if let ln = dict[Meme.lengthKey] as? Int {
                if let l = find(keys[1], ln) {
                    lengthIndex = l
                    rowSelected[1] = lengthIndex
                }
            }
        } else {
            // create with defaults
            let dict = [Meme.sizeKey : 1, Meme.lengthKey : 7]
            defaults.setObject(dict, forKey: Meme.settingsKey)
            sizeIndex = 1
            lengthIndex = 1
            rowSelected = [1,1]
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == sizeIndex {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        } else {
            if indexPath.row == lengthIndex {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if rowSelected[indexPath.section] >= 0 {
            let oldPath = NSIndexPath(forRow: rowSelected[indexPath.section], inSection: indexPath.section)
            if let oldCell = tableView.cellForRowAtIndexPath(oldPath) {
                oldCell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        if var cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            rowSelected[indexPath.section] = indexPath.row
            
            if var dict = defaults.dictionaryForKey(Meme.settingsKey) {
                
                if indexPath.section == 0 {
                    dict.updateValue(keys[0][indexPath.row], forKey: Meme.sizeKey)
                } else {
                    dict.updateValue(keys[1][indexPath.row], forKey: Meme.lengthKey)
                }
                
                defaults.setObject(dict, forKey: Meme.settingsKey)
            }
        }
    }
}
