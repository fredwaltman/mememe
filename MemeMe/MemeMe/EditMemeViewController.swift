//
//  EditMemeViewController.swift
//  MemeMe
//
//  Created by Fred Waltman on 3/11/15.
//  Copyright (c) 2015 Fred Waltman. All rights reserved.
//

import UIKit

class EditMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, SelectFilterDelegate {

    var shouldSlide : Bool = false // Slide the text field?
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var helpText: UITextView!
    @IBOutlet weak var textTop: UITextField!
    @IBOutlet weak var textBottom: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!

    @IBAction func chooseAlbum(sender: UIBarButtonItem) {
        // Call the image picker
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)

    }

    @IBAction func useCamera(sender: UIBarButtonItem) {
        // Call the image picker to use the camera
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //add Navigation Bar buttons to Cancel and Share
        let b = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action:
            Selector("goBack"))
        self.navigationItem.rightBarButtonItem = b

        let s = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action,  target: self, action: Selector("goShare"))
        self.navigationItem.leftBarButtonItem = s
        self.navigationItem.leftBarButtonItem?.enabled = false

        self.navigationItem.title = "Create Meme"
        
        //Set up the two text fields (hidden until image selected)
        textTop.defaultTextAttributes = Meme.memeTextAttributes
        textBottom.defaultTextAttributes = Meme.memeTextAttributes

        textTop.textAlignment = .Center
        textBottom.textAlignment = .Center

        textTop.delegate = self
        textBottom.delegate = self

        textTop.hidden = true
        textBottom.hidden = true

    }
    
    override func viewWillAppear(animated: Bool) {

        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)

        self.subscribeToKeyboardNotifications()
        
        if let img = memeImage.image {
            // There is an image, so hide the help text and tool bar
            helpText.hidden = true
            toolBar.hidden = true
        } else {
            // no image so show help text
            helpText.hidden = false
        }
        
        shouldSlide = false

    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }

    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch(segue.identifier! as String) {
        case "addFilter" :
            let controller = segue.destinationViewController as FilterViewController            
            controller.imageToFilter = memeImage.image
            controller.delegate = self
        default :
            let x = 0
        }
    }


    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.memeImage.image = image
            
            self.textTop.hidden = false
            self.textBottom.hidden = false
            self.navigationItem.leftBarButtonItem?.enabled = true

            self.dismissViewControllerAnimated(true, completion: nil)

            // Go filter it
            performSegueWithIdentifier("addFilter", sender: self)

        } else {
            // for some reason didn't come back with an image.
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK: - SelectFilterDelegate
    
     func didSelectFilterImage(image: UIImage) {
        self.memeImage.image = image
    }
    
    // MARK: - Keyboard functions
    
    func keyboardWillShow(notification : NSNotification) {            
        if shouldSlide {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
     }
    
    func keyboardWillHide(notification : NSNotification) {
        if shouldSlide {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification : NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keybordSize = userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue // of CGRect
        
        return keybordSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    // MARK: TextField Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.tag == 1 && textField.text == "TOP") {
            textField.text = ""
        } else if (textField.tag == 2 && textField.text == "BOTTOM") {
            textField.text = ""
        }

        //Only need to slide for bottom text (which has a tag of 2)
        shouldSlide = (textField.tag == 2)
    }

    //MARK: - Helper Functions
    
    func goBack() {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    func goShare() {
        //Lauch the Activity View Controller to share the image
        if let i = memeImage.image {
            //check that we actually have an image
            let memedImage = save()
            
            let objectsToShare = [memedImage]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true) {Void in self.goBack()}
        }
    }
    
    func save() -> UIImage {
        //Create the meme item, which will generate the Meme Image
        
        var meme = Meme(topText: textTop.text.uppercaseString , bottomText: textBottom.text.uppercaseString, baseImage: self.memeImage.image!)
        
        return meme.fileImage!
    }
    
 }
