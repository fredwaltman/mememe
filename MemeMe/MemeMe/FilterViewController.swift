//
//  FilterViewController.swift
//  MemeMe
//
//  Created by Fred Waltman on 3/17/15.
//  Copyright (c) 2015 Fred Waltman. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var delegate : SelectFilterDelegate? = nil
    
    var imageToFilter : UIImage!    // The inbound image from EditMeme
    var imageData : NSData!         // NSData version
    var thumbnailData : NSData!     // NSData of thumbnail, used to generate filter images
    
    var context:CIContext = CIContext(options: nil)
    var filters:[CIFilter] = []
    let filterNames = ["No Filter", "Blur", "Instant photo", "Noir", "Unsharpen", "Monochrome", "Sepia", "Vignette"]
    let placeHolderImage = UIImage(named: "placeholder")
    let tmp = NSTemporaryDirectory()
    
    let kIntensity = 0.7
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageData = UIImagePNGRepresentation(imageToFilter)
        
        // To save time make a thumbnail and apply the filters to it for choosing
        // resize thumbnail to 150px jpg at 30%
        let size = CGSizeApplyAffineTransform(imageToFilter.size, CGAffineTransformMakeScale(150.00/imageToFilter.size.width, 150.00/imageToFilter.size.height))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        imageToFilter.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        thumbnailData = UIImageJPEGRepresentation(scaledImage, 0.3)

        filters = photoFilters()
    }

    //MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("filterCell", forIndexPath: indexPath) as FilterCell

        cell.cellLabel.text = filterNames[indexPath.row]
        
        if indexPath.row == 0 {
            // The first cell is "No filter"
            cell.cellImage.image = UIImage(data: thumbnailData)
        } else {
            // go apply filter in another thread, the cell will have a placeholder until done
            
            cell.cellImage.image = placeHolderImage
            
            let filterQueue : dispatch_queue_t = dispatch_queue_create("filter queue", nil)
            
            dispatch_async(filterQueue, { () -> Void in
                let filterImage = self.getCachedImage(indexPath.row)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.cellImage.image = filterImage
                })
            })
        }
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == 0 {
            // No filter
            self.delegate?.didSelectFilterImage(imageToFilter)
        } else {
            // Apply filter to full sized image off the UI thread
            let filterQueue : dispatch_queue_t = dispatch_queue_create("filter queue", nil)
            
            dispatch_async(filterQueue, { () -> Void in
                
                let filterImage = self.filteredImageFromImage(self.imageData, filter: self.filters[indexPath.row])
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let x: Void? = self.delegate?.didSelectFilterImage(filterImage)
                })
            })
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

/*    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            
            let w = collectionView.frame.width
            let numAcross = floor( w / 150)
            let cellWidth = w / numAcross - 5
            
            return CGSize(width: cellWidth, height: cellWidth)
    } */
    

    //MARK: - Helper functions
    
    func photoFilters () -> [CIFilter] {
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
 
/* removed these filters in the interest of speed
   could also add composite from above -- needed for vingnette.
        
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents") */
        
        //First blur is dummy to fill in for no filter
        return [blur, blur, instant, noir, unsharpen, monochrome, sepia, vignette]
    }
    
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage
        
        let extent = filteredImage.extent()
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
    }
    
    
    // Caching functions, in case they comeback with the same image we can use
    // the one we've already filtered. Use length of image data as a "hash"
    
    func cacheImage(imageNumber : Int) {
        let fileName = "\(imageNumber)\(imageData.length)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            let data = self.thumbnailData
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getCachedImage(imageNumber : Int) -> UIImage {
        let fileName = "\(imageNumber)\(imageData.length)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)!
            
        } else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        
        return image
    }
}
