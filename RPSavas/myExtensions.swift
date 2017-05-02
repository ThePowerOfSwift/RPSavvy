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


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

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

let hambutton: MIBadgeButton = MIBadgeButton(type: .custom)

// MARK: - UIViewController
var prevOffset: CGFloat?


extension UIViewController {
    
    
    func addKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name(rawValue: "UIKeyboardWillShow"), object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name(rawValue: "UIKeyboardWillHide"), object: self.view.window)
    }
    
    func removeKeyboard() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "UIKeyboardWillShow"), object: self.view.window)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "UIKeyboardWillHide"), object: self.view.window)
        prevOffset = nil
    }
    
    func keyboardWillHide(_ sender: Notification) {
        let userInfo: [AnyHashable: Any] = (sender as Notification).userInfo!
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
        self.view.frame.origin.y += keyboardSize.height
        prevOffset = nil
    }
    
    func keyboardWillShow(_ sender: Notification) {
        let userInfo: [AnyHashable: Any] = (sender as Notification).userInfo!
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
        let offset: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        if prevOffset == nil {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y -= keyboardSize.height
                prevOffset = keyboardSize.height
            })
        } else {
            if prevOffset > offset.height {
                let newOffset = (prevOffset! - offset.height)
                prevOffset = newOffset
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.view.frame.origin.y += newOffset
                })
            } else {
                let newOffset = (offset.height - prevOffset!)
                prevOffset = newOffset
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= newOffset
                })
            }
        }
    }
    
    func hideBackButton() {
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil), animated: false)
    }
    
    func photoButtonPressed(_ sender: UITapGestureRecognizer) {
        let alertVC = UIAlertController(title: "Upload New Profile Picture", message: "How would you like to upload your photo?", preferredStyle: UIAlertControllerStyle.actionSheet)
        let Take = UIAlertAction(title: "Take Picture", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in
            Camera.shouldStartCamera(self, canEdit: true, frontFacing: true)
        }
        let Lib = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in
            Camera.shouldStartPhotoLibrary(self, canEdit: true)
        }
        let Cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (UIAlertAction) -> Void in}
        alertVC.addAction(Take)
        alertVC.addAction(Lib)
        alertVC.addAction(Cancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func addLogOut() {
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.tappedLogout)), animated: false)
    }
    
    func tappedLogout() {
        PFUser.logOut()
        sideMenuNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LobbyNAV") as? UINavigationController
        appDelegate.window?.rootViewController = sideMenuNavigationController
    }
    
    func addBackButton() {
        self.navigationItem.setLeftBarButton(UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.tappedBack)), animated: false)
    }
    
    
    func tappedBack() {
        sideMenuNavigationController!.popViewController(animated: true)
    }
    
    func addHamMenu() {
        hambutton.frame = CGRect(x:0,y:0,width:sideMenuNavigationController!.navigationBar.frame.height,height:sideMenuNavigationController!.navigationBar.frame.height)
        hambutton.badgeTextColor = UIColor.white
        hambutton.badgeBackgroundColor = UIColor.red
        hambutton.badgeEdgeInsets = UIEdgeInsetsMake(15, 0, 0, 10)
        hambutton.setImage(UIImage(named: "MenuIcon")!, for: UIControlState())
        hambutton.tintColor = .white
        hambutton.addTarget(self, action:  #selector(self.tappedMenu), for: .touchUpInside)
        let menuButton: UIBarButtonItem = UIBarButtonItem(customView: hambutton)
        menuButton.tintColor = UIColor.white
        self.navigationItem.setRightBarButton(menuButton, animated: true)
    }
    
    func tappedMenu() {
        hambutton.badgeString = 0
        sideMenuVC.toggleMenu()
    }
    
    func addGradLayer() {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        gradientLayer.frame = frame
        let color1 = UIColor.black.cgColor as CGColor
        gradientLayer.colors = [color1, AppConfiguration.scheme[2], AppConfiguration.scheme[2], AppConfiguration.scheme[2], color1]
        gradientLayer.locations = [0.0, 0.3, 0.5, 0.7, 1.0]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addSwipers() {
        let swiper:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.showMenu))
        swiper.direction = .left
        self.view.addGestureRecognizer(swiper)
        let swiper2:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissMenu))
        swiper2.direction = .right
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
    
    
    func imageWithString(_ word: String, color: UIColor? = nil, circular: Bool = true, fontAttributes: [String : AnyObject]? = nil){
        imageSnapShotFromWords(word.getInitials(), color: color, circular: circular, fontAttributes: fontAttributes)
    }
    
    func imageSnapShotFromWords(_ snapShotString: String, color: UIColor?, circular: Bool, fontAttributes: [String : AnyObject]?) {
        let attributes: [String : AnyObject]
        if let attr = fontAttributes {
            attributes = attr
        } else {
            attributes = [NSForegroundColorAttributeName : UIColor.white,  NSFontAttributeName : UIFont(name: "AmericanTypewriter-Semibold", size:  self.bounds.width * 0.4)!]
        }
        let imageBackgroundColor: UIColor
        if let color = color {
            imageBackgroundColor = color
        } else {
            imageBackgroundColor = .gray
        }
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        if circular {
            self.layer.cornerRadius = self.frame.width/2
        } else {
            self.layer.cornerRadius = 8.0
        }
        self.clipsToBounds = true
        context!.setFillColor(red: imageBackgroundColor.red(), green: imageBackgroundColor.green(), blue: imageBackgroundColor.blue(), alpha: 1.0)
        context!.fill(CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        let textSize = NSString(string: snapShotString).size(attributes: attributes)
        NSString(string: snapShotString).draw(in: CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height), withAttributes: attributes)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.image = image
    }
    
    func setPic(_ user: PFUser, completion: UserSettingClosure?) {
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 2.0
        self.tintColor = AppConfiguration.navText
        self.layer.borderColor = UIColor.clear.cgColor
        self.contentMode = .scaleAspectFill
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.masksToBounds = true
        if user["picture"] != nil {
            self.file = user["picture"] as? PFFile
            self.loadInBackground()
        } else {
            if user["fullname"] != nil {
                self.imageWithString(PFUser.current()!["fullname"] as! String, color: .charcoalColor(), circular: true, fontAttributes: nil)
            } else {
                self.imageWithString("R P S", color: .charcoalColor(), circular: true, fontAttributes: nil)
            }
        }
        if completion != nil {
            completion!()
        }
    }
    
    func setProfPic(_ color: UIColor?, completion: UserSettingClosure?) {
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 2.0
        self.tintColor = AppConfiguration.navText
        self.layer.borderColor = UIColor.clear.cgColor
        self.contentMode = .scaleAspectFill
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = color != nil ? color!.cgColor : UIColor.white.cgColor
        self.layer.masksToBounds = true
        if  PFUser.current() != nil {
            if PFUser.current()!["picture"] != nil {
                self.file = PFUser.current()!["picture"] as? PFFile
                self.load(inBackground: { (image, error) in
                    if image == nil {
                        print("Got Image")
                        self.imageWithString(PFUser.current()!["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
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
                userQuery?.getObjectInBackground(withId: PFUser.current()!.objectId!, block: { (object, error) in
                    if error == nil {
                        self.file = PFUser.current()!["picture"] as? PFFile
                        self.load(inBackground: { (image, error) in
                            if image == nil {
                                print("Got Image 2")
                                self.imageWithString(PFUser.current()!["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
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
        if  PFUser.current() != nil {
            self.file = PFUser.current()!.profPic
            self.loadInBackground()
        }
        self.layer.cornerRadius = (self.frame.height) / 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 4.0
    }
    
    func setProfPicOfUser(_ user: PFUser) {
        self.file = user.profPic
        self.loadInBackground()
        self.layer.cornerRadius = (self.frame.height) / 2
        self.tintColor = AppConfiguration.navText
        self.layer.borderColor = AppConfiguration.navText.cgColor
        self.layer.borderWidth = 4.0
        self.contentMode = .scaleAspectFill
        self.backgroundColor = UIColor.clear
        self.layer.masksToBounds = true
    }
    
    typealias UserSettingClosure = (Void) -> Void
    
    func setProfPic(_ user: PFUser, color: UIColor?, completion: UserSettingClosure?) {
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 2.0
        self.tintColor = AppConfiguration.navText
        self.layer.borderColor = UIColor.clear.cgColor
        self.contentMode = .scaleAspectFill
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = color != nil ? color!.cgColor : UIColor.white.cgColor
        self.layer.masksToBounds = true
        if user["fullname"] != nil {
            self.imageWithString(user["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
        }
        if user["picture"] != nil {
            self.file = user["picture"] as? PFFile
            self.load(inBackground: { (image, error) in
                if image == nil {
                    if user["fullname"] == nil {
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
            userQuery?.getObjectInBackground(withId: user.objectId!, block: { (object, error) in
                if error == nil {
                    if object!["picture"] != nil {
                        self.file = object!["picture"] as? PFFile
                        self.load(inBackground: { (image, error) in
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
            let textSize = self.text!.size(attributes: [NSFontAttributeName:self.font!])
            let widthCheck: CGFloat = (UIScreen.main.bounds.width <= 320) ? 201.5 : 256
            if widthCheck <= CGFloat(textSize.width) {
                let fontSize = self.font.pointSize - 1.0
                self.font = UIFont(name: self.font.fontName, size: fontSize)!
                self.setNeedsLayout()
                self.resizeFont()
            }
        }
    }
    
    func Fullname(_ user: PFUser, color: UIColor?) {
        self.font = (UIScreen.main.bounds.width <= 320) ? UIFont(name: "AmericanTypewriter", size: 25.0)! : UIFont(name: "AmericanTypewriter", size: 35.0)!
        if color != nil {
            self.textColor = color!
        } else {
            self.textColor = UIColor.white
        }
        self.adjustsFontSizeToFitWidth = true
        if user["fullname"] != nil {
            self.text = user["fullname"] as? String ?? ""
        } else {
            let userQuery = PFUser.query()
            userQuery?.cachePolicy = AppConfiguration.cachePolicy
            userQuery?.maxCacheAge = 3600
            userQuery?.getObjectInBackground(withId: user.objectId!, block: { (object, error) in
                if error == nil {
                    self.text = object!["fullname"] as? String ?? ""
                }
            })
        }
    }
    
    
    func evaporate(_ newText: String) {
        let originalFrame = self.frame
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.frame = self.frame.offsetBy(dx: 0, dy: -self.frame.height / 2)
            self.alpha = 0.0
        }) { (success) in
            self.frame = self.frame.offsetBy(dx: 0, dy: self.frame.height + (self.frame.height / 2))
            self.text = newText
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.frame = originalFrame
                self.alpha = 1.0
                }, completion: nil)
        }
    }
    
    func evap(_ newText: String) {
        let originalFrame = self.frame
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.frame = self.frame.offsetBy(dx: 0, dy: -self.frame.height / 4)
            self.alpha = 0.0
        }) { (success) in
            self.frame = self.frame.offsetBy(dx: 0, dy: self.frame.height / 2)
            self.text = newText
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
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
            layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
            rects.append(layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer))
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
            layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
            rectWidth = rectWidth + layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer).width
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
    
    
    func imageWithString(_ word: String, color: UIColor, bounds: CGRect) -> UIImage  {
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
    
    func imageSnapShotFromWords(_ snapShotString: String, color: UIColor?, fontAttributes: [String : AnyObject]?, bounds: CGRect) -> UIImage {
        let attributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.white,  NSFontAttributeName : UIFont(name: "AmericanTypewriter-Semibold", size:  bounds.width * 0.4)!]
        let imageBackgroundColor: UIColor = UIColor.clear
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(red: imageBackgroundColor.red(), green: imageBackgroundColor.green(), blue: imageBackgroundColor.blue(), alpha: 1.0)
        context!.fill(CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        let textSize = NSString(string: snapShotString).size(attributes: attributes)
        NSString(string: snapShotString).draw(in: CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height), withAttributes: attributes)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    typealias GetPicClosure = (UIImage?) -> Void
    
    func getProfPic(_ bounds: CGRect, completion: GetPicClosure?) {
        if completion != nil {
            if self["picture"] != nil {
                let file = self["picture"] as! PFFile
                file.getDataInBackground(block: { (data, error) in
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
    
    func createSession(_ completion: @escaping CreateSessionClosure) {
        let query = PFQuery(className: "ActiveSessions")
        query.whereKey("caller", equalTo: PFUser.current()!)
        query.whereKey("receiver", equalTo: self)
        query.getFirstObjectInBackground { (object, error) in
            if error == nil || object != nil {
                AppConfiguration.activeSession = nil
                completion(false)
            } else {
                let activeSession:PFObject = PFObject(className: "ActiveSessions")
                activeSession["caller"] = PFUser.current()!
                activeSession["receiver"] = self
                activeSession["callerTitle"] = "\(PFUser.current()!.Fullname()) sent you a game request!"
                activeSession["Accepted"] = false
                activeSession.saveInBackground(block: {(succeeded: Bool?, error: Error?) -> Void in
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
    
    var loadingTimer: Timer?
    
    lazy var fontSize: CGFloat? = {
        return self.font.pointSize
    }()
    
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
            let textSize = self.text!.size(attributes: [NSFontAttributeName:self.font!])
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
    
    var index: IndexPath?
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
        loadingTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.loadingTextTimer(_:)), userInfo: nil, repeats: true)
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

    func loadingTextTimer(_ sender: Timer) {
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
                    loadingTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.loadingTextTimer(_:)), userInfo: nil, repeats: true)
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
                    loadingTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.loadingTextTimer(_:)), userInfo: nil, repeats: true)
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
                    loadingTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.loadingTextTimer(_:)), userInfo: nil, repeats: true)
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
                    loadingTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.loadingTextTimer(_:)), userInfo: nil, repeats: true)
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
    
    override func Fullname(_ user: PFUser, color: UIColor?) {
        self.font = (UIScreen.main.bounds.width <= 320) ? UIFont(name: "AmericanTypewriter", size: 25.0)! : UIFont(name: "AmericanTypewriter", size: 35.0)!
        if color != nil {
            self.textColor = color!
        } else {
            self.textColor = UIColor.white
        }
        self.adjustsFontSizeToFitWidth = true
        if user["fullname"] != nil {
            self.text = user["fullname"] as? String ?? ""
            resizeFont()
        } else {
            let userQuery = PFUser.query()
            userQuery?.cachePolicy = AppConfiguration.cachePolicy
            userQuery?.maxCacheAge = 3600
            userQuery?.getObjectInBackground(withId: user.objectId!, block: { (object, error) in
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
    var formatter: NumberFormatter = NumberFormatter()
    
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
                self.valueLabel.text = self.formatter.string(from: NSNumber(integerLiteral: self.badgeNumber))!
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
        self.isHidden = true
        self.backgroundColor = UIColor.red
        self.valueLabel.textAlignment = .center
        self.valueLabel.backgroundColor = UIColor.clear
        self.addSubview(self.valueLabel)
        self.textColor = UIColor.white
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
        let badgeLabelWidth: CGFloat = self.valueLabel.frame.width
        let badgeLabelHeight: CGFloat = self.valueLabel.frame.height
        let height: CGFloat = max(kBadgeViewMinimumSize, badgeLabelHeight + kBadgeViewPadding)
        let width: CGFloat = max(height, badgeLabelWidth + (2 * kBadgeViewPadding))
        self.frame = CGRect(x: self.superview!.frame.width - (width / 2.0) - self.rightOffset, y: -(height / 2.0) + self.topOffset, width: width, height: height)
        self.layer.cornerRadius = height / 2.0
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.white.cgColor
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
        if self.isHidden && self.badgeValue > 0 {
            self.layoutBadgeSubviews()
            self.show()
        }
        else if !self.isHidden && self.badgeValue <= 0 {
            self.hide()
        }
        else {
            self.layoutBadgeSubviews()
        }
    }
    
    // MARK: - Visibility
    
    func show() {
        if #available(iOS 10.0, *) {
            let timing:UICubicTimingParameters = UICubicTimingParameters(animationCurve: UIViewAnimationCurve.easeInOut)
            let animator:UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 0.66, timingParameters: timing)
            animator.addAnimations {
                self.isHidden = false
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
        } else {
            self.isHidden = false
        }
    }
    
    func hide() {
        if #available(iOS 10.0, *) {
            let timing:UICubicTimingParameters = UICubicTimingParameters(animationCurve: UIViewAnimationCurve.easeInOut)
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
                        self.isHidden = true
                    }
                    animator.startAnimation()
                }
                animator.startAnimation()
            }
            animator.startAnimation()
        } else {
            self.isHidden = true
        }
    }
}

// MARK: - MIBadgeButton

open class MIBadgeButton: UIButton {
    
    var formatter: NumberFormatter = NumberFormatter()
    
    open var badgeLabel: UILabel
    
    fileprivate var badgeNumber: Int = 0
    
    open var badgeString: Int {
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
                self.setupBadgeViewWithString(self.formatter.string(from: NSNumber(integerLiteral: self.badgeNumber))!)
            } else {
                self.hide()
            }
        }
    }
    
    open var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            setupBadgeViewWithString("\(badgeString)")
        }
    }
    
    open var badgeBackgroundColor: UIColor? {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    open var badgeTextColor: UIColor? {
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
    
    open func initWithFrame(_ frame: CGRect, withBadgeString badgeString: String, withBadgeInsets badgeInsets: UIEdgeInsets) -> AnyObject {
        badgeLabel = UILabel()
        badgeEdgeInsets = badgeInsets
        self.formatter.groupingSeparator = ","
        self.formatter.usesGroupingSeparator = true
        setupBadgeViewWithString(badgeString)
        return self
    }
    
    open func increment() {
        badgeString += 1
    }
    
    // MARK: - Visibility
    
    func show() {
        self.badgeLabel.isHidden = false
        let SpringVelocity: CGFloat = 8.0
        let Damping: CGFloat = 0.2
        let Duration: Double = 0.15
        UIView.animate(withDuration: Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.curveLinear, animations: {
            self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: -1)
            }, completion: { _ in
                UIView.animate(withDuration: Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: 2)
                    }, completion: { _ in
                        UIView.animate(withDuration: Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.curveLinear, animations: {
                            self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: -1)
                            }, completion: nil)
                })
        })
    }
    
    func hide() {
        let SpringVelocity: CGFloat = 8.0
        let Damping: CGFloat = 0.2
        let Duration: Double = 0.05
        UIView.animate(withDuration: Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.curveLinear, animations: {
            self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: -1)
            }, completion: { _ in
                UIView.animate(withDuration: Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: 2)
                    }, completion: { _ in
                        UIView.animate(withDuration: Duration, delay: 0.0, usingSpringWithDamping: Damping, initialSpringVelocity: SpringVelocity, options: UIViewAnimationOptions.curveLinear, animations: {
                            self.badgeLabel.frame = self.badgeLabel.frame.offsetBy(dx: 0, dy: -1)
                            }, completion: { _ in
                                self.badgeLabel.isHidden = true
                        })
                })
        })
    }
    
    fileprivate func setupBadgeViewWithString(_ badgeText: String?) {
        badgeLabel.clipsToBounds = true
        badgeLabel.text = badgeText
        badgeLabel.isHidden = true
        badgeLabel.font = UIFont(name: "AmericanTypewriter-Semibold", size: 12)!
        badgeLabel.textAlignment = .center
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
            let x = self.frame.width - CGFloat((width / 2.0))
            let y = CGFloat(-(height / 2.0))
            badgeLabel.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
        }
        setupBadgeStyle()
        addSubview(badgeLabel)
        badgeLabel.text == "0" ? hide() : show()
    }
    
    fileprivate func setupBadgeStyle() {
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.textColor = badgeTextColor
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.size.height / 2
        badgeLabel.layer.borderWidth = 1.0
        badgeLabel.layer.borderColor = UIColor.white.cgColor
    }
}


// MARK: - ImageTextField

@IBDesignable class ImageTextField: UITextField {
    
    fileprivate var ImgIcon: UIImageView?
    
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

    @IBInspectable var lineColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var placeHolerColor: UIColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0) {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var errorColor: UIColor = UIColor.red {
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

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    fileprivate func newBounds(_ bounds: CGRect) -> CGRect {
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
            imgView.frame = CGRect(x: 0, y: 0, width: CGFloat(imageWidth), height: self.frame.height)
            imgView.contentMode = .center
            self.leftViewMode = UITextFieldViewMode.always
            self.leftView = imgView
        }
    }
    
    override func draw(_ rect: CGRect) {
        let height = self.bounds.height
        // get the current drawing context
        let context = UIGraphicsGetCurrentContext()
        
        // set the line color and width
        if errorEntry {
            context!.setStrokeColor(errorColor.cgColor)
            context!.setLineWidth(1.5)
        } else {
            context!.setStrokeColor(lineColor.cgColor)
            context!.setLineWidth(0.5)
        }
        // start a new Path
        context!.beginPath()
        context!.move(to: CGPoint(x: self.bounds.origin.x, y: height - 0.5))
        context!.addLine(to: CGPoint(x: self.bounds.size.width, y: height - 0.5))
        // close and stroke (draw) it
        context!.closePath()
        context!.strokePath()
        //Setting custom placeholder color
        if let strPlaceHolder: String = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string:strPlaceHolder, attributes:[NSForegroundColorAttributeName:placeHolerColor])
        }
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: CGFloat(imageWidth), height: self.frame.height)
    }
}

// MARK: - CLLocationCoordinate2D

extension CLLocationCoordinate2D {
    func isEqualTo(_ location: CLLocationCoordinate2D) -> Bool {
        return (self.latitude == location.latitude && self.longitude == location.longitude)
    }
}

extension Date {
    
    /// Returns the amount of years from another date
    func years(from date: Date) -> CGFloat {
        return CGFloat((Calendar.current as NSCalendar).components(NSCalendar.Unit.year, from: date, to: self, options: []).year!) ?? 0
    }
    
    /// Returns the amount of months from another date
    func months(from date: Date) -> CGFloat {
        return CGFloat((Calendar.current as NSCalendar).components(NSCalendar.Unit.month, from: date, to: self, options: []).month!) ?? 0
    }
    
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> CGFloat {
        if CGFloat(self.timeIntervalSince(date) / 604800) < 0 {
            return CGFloat(self.timeIntervalSince(date) / 604800) * -1
        }
        return CGFloat(self.timeIntervalSince(date) / 604800)
    }
    
    /// Returns the amount of days from another date
    func days(from date: Date) -> CGFloat {
        if CGFloat(self.timeIntervalSince(date) / 86400) < 0 {
            return CGFloat(self.timeIntervalSince(date) / 86400) * -1
        }
        return CGFloat(self.timeIntervalSince(date) / 86400)
    }
    
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> CGFloat {
        if CGFloat(self.timeIntervalSince(date) / 3600) < 0 {
            return CGFloat(self.timeIntervalSince(date) / 3600) * -1
        }
        return CGFloat(self.timeIntervalSince(date) / 3600)
    }
    
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> CGFloat {
        if CGFloat(self.timeIntervalSince(date) / 60) < 0 {
            return CGFloat(self.timeIntervalSince(date) / 60) * -1
        }
        return CGFloat(self.timeIntervalSince(date) / 60)
    }
    
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> CGFloat {
        if self.timeIntervalSince(date) < 0 {
            return CGFloat(self.timeIntervalSince(date)) * -1
        }
        return CGFloat(self.timeIntervalSince(date))
    }
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        return isGreater
    }

    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        var isLess = false
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        return isLess
    }

    func equalToDate(_ dateToCompare: Date) -> Bool {
        var isEqualTo = false
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        return isEqualTo
    }

    var formatted:String {
        let formatter = DateFormatter()
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let cal: Calendar = Calendar.current
        if cal.isDateInToday(self) {
            formatter.dateFormat = "h"
        } else {
            formatter.dateFormat = "M/d h"
        }
        return formatter.string(from: self)
    }

    func formattedWith(_ format:String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    static func daysAgo(_ days: Int) -> Date {
        return Date(timeIntervalSinceNow: TimeInterval(days * 86400))
    }
}



// MARK: - UITableViewCell

extension UITableViewCell {
    func GradCellLayer() {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.frame = frame
        let color1 = UIColor.charcoalColor().changeAlpha(0.4).cgColor as CGColor
        let color2 = UIColor.charcoalColor().lightenedColor(0.2).changeAlpha(0.4).cgColor as CGColor
        let color3 = UIColor.charcoalColor().lightenedColor(0.5).changeAlpha(0.4).cgColor as CGColor
        gradientLayer.colors = [color1, color2, color3, color2, color1]
        gradientLayer.locations = [0.0, 0.15, 0.5, 0.85, 1.0]
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - UIView


extension UITextField {
    func addDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.PressedDone))
        doneButton.tintColor = UIColor.black
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
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
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.PressedDone))
        doneButton.tintColor = UIColor.black
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
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
        if UIScreen.main.bounds.size.height >= 736 {
            let widther: CGFloat = (self.bounds.width / 3.0) - 6.0
            rockframe = CGRect(x: 3, y: self.bounds.height - (widther + 5), width: widther, height: widther)
            paperframe = CGRect(x: rockframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
            scissorsframe = CGRect(x: paperframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
        } else if UIScreen.main.bounds.size.height < 736 && UIScreen.main.bounds.size.height >= 667 {
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
    
    func addblur(_ color: UIColor) {
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
    
    func addBlur(_ color: UIColor, below: UIView) {
        let visualEffectView = VisualEffectView(frame: self.frame)
        visualEffectView.colorTint = color
        visualEffectView.colorTintAlpha = 0.9
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        self.insertSubview(visualEffectView, belowSubview: below)
    }
    
    func addborder() {
        self.layer.cornerRadius = 8.0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = true
        self.autoresizingMask = UIViewAutoresizing.flexibleWidth
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
            return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) : UIColor.clear
        }
        set {
            layer.borderColor = newValue.cgColor
            layer.masksToBounds = true
        }
    }
    
    func GradLayer() {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.frame = frame
        let color1 = AppConfiguration.startingColor.lightenedColor(0.4).cgColor
        let color2 = AppConfiguration.startingColor.darkenedColor(0.2).cgColor
        let color3 = AppConfiguration.startingColor.darkenedColor(0.4).cgColor
        gradientLayer.colors = [color1, color2, color3, color2, color1]
        gradientLayer.locations = [0.0, 0.3, 0.5, 0.7, 1.0]
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addBlur() {
        let visualEffectView = VisualEffectView(frame: self.frame)
        visualEffectView.colorTint = .white
        visualEffectView.colorTintAlpha = 0.2
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        self.addSubview(visualEffectView)
    }
    
    typealias SpinClosure = (Void) -> Void
    
    func spin(_ complete: SpinClosure?) {
        let rotationAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = -Double.pi
        rotationAnimation.duration = 0.5
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        layer.add(rotationAnimation, forKey: "rotationAnimation")
        UIView.animate(withDuration: 0.5, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            inviteRequestsbutton.tintColor = inviteRequestsbutton.tintColor == UIColor.white ? UIColor.waveColor() : UIColor.white
            }, completion: {_ in
                if complete != nil {
                    complete!()
                }
        })
    }
    
}

// MARK: - GradientButton

class GradientButton: UIButton {
    
    fileprivate let Grads: [String: [UIColor]] = [
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
    fileprivate var selectedColors: String = "blackGrad" {
        didSet {
            normalGradients = Grads[selectedColors]!
        }
    }

    func toggleAnimation(_ completion: @escaping GradientClosure) {
        self.isSelected = !self.isSelected
        self.delay(0.2, closure: {
            self.isSelected = !self.isSelected
            completion()
        })
    }
    
    override var isSelected: Bool {
        didSet {
            var oppositeColor: String = selectedColors
            if oppositeColor.hasSuffix("Highlighted") {
                let range = oppositeColor.characters.index(oppositeColor.endIndex, offsetBy: -"Highlighted".characters.count)..<oppositeColor.endIndex
                oppositeColor.removeSubrange(range)
                oppositeColor += "Grad"
            } else {
                let range = oppositeColor.characters.index(oppositeColor.endIndex, offsetBy: -"Grad".characters.count)..<oppositeColor.endIndex
                oppositeColor.removeSubrange(range)
                oppositeColor += "Highlighted"
            }
            selectedColors = oppositeColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        tintColor = UIColor.clear
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        layer.borderWidth = 2.0
        layer.backgroundColor = UIColor.clear.cgColor
        layer.borderColor = UIColor.white.cgColor
        setTitleColor(UIColor.white, for: UIControlState())
        setTitleColor(UIColor.white, for: .selected)
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
    
    override func draw(_ rect: CGRect) {
        let startPoint = CGPoint(x:(self.bounds.size.width / 2.0), y:self.bounds.size.height - 0.5)
        let endPoint = CGPoint(x:(self.bounds.size.width / 2.0), y:0.0)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var cgcolors: [CGColor] = [CGColor]()
        self.normalGradients.forEach { (color) in
            cgcolors.append(color.cgColor)
        }
        let gradient = CGGradient(colorsSpace: colorSpace, colors: cgcolors as CFArray, locations: self.normalGradientLocations)
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
    }
    
}


// MARK: - UIResponder

extension UIResponder {
    
   
    
    func getParentViewController() -> UIViewController? {
        if self.next is UIViewController {
            return self.next as? UIViewController
        } else {
            if self.next != nil {
                return (self.next!).getParentViewController()
            }
            else {return nil}
        }
    }
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    typealias NavPushClosure = (UIViewController) -> Void
    
    func NavPush(_ name: String, completion: NavPushClosure?) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
        sideMenuNavigationController!.pushViewController(viewController, animated: true)
        if completion != nil {
            completion!(viewController)
        }
    }
    
    func goToLobby() {
        appDelegate.window?.rootViewController = kConstantObj.SetIntialMainViewController("Lobby")
    }
}


open class VisualEffectView: UIVisualEffectView {
    
    let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    /// Tint color.
    open var colorTint: UIColor {
        get { return _valueForKey("colorTint") as! UIColor }
        set { _setValue(newValue, forKey: "colorTint") }
    }
    
    /// Tint color alpha.
    open var colorTintAlpha: CGFloat {
        get { return _valueForKey("colorTintAlpha") as! CGFloat }
        set { _setValue(newValue as AnyObject?, forKey: "colorTintAlpha") }
    }
    
    /// Blur radius.
    open var blurRadius: CGFloat {
        get { return _valueForKey("blurRadius") as! CGFloat }
        set { _setValue(newValue as AnyObject?, forKey: "blurRadius") }
    }
    
    /// Scale factor.
    open var scale: CGFloat {
        get { return _valueForKey("scale") as! CGFloat }
        set { _setValue(newValue as AnyObject?, forKey: "scale") }
    }
    
    func _valueForKey(_ key: String) -> Any? {
        return blurEffect.value(forKeyPath: key)
    }
    
    func _setValue(_ value: AnyObject?, forKey key: String) {
        blurEffect.setValue(value, forKeyPath: key)
        self.effect = blurEffect
    }
    
}



// MARK: - UIColor

extension UIColor{
    class func colorWithHex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var rgb: CUnsignedInt = 0;
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        scanner.scanHexInt32(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0xFF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}



