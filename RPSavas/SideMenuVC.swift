
//
//  SideMenuVC.swift
//  SideMenuSwiftDemo
//
//  Created by Kiran Patel on 1/2/16.
//  Copyright © 2016  SOTSYS175. All rights reserved.
//


import Foundation
import UIKit
import ParseUI
import Parse
import GLKit
import AVFoundation
import CoreMedia
import CoreImage
import OpenGLES
import QuartzCore
import Foundation
import CoreVideo



protocol KSideMenuVCDelegate: class {
    func sidemenuDidOpen(sidemenu: KSideMenuVC)
    func sidemenuDidStartOpen(sidemenu: KSideMenuVC)
}

class KSideMenuVC: UIViewController,UIGestureRecognizerDelegate {
    var sideMenuDelegate: KSideMenuVCDelegate?
    
    var mainContainer : UIViewController?
    var menuContainer : UIViewController?
    var menuViewController : UIViewController?
    var mainViewController : UIViewController?
    var bgImageContainer : UIImageView?
    var distanceOpenMenu : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    func setUp(){
        self.distanceOpenMenu = self.view.frame.size.width-(self.view.frame.size.width/2)//3);
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.GradLayer()
        self.menuContainer = UIViewController()
        self.menuContainer!.view.layer.anchorPoint = CGPoint(x:1.0, y:0.5)
        self.menuContainer!.view.frame = self.view.bounds;
        self.menuContainer!.view.backgroundColor = UIColor.clearColor()
        self.addChildViewController(self.menuContainer!)
        self.view.addSubview((self.menuContainer?.view)!)
        self.menuContainer?.didMoveToParentViewController(self)
        self.mainContainer = UIViewController()
        self.mainContainer!.view.frame = self.view.bounds;
        self.mainContainer!.view.backgroundColor = UIColor.clearColor()
        self.addChildViewController(self.mainContainer!)
        self.view.addSubview((self.mainContainer?.view)!)
        self.mainContainer?.didMoveToParentViewController(self)
        
    }
    
    func setupMenuViewController(menuVC : UIViewController)->Void{
        if (self.menuViewController != nil) {
            self.menuViewController?.willMoveToParentViewController(nil)
            self.menuViewController?.removeFromParentViewController()
            self.menuViewController?.view.removeFromSuperview()
        }
        self.menuViewController = menuVC;
        self.menuViewController!.view.frame = self.view.bounds;
        self.menuContainer?.addChildViewController(self.menuViewController!)
        self.menuContainer?.view.addSubview(menuVC.view)
        self.menuContainer?.didMoveToParentViewController(self.menuViewController)
    }
    
    func setupMainViewController(mainVC : UIViewController)->Void{
        closeMenu()
        if (self.mainViewController != nil) {
            self.mainViewController?.willMoveToParentViewController(nil)
            self.mainViewController?.removeFromParentViewController()
            self.mainViewController?.view.removeFromSuperview()
        }
        self.mainViewController = mainVC;
        self.mainViewController!.view.frame = self.view.bounds;
        self.mainContainer?.addChildViewController(self.mainViewController!)
        self.mainContainer?.view.addSubview(self.mainViewController!.view)
        self.mainViewController?.didMoveToParentViewController(self.mainContainer)
        if (self.mainContainer!.view.frame.minX == self.distanceOpenMenu) {
            closeMenu()
        }
    }
    
