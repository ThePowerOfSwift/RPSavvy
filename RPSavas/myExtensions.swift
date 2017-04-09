//
//  myExtensions.swift
//  TipTap
//
//  Created by Dillon Murphy on 5/17/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import ParseUI
import Parse
import CoreGraphics


// MARK: - String

extension String {
    func outputArray() -> [String] {
        var output: [String] = [String]()
        var valueChecker: String = ""
        for char in self.characters {
            valueChecker += "\(char)"
            output.append(valueChecker)
        }
        print(output)
        return output
    }
    
    func getInitials() -> String {
        var imageViewString: String = ""
        let wordsArray = self.characters.split{$0 == " "}.map(String.init)
        for word in wordsArray {
            imageViewString += "\(word.characters.first!)"
            if imageViewString.characters.count >= 3 {
                break
            }
        }
        return imageViewString
    }
    
}

let hambutton: MIBadgeButton = MIBadgeButton(type: .Custom)

// MARK: - UIViewController
var prevOffset: CGFloat?


extension UIViewController {
    
    
    func addKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:"UIKeyboardWillShow", object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:"UIKeyboardWillHide", object: self.view.window)
    }
    
    func removeKeyboard() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"UIKeyboardWillShow", object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"UIKeyboardWillHide", object: self.view.window)
        prevOffset = nil
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = (sender as NSNotification).userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
        self.view.frame.origin.y += keyboardSize.height
        prevOffset = nil
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = (sender as NSNotification).userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue().size
        if prevOffset == nil {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y -= keyboardSize.height
                prevOffset = keyboardSize.height
            })
        } else {
            if prevOffset > offset.height {
                let newOffset = (prevOffset! - offset.height)
                prevOffset = newOffset
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y += newOffset
                })
            } else {
                let newOffset = (offset.height - prevOffset!)
                prevOffset = newOffset
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= newOffset
                })
            }
        }
    }
    
    func hideBackButton() {
        navigationItem.setLeftBarButtonItem(UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil), animated: false)
    }
    
    func photoButtonPressed(sender: UITapGestureRecognizer) {
        let alertVC = UIAlertController(title: "Upload New Profile Picture", message: "How would you like to upload your photo?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let Take = UIAlertAction(title: "Take Picture", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            Camera.shouldStartCamera(self, canEdit: true, frontFacing: true)
        }
        let Lib = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            Camera.shouldStartPhotoLibrary(self, canEdit: true)
        }
        let Cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in}
        alertVC.addAction(Take)
        alertVC.addAction(Lib)
        alertVC.addAction(Cancel)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func addLogOut() {
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.tappedLogout)), animated: false)
    }
    
    func tappedLogout() {
        PFUser.logOut()
        sideMenuNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LobbyNAV") as? UINavigationController
        appDelegate.window?.rootViewController = sideMenuNavigationController
    }
    
    func addBackButton() {
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.tappedBack)), animated: false)
    }
    
    
    func tappedBack() {
        sideMenuNavigationController!.popViewControllerAnimated(true)
    }
    
    func addHamMenu() {
        hambutton.frame = CGRect(x:0,y:0,width:sideMenuNavigationController!.navigationBar.frame.height,height:sideMenuNavigationController!.navigationBar.frame.height)
        hambutton.badgeTextColor = UIColor.whiteColor()
        hambutton.badgeBackgroundColor = UIColor.redColor()
        hambutton.badgeEdgeInsets = UIEdgeInsetsMake(15, 0, 0, 10)
        hambutton.setImage(UIImage(named: "MenuIcon")!, forState: .Normal)
        hambutton.tintColor = .whiteColor()
        hambutton.addTarget(self, action:  #selector(self.tappedMenu), forControlEvents: .TouchUpInside)
        let menuButton: UIBarButtonItem = UIBarButtonItem(customView: hambutton)
        menuButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(menuButton, animated: true)
    }
    
    func tappedMenu() {
        hambutton.badgeString = 0
        sideMenuVC.toggleMenu()
    }
    
    func addGradLayer() {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        gradientLayer.frame = frame
        let color1 = UIColor.blackColor().CGColor as CGColorRef
        gradientLayer.colors = [color1, AppConfiguration.scheme[2], AppConfiguration.scheme[2], AppConfiguration.scheme[2], color1]
        gradientLayer.locations = [0.0, 0.3, 0.5, 0.7, 1.0]
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func addSwipers() {
        let swiper:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.showMenu))
        swiper.direction = .Left
        self.view.addGestureRecognizer(swiper)
        let swiper2:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissMenu))
        swiper2.direction = .Right
        self.view.addGestureRecognizer(swiper2)
    }

    func showMenu() {
        sideMenuVC.openMenu()
    }
    
    func dismissMenu() {
        sideMenuVC.closeMenu()
    }

    func addDismissGesture() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: - PFImageView

extension PFImageView {
    
    
    func imageWithString(word: String, color: UIColor? = nil, circular: Bool = true, fontAttributes: [String : AnyObject]? = nil){
        imageSnapShotFromWords(word.getInitials(), color: color, circular: circular, fontAttributes: fontAttributes)
    }
    
    func imageSnapShotFromWords(snapShotString: String, color: UIColor?, circular: Bool, fontAttributes: [String : AnyObject]?) {
        let attributes: [String : AnyObject]
        if let attr = fontAttributes {
            attributes = attr
        } else {
            attributes = [NSForegroundColorAttributeName : UIColor.whiteColor(),  NSFontAttributeName : UIFont(name: "AmericanTypewriter-Semibold", size:  self.bounds.width * 0.4)!]
        }
        let imageBackgroundColor: UIColor
        if let color = color {
            imageBackgroundColor = color
        } else {
            imageBackgroundColor = .grayColor()
        }
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        if circular {
            self.layer.cornerRadius = self.frame.width/2
        } else {
            self.layer.cornerRadius = 8.0
        }
        self.clipsToBounds = true
        CGContextSetRGBFillColor(context!, imageBackgroundColor.red(), imageBackgroundColor.green(), imageBackgroundColor.blue(), 1.0)
        CGContextFillRect(context!, CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        let textSize = NSString(string: snapShotString).sizeWithAttributes(attributes)
        NSString(string: snapShotString).drawInRect(CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height), withAttributes: attributes)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.image = image
    }
    
    func setPic(user: PFUser, completion: UserSettingClosure?) {
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 2.0
        self.tintColor = AppConfiguration.navText
        self.layer.borderColor = UIColor.clearColor().CGColor
        self.contentMode = .ScaleAspectFill
        self.backgroundColor = UIColor.clearColor()
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.masksToBounds = true
        if user["picture"] != nil {
            self.file = user["picture"] as? PFFile
            self.loadInBackground()
        } else {
            if user["fullname"] != nil {
                self.imageWithString(PFUser.currentUser()!["fullname"] as! String, color: .charcoalColor(), circular: true, fontAttributes: nil)
            } else {
                self.imageWithString("R P S", color: .charcoalColor(), circular: true, fontAttributes: nil)
            }
        }
        if completion != nil {
            completion!()
        }
    }
    
