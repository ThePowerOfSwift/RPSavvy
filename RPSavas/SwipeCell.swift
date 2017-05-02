//
//  FriendTable.swift
//  RPSavvy
//
//  Created by Dillon Murphy on 3/14/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI
import ParseFacebookUtilsV4

var cellHeight: CGFloat = 80.0
let MessageImg = Images.resizeImage(UIImage(named:"Message")!, width: cellHeight*0.8, height: (cellHeight*0.8)*(UIImage(named:"Message")!.size.height/UIImage(named:"Message")!.size.width))!
let Trash = Images.resizeImage(UIImage(named:"trash")!, width: cellHeight*0.8, height: cellHeight*0.8)!
let Check = Images.resizeImage(UIImage(named:"Check")!, width: cellHeight*0.6, height: cellHeight*0.6)!
let messageColor = UIColor.init(rgba: (r: AppConfiguration.startingColor.darkenedColor(0.2).red(), g: AppConfiguration.startingColor.darkenedColor(0.2).green(), b: AppConfiguration.startingColor.darkenedColor(0.2).blue(), a: 0.3))
let checkColor = UIColor.init(rgba: (r: UIColor.emeraldColor().red(), g: UIColor.emeraldColor().green(), b: UIColor.emeraldColor().blue(), a: 0.4))
let trashColor = UIColor.init(rgba: (r: UIColor.brickRedColor().red(), g: UIColor.brickRedColor().green(), b: UIColor.brickRedColor().blue(), a: 0.3))



extension UIImageView {
    func startImageDissolve() {
        self.animationImages = [UIImage(named:"rock")!,UIImage(named:"paper")!,UIImage(named:"scissors")!]
        self.animationDuration = 3.0
        self.startAnimating()
    }
    
    func stopImageDissolve() {
        self.stopAnimating()
    }
}


class SwipeCell: MGSwipeTableCell, MGSwipeTableCellDelegate {
    
    @IBOutlet weak var ProfileImage: PFImageView!
    @IBOutlet weak var Name: loadingLabel!
    @IBOutlet weak var Details: loadingLabel?
    
    var fontSize: CGFloat = 35.0
    
    var table: ParseTable!
    
    fileprivate var idx: Int = 0
    fileprivate let backGroundArray = [UIImage(named:"rock"),UIImage(named:"paper"),UIImage(named:"scissors")]
    var index: IndexPath? {
        didSet {
            self.Name.index = self.index
        }
    }
    var PushUser: PFUser?
    
    var CreateGame: MGSwipeButton?
    
    func setupCreateButton() {
        self.CreateGame = MGSwipeButton(title: "", icon: UIImage(named:"paper")!, backgroundColor: messageColor, callback: { (sender: MGSwipeTableCell!) -> Bool in
            let query = PFQuery(className: "ActiveSessions")
            query.whereKey("receiver", equalTo: self.PushUser!)
            query.whereKey("caller", equalTo: PFUser.current()!)
            query.findObjectsInBackground(block: {(objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    if objects?.count == 0 {
                        self.PushUser!.createSession({ success in
                            if success {
                                ProgressHUD.showSuccess("Game request sent")
                            } else {
                                ProgressHUD.showError("Error Creating Game")
                            }
                            activityIndicatorView.stopAnimation()
                        })
                    } else {
                        ProgressHUD.showError("Game request already sent")
                        activityIndicatorView.stopAnimation()
                    }
                }
            })
            return true
        })
        self.CreateGame!.buttonWidth = 80.0
    }
    
    var AddFriend: MGSwipeButton?
    