    func openMenu(){
        addTapGestures()
        if self.sideMenuDelegate != nil {
            self.sideMenuDelegate!.sidemenuDidStartOpen(self)
        }
        var fMain : CGRect = self.mainContainer!.view.frame
        fMain.origin.x = -self.distanceOpenMenu;
        UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            let layerTemp : CALayer = (self.mainContainer?.view.layer)!
            layerTemp.zPosition = 1000
            var tRotate : CATransform3D = CATransform3DIdentity
            tRotate.m34 = 1.0/(-500)
            let aXpos: CGFloat = CGFloat(20.0*(M_PI/180))//CGFloat(-20.0*(M_PI/180))
            tRotate = CATransform3DRotate(tRotate,aXpos, 0, 1, 0)
            var tScale : CATransform3D = CATransform3DIdentity
            tScale.m34 = 1.0/(-500)
            tScale = CATransform3DScale(tScale, 0.8, 0.8, 1.0);
            layerTemp.transform = CATransform3DConcat(tScale, tRotate)
            self.mainContainer?.view.frame = fMain
        }) { (finished: Bool) -> Void in
            if self.sideMenuDelegate != nil {
                self.sideMenuDelegate!.sidemenuDidOpen(self)
            }
        }
    }
    
    func closeMenu(){
        var fMain : CGRect = self.mainContainer!.view.frame
        fMain.origin.x = 0
        UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.mainContainer?.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            let layerTemp : CALayer = (self.mainContainer?.view.layer)!
            layerTemp.zPosition = 1000
            var tRotate : CATransform3D = CATransform3DIdentity
            tRotate.m34 = 1.0/(-500)
            let aXpos: CGFloat = CGFloat(0.0*(M_PI/180))
            tRotate = CATransform3DRotate(tRotate,aXpos, 0, 1, 0)
            layerTemp.transform = tRotate
            var tScale : CATransform3D = CATransform3DIdentity
            tScale.m34 = 1.0/(-500)
            tScale = CATransform3DScale(tScale,1.0, 1.0, 1.0);
            layerTemp.transform = tScale;
            layerTemp.transform = CATransform3DConcat(tRotate, tScale)
            layerTemp.transform = CATransform3DConcat(tScale, tRotate)
            self.mainContainer!.view.frame = CGRect(x:0, y:0, width:appDelegate.window!.frame.size.width, height:appDelegate.window!.frame.size.height)
        }) { (finished: Bool) -> Void in
            self.mainViewController!.view.userInteractionEnabled = true
            self.removeGesture()
        }
    }
    
    func quickCloseMenu() {
        var fMain : CGRect = self.mainContainer!.view.frame
        fMain.origin.x = 0
        UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.mainContainer?.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            let layerTemp : CALayer = (self.mainContainer?.view.layer)!
            layerTemp.zPosition = 1000
            var tRotate : CATransform3D = CATransform3DIdentity
            tRotate.m34 = 1.0/(-500)
            let aXpos: CGFloat = CGFloat(0.0*(M_PI/180))
            tRotate = CATransform3DRotate(tRotate,aXpos, 0, 1, 0)
            layerTemp.transform = tRotate
            var tScale : CATransform3D = CATransform3DIdentity
            tScale.m34 = 1.0/(-500)
            tScale = CATransform3DScale(tScale,1.0, 1.0, 1.0);
            layerTemp.transform = tScale;
            layerTemp.transform = CATransform3DConcat(tRotate, tScale)
            layerTemp.transform = CATransform3DConcat(tScale, tRotate)
            self.mainContainer!.view.frame = CGRect(x:0, y:0, width:appDelegate.window!.frame.size.width, height:appDelegate.window!.frame.size.height)
        }) { (finished: Bool) -> Void in
            self.mainViewController!.view.userInteractionEnabled = true
            self.removeGesture()
        }
    }
    
    func addTapGestures(){
        self.mainViewController!.view.userInteractionEnabled = false
        let tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(KSideMenuVC.tapMainAction))
        self.mainContainer!.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func removeGesture(){
        for recognizer in  self.mainContainer!.view.gestureRecognizers ?? [] {
            if (recognizer is UITapGestureRecognizer){
                self.mainContainer!.view.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    func tapMainAction(){
        closeMenu()
    }
    
    func toggleMenu(){
        let fMain : CGRect = self.mainContainer!.view.frame
        if (fMain.minX == self.distanceOpenMenu) {
            closeMenu()
        }else{
            openMenu()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

public class SideMenuCell: UITableViewCell {
    @IBOutlet weak var Field: UILabel!
    
    func evap(newText: String) {
        let originalFrame = self.frame
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.frame = self.frame.offsetBy(dx: self.frame.width/2, dy:0)
            self.alpha = 0.0
        }) { (success) in
            self.frame = self.frame.offsetBy(dx: -self.frame.width, dy:0)
            self.Field.text = newText
            sideMenuVC.quickCloseMenu()
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.frame = originalFrame
                self.alpha = 1.0
                }, completion: {_ in
                    //sideMenuVC.quickCloseMenu()
            })
        }
    }
    
    
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
    
    public override func awakeFromNib() {
        badgeLabel = UILabel()
        super.awakeFromNib()
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
        self.formatter.groupingSeparator = ","
        self.formatter.usesGroupingSeparator = true
        setupBadgeViewWithString(badgeString)
        return self
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
        badgeLabel.frame = CGRectMake(CGFloat(-(width / 2.0)), CGFloat(-(height / 4.0)), CGFloat(width), CGFloat(height))
        setupBadgeStyle()
        addSubview(badgeLabel)
        badgeLabel.text == "0" ? hide() : show()
    }
    
    private func setupBadgeStyle() {
        badgeLabel.textAlignment = .Center
        badgeLabel.backgroundColor = UIColor.redColor()
        badgeLabel.textColor = UIColor.whiteColor()
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.size.height / 2
        badgeLabel.layer.borderWidth = 1.0
        badgeLabel.layer.borderColor = UIColor.whiteColor().CGColor
    }

}


var items = ["Quick Match", "Friends", "Game Requests", "Friend Requests", "Practice", "Nearby"]

class SideMenuVC: UIViewController,KSideMenuVCDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var ProfileImage: PFImageView!
    @IBOutlet weak var NameField: UILabel!
    @IBOutlet weak var SidebarBackground: UIView!
    
    
    private var GameMenu: Bool = false
    var gameControls: Bool {
        get {
            return self.GameMenu
        }
        set {
            if newValue {
                items = ["Mute", "Mute Video", "Mute Mic", "Mute Opponent", "Quit"]
                tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                self.GameMenu = newValue
            } else {
                items = ["Quick Match", "Friends", "Game Requests", "Friend Requests", "Practice", "Nearby"]
                tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                self.GameMenu = newValue
            }
        }
    }
    
    func tappedProfile() {
        sideMenuVC.closeMenu()
        if gameControls {
            sideMenuVC.closeMenu()
        } else {
            self.NavPush("ProfileViewController", completion: {
                vc in
                (vc as! ProfileViewController).user = PFUser.currentUser()!
            })
        }
    }
    
    func tappedBackground() {
        sideMenuVC.quickCloseMenu()
    }
    
    @IBOutlet weak var closeView: UIView!
    
    override func viewDidLoad() {
        NameField.adjustsFontSizeToFitWidth = true
        sideMenuVC.sideMenuDelegate = self
        view.backgroundColor = AppConfiguration.navColor
        ProfileImage.setPic(PFUser.currentUser()!) {
            self.NameField.text = PFUser.currentUser()!.Fullname()
            self.NameField.resizeFont()
        }
        self.ProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedProfile)))
        self.closeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedBackground)))
    }
    
    func sidemenuDidOpen(sidemenu: KSideMenuVC) {
        if !gameControls {
            //print("FriendAccepted : \(PFUser.currentUser()!["friendAccepted"] as! Int), friendInvite : \(PFUser.currentUser()!["friendInvite"] as! Int), game : \((PFUser.currentUser()!["gameInvite"] as! Int) + (PFUser.currentUser()!["accepted"] as! Int))")
            if PFUser.currentUser()!["friendAccepted"] != nil {
                (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! SideMenuCell).badgeString = PFUser.currentUser()!["friendAccepted"] as! Int
            } else {
                (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! SideMenuCell).badgeString = 0
                PFUser.currentUser()!["friendAccepted"] = 0
                PFUser.currentUser()!.saveInBackground()
            }
            if PFUser.currentUser()!["friendInvite"] != nil {
                (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as! SideMenuCell).badgeString = PFUser.currentUser()!["friendInvite"] as! Int
            } else {
                (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as! SideMenuCell).badgeString = 0
                PFUser.currentUser()!["friendInvite"] = 0
                PFUser.currentUser()!.saveInBackground()
            }
            if PFUser.currentUser()!["gameInvite"] != nil && PFUser.currentUser()!["accepted"] != nil {
                (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! SideMenuCell).badgeString = (PFUser.currentUser()!["gameInvite"] as! Int) + (PFUser.currentUser()!["accepted"] as! Int)
            } else {
                (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! SideMenuCell).badgeString = 0
                PFUser.currentUser()!["accepted"] = 0
                PFUser.currentUser()!["gameInvite"] = 0
                PFUser.currentUser()!.saveInBackground()
            }
        }
    }
    
    func sidemenuDidStartOpen(sidemenu: KSideMenuVC) {
        if gameControls {
            (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! SideMenuCell).badgeString = 0
            (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as! SideMenuCell).badgeString = 0
            (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! SideMenuCell).badgeString = 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sideCell:SideMenuCell = tableView.dequeueReusableCellWithIdentifier("kCell")! as! SideMenuCell
        sideCell.Field.text = items[indexPath.row]
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            sideCell.Field.font = UIFont(name: "AmericanTypewriter-Bold", size: 21)!
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            sideCell.Field.font = UIFont(name: "AmericanTypewriter-Bold", size: 18)!
        } else {
            sideCell.Field.font = UIFont(name: "AmericanTypewriter-Bold", size: 16)!
        }
        sideCell.backgroundColor = .clearColor()
        return sideCell
    }
    
    func handleGameSelection(indexPath: NSIndexPath, gameview: GameView) {
        if indexPath.row == 0 {
            gameview.Muted = !gameview.Muted
        } else if indexPath.row == 1 {
            gameview.MutedVid = !gameview.MutedVid
        } else if indexPath.row == 2 {
            gameview.MutedMe = !gameview.MutedMe
        } else if indexPath.row == 3 {
            gameview.MutedOpp = !gameview.MutedOpp
        } else if indexPath.row == 4 {
            gameview.disconnect()
            sideMenuVC.closeMenu()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if sideMenuNavigationController!.topViewController is FriendGame {
            let friendGame = sideMenuNavigationController!.topViewController as! FriendGame
            if friendGame.gameview != nil {
                handleGameSelection(indexPath, gameview: friendGame.gameview!)
            }
        } else if sideMenuNavigationController!.topViewController is GameController {
            let gameController = sideMenuNavigationController!.topViewController as! GameController
            if gameController.gameview != nil {
                handleGameSelection(indexPath, gameview: gameController.gameview!)
            }
        } else {
            sideMenuVC.closeMenu()
            if indexPath.row == 0 {
                self.NavPush("GameController",completion: nil)
            } else if indexPath.row == 1 {
                self.NavPush("FriendsTable") {
                    vc in
                    (vc as! FriendsTable).forceFetchData()
                }
                PFUser.currentUser()!["friendAccepted"] = 0
                PFUser.currentUser()!.saveInBackground()
            } else if indexPath.row == 2 {
                self.NavPush("RequestTable",completion: nil)
                PFUser.currentUser()!["gameInvite"] = 0
                PFUser.currentUser()!.saveInBackground()
            } else if indexPath.row == 3 {
                self.NavPush("InviteTable",completion: nil)
                PFUser.currentUser()!["friendInvite"] = 0
                PFUser.currentUser()!.saveInBackground()
            } else if indexPath.row == 4 {
                self.NavPush("Practice",completion: nil)
            } else if indexPath.row == 5 {
                self.NavPush("LSViewController",completion: nil)
            } else if indexPath.row == 6 {
                PFUser.logOut()
                appDelegate.window?.rootViewController = kConstantObj.SetIntialMainViewController("Lobby")
            }
        }
    }
}