    func setProfPic(color: UIColor?, completion: UserSettingClosure?) {
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 2.0
        self.tintColor = AppConfiguration.navText
        self.layer.borderColor = UIColor.clearColor().CGColor
        self.contentMode = .ScaleAspectFill
        self.backgroundColor = UIColor.clearColor()
        self.layer.borderColor = color != nil ? color!.CGColor : UIColor.whiteColor().CGColor
        self.layer.masksToBounds = true
        if  PFUser.currentUser() != nil {
            if PFUser.currentUser()!["picture"] != nil {
                self.file = PFUser.currentUser()!["picture"] as? PFFile
                self.loadInBackground({ (image, error) in
                    if image == nil {
                        print("Got Image")
                        self.imageWithString(PFUser.currentUser()!["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
                    } else {
                        print("Fail Image")
                        self.imageWithString("R P S", color: .charcoalColor(), circular: false, fontAttributes: nil)
                    }
                    if completion != nil {
                        completion!()
                    }
                })
            } else {
                let userQuery = PFUser.query()
                userQuery?.cachePolicy = AppConfiguration.cachePolicy
                userQuery?.maxCacheAge = 3600
                userQuery?.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) in
                    if error == nil {
                        self.file = PFUser.currentUser()!["picture"] as? PFFile
                        self.loadInBackground({ (image, error) in
                            if image == nil {
                                print("Got Image 2")
                                self.imageWithString(PFUser.currentUser()!["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
                            } else {
                                print("Fail Image 2")
                                self.imageWithString("R P S", color: .charcoalColor(), circular: false, fontAttributes: nil)
                            }
                        })
                    }
                    if completion != nil {
                        completion!()
                    }
                })
            }
        } else {
            self.imageWithString("R P S", color: .charcoalColor(), circular: false, fontAttributes: nil)
            if completion != nil {
                completion!()
            }
        }
    }
    
    
    func setProfPic() {
        self.image = UIImage(named: "ProfileIcon")
        if  PFUser.currentUser() != nil {
            self.file = PFUser.currentUser()!.profPic
            self.loadInBackground()
        }
        self.layer.cornerRadius = (self.frame.height) / 2
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 4.0
    }
    
    func setProfPicOfUser(user: PFUser) {
        self.file = user.profPic
        self.loadInBackground()
        self.layer.cornerRadius = (self.frame.height) / 2
        self.tintColor = AppConfiguration.navText
        self.layer.borderColor = AppConfiguration.navText.CGColor
        self.layer.borderWidth = 4.0
        self.contentMode = .ScaleAspectFill
        self.backgroundColor = UIColor.clearColor()
        self.layer.masksToBounds = true
    }
    
    typealias UserSettingClosure = (Void) -> Void
    
    func setProfPic(user: PFUser, color: UIColor?, completion: UserSettingClosure?) {
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 2.0
        self.tintColor = AppConfiguration.navText
        self.layer.borderColor = UIColor.clearColor().CGColor
        self.contentMode = .ScaleAspectFill
        self.backgroundColor = UIColor.clearColor()
        self.layer.borderColor = color != nil ? color!.CGColor : UIColor.whiteColor().CGColor
        self.layer.masksToBounds = true
        if user["picture"] != nil {
            self.file = user["picture"] as? PFFile
            self.loadInBackground({ (image, error) in
                if image == nil {
                    if user["fullname"] != nil {
                        self.imageWithString(user["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
                    } else {
                        self.imageWithString("R P S", color: .charcoalColor(), circular: false, fontAttributes: nil)
                    }
                }
            })
            if completion != nil {
                completion!()
            }
        } else {
            let userQuery = PFUser.query()
            userQuery?.cachePolicy = AppConfiguration.cachePolicy
            userQuery?.maxCacheAge = 3600
            userQuery?.getObjectInBackgroundWithId(user.objectId!, block: { (object, error) in
                if error == nil {
                    if object!["picture"] != nil {
                        self.file = object!["picture"] as? PFFile
                        self.loadInBackground({ (image, error) in
                            if image == nil {
                                if object!["fullname"] != nil {
                                    self.imageWithString(object!["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
                                } else {
                                    self.imageWithString("R P S", color: .charcoalColor(), circular: false, fontAttributes: nil)
                                }
                            }
                        })
                    } else {
                        if object!["fullname"] != nil {
                            self.imageWithString(object!["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
                        } else {
                            self.imageWithString("R P S", color: .charcoalColor(), circular: false, fontAttributes: nil)
                        }
                    }
                }
                if completion != nil {
                    completion!()
                }
            })
        }
    }
}


// MARK: - UILabel

extension UILabel {
    
    func resizeFont() {
        if self.text != nil {
            let textSize = self.text!.sizeWithAttributes([NSFontAttributeName:self.font!])
            let widthCheck: CGFloat = (UIScreen.mainScreen().bounds.width <= 320) ? 201.5 : 256
            if widthCheck <= CGFloat(textSize.width) {
                let fontSize = self.font.pointSize - 1.0
                self.font = UIFont(name: self.font.fontName, size: fontSize)!
                self.setNeedsLayout()
                self.resizeFont()
            }
        }
    }
    
    func Fullname(user: PFUser, color: UIColor?) {
        self.font = (UIScreen.mainScreen().bounds.width <= 320) ? UIFont(name: "AmericanTypewriter", size: 25.0)! : UIFont(name: "AmericanTypewriter", size: 35.0)!
        if color != nil {
            self.textColor = color!
        } else {
            self.textColor = UIColor.whiteColor()
        }
        self.adjustsFontSizeToFitWidth = true
        if user["fullname"] != nil {
            self.text = user["fullname"] as? String ?? ""
        } else {
            let userQuery = PFUser.query()
            userQuery?.cachePolicy = AppConfiguration.cachePolicy
            userQuery?.maxCacheAge = 3600
            userQuery?.getObjectInBackgroundWithId(user.objectId!, block: { (object, error) in
                if error == nil {
                    self.text = object!["fullname"] as? String ?? ""
                }
            })
        }
    }
    
    
    func evaporate(newText: String) {
        let originalFrame = self.frame
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.frame = self.frame.offsetBy(dx: 0, dy: -self.frame.height / 2)
            self.alpha = 0.0
        }) { (success) in
            self.frame = self.frame.offsetBy(dx: 0, dy: self.frame.height + (self.frame.height / 2))
            self.text = newText
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.frame = originalFrame
                self.alpha = 1.0
                }, completion: nil)
        }
    }
    
    func evap(newText: String) {
        let originalFrame = self.frame
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.frame = self.frame.offsetBy(dx: 0, dy: -self.frame.height / 4)
            self.alpha = 0.0
        }) { (success) in
            self.frame = self.frame.offsetBy(dx: 0, dy: self.frame.height / 2)
            self.text = newText
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.frame = originalFrame
                self.alpha = 1.0
                }, completion: nil)
        }
    }
    
    func boundingRects() -> [CGRect]? {
        var rects: [CGRect] = [CGRect]()
        guard let Text = text else { return nil }
        for char in 0...(Text.characters.count) {
            let textStorage = NSTextStorage(string: Text, attributes: [NSForegroundColorAttributeName : self.textColor, NSFontAttributeName : self.font] as [String : AnyObject])
            let layoutManager = NSLayoutManager()
            textStorage.addLayoutManager(layoutManager)
            let textContainer = NSTextContainer(size: bounds.size)
            textContainer.lineFragmentPadding = 0.0
            layoutManager.addTextContainer(textContainer)
            var glyphRange = NSRange()
            let range: NSRange = NSMakeRange(char, 1)
            layoutManager.characterRangeForGlyphRange(range, actualGlyphRange: &glyphRange)
            rects.append(layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer))
        }
        return rects
    }
    
    func boundingWidth() -> CGFloat {
        var rectWidth: CGFloat = 0.0
        guard let Text = text else { return 0.0 }
        for char in 0...(Text.characters.count) {
            let textStorage = NSTextStorage(string: Text, attributes: [NSForegroundColorAttributeName : self.textColor, NSFontAttributeName : self.font] as [String : AnyObject])
            let layoutManager = NSLayoutManager()
            textStorage.addLayoutManager(layoutManager)
            let textContainer = NSTextContainer(size: bounds.size)
            textContainer.lineFragmentPadding = 0.0
            layoutManager.addTextContainer(textContainer)
            var glyphRange = NSRange()
            let range: NSRange = NSMakeRange(char, 1)
            layoutManager.characterRangeForGlyphRange(range, actualGlyphRange: &glyphRange)
            rectWidth = rectWidth + layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer).width
        }
        return rectWidth
    }
}

// MARK: - PFUser

extension PFUser {
    
    
    var profPic : PFFile {
        get {
            do {
                try self.fetchIfNeeded()
                if  self["profPic"] != nil {
                    return (self["profPic"] as? PFFile)!
                } else {
                    return PFFile(name: "thumbnail.jpg", data: UIImageJPEGRepresentation(UIImage(named: "ProfileIcon")!, 0.6)!)!
                }
            } catch {
                return PFFile(name: "thumbnail.jpg", data: UIImageJPEGRepresentation(UIImage(named: "ProfileIcon")!, 0.6)!)!
            }
        }
    }
    
    
    
    var fullname: String {
        get {
            do {
                try self.fetchIfNeeded()
                if self["fullname"] != nil {
                    return self["fullname"] as! String
                } else {
                    return "No Name"
                }
            } catch {
                return "No Name"
            }
        }
    }
    
    var BlockedUsers : [PFUser]  {
        get {
            do {
                try self.fetchIfNeeded()
                if self["BlockedPeople"] != nil {
                    return self["BlockedPeople"] as! [PFUser]
                } else {
                    return []
                }
            } catch {
                return []
            }
        }
    }
    