    func setupAddFriend() {
        self.AddFriend = MGSwipeButton(title: "", icon: UIImage(named: "AddFriend")!, backgroundColor: messageColor, callback: { (sender: MGSwipeTableCell!) -> Bool in
            let query = PFQuery(className: "Notification")
            query.whereKey("User", equalTo: self.PushUser!)
            query.whereKey("SentFrom", equalTo: PFUser.current()!)
            query.findObjectsInBackground(block: {(objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    if objects?.count == 0 {
                        let notification: PFObject = PFObject(className: "Notification")
                        notification["User"] = self.PushUser!
                        notification["Message"] = "\(PFUser.current()!.Fullname()) sent you a friend request!"
                        notification["Type"] = "friendInvite"
                        notification["SentFrom"] = PFUser.current()!
                        notification.saveInBackground(block: { (success, error) in
                            if error == nil {
                                ProgressHUD.showSuccess("Friend request sent")
                            }
                            self.table.tableView.isUserInteractionEnabled = true
                            activityIndicatorView.stopAnimation()
                        })
                    } else {
                        ProgressHUD.showError("Friend request already sent")
                        self.table.tableView.isUserInteractionEnabled = true
                        activityIndicatorView.stopAnimation()
                    }
                }
            })
            return true
        })
        self.AddFriend!.buttonWidth = 80.0
    }
    
    var ProfileButton: MGSwipeButton?
    
    func setupProfileButton() {
        self.ProfileButton = MGSwipeButton(title: "", icon: UIImage(named: "profile")!, backgroundColor: messageColor, callback: { (sender: MGSwipeTableCell!) -> Bool in
            self.NavPush("ProfileViewController", completion: {
                vc in
                (vc as! ProfileViewController).user = self.PushUser!
            })
            return true
        })
        self.ProfileButton!.buttonWidth = 80.0
    }
    /*
    var message: MGSwipeButton?
    
    func setupMessage() {
        self.message = MGSwipeButton(title: "", icon: MessageImg, backgroundColor: messageColor, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            Messages.startPrivateChat(self.PushUser!, user2: PFUser.currentUser()!)
            return true
        })
        self.message!.buttonWidth = 80.0
    }
    */
    var accept : MGSwipeButton?
    
