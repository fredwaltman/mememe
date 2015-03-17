//
//  Meme.swift
//  MemeMe
//
//  Created by Fred Waltman on 3/11/15.
//  Copyright (c) 2015 Fred Waltman. All rights reserved.
//
// This struct does most of the work.

import Foundation
import UIKit

struct Meme {

    static let dictionaryKey = "MemeMeKey"      // for saving image names and tezt
    static let settingsKey = "MemeMeSettings"   // for saving settings
    static let sizeKey = "Size"                 // for settings
    static let lengthKey = "Length"             // for settings
    
    static let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 36)!,
        NSStrokeWidthAttributeName : -3.0
    ]

    // Member properties
    
    var topText : String?
    var bottomText : String?
    var thumbImage : UIImage?
    var fileName : String

    var text : String? {
        // returns the two text fields joined with a /
        get {
            return self.topText! + " / " + self.bottomText!
            }
    }
    
    var fileImage : UIImage? {
        // read the memed image from local storage
        get {
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            
            let path = dirPath.stringByAppendingPathComponent(self.fileName)
            
            if let memedImage = UIImage(contentsOfFile: path) {
                return memedImage
            } else {
                return nil
            }
        }
    }
    
    var createDate : NSDate? {
        // return the creation date from the file name
        get {
            let dd = Meme.substring(self.fileName, start: 2, len: 2)
            let MM = Meme.substring(self.fileName, start: 4, len: 2)
            let yyyy = Meme.substring(self.fileName, start: 6, len: 4)
            
            var dateFormater : NSDateFormatter = NSDateFormatter()
            dateFormater.dateFormat = "yyyy-MM-dd"
            
            return dateFormater.dateFromString("\(yyyy)-\(MM)-\(dd)")
        }
    }
    
    init(topText : String?, bottomText : String?, baseImage: UIImage) {
    // Adding a new meme just created.
    // Generate the memed image and write it to disk
    // The memed UIImage's are not stored in the struct to save memory. A thumbnail is generated
    // to use with table and collection views.
        
        self.topText = topText
        self.bottomText = bottomText
        
        let memedImage = Meme.generateMemeImage(topText!, bottomText: bottomText!, baseImage: baseImage)
        self.thumbImage = Meme.resizeImage(memedImage, dim: 100.0)
        
        // Write the image to local storage
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let imageName = "mm" + formatter.stringFromDate(currentDateTime)+".png"
        self.fileName = imageName
        
        let filePath = dirPath.stringByAppendingPathComponent(imageName)
        
        // Update the dictionary
        let defaults = NSUserDefaults.standardUserDefaults()
        if var dict = defaults.dictionaryForKey(Meme.dictionaryKey) {
            dict.updateValue(self.text!, forKey: imageName)
            defaults.setObject(dict, forKey: Meme.dictionaryKey)
        } else {
            let dict = [imageName : self.text!]
            defaults.setObject(dict, forKey: Meme.dictionaryKey)
        }
  
        //TODO: do this in the background with dispatch_async
        //      it was working but then stopped ????
        
        let fileManager = NSFileManager.defaultManager()
        var imageData: NSData = UIImagePNGRepresentation(memedImage)
        
        fileManager.createFileAtPath(filePath, contents: imageData, attributes: nil)

//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//            UIImagePNGRepresentation(memedImage).writeToFile(filePath, atomically: true)
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                return
//            }
//        }
        //Update the global memes array
        (UIApplication.sharedApplication().delegate as AppDelegate).memes.append(self)
        
    }
    
    init (fileName: String) {
        // Create meme from local image file and dictionary
        self.fileName = fileName
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var dict = defaults.dictionaryForKey(Meme.dictionaryKey)

        //Split the text into its two parts
        if let t = dict?[fileName] as? String {
            let result = split(t as String, { $0 == "/" }, maxSplit: 1, allowEmptySlices: true)
            self.topText = result[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.bottomText = result[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        } else {
            self.topText = ""
            self.bottomText = ""
        }
        //Generate thumbnail
        if let memedImage = self.fileImage {
           self.thumbImage = Meme.resizeImage(memedImage, dim: 100.0)
        }
        
        //Add to the global memes array
        (UIApplication.sharedApplication().delegate as AppDelegate).memes.append(self)
    }
    
    
    func delete(index: Int) {
        // Delete a meme: image file and remove from defaults dictionary and the global array
        
        var error: NSError?

        let fileManager = NSFileManager.defaultManager()
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let path = dirPath.stringByAppendingPathComponent(self.fileName)
        
        if fileManager.removeItemAtPath(path, error: &error) {
            Meme.log("Removed: " + path)
        } else {
            NSLog("Remove failed: \(error!.localizedDescription)")
        }
        
        // Now update the dictionary
        let defaults = NSUserDefaults.standardUserDefaults()
        var dict = defaults.dictionaryForKey(Meme.dictionaryKey)
        dict?.removeValueForKey(self.fileName)
        defaults.setObject(dict, forKey: Meme.dictionaryKey)
        
        //update the global memes array
        if (index >= 0) {
            // A user initiated delete
            (UIApplication.sharedApplication().delegate as AppDelegate).memes.removeAtIndex(index)
        } else {
            //We've removed the one just added as part of an automatic delete
            (UIApplication.sharedApplication().delegate as AppDelegate).memes.removeLast()
        }
    }
 
    static func generateMemeImage(topText : String, bottomText : String, baseImage : UIImage) -> UIImage {
        var imageSize : CGFloat = 640.0
        
        //get the desired image size from the settings
        let defaults = NSUserDefaults.standardUserDefaults()
        if var dict = defaults.dictionaryForKey(Meme.settingsKey) {
            if let sz = dict[Meme.sizeKey] as? Int {
                imageSize = [320.0, 640.0, 1280.0][sz-1]
            }
        }
        
        // now actually resize it
        var img = Meme.resizeImage(baseImage, dim: imageSize)
        
        //Use image as canvas
        let sz = img.size
        let h = (sz.height)
        let w = (sz.width)
        let r = max(h,w)
        
        //Size the text fields so they fit
        let topText = topText.uppercaseString
        let topFont = Meme.getFontSize(topText, maxWidth: w, imageSize: r)
        
        let bottomText = bottomText.uppercaseString
        let bottomFont = Meme.getFontSize(bottomText, maxWidth: w, imageSize: r)
        
        // use same font size for both -- could change this (or make it a setting)
        var f = min(topFont, bottomFont)
        
        var drawAttr = Meme.memeTextAttributes
        drawAttr.updateValue(UIFont(name: "HelveticaNeue-CondensedBlack", size: CGFloat(f))!, forKey: NSFontAttributeName)
        
        let rect = CGRectMake(0, 0, w, h)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.width, height: rect.height), true, 0)
        let context = UIGraphicsGetCurrentContext()
        img.drawInRect(rect)
        
        //draw the top text
        
        var tsize = topText.sizeWithAttributes(drawAttr)
        var rectText = CGRectMake((w-tsize.width)/2, h*0.1, (w-tsize.width)/2+tsize.width, h*0.1+tsize.height)
        topText.drawInRect(rectText, withAttributes: drawAttr)
        
        //now bottom text
        
        tsize = bottomText.sizeWithAttributes(drawAttr)
        rectText = CGRectMake((w-tsize.width)/2, h*0.9-tsize.height, (w-tsize.width)/2+tsize.width, h*0.9)
        bottomText.drawInRect(rectText, withAttributes: drawAttr)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
    }
    

    static func resizeImage(img :UIImage, dim:CGFloat = 640.0) -> UIImage {
        // resize an image
        
        let r = max(img.size.height, img.size.width)
        var factor : CGFloat = 0.0
        
        if (r < dim) {
            factor = 1.0
        } else {
            factor = dim/r
        }
        
        if (factor < 1.0) {
            // only resize down
            let size = CGSizeApplyAffineTransform(img.size, CGAffineTransformMakeScale(factor, factor))
            let hasAlpha = false
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
            
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            img.drawInRect(CGRect(origin: CGPointZero, size: size))
            
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return scaledImage
        } else {
            // return the original image
            return img
        }
    }
    
    //MARK: - Helper functions
    
    static func substring(str : String, start : Int, len: Int) -> String {
        //because I still think in substrings :)
        let startIndex = advance(str.startIndex, start)
        let endIndex = advance(startIndex, len)
        let range = startIndex..<endIndex
        return str[range]
    }

    static func log(str : String) {
        // print to the log if running on an emulator
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            println(str)
        #endif
    }
    
    static func load() {
        // load all save memes. May delete them if older than the age setting
        
        var error: NSError?
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let fileManager = NSFileManager.defaultManager()
        let today = NSDate()
        
        var maxAge = 999999.0
        let defaults = NSUserDefaults.standardUserDefaults()
        if var dict = defaults.dictionaryForKey(Meme.settingsKey) {
            if let sz = dict[Meme.lengthKey] as? Int {
                maxAge = Double(sz)
            }
        }

        Meme.log(dirPath) // so I can find the emulator's documents folder with the finder...

        if let docsArray = fileManager.contentsOfDirectoryAtPath(dirPath, error:&error) as? [String] {
            for pathComponent in docsArray {
                if Meme.substring(pathComponent, start: 0, len: 2) == "mm" {
                    // our images start with mm...
                    
                    let path = dirPath.stringByAppendingPathComponent(pathComponent)
                    
                    if let attributes : NSDictionary = fileManager.attributesOfItemAtPath(path, error: &error) {
                        //Just checking that file really exists
                        var meme = Meme(fileName: pathComponent)
                        let days = today.timeIntervalSinceDate(meme.createDate!)/(60*60*24)
                        if (days > maxAge) {
                            //We go thru the effort of creating it, then turn around and delete it :)
                            Meme.log("deleted \(pathComponent) at \(days) days")
                            meme.delete(-1)
                        }
                    } else {
                        NSLog("Failed to read file size of \(path) with error \(error)")
                    }
                }
            }
        }
    }

    static func getFontSize(text : NSString, maxWidth : CGFloat, imageSize : CGFloat = 640.0) -> CGFloat {
        //Figure out the font size that will allow the text to fit on the image
        //Higher rez images need a larger font for same relative size.
        // 54pt on 640x image seemed about right
        
        var tryFont:CGFloat = 0.9 * imageSize/10 //made up factors
        
        var attr = Meme.memeTextAttributes
        
        attr.updateValue(UIFont(name: "HelveticaNeue-CondensedBlack", size: CGFloat(tryFont))!, forKey: NSFontAttributeName)
        var tsize = text.sizeWithAttributes(attr)
        
        if (tsize.width > maxWidth) {
            // to long to fit, try to resize font
            return (tryFont * maxWidth / tsize.width) - 2 //2 is fudge factor
        } else {
            // this font works
            return tryFont
        }
    }


}