    var Friends : [PFUser]  {
        get {
            do {
                try self.fetchIfNeeded()
                if self["Friends"] != nil {
                    return self["Friends"] as! [PFUser]
                } else {
                    return []
                }
            } catch {
                return []
            }
        }
    }
    

    
    
    func imageWithString(word: String, color: UIColor, bounds: CGRect) -> UIImage  {
        var imageViewString: String = ""
        let wordsArray = word.characters.split{$0 == " "}.map(String.init)
        for word in wordsArray {
            imageViewString += "\(word.characters.first!)"
            if imageViewString.characters.count >= 3 {
                break
            }
        }
        return imageSnapShotFromWords(imageViewString, color: nil, fontAttributes: nil, bounds: bounds)
    }
    
    func imageSnapShotFromWords(snapShotString: String, color: UIColor?, fontAttributes: [String : AnyObject]?, bounds: CGRect) -> UIImage {
        let attributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.whiteColor(),  NSFontAttributeName : UIFont(name: "AmericanTypewriter-Semibold", size:  bounds.width * 0.4)!]
        let imageBackgroundColor: UIColor = UIColor.clearColor()
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBFillColor(context!, imageBackgroundColor.red(), imageBackgroundColor.green(), imageBackgroundColor.blue(), 1.0)
        CGContextFillRect(context!, CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        let textSize = NSString(string: snapShotString).sizeWithAttributes(attributes)
        NSString(string: snapShotString).drawInRect(CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height), withAttributes: attributes)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    typealias GetPicClosure = (UIImage?) -> Void
    
    func getProfPic(bounds: CGRect, completion: GetPicClosure?) {
        if completion != nil {
            if self["picture"] != nil {
                let file = self["picture"] as! PFFile
                file.getDataInBackgroundWithBlock({ (data, error) in
                    if error == nil {
                        if data != nil {
                            let image = UIImage(data: data!)
                            completion!(image)
                        } else {
                            completion!(self.imageWithString(self["fullname"] as? String ?? "R P S", color: UIColor.charcoalColor(), bounds: CGRect(x: 0, y: 0, width: 70, height: 70)))
                        }
                    } else {
                        completion!(self.imageWithString(self["fullname"] as? String ?? "R P S", color: UIColor.charcoalColor(), bounds: bounds))
                    }
                })
            } else {
                completion!(self.imageWithString(self["fullname"] as? String ?? "R P S", color: UIColor.charcoalColor(), bounds: bounds))
            }
        }
    }
    
    @objc func Fullname() -> String  {
        return self["fullname"] as? String ?? ""//"R P S"
    }
    
    typealias CreateSessionClosure = (Bool) -> Void
    
    func createSession(completion: CreateSessionClosure) {
        let query = PFQuery(className: "ActiveSessions")
        query.whereKey("caller", equalTo: PFUser.currentUser()!)
        query.whereKey("receiver", equalTo: self)
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
            if error == nil || object != nil {
                AppConfiguration.activeSession = nil
                completion(false)
            } else {
                let activeSession:PFObject = PFObject(className: "ActiveSessions")
                activeSession["caller"] = PFUser.currentUser()!
                activeSession["receiver"] = self
                activeSession["callerTitle"] = "\(PFUser.currentUser()!.Fullname()) sent you a game request!"
                //activeSession["Accepted"] = false
                activeSession.saveInBackgroundWithBlock({(succeeded: Bool?, error: NSError?) -> Void in
                    if error == nil {
                        AppConfiguration.activeSession = activeSession
                        completion(true)
                    } else {
                        AppConfiguration.activeSession = nil
                        completion(false)
                    }
                })
            }
        }
    }
}

// MARK: - loadingLabel

class loadingLabel: LTMorphingLabel {
    
    var loadingTimer: NSTimer?
    
    lazy var fontSize: CGFloat? = {
        return self.font.pointSize
    }()
    
