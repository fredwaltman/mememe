//
//  MemeViewController.swift
//  MemeMe
//
//  Created by Fred Waltman on 3/12/15.
//  Copyright (c) 2015 Fred Waltman. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController {

    var meme:Meme!
    
    @IBOutlet weak var memeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let m = meme {
            self.memeImage.image = m.fileImage
            let formattedDate = NSDateFormatter.localizedStringFromDate(
                m.createDate!,
                dateStyle: .ShortStyle,
                timeStyle: .NoStyle)
            
            self.navigationItem.title = formattedDate
        }

        let s = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action,  target: self, action: Selector("goShare"))
        self.navigationItem.rightBarButtonItem = s

    }

    //MARK: - Helper Functions
    
    func goBack() {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    func goShare() {
            let objectsToShare = [meme.fileImage!]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true) {Void in self.goBack()}
    }

}