var sideMenuVC: KSideMenuVC = KSideMenuVC()
let sideMenuObj: SideMenuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("sideMenuID") as! SideMenuVC

class kConstant {
    
    func appDelegateSetup() {
        if PFUser.currentUser() != nil {
            appDelegate.window?.rootViewController = kConstantObj.SetIntialMainViewController("Lobby")
        } else {
            sideMenuNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LobbyNAV") as? UINavigationController
            appDelegate.window?.rootViewController = sideMenuNavigationController
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
    func SetIntialMainViewController(aStoryBoardID: String)->(KSideMenuVC){
        sideMenuNavigationController = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(aStoryBoardID))
        sideMenuNavigationController!.navigationBar.barTintColor = AppConfiguration.startingColor
        sideMenuVC.view.frame = UIScreen.mainScreen().bounds
        sideMenuVC.setupMainViewController(sideMenuNavigationController!)
        sideMenuVC.setupMenuViewController(sideMenuObj)
        return sideMenuVC
    }
    
    func SetMainViewController(aStoryBoardID: String)->(KSideMenuVC){
        sideMenuNavigationController = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(aStoryBoardID))
        sideMenuNavigationController!.navigationBar.barTintColor = AppConfiguration.startingColor
        sideMenuVC.view.frame = UIScreen.mainScreen().bounds
        sideMenuVC.setupMainViewController(sideMenuNavigationController!)
        return sideMenuVC
    }
    
}