    /* {
        get {
            return self.fontSize != nil ? super.font.pointSize : 35.0
        }
        set {
            /*var value = newValue
            if (UIScreen.mainScreen().bounds.width <= 320) {
                value = (self.text!.characters.count >= 15) ? (self.text!.characters.count >= 20) ? 15.0 : 20.0 : 25.0
            } else {
                value = (self.text!.characters.count >= 15) ? (self.text!.characters.count >= 20) ? 20.0 : 25.0 : 35.0
            }*/
            self.font = UIFont(name: "AmericanTypewriter-Semibold", size: (newValue >= 10.0 && newValue != nil) ? newValue! : 10.0)!
            self.setNeedsLayout()
        }
    }*/
    
    var variableWidth: Bool = true
    
    var LoadingText: String! {
        get {
            return text
        }
        set {
            text = newValue
            if self.variableWidth {
                self.resizeGameFont()
            } else {
                self.resizeFont()
            }
        }
    }
    
    func resizeGameFont() {
        if self.text != nil {
            let textSize = self.text!.sizeWithAttributes([NSFontAttributeName:self.font!])
            if self.bounds.width <= textSize.width {
                let fontSize = self.font.pointSize - 1.0
                if fontSize > 13.0 {
                    self.font = UIFont(name: self.font.fontName, size: fontSize)!
                    self.setNeedsLayout()
                    self.resizeFont()
                }
            }
        }
    }
    
    var index: NSIndexPath?
    var labelSet: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startLoading()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        startLoading()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        startLoading()
    }
    
    func startLoading() {
        loadingTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(self.loadingTextTimer(_:)), userInfo: nil, repeats: true)
    }
    
    func stopLoading() {
        if loadingTimer != nil {
            loadingTimer!.invalidate()
            loadingTimer = nil
            text = nil
        }
    }
    
    deinit {
        stopLoading()
    }

    func loadingTextTimer(sender: NSTimer) {
        if text != nil {
            switch LoadingText {
            case "":
                LoadingText = "L"
            case "L":
                LoadingText = "LO"
            case "LO":
                LoadingText = "LOA"
            case "LOA":
                LoadingText = "LOAD"
            case "LOAD":
                LoadingText = "LOADI"
            case "LOADI":
                LoadingText = "LOADIN"
            case "LOADIN":
                LoadingText = "LOADING"
            case "LOADING":
                LoadingText = "LOADING."
            case "LOADING.":
                LoadingText = "LOADING.."
            case "LOADING..":
                LoadingText = "LOADING..."
                if loadingTimer == nil {
                    loadingTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(self.loadingTextTimer(_:)), userInfo: nil, repeats: true)
                    labelSet = false
                }
            case "LOADING...":
                if labelSet {
                    if loadingTimer != nil {
                        loadingTimer!.invalidate()
                        loadingTimer = nil
                    }
                } else {
                    LoadingText = ""
                }
            case "W" :
                LoadingText = "Wa"
            case "Wa" :
                LoadingText = "Wai"
            case "Wai" :
                LoadingText = "Wait"
            case "Wait" :
                LoadingText = "Waiti"
            case "Waiti" :
                LoadingText = "Waitin"
            case "Waitin" :
                LoadingText = "Waiting"
            case "Waiting" :
                LoadingText = "Waiting "
            case "Waiting " :
                LoadingText = "Waiting f"
            case "Waiting f" :
                LoadingText = "Waiting fo"
            case "Waiting fo" :
                LoadingText = "Waiting for"
            case "Waiting for" :
                LoadingText = "Waiting for "
            case "Waiting for " :
                LoadingText = "Waiting for O"
            case "Waiting for O" :
                LoadingText = "Waiting for Op"
            case "Waiting for Op" :
                LoadingText = "Waiting for Opp"
            case "Waiting for Opp" :
                LoadingText = "Waiting for Oppo"
            case "Waiting for Oppo" :
                LoadingText = "Waiting for Oppon"
            case "Waiting for Oppon" :
                LoadingText = "Waiting for Oppone"
            case "Waiting for Oppone" :
                LoadingText = "Waiting for Opponen"
            case "Waiting for Opponen" :
                LoadingText = "Waiting for Opponent"
            case "Waiting for Opponent" :
                LoadingText = "Waiting for Opponent."
            case "Waiting for Opponent." :
                LoadingText = "Waiting for Opponent.."
                if loadingTimer == nil {
                    loadingTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(self.loadingTextTimer(_:)), userInfo: nil, repeats: true)
                    labelSet = false
                }
            case "Waiting for Opponent.." :
                if labelSet {
                    if loadingTimer != nil {
                        loadingTimer!.invalidate()
                        loadingTimer = nil
                    }
                } else {
                    LoadingText = "W"
                }
            case "Y":
                LoadingText = "Yo"
            case "Yo":
                LoadingText = "You"
            case "You":
                LoadingText = "Your"
            case "Your":
                LoadingText = "Your "
            case "Your ":
                LoadingText = "Your I"
            case "Your I":
                LoadingText = "Your In"
            case "Your In":
                LoadingText = "Your Inv"
            case "Your Inv":
                LoadingText = "Your Invi"
            case "Your Invi":
                LoadingText = "Your Invit"
            case "Your Invit":
                LoadingText = "Your Invite Is"
            case "Your Invite Is":
                LoadingText = "Your Invite Is "
            case "Your Invite Is ":
                LoadingText = "Your Invite Is P"
            case "Your Invite Is P":
                LoadingText = "Your Invite Is Pe"
            case "Your Invite Is Pe":
                LoadingText = "Your Invite Is Pen"
            case "Your Invite Is Pen":
                LoadingText = "Your Invite Is Pend"
            case "Your Invite Is Pend":
                LoadingText = "Your Invite Is Pendi"
            case "Your Invite Is Pendi":
                LoadingText = "Your Invite Is Pendin"
            case "Your Invite Is Pendin":
                LoadingText = "Your Invite Is Pending"
            case "Your Invite Is Pending":
                LoadingText = "Your Invite Is Pending."
            case "Your Invite Is Pending.":
                LoadingText = "Your Invite Is Pending.."
            case "Your Invite Is Pending..":
                LoadingText = "Your Invite Is Pending..."
                if loadingTimer == nil {
                    loadingTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(self.loadingTextTimer(_:)), userInfo: nil, repeats: true)
                    labelSet = false
                }
            case "Your Invite Is Pending...":
                if labelSet {
                    if loadingTimer != nil {
                        loadingTimer!.invalidate()
                        loadingTimer = nil
                    }
                } else {
                    LoadingText = "Y"
                }
            case "S":
                LoadingText = "Se"
            case "Se":
                LoadingText = "Sen"
            case "Sen":
                LoadingText = "Sent"
            case "Sent":
                LoadingText = "Sent "
            case "Sent ":
                LoadingText = "Sent Y"
            case "Sent Y":
                LoadingText = "Sent Yo"
            case "Sent Yo":
                LoadingText = "Sent You"
            case "Sent You":
                LoadingText = "Sent You "
            case "Sent You ":
                LoadingText = "Sent You A"
            case "Sent You A":
                LoadingText = "Sent You A "
            case "Sent You A ":
                LoadingText = "Sent You A G"
            case "Sent You A G":
                LoadingText = "Sent You A Ga"
            case "Sent You A Ga":
                LoadingText = "Sent You A Gam"
            case "Sent You A Gam":
                LoadingText = "Sent You A Game"
            case "Sent You A Game":
                LoadingText = "Sent You A Game "
            case "Sent You A Game ":
                LoadingText = "Sent You A Game R"
            case "Sent You A Game R":
                LoadingText = "Sent You A Game Re"
            case "Sent You A Game Re":
                LoadingText = "Sent You A Game Req"
            case "Sent You A Game Req":
                LoadingText = "Sent You A Game Requ"
            case "Sent You A Game Requ":
                LoadingText = "Sent You A Game Reque"
            case "Sent You A Game Reque":
                LoadingText = "Sent You A Game Reques"
            case "Sent You A Game Reques":
                LoadingText = "Sent You A Game Request"
            case "Sent You A Game Request":
                LoadingText = "Sent You A Game Request!"
            case "Sent You A Game Request!":
                if loadingTimer == nil {
                    loadingTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(self.loadingTextTimer(_:)), userInfo: nil, repeats: true)
                    labelSet = false
                }
                LoadingText = "Sent You A Game Request! "
            case "Sent You A Game Request! ":
                if labelSet {
                    if loadingTimer != nil {
                        loadingTimer!.invalidate()
                        loadingTimer = nil
                    }
                } else {
                    LoadingText = "S"
                }
            default:
                labelSet = true
            }
        } else {
            LoadingText = "LOADING..."
        }
    }
    
    override func Fullname(user: PFUser, color: UIColor?) {
        self.font = (UIScreen.mainScreen().bounds.width <= 320) ? UIFont(name: "AmericanTypewriter", size: 25.0)! : UIFont(name: "AmericanTypewriter", size: 35.0)!
        if color != nil {
            self.textColor = color!
        } else {
            self.textColor = UIColor.whiteColor()
        }
        self.adjustsFontSizeToFitWidth = true
        if user["fullname"] != nil {
            self.text = user["fullname"] as? String ?? ""
            resizeFont()
        } else {
            let userQuery = PFUser.query()
            userQuery?.cachePolicy = AppConfiguration.cachePolicy
            userQuery?.maxCacheAge = 3600
            userQuery?.getObjectInBackgroundWithId(user.objectId!, block: { (object, error) in
                if error == nil {
                    self.text = object!["fullname"] as? String ?? ""
                    self.resizeFont()
                }
            })
        }
    }
}

// MARK: - BadgeView

class BadgeView: UIView {
    
    var valueLabel: UILabel = UILabel()
    var formatter: NSNumberFormatter = NSNumberFormatter()
    
    let kBadgeViewMinimumSize: CGFloat = 20.0
    let kBadgeViewPadding: CGFloat = 5.0
    let kBadgeViewDefaultFont: UIFont = UIFont(name: "AmericanTypewriter", size: 12)!
    
    var badgeNumber: Int = 0
    
    var badgeValue: Int {
        get {
            return self.badgeNumber
        }
        set (newVal) {
            if (newVal <= 0 && self.badgeNumber == 0) {
                return
            }
            if newVal < 0 && self.badgeNumber > 0 {
                self.badgeNumber = 0
            } else {
                self.badgeNumber = newVal
            }
            if self.badgeNumber > 0 {
                self.valueLabel.text = self.formatter.stringFromNumber(self.badgeNumber)!
            }
            self.updateState()
        }
    }
    
    var textColor: UIColor! {
        didSet {
            self.valueLabel.textColor = self.textColor
        }
    }
    
    var font: UIFont! {
        didSet {
            self.valueLabel.font = self.font
        }
    }
    
    var topOffset: CGFloat = 0.0
    var rightOffset: CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit() {
        self.formatter.groupingSeparator = ","
        self.formatter.usesGroupingSeparator = true
        self.setupDefaultAppearance()
    }
    
    // MARK: - Appearance
    
    func setupDefaultAppearance() {
        self.clipsToBounds = true
        self.hidden = true
        self.backgroundColor = UIColor.redColor()
        self.valueLabel.textAlignment = .Center
        self.valueLabel.backgroundColor = UIColor.clearColor()
        self.addSubview(self.valueLabel)
        self.textColor = UIColor.whiteColor()
        self.font = UIFont(name: "AmericanTypewriter", size: 12)!
        self.topOffset = 0.0
        self.rightOffset = 0.0
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutBadgeSubviews()
    }
    
    func layoutBadgeSubviews() {
        self.valueLabel.sizeToFit()
        let badgeLabelWidth: CGFloat = CGRectGetWidth(self.valueLabel.frame)
        let badgeLabelHeight: CGFloat = CGRectGetHeight(self.valueLabel.frame)
        let height: CGFloat = max(kBadgeViewMinimumSize, badgeLabelHeight + kBadgeViewPadding)
        let width: CGFloat = max(height, badgeLabelWidth + (2 * kBadgeViewPadding))
        self.frame = CGRect(x: CGRectGetWidth(self.superview!.frame) - (width / 2.0) - self.rightOffset, y: -(height / 2.0) + self.topOffset, width: width, height: height)
        self.layer.cornerRadius = height / 2.0
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.valueLabel.frame = CGRect(x: (width / 2.0) - (badgeLabelWidth / 2.0), y: (height / 2.0) - (badgeLabelHeight / 2.0), width: badgeLabelWidth, height: badgeLabelHeight)
    }
    
    // MARK: - Updating the badge value
    
    func increment() {
        self.badgeValue += 1
    }
    
