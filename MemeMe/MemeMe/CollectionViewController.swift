//
//  CollectionViewController.swift
//  MemeMe
//
//  Created by Fred Waltman on 3/11/15.
//  Copyright (c) 2015 Fred Waltman. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var memes : [Meme]!     // local copy of global memes array
    var thisMeme : Meme!    // meme to pass to the viewer
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sent Memes"
        
        let applicationDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        memes = applicationDelegate.memes
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        // May have added a meme
        let applicationDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        memes = applicationDelegate.memes
        
        self.collectionView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "addMemeCollection" {
            let destVC = segue.destinationViewController as EditMemeViewController
            destVC.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "memeDetailCollection" {
            let destVC = segue.destinationViewController as MemeViewController
            destVC.meme = thisMeme
        }
    }

//MARK: - UICollectionViewDataSource
 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionViewCell", forIndexPath: indexPath) as MemeCollectionViewCell
        
        var meme = memes[indexPath.row]
        
        cell.cellImage.image = meme.thumbImage
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        thisMeme = memes[indexPath.row]
    }
    
    //MARK: - UICollectionViewFlowDelegate
    
    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            
        let w = collectionView.frame.width
        let numAcross = floor( w / 100)
        let cellWidth = w / numAcross - 5

        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    
/*    private let sectionInsets = UIEdgeInsets(top: 2.0, left: 5.0, bottom: 5.0, right: 5.0)
    
    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    } */
}