    func setupAccept() {
        self.accept = MGSwipeButton(title: "", icon: Check, backgroundColor: checkColor, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            activityIndicatorView.startAnimation()
            if self.UserInvite != nil {
                self.UserInvite!["Message"] = "\(PFUser.current()!.Fullname()) accepted your friend request"
                self.UserInvite!["Accepted"] = true
                self.UserInvite!.saveInBackground(block: {
                    success, error in
                    if error == nil {
                        self.UserInvite!.deleteInBackground(block: {success, error in
                            if error == nil {
                                (self.table as! InviteTable).invitesList.remove(at: self.index!.row)
                                (self.table as! InviteTable).tableView.reloadData()
                            }
                        })
                        self.addToFriends()
                    }
                    activityIndicatorView.stopAnimation()
                })
            } else if self.UserRequest != nil {
                AppConfiguration.activeSession = self.UserRequest!
                AppConfiguration.activeSession!["callerTitle"] = "\(PFUser.current()!.Fullname()) joined your game"
                AppConfiguration.activeSession!["Accepted"] = true
                AppConfiguration.activeSession!.saveInBackground(block: {success, error in
                    activityIndicatorView.stopAnimation()
                    if error == nil && success == true {
                        sideMenuNavigationController!.NavPush("FriendGame") { _ in
                        
                        }
                    }
                })
            }
            return true
        })
        self.accept!.buttonWidth = 80.0
    }
    
    var delete : MGSwipeButton?
    
    func setupDelete() {
        self.delete = MGSwipeButton(title: "", icon: Trash, backgroundColor: trashColor, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            if self.UserInvite != nil {
                self.UserInvite!.deleteInBackground(block: {success, error in
                    if error == nil {
                        (self.table as! InviteTable).invitesList.remove(at: self.index!.row)
                        (self.table as! InviteTable).tableView.reloadData()
                    }
                })
            } else if self.UserRequest != nil {
                self.UserRequest!.deleteInBackground(block: {success, error in
                    if error == nil {
                        (self.table as! RequestTable).GameList.remove(at: self.index!.row)
                        (self.table as! RequestTable).tableView.reloadData()
                    }
                })
            } else if self.User != nil {
                ProgressHUD.showSuccess("Deleted \(self.PushUser!.Fullname())")
                self.removeFromFriends()
            }
            return true
        })
        self.delete!.buttonWidth = 80.0
    }
    
    var nearbyUser: PFUser? {
        get {
            return self.PushUser
        }
        set (newVal) {
            self.PushUser = newVal
        }
    }
    
    func setupNearbyUser(_ viewController: ParseTable) {
        setupAnimation(viewController)
        ProfileImage.setProfPic(self.nearbyUser!, color: nil) {
            self.Name.variableWidth = false
            self.Name.LoadingText = self.nearbyUser!.Fullname()
            //self.setupMessage()
            self.setupDelete()
            self.setupProfileButton()
            self.setupCreateButton()
            self.setupAddFriend()
            if PFUser.current()!["Friends"] != nil {
                let friends: [String] = PFUser.current()!["Friends"] as! [String]
                if friends.contains(self.nearbyUser!.objectId!) {
                    self.rightButtons = [self.CreateGame!,self.ProfileButton!,self.delete!]
                } else {
                    self.rightButtons = [self.CreateGame!,self.AddFriend!]
                }
            } else {
                self.rightButtons = [self.CreateGame!,self.AddFriend!]
            }
        }
    }
    
    fileprivate var userInvite: PFObject?
    
    var UserInvite: PFObject? {
        get {
            return self.userInvite
        }
        set (newVal) {
            self.Details!.isHidden = false
            self.userInvite = newVal
        }
    }
    
    func setUpUserInvite(_ viewController: ParseTable) {
        self.PushUser = self.UserInvite!["SentFrom"] as? PFUser//((self.UserInvite!["SentFrom"] as! PFUser).objectId! != PFUser.currentUser()!.objectId!) ? self.UserInvite!["SentFrom"] as! PFUser : self.UserInvite!["User"] as! PFUser
        self.setupAnimation(viewController)
        PFUser.query()?.getObjectInBackground(withId: self.PushUser!.objectId!, block: { (user, error) in
            if error == nil {
                self.ProfileImage.tintColor = AppConfiguration.navText
                if user!["picture"] != nil {
                    self.ProfileImage.file = user!["picture"] as? PFFile
                    self.ProfileImage.load(inBackground: { (image, error) in
                        if image == nil {
                            if user!["fullname"] != nil {
                                self.ProfileImage.imageWithString(user!["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
                            }
                        }
                        self.ProfileImage.layer.borderColor = UIColor.white.cgColor
                    })
                }
                if user!["fullname"] != nil {
                    self.Name.LoadingText =  user!["fullname"] as! String
                    self.Details!.LoadingText = "Sent You A Friend Invite!"
                }
            }
            //self.setupMessage()
            self.setupDelete()
            self.setupAccept()
            self.rightButtons = [self.accept!, self.delete!]
        })
    }
    
    fileprivate var userRequest: PFObject?
    
    var UserRequest: PFObject? {
        get {
            return self.userRequest
        }
        set (newVal) {
            self.Details!.isHidden = false
            self.userRequest = newVal
        }
    }
    
    func setupUserRequest(_ viewController: ParseTable) {
        self.PushUser = ((self.UserRequest!["receiver"] as! PFUser).objectId! != PFUser.current()!.objectId!) ? self.UserRequest!["receiver"] as! PFUser : self.UserRequest!["caller"] as! PFUser
        self.setupAnimation(viewController)
        self.setupDelete()
        self.setupAccept()
        self.rightButtons = [self.accept!, self.delete!]
        PFUser.query()?.getObjectInBackground(withId: self.PushUser!.objectId!, block: { (user, error) in
            if error == nil {
                self.ProfileImage.tintColor = AppConfiguration.navText
                if user!["picture"] != nil {
                    self.ProfileImage.file = user!["picture"] as? PFFile
                    self.ProfileImage.load(inBackground: { (image, error) in
                        if image == nil {
                            if user!["fullname"] != nil {
                                self.ProfileImage.imageWithString(user!["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
                            }
                        }
                        self.ProfileImage.layer.borderColor = UIColor.white.cgColor
                    })
                }
                if user!["fullname"] != nil {
                    self.Name.LoadingText =  user!["fullname"] as! String
                }
            }
        })
        guard let accepted = self.UserRequest!["Accepted"] as? Bool else {
            return
        }
        if accepted {
            if ((self.UserRequest!["receiver"] as! PFUser).objectId! == PFUser.current()!.objectId!) {
                self.Details!.LoadingText = "Game Request Accepted!"
            } else {
                self.Details!.LoadingText = "Accepted Your Game Invite!"
            }
        } else {
            if ((self.UserRequest!["receiver"] as! PFUser).objectId! == PFUser.current()!.objectId!) {
                self.Details!.LoadingText = "Sent You A Game Request!"
            } else {
                self.Details!.LoadingText = "Your Invite Is Pending.."
            }
        }
        /*
         if ((self.UserRequest!["receiver"] as! PFUser).objectId! == PFUser.currentUser()!.objectId!) {
         self.Details!.LoadingText = self.UserRequest!["Accepted"] == nil ? "Sent You A Game Request!" : "Game Request Accepted!"
         } else {
         self.Details!.LoadingText = self.UserRequest!["Accepted"] == nil ? "Your Invite Is Pending.." : "Accepted Your Game Invite!"
         }
         
        //self.setupMessage()
        self.setupDelete()
        self.setupAccept()
        self.rightButtons = [self.accept!, self.delete!]*/
    }
    
    func setupAnimation(_ viewController: ParseTable) {
        let moveRight = CASpringAnimation(keyPath: "transform.translation.x")
        moveRight.fromValue = -self.contentView.frame.width
        moveRight.toValue = 0
        moveRight.duration = moveRight.settlingDuration
        moveRight.fillMode = kCAFillModeBackwards
        if viewController.initialLoad == false {
            self.alpha = 0
            self.frame = self.frame.offsetBy(dx: -self.frame.width, dy: 0)
            self.delay(Double(index!.row) * 0.5, closure: {
                self.contentView.layer.add(moveRight, forKey: nil)
                UIView.animate(withDuration: moveRight.settlingDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.alpha = 1.0
                }, completion: {_ in
                    if self == viewController.tableView.visibleCells.last {
                        viewController.initialLoad = true
                    }
                })
            })
        } else {
            self.contentView.layer.add(moveRight, forKey: nil)
            UIView.animate(withDuration: moveRight.settlingDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.contentView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    var User: PFUser? {
        get {
            if self.PushUser != nil {
                return self.PushUser!
            } else {
                return nil
            }
        }
        set {
            self.PushUser = newValue
        }
    }
    
    func setupUser(_ viewController: ParseTable) {
        setupAnimation(viewController)
        ProfileImage.setProfPic(self.User!, color: nil) {
            self.Name.variableWidth = false
            self.Name.LoadingText = self.User!.Fullname()
            //self.setupMessage()
            self.setupDelete()
            self.setupProfileButton()
            self.setupCreateButton()
            self.setupAddFriend()
            self.checkForText()
            if PFUser.current()!["Friends"] != nil {
                let friends: [String] = PFUser.current()!["Friends"] as! [String]
                if friends.contains(self.User!.objectId!) {
                    self.rightButtons = [self.CreateGame!,self.ProfileButton!,self.delete!]
                } else {
                    self.rightButtons = [self.CreateGame!,self.AddFriend!]
                }
            } else {
                self.rightButtons = [self.CreateGame!,self.AddFriend!]
            }
        }
    }
    
    func checkForText() {
        let query = PFQuery(className: "Chat")
        let id1: String = self.User!.objectId!
        let id2: String = PFUser.current()!.objectId!
        let groupId: String = (id1 < id2) ? "\(id1),\(id2)" : "\(id2),\(id1)"
        query.whereKey("groupId", equalTo: groupId)
        query.order(byDescending: "createdAt")
        query.getFirstObjectInBackground(block: { (object, error) in
            if error == nil && object != nil {
                self.Details!.text = object!["text"] as! String
                self.Details!.isHidden = false
            } else {
                self.Details!.text = nil
                self.Details!.isHidden = true
            }
        })
    }
    
    var normalGradientLocations: [CGFloat] = [0.0,1.0,0.548,0.462]
    var normalGradients:[UIColor] = [UIColor(red: 0.154, green: 0.154, blue: 0.154, alpha: 1.0),UIColor(red: 0.307, green: 0.307, blue: 0.307, alpha: 1.0),UIColor(red: 0.166, green: 0.166, blue: 0.166, alpha: 1.0),UIColor(red: 0.118, green: 0.118, blue: 0.118, alpha: 1.0)] {
        didSet {
            normalGradientLocations = normalGradients.count == 4 ? [0.0,1.0,0.548,0.462] : [0.0,1.0,0.582,0.418,0.346]
            setNeedsDisplay()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.normalGradients = [UIColor(red: 0.199, green: 0.199, blue: 0.199, alpha: 1.0),UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1.0),UIColor(red: 0.074, green: 0.074, blue: 0.074, alpha: 1.0),UIColor(red: 0.112, green: 0.112, blue: 0.112, alpha: 1.0)]
            self.delay(0.3, closure: {
                self.normalGradients = [UIColor(red: 0.154, green: 0.154, blue: 0.154, alpha: 1.0),UIColor(red: 0.307, green: 0.307, blue: 0.307, alpha: 1.0),UIColor(red: 0.166, green: 0.166, blue: 0.166, alpha: 1.0),UIColor(red: 0.118, green: 0.118, blue: 0.118, alpha: 1.0)]
                self.isSelected = false
            })
        }
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
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, didChange state: MGSwipeState, gestureIsActive: Bool) {
        if self.CreateGame != nil {
            if (self.rightButtons as! [MGSwipeButton]).contains(self.CreateGame!) {
                if cell.swipeState == MGSwipeState.swipingLeftToRight {
                    self.CreateGame!.imageView!.stopImageDissolve()
                } else {
                    self.CreateGame!.imageView!.startImageDissolve()
                }
            }
        }
    }
    
    func addToFriends() {
        if PFUser.current()!["Friends"] != nil {
            var friends: [String] = PFUser.current()!["Friends"] as! [String]
            if !friends.contains(self.PushUser!.objectId!) {
                friends.append(self.PushUser!.objectId!)
                PFUser.current()!["Friends"] = friends
                PFUser.current()!.saveInBackground()
            }
        } else {
            PFUser.current()!["Friends"] = [self.PushUser!.objectId!]
            PFUser.current()!.saveInBackground()
        }
        activityIndicatorView.stopAnimation()
    }
    
    func removeFromFriends() {
        if PFUser.current()!["Friends"] != nil {
            var friends: [String] = PFUser.current()!["Friends"] as! [String]
            if friends.contains(self.PushUser!.objectId!) {
                let index = friends.index(of: self.PushUser!.objectId!)
                friends.remove(at: index!)
                PFUser.current()!["Friends"] = friends
                PFUser.current()!.saveInBackground()
            }
        }
        guard let index = self.table.FriendsList.index(of: self.PushUser!) else {
            return
        }
        self.table.FriendsList.remove(at: index)
        self.table.tableView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.selectionStyle = .none
        self.rightSwipeSettings.transition = MGSwipeTransition.drag
        self.Name.font = (UIScreen.main.bounds.width <= 320) ? UIFont(name: "AmericanTypewriter-Semibold", size: 25.0)! : UIFont(name: "AmericanTypewriter-Semibold", size: 35.0)!
        self.Name.textColor = UIColor.white
        self.Name.adjustsFontSizeToFitWidth = true
        self.Name.minimumScaleFactor = 0.5
        if self.Details != nil {
            self.Details!.font = (UIScreen.main.bounds.width <= 320) ? UIFont(name: "AmericanTypewriter", size: 12.0)! : UIFont(name: "AmericanTypewriter", size: 17.0)!
            self.Details!.textColor = UIColor.white.darkenedColor(0.1)
            self.Details!.adjustsFontSizeToFitWidth = true
            self.Details!.lineBreakMode = NSLineBreakMode.byTruncatingTail
            self.Details!.minimumScaleFactor = 0.5
        }
    }
}