    func decrement() {
        self.badgeValue -= 1
    }
    
    // MARK: - State
    
    func updateState() {
        // If we're currently hidden and we should be visible, show ourself.
        if self.hidden && self.badgeValue > 0 {
            self.layoutBadgeSubviews()
            self.show()
        }
        else if !self.hidden && self.badgeValue <= 0 {
            self.hide()
        }
        else {
            self.layoutBadgeSubviews()
        }
    }
    
    // MARK: - Visibility
    
    func show() {
        /*if #available(iOS 10.0, *) {
            let timing:UICubicTimingParameters = UICubicTimingParameters(animationCurve: UIViewAnimationCurve.EaseInOut)
            let animator:UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 0.66, timingParameters: timing)
            animator.addAnimations {
                self.hidden = false
                self.frame = self.frame.offsetBy(dx: 0, dy: -3)
            }
            animator.addCompletion { (_) in
                animator.addAnimations {
                    self.frame = self.frame.offsetBy(dx: 0, dy: 6)
                }
                animator.addCompletion { (_) in
                    animator.addAnimations {
                        self.frame = self.frame.offsetBy(dx: 0, dy: -3)
                    }
                    animator.startAnimation()
                }
                animator.startAnimation()
            }
            animator.startAnimation()
        } else {*/
            self.hidden = false
        //}
    }
    
    func hide() {
        /*if #available(iOS 10.0, *) {
            let timing:UICubicTimingParameters = UICubicTimingParameters(animationCurve: UIViewAnimationCurve.EaseInOut)
            let animator:UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 0.66, timingParameters: timing)
            animator.addAnimations {
                self.frame = self.frame.offsetBy(dx: 0, dy: -3)
            }
            animator.addCompletion { (_) in
                animator.addAnimations {
                    self.frame = self.frame.offsetBy(dx: 0, dy: 6)
                }
                animator.addCompletion { (_) in
                    animator.addAnimations {
                        self.frame = self.frame.offsetBy(dx: 0, dy: -3)
                    }
                    animator.addCompletion { (_) in
                        self.hidden = true
                    }
                    animator.startAnimation()
                }
                animator.startAnimation()
            }
            animator.startAnimation()
        } else {*/
            self.hidden = true
        //}
    }
}

// MARK: - MIBadgeButton

public class MIBadgeButton: UIButton {
    
    var formatter: NSNumberFormatter = NSNumberFormatter()
    
    public var badgeLabel: UILabel
    
    private var badgeNumber: Int = 0
    
    public var badgeString: Int {
        get {
            return self.badgeNumber
        }
        set (newVal) {
            if (newVal <= 0 && self.badgeNumber == 0) {
                self.hide()
                return
            }
            if newVal <= 0 && self.badgeNumber > 0 {
                self.badgeNumber = 0
                self.hide()
            } else {
                self.badgeNumber = newVal
                if (newVal == 0) {
                    self.hide()
                }
            }
            if self.badgeNumber > 999 {
                self.setupBadgeViewWithString("999+")
            } else if self.badgeNumber > 0 {
                self.setupBadgeViewWithString(self.formatter.stringFromNumber(self.badgeNumber)!)
            } else {
                self.hide()
            }
        }
    }
    
    public var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            setupBadgeViewWithString("\(badgeString)")
        }
    }
    
    public var badgeBackgroundColor: UIColor? {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    public var badgeTextColor: UIColor? {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }
    
    override public init(frame: CGRect) {
        badgeLabel = UILabel()
        super.init(frame: frame)
        self.formatter.groupingSeparator = ","
        self.formatter.usesGroupingSeparator = true
        setupBadgeViewWithString("0")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        badgeLabel = UILabel()
        super.init(coder: aDecoder)
        self.formatter.groupingSeparator = ","
        self.formatter.usesGroupingSeparator = true
        setupBadgeViewWithString("0")
    }
    
    public func initWithFrame(frame: CGRect, withBadgeString badgeString: String, withBadgeInsets badgeInsets: UIEdgeInsets) -> AnyObject {
        badgeLabel = UILabel()
        badgeEdgeInsets = badgeInsets
        self.formatter.groupingSeparator = ","
        self.formatter.usesGroupingSeparator = true
        setupBadgeViewWithString(badgeString)
        return self
    }
    
    public func increment() {
        badgeString += 1
    }
    
    // MARK: - Visibility
    
    func show() {
        self.badgeLabel.hidden = false
        let SpringVelocity: CGFloat = 8.0
        let Damping: CGFloat = 0.2
        let Duration: Double = 0.15
        UIView.animateWithDuration(Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: -1)
            }, completion: { _ in
                UIView.animateWithDuration(Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.CurveLinear, animations: {
                    self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: 2)
                    }, completion: { _ in
                        UIView.animateWithDuration(Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.CurveLinear, animations: {
                            self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: -1)
                            }, completion: nil)
                })
        })
    }
    
    func hide() {
        let SpringVelocity: CGFloat = 8.0
        let Damping: CGFloat = 0.2
        let Duration: Double = 0.05
        UIView.animateWithDuration(Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: -1)
            }, completion: { _ in
                UIView.animateWithDuration(Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.CurveLinear, animations: {
                    self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: 2)
                    }, completion: { _ in
                        UIView.animateWithDuration(Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.CurveLinear, animations: {
                            self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: -1)
                            }, completion: { _ in
                                self.badgeLabel.hidden = true
                        })
                })
        })
    }
    
    private func setupBadgeViewWithString(badgeText: String?) {
        badgeLabel.clipsToBounds = true
        badgeLabel.text = badgeText
        badgeLabel.hidden = true
        badgeLabel.font = UIFont(name: "AmericanTypewriter-Semibold", size: 12)!
        badgeLabel.textAlignment = .Center
        badgeLabel.sizeToFit()
        let badgeSize = badgeLabel.frame.size
        let height = max(20, Double(badgeSize.height) + 5.0)
        let width = max(height, Double(badgeSize.width) + 10.0)
        var vertical: Double?, horizontal: Double?
        if let badgeInset = self.badgeEdgeInsets {
            vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
            horizontal = Double(badgeInset.left) - Double(badgeInset.right)
            let x = (Double(bounds.size.width) - 10 + horizontal!)
            let y = -(Double(badgeSize.height) / 2) - 10 + vertical!
            badgeLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        } else {
            let x = CGRectGetWidth(self.frame) - CGFloat((width / 2.0))
            let y = CGFloat(-(height / 2.0))
            badgeLabel.frame = CGRectMake(x, y, CGFloat(width), CGFloat(height))
        }
        setupBadgeStyle()
        addSubview(badgeLabel)
        badgeLabel.text == "0" ? hide() : show()
    }
    
    private func setupBadgeStyle() {
        badgeLabel.textAlignment = .Center
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.textColor = badgeTextColor
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.size.height / 2
        badgeLabel.layer.borderWidth = 1.0
        badgeLabel.layer.borderColor = UIColor.whiteColor().CGColor
    }
}


// MARK: - ImageTextField

@IBDesignable class ImageTextField: UITextField {
    
    private var ImgIcon: UIImageView?
    
    @IBInspectable var errorEntry: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var leftTextPedding: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var lineColor: UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var placeHolerColor: UIColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0) {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var errorColor: UIColor = UIColor.redColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var imageWidth: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var txtImage : UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }

    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    private func newBounds(bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += CGFloat(leftTextPedding) + CGFloat(imageWidth)
        return newBounds
    }
    
    var errorMessage: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //setting left image
        if (txtImage != nil) {
            let imgView = UIImageView(image: txtImage)
            imgView.frame = CGRectMake(0, 0, CGFloat(imageWidth), self.frame.height)
            imgView.contentMode = .Center
            self.leftViewMode = UITextFieldViewMode.Always
            self.leftView = imgView
        }
    }
    
    override func drawRect(rect: CGRect) {
        let height = self.bounds.height
        // get the current drawing context
        let context = UIGraphicsGetCurrentContext()
        
        // set the line color and width
        if errorEntry {
            CGContextSetStrokeColorWithColor(context!, errorColor.CGColor)
            CGContextSetLineWidth(context!, 1.5)
        } else {
            CGContextSetStrokeColorWithColor(context!, lineColor.CGColor)
            CGContextSetLineWidth(context!, 0.5)
        }
        // start a new Path
        CGContextBeginPath(context!)
        CGContextMoveToPoint(context!, self.bounds.origin.x, height - 0.5)
        CGContextAddLineToPoint(context!, self.bounds.size.width, height - 0.5)
        // close and stroke (draw) it
        CGContextClosePath(context!)
        CGContextStrokePath(context!)
        //Setting custom placeholder color
        if let strPlaceHolder: String = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string:strPlaceHolder, attributes:[NSForegroundColorAttributeName:placeHolerColor])
        }
    }
    
    override func leftViewRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(0, 0, CGFloat(imageWidth), self.frame.height)
    }
}

// MARK: - CLLocationCoordinate2D

extension CLLocationCoordinate2D {
    func isEqualTo(location: CLLocationCoordinate2D) -> Bool {
        return (self.latitude == location.latitude && self.longitude == location.longitude)
    }
}

// MARK: - NSDate

extension NSDate : Comparable {}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}


extension NSDate {
    
    /// Returns the amount of years from another date
    func years(from date: NSDate) -> CGFloat {
        return CGFloat(NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: date, toDate: self, options: []).year) ?? 0
    }
    
    /// Returns the amount of months from another date
    func months(from date: NSDate) -> CGFloat {
        return CGFloat(NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: date, toDate: self, options: []).month) ?? 0
    }
    
    /// Returns the amount of weeks from another date
    func weeks(from date: NSDate) -> CGFloat {
        if CGFloat(self.timeIntervalSinceDate(date) / 604800) < 0 {
            return CGFloat(self.timeIntervalSinceDate(date) / 604800) * -1
        }
        return CGFloat(self.timeIntervalSinceDate(date) / 604800)
    }
    
    /// Returns the amount of days from another date
    func days(from date: NSDate) -> CGFloat {
        if CGFloat(self.timeIntervalSinceDate(date) / 86400) < 0 {
            return CGFloat(self.timeIntervalSinceDate(date) / 86400) * -1
        }
        return CGFloat(self.timeIntervalSinceDate(date) / 86400)
    }
    
    /// Returns the amount of hours from another date
    func hours(from date: NSDate) -> CGFloat {
        if CGFloat(self.timeIntervalSinceDate(date) / 3600) < 0 {
            return CGFloat(self.timeIntervalSinceDate(date) / 3600) * -1
        }
        return CGFloat(self.timeIntervalSinceDate(date) / 3600)
    }
    
    /// Returns the amount of minutes from another date
    func minutes(from date: NSDate) -> CGFloat {
        if CGFloat(self.timeIntervalSinceDate(date) / 60) < 0 {
            return CGFloat(self.timeIntervalSinceDate(date) / 60) * -1
        }
        return CGFloat(self.timeIntervalSinceDate(date) / 60)
    }
    
    /// Returns the amount of seconds from another date
    func seconds(from date: NSDate) -> CGFloat {
        if self.timeIntervalSinceDate(date) < 0 {
            return CGFloat(self.timeIntervalSinceDate(date)) * -1
        }
        return CGFloat(self.timeIntervalSinceDate(date))
    }
    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        return isGreater
    }

    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        var isLess = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        return isLess
    }

    func equalToDate(dateToCompare: NSDate) -> Bool {
        var isEqualTo = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        return isEqualTo
    }

    var formatted:String {
        let formatter = NSDateFormatter()
        formatter.AMSymbol = "AM"
        formatter.PMSymbol = "PM"
        let cal: NSCalendar = NSCalendar.currentCalendar()
        if cal.isDateInToday(self) {
            formatter.dateFormat = "h"
        } else {
            formatter.dateFormat = "M/d h"
        }
        return formatter.stringFromDate(self)
    }

    func formattedWith(format:String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
    class func daysAgo(days: Int) -> NSDate {
        return NSDate(timeIntervalSinceNow: NSTimeInterval(days * 86400))
    }
}



// MARK: - UITableViewCell

extension UITableViewCell {
    func GradCellLayer() {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.frame = frame
        let color1 = UIColor.charcoalColor().changeAlpha(0.4).CGColor as CGColorRef
        let color2 = UIColor.charcoalColor().lightenedColor(0.2).changeAlpha(0.4).CGColor as CGColorRef
        let color3 = UIColor.charcoalColor().lightenedColor(0.5).changeAlpha(0.4).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color2, color1]
        gradientLayer.locations = [0.0, 0.15, 0.5, 0.85, 1.0]
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
}

// MARK: - UIView


extension UITextField {
    func addDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(self.PressedDone))
        doneButton.tintColor = UIColor.blackColor()
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        self.inputAccessoryView = toolBar
    }
    
    func PressedDone() {
        self.resignFirstResponder()
    }
}

extension UITextView {
    func addDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(self.PressedDone))
        doneButton.tintColor = UIColor.blackColor()
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        self.inputAccessoryView = toolBar
    }
    
    func PressedDone() {
        self.resignFirstResponder()
    }
}

extension UIView {
    
    func getRects() -> [CGRect] {
        var rockframe: CGRect!
        var paperframe: CGRect!
        var scissorsframe: CGRect!
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            let widther: CGFloat = (self.bounds.width / 3.0) - 6.0
            rockframe = CGRect(x: 3, y: self.bounds.height - (widther + 5), width: widther, height: widther)
            paperframe = CGRect(x: rockframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
            scissorsframe = CGRect(x: paperframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            let widther: CGFloat = (self.bounds.width / 3.0) - 6.0
            rockframe = CGRect(x: 3, y: self.bounds.height - (widther + 5), width: widther, height: widther)
            paperframe = CGRect(x: rockframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
            scissorsframe = CGRect(x: paperframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
        } else {
            let widther: CGFloat = (self.bounds.width / 3.5) - 6.0
            rockframe = CGRect(x: 10, y: self.bounds.height - (widther + 5), width: widther, height: widther)
            paperframe = CGRect(x: self.bounds.midX - (widther / 2), y: rockframe.minY, width: widther, height: widther)
            scissorsframe = CGRect(x: self.bounds.maxX - (widther + 10), y: rockframe.minY, width: widther, height: widther)
        }
        return [rockframe,paperframe,scissorsframe]
    }
    
    func addblur(color: UIColor) {
        let visualEffectView = VisualEffectView(frame: self.frame)
        visualEffectView.colorTint = color
        visualEffectView.colorTintAlpha = 0.9
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        self.addSubview(visualEffectView)
    }
    
    func removeBlur() {
        for sub in subviews {
            if sub is VisualEffectView {
                sub.removeFromSuperview()
            }
        }
    }
    
    func addBlur(color: UIColor, below: UIView) {
        let visualEffectView = VisualEffectView(frame: self.frame)
        visualEffectView.colorTint = color
        visualEffectView.colorTintAlpha = 0.9
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        self.insertSubview(visualEffectView, belowSubview: below)
    }
    
    func addborder() {
        self.layer.cornerRadius = 8.0
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = true
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth
    }
    
    func removeGestures() {
        for recognizer in self.gestureRecognizers! {
            self.removeGestureRecognizer(recognizer)
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return layer.borderColor != nil ? UIColor(CGColor: layer.borderColor!) : UIColor.clearColor()
        }
        set {
            layer.borderColor = newValue.CGColor
            layer.masksToBounds = true
        }
    }
    
    func GradLayer() {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.frame = frame
        let color1 = AppConfiguration.startingColor.lightenedColor(0.4).CGColor
        let color2 = AppConfiguration.startingColor.darkenedColor(0.2).CGColor
        let color3 = AppConfiguration.startingColor.darkenedColor(0.4).CGColor
        gradientLayer.colors = [color1, color2, color3, color2, color1]
        gradientLayer.locations = [0.0, 0.3, 0.5, 0.7, 1.0]
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func addBlur() {
        let visualEffectView = VisualEffectView(frame: self.frame)
        visualEffectView.colorTint = .whiteColor()
        visualEffectView.colorTintAlpha = 0.2
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        self.addSubview(visualEffectView)
    }
    
    typealias SpinClosure = (Void) -> Void
    
    func spin(complete: SpinClosure?) {
        let rotationAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = -M_PI
        rotationAnimation.duration = 0.5
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
        UIView.animateWithDuration(0.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            inviteRequestsbutton.tintColor = inviteRequestsbutton.tintColor == UIColor.whiteColor() ? UIColor.waveColor() : UIColor.whiteColor()
            }, completion: {_ in
                if complete != nil {
                    complete!()
                }
        })
    }
    
    /*
    func getColors(color: UIColor) {
        let grads = UIColor(gradientStyle: UIGradientStyle.TopToBottom, withFrame: self.frame, andColors: [color])
        //(gradientStyle:UIGradientStyle, withFrame:CGRect, andColors:[UIColor])
        //let color = GradientColor(UIGradientStyle.TopToBottom, frame: self.frame, colors: [color])
        //print("Gradient: \(grads)")
        //print("Colors: \(color)")
        //backgroundColor = grads
    }*/
}

// MARK: - GradientButton

class GradientButton: UIButton {
    
    private let Grads: [String: [UIColor]] = [
        "blackGrad": [UIColor(red: 0.154, green: 0.154, blue: 0.154, alpha: 1.0),UIColor(red: 0.307, green: 0.307, blue: 0.307, alpha: 1.0),UIColor(red: 0.166, green: 0.166, blue: 0.166, alpha: 1.0),UIColor(red: 0.118, green: 0.118, blue: 0.118, alpha: 1.0)],
        "greenGrad" : [UIColor(red: 0.15, green: 0.667, blue: 0.152, alpha: 1.0),UIColor(red: 0.566, green: 0.841, blue: 0.566, alpha: 1.0),UIColor(red: 0.341, green: 0.75, blue: 0.345, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0)],
        "redGrad" : [UIColor(red: 0.667, green: 0.15, blue: 0.152, alpha: 1.0),UIColor(red: 0.841, green: 0.566, blue: 0.566, alpha: 1.0),UIColor(red: 0.75, green: 0.341, blue: 0.345, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0)],
        "blackHighlighted" : [UIColor(red: 0.199, green: 0.199, blue: 0.199, alpha: 1.0),UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1.0),UIColor(red: 0.074, green: 0.074, blue: 0.074, alpha: 1.0),UIColor(red: 0.112, green: 0.112, blue: 0.112, alpha: 1.0)],
        "redHighlighted" : [UIColor(red: 0.467, green: 0.009, blue: 0.005, alpha: 1.0),UIColor(red: 0.754, green: 0.562, blue: 0.562, alpha: 1.0),UIColor(red: 0.543, green: 0.212, blue: 0.212, alpha: 1.0),UIColor(red: 0.5, green: 0.153, blue: 0.152, alpha: 1.0),UIColor(red: 0.388, green: 0.004, blue: 0.0, alpha: 1.0)],
        "greenHighlighted" : [UIColor(red: 0.009, green: 0.467, blue: 0.005, alpha: 1.0),UIColor(red: 0.562, green: 0.754, blue: 0.562, alpha: 1.0),UIColor(red: 0.212, green: 0.543, blue: 0.212, alpha: 1.0),UIColor(red: 0.153, green: 0.5, blue: 0.152, alpha: 1.0),UIColor(red: 0.004, green: 0.388, blue: 0.0, alpha: 1.0)],
        "loginHighlighted" : [UIColor(red: 0.15, green: 0.667, blue: 0.152, alpha: 1.0),UIColor(red: 0.566, green: 0.841, blue: 0.566, alpha: 1.0),UIColor(red: 0.341, green: 0.75, blue: 0.345, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0)],
        "loginGrad" : [UIColor(red: 0.667, green: 0.15, blue: 0.152, alpha: 1.0),UIColor(red: 0.841, green: 0.566, blue: 0.566, alpha: 1.0),UIColor(red: 0.75, green: 0.341, blue: 0.345, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0)],
        "blueGrad" : [UIColor(red: 0.152, green: 0.15, blue: 0.667, alpha: 1.0),UIColor(red: 0.566, green: 0.566, blue: 0.841, alpha: 1.0),UIColor(red: 0.345, green: 0.341, blue: 0.75, alpha: 1.0),UIColor(red: 0.0, green: 0.0, blue: 0.592, alpha: 1.0),UIColor(red: 0.0, green: 0.0, blue: 0.592, alpha: 1.0)],
        "blueHighlighted" : [UIColor(red: 0.005, green: 0.009, blue: 0.467, alpha: 1.0),UIColor(red: 0.562, green: 0.562, blue: 0.754, alpha: 1.0),UIColor(red: 0.212, green: 0.212, blue: 0.543, alpha: 1.0),UIColor(red: 0.152, green: 0.153, blue: 0.5, alpha: 1.0),UIColor(red: 0.0, green: 0.004, blue: 0.388, alpha: 1.0)]
    ]
    
    typealias GradientClosure = (Void) -> Void
    
    var normalGradientLocations: [CGFloat] = [0.0,1.0,0.548,0.462]
    var normalGradients:[UIColor] = [UIColor(red: 0.154, green: 0.154, blue: 0.154, alpha: 1.0),UIColor(red: 0.307, green: 0.307, blue: 0.307, alpha: 1.0),UIColor(red: 0.166, green: 0.166, blue: 0.166, alpha: 1.0),UIColor(red: 0.118, green: 0.118, blue: 0.118, alpha: 1.0)] {
        didSet {
            normalGradientLocations = normalGradients.count == 4 ? [0.0,1.0,0.548,0.462] : [0.0,1.0,0.582,0.418,0.346]
            setNeedsLayout()
        }
    }
    private var selectedColors: String = "blackGrad" {
        didSet {
            normalGradients = Grads[selectedColors]!
        }
    }

    func toggleAnimation(completion: GradientClosure) {
        self.selected = !self.selected
        self.delay(0.2, closure: {
            self.selected = !self.selected
            completion()
        })
    }
    
    override var selected: Bool {
        didSet {
            var oppositeColor: String = selectedColors
            if oppositeColor.hasSuffix("Highlighted") {
                let range = oppositeColor.endIndex.advancedBy(-"Highlighted".characters.count)..<oppositeColor.endIndex
                oppositeColor.removeRange(range)
                oppositeColor += "Grad"
            } else {
                let range = oppositeColor.endIndex.advancedBy(-"Grad".characters.count)..<oppositeColor.endIndex
                oppositeColor.removeRange(range)
                oppositeColor += "Highlighted"
            }
            selectedColors = oppositeColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        tintColor = UIColor.clearColor()
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        layer.borderWidth = 2.0
        layer.backgroundColor = UIColor.clearColor().CGColor
        layer.borderColor = UIColor.whiteColor().CGColor
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        setTitleColor(UIColor.whiteColor(), forState: .Selected)
        useBlackStyle()
    }
    
    func useLoginStyle() {
        selectedColors = "loginGrad"
    }
    
    func useBlackStyle() {
        selectedColors = "blackGrad"
    }
    
    func useRedStyle() {
        selectedColors = "redGrad"
    }
    
    func useBlueStyle() {
        selectedColors = "blueGrad"
    }
    
    func useGreenStyle() {
        selectedColors = "greenGrad"
    }
    
    override func drawRect(rect: CGRect) {
        let startPoint = CGPoint(x:(self.bounds.size.width / 2.0), y:self.bounds.size.height - 0.5)
        let endPoint = CGPoint(x:(self.bounds.size.width / 2.0), y:0.0)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var cgcolors: [CGColor] = [CGColor]()
        self.normalGradients.forEach { (color) in
            cgcolors.append(color.CGColor)
        }
        let gradient = CGGradientCreateWithColors(colorSpace, cgcolors, self.normalGradientLocations)
        CGContextDrawLinearGradient(context!, gradient!, startPoint, endPoint, CGGradientDrawingOptions.DrawsBeforeStartLocation)
    }
    
}


// MARK: - UIResponder

extension UIResponder {
    
   
    
    func getParentViewController() -> UIViewController? {
        if self.nextResponder() is UIViewController {
            return self.nextResponder() as? UIViewController
        } else {
            if self.nextResponder() != nil {
                return (self.nextResponder()!).getParentViewController()
            }
            else {return nil}
        }
    }
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
    typealias NavPushClosure = (UIViewController) -> Void
    
    func NavPush(name: String, completion: NavPushClosure?) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(name)
        sideMenuNavigationController!.pushViewController(viewController, animated: true)
        if completion != nil {
            completion!(viewController)
        }
    }
    
    /*typealias MessagePushClosure = (MurphMessageController) -> Void
    
    func MessagePush(completion: MessagePushClosure?) {
        let viewController: MurphMessageController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MurphMessageController") as! MurphMessageController
        sideMenuNavigationController!.pushViewController(viewController, animated: true)
        if completion != nil {
            completion!(viewController)
        }
    }*/
    
    func goToLobby() {
        appDelegate.window?.rootViewController = kConstantObj.SetIntialMainViewController("Lobby")
    }
}


public class VisualEffectView: UIVisualEffectView {
    
    let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    /// Tint color.
    public var colorTint: UIColor {
        get { return _valueForKey("colorTint") as! UIColor }
        set { _setValue(newValue, forKey: "colorTint") }
    }
    
    /// Tint color alpha.
    public var colorTintAlpha: CGFloat {
        get { return _valueForKey("colorTintAlpha") as! CGFloat }
        set { _setValue(newValue as AnyObject?, forKey: "colorTintAlpha") }
    }
    
    /// Blur radius.
    public var blurRadius: CGFloat {
        get { return _valueForKey("blurRadius") as! CGFloat }
        set { _setValue(newValue as AnyObject?, forKey: "blurRadius") }
    }
    
    /// Scale factor.
    public var scale: CGFloat {
        get { return _valueForKey("scale") as! CGFloat }
        set { _setValue(newValue as AnyObject?, forKey: "scale") }
    }
    
    func _valueForKey(key: String) -> Any? {
        return blurEffect.valueForKeyPath(key)
    }
    
    func _setValue(value: AnyObject?, forKey key: String) {
        blurEffect.setValue(value, forKeyPath: key)
        self.effect = blurEffect
    }
    
}



// MARK: - UIColor

extension UIColor{
    class func colorWithHex(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var rgb: CUnsignedInt = 0;
        let scanner = NSScanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        scanner.scanHexInt(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0xFF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /*
     
     
     //primary 0.667 -> 0.467 , 0.841 -> 0.754 , 0.75 -> 0.543 , 0.592 -> 0.5 , 0.592 -> 0.388
     
     //secondary 0.152 -> 0.005 , 0.566 -> 0.562 , 0.345 -> 0.212 , 0.0 -> 0.152 , 0.0 -> 0.0
     
     //last 0.15 -> 0.009 , 0.566 -> 0.562 , 0.341 -> 0.212 , 0.0 -> 0.153 , 0.0 -> 0.004
     
     //let grads = UIColor(gradientStyle: UIGradientStyle.TopToBottom, withFrame: self.frame, andColors: [])
     //(gradientStyle:UIGradientStyle, withFrame:CGRect, andColors:[UIColor])
     //let color = GradientColor(gradientStyle, frame, colors)
     
     
     //lastGrad + 0.013 , + 0.013 , - 0.208 , - 0.553
     //secondGrad + 0.416 , + 0.191 , - 0.15 , - 0.15
     //primaryGrad + 0.174 , + 0.083 , - 0.075 , - 0.075
     
     //red: 0.553,0.566,0.566,0.345,0.0
     //green: 0.15,0.566,0.341,0.0,0.0
     //blue: 0.667,0.841,0.75,0.592,0.592
     
     //etGlobalThemeUsingPrimaryColor:(UIColor *)color withContentStyle:(UIContentStyle)contentStyle];
     
     //primary 0.667 -> 0.841 -> 0.75 -> 0.592 -> 0.592
     //primary 0.467 -> 0.754 -> 0.543 -> 0.5 -> 0.388
     
     //UIColor(red: red, green: green, blue: blue  , alpha: 1.0).CGColor
     
     
     UIColor(red: 0.553, green: 0.855, blue: 0.969, alpha: 1.0).CGColor
     UIColor(red: 0.566, green: 0.855, blue: 0.969, alpha: 1.0).CGColor
     UIColor(red: 0.553, green: 0.855, blue: 0.969, alpha: 1.0).CGColor
     UIColor(red: 0.553, green: 0.855, blue: 0.969, alpha: 1.0).CGColor
     UIColor(red: 0.553, green: 0.855, blue: 0.969, alpha: 1.0).CGColor
     
     UIColor(red: 0.412, green: 0.855, blue: 0.969, alpha: 1.0).CGColor
     UIColor(red: 0.549, green: 0.855, blue: 0.969, alpha: 1.0).CGColor
     UIColor(red: 0.553, green: 0.855, blue: 0.969, alpha: 1.0).CGColor
     UIColor(red: 0.553, green: 0.855, blue: 0.969, alpha: 1.0).CGColor
     UIColor(red: 0.553, green: 0.855, blue: 0.969, alpha: 1.0).CGColor
     
     //highlighted difference
     //primary - 0.2 ,primary - 0.087 ,primary - 0.207 ,primary - 0.092 ,primary - 0.204
     
     //secondary - 0.147 ,secondary - 0.004 ,secondary - 0.133 ,secondary + 0.152 , secondary
     
     //last - 0.141 ,last - 0.004 ,last - 0.129 ,last + 0.153 ,last + 0.004
     
     func colorGrad() -> [UIColor] {
     let red = self.red()
     let green = self.green()
     let blue = self.blue()
     var gradColors: [UIColor] = [UIColor]()
     var highlightedColor: [UIColor] = [UIColor]()
     var primary: CGFloat = 0.0
     var secondary: CGFloat = 0.0
     var last: CGFloat = 0.0
     var order = "RGB"
     if red > green && red > blue {
     if green > blue {
     order = "RGB"
     primary = red
     secondary = green
     last = blue
     } else {
     order = "RBG"
     primary = red
     secondary = blue
     last = green
     }
     } else if green > red && green > blue {
     if red > blue {
     order = "GRB"
     primary = green
     secondary = red
     last = blue
     } else {
     order = "GBR"
     primary = green
     secondary = blue
     last = red
     }
     } else if blue > red && green < blue {
     if green > red {
     order = "BGR"
     primary = blue
     secondary = green
     last = red
     } else {
     order = "BRG"
     primary = blue
     secondary = red
     last = green
     }
     }
     for i in 0..<5 {
     switch i {
     case 0: gradColors.append(self.colors(primary, secondary: secondary, last: last, order: order))
     case 1: gradColors.append(self.colors(primary + 0.174, secondary: secondary + 0.416, last: last + 0.013, order: order))
     case 2: gradColors.append(self.colors(primary + 0.083, secondary: secondary + 0.191, last: last + 0.013, order: order))
     case 3: gradColors.append(self.colors(primary - 0.075, secondary: secondary - 0.15, last: last - 0.208, order: order))
     case 4: gradColors.append(self.colors(primary - 0.075, secondary: secondary - 0.15, last: last - 0.553, order: order))
     default: gradColors.append(self.colors(primary, secondary: secondary, last: last, order: order))
     }
     }
     return gradColors
     /*for i in 0..<gradColors.count {
     switch i {
     case 0:
     let color = gradColors[0]
     highlightedColor.append(self.colors(color.red() - 0.2, secondary: secondary + 0.416, last: last + 0.013, order: order))
     case 1: gradColors.append(self.colors(primary + 0.174, secondary: secondary + 0.416, last: last + 0.013, order: order))
     case 2: gradColors.append(self.colors(primary + 0.083, secondary: secondary + 0.191, last: last + 0.013, order: order))
     case 3: gradColors.append(self.colors(primary - 0.075, secondary: secondary - 0.15, last: last - 0.208, order: order))
     case 4: gradColors.append(self.colors(primary - 0.075, secondary: secondary - 0.15, last: last - 0.553, order: order))
     }
     }*/
     }
     
     func colors(primary: CGFloat, secondary: CGFloat, last: CGFloat, order: String) -> UIColor {
     switch order {
     case "RGB": return UIColor(red: primary, green: secondary, blue: last, alpha: 1.0)//.CGColor
     case "RBG": return UIColor(red: primary, green: last, blue: secondary, alpha: 1.0)//.CGColor
     case "GRB": return UIColor(red: secondary, green: primary, blue: last, alpha: 1.0)//.CGColor
     case "GBR": return UIColor(red: last, green: primary, blue: secondary, alpha: 1.0)//.CGColor
     case "BGR": return UIColor(red: last, green: secondary, blue: primary, alpha: 1.0)//.CGColor
     case "BRG": return UIColor(red: secondary, green: last, blue: primary, alpha: 1.0)//.CGColor
     default: return UIColor(red: primary, green: secondary, blue: last, alpha: 1.0)//.CGColor
     }
     }*/
}



