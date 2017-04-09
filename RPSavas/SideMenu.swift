//
//  SideMenu.swift
//  RPSavvy
//
//  Created by Dillon Murphy on 7/27/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//
import Foundation
import UIKit
import Parse
import ParseUI

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
    
}

public class SideMenu: UIView, UIGestureRecognizerDelegate {
    
    var mainContainer : UIViewController?
    //var menuContainer : UIViewController?
    var menuViewController : UIViewController?
    var mainViewController : UIViewController?
    
    var selectRowAtIndexPathHandler: ((indexPath: Int) -> ())?
    var bgImageContainer : PFImageView?
    var distanceOpenMenu : CGFloat = 0
    var Container: UIViewController?
    var menuOpen = false
    var originalFrame: CGRect?
    
    var tableView: UITableView!
    
    struct item {
        var name: String?
        var VC: String?
    }
    
    var items : [item] = [item]()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0.0
        self.originalFrame = frame
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        self.distanceOpenMenu = frame.size.width-(frame.size.width/3)
        if PFUser.currentUser() != nil {
            let userQuery = PFUser.query()
            userQuery?.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) in
                if error == nil {
                    
                }
            })
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    /*
    func setMenuViewController(menuVC : UIViewController)->Void{
        if (self.menuViewController != nil) {
            self.menuViewController?.willMoveToParentViewController(nil)
            self.menuViewController?.removeFromParentViewController()
            self.menuViewController?.view.removeFromSuperview()
        }
        
        self.menuViewController = menuVC;
        self.menuViewController!.view.frame = self.originalFrame!;
        self.menuContainer?.addChildViewController(self.menuViewController!)
        self.menuContainer?.view.addSubview(menuVC.view)
        self.menuContainer?.didMoveToParentViewController(self.menuViewController)
    }
    
    func setMainViewController(mainVC : UIViewController)->Void{
        closeMenu()
        
        //        if (self.mainViewController == mainVC) {
        //            if (CGRectGetMinX(self.mainContainer!.view.frame) == self.distanceOpenMenu) {
        //                closeMenu()
        //            }
        //        }
        if (self.mainViewController != nil) {
            self.mainViewController?.willMoveToParentViewController(nil)
            self.mainViewController?.removeFromParentViewController()
            self.mainViewController?.view.removeFromSuperview()
        }
        self.mainViewController = mainVC;
        self.mainViewController!.view.frame =  self.originalFrame!;
        self.mainContainer?.addChildViewController(self.mainViewController!)
        self.mainContainer?.view.addSubview(self.mainViewController!.view)
        self.mainViewController?.didMoveToParentViewController(self.mainContainer)
        
        if (CGRectGetMinX(self.mainContainer!.view.frame) == self.distanceOpenMenu) {
            closeMenu()
        }
    }
*/

    func setup(vc: UIViewController) {
        //self.tableView.reloadData()
        /*self.menuContainer = UIViewController()
        self.menuContainer!.view.layer.anchorPoint = CGPointMake(1.0, 0.5)
        self.menuContainer!.view.frame = self.originalFrame!
        self.menuContainer!.view.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        vc.addChildViewController(self.menuContainer!)
        vc.view.addSubview((self.menuContainer?.view)!)
        self.menuContainer?.didMoveToParentViewController(vc)
        
        self.mainContainer = UIViewController()
        self.mainContainer!.view.frame = self.originalFrame!
        self.mainContainer!.view.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        vc.addChildViewController(self.mainContainer!)
        vc.view.addSubview((self.mainContainer?.view)!)
        self.mainContainer?.didMoveToParentViewController(vc)*/
        
        let image: UIImage = UIImage(named:"Hamburger")!
        
        self.Container = vc
        let newButton: UIBarButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(self.toggleOpenClose))
        newButton.tintColor = UIColor(white: 1.0, alpha: 0.5)
        self.Container!.navigationItem.setRightBarButtonItem(newButton, animated: false)
        self.Container!.view.addSubview(self)//, belowSubview: self.menuContainer!.view)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func toggleOpenClose() {
        if menuOpen == false {
            menuOpen = true
            openMenu()
        } else {
            menuOpen = false
            closeMenu()
        }
    }

    func openMenu(){
        addTapGestures()
        let viewer = snapshotOfView()
        //self.Container!.view.alpha = 0.0
        viewer.frame = self.Container!.view.frame
        self.Container!.view.addSubview(viewer)
        var fMain : CGRect = self.Container!.view.frame
        fMain.origin.x = -self.distanceOpenMenu;
        //Simple Open Menu
        /*
         UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
         self.mainContainer!.view.frame = fMain
         
         }) { (finished: Bool) -> Void in
         
         }*/
        
        UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            let layerTemp : CALayer = (self.Container?.view.layer)!
            layerTemp.zPosition = 1000
            var tRotate : CATransform3D = CATransform3DIdentity
            tRotate.m34 = 1.0/(-500)
            let aXpos: CGFloat = CGFloat(20.0*(M_PI/180))//CGFloat(-20.0*(M_PI/180))
            tRotate = CATransform3DRotate(tRotate,aXpos, 0, 1, 0)
            var tScale : CATransform3D = CATransform3DIdentity
            tScale.m34 = 1.0/(-500)
            tScale = CATransform3DScale(tScale, 0.8, 0.8, 1.0);
            layerTemp.transform = CATransform3DConcat(tScale, tRotate)
            
            self.Container?.view.frame = fMain
        }) { (finished: Bool) -> Void in
        }
    }
    
    func closeMenu(){
        var fMain : CGRect = self.Container!.view.frame
        fMain.origin.x = 0
        /*
         UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
         self.mainContainer!.view.frame = fMain
         
         }) { (finished: Bool) -> Void in
         
         }*/
        
        UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.Container?.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            let layerTemp : CALayer = (self.Container?.view.layer)!
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
            
            self.Container!.view.frame = self.originalFrame!//CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        }) { (finished: Bool) -> Void in
            self.Container!.view.userInteractionEnabled = true
            self.removeGesture()
            
        }
    }
    
    func snapshotOfView() -> UIView {
        UIGraphicsBeginImageContextWithOptions(self.Container!.view.bounds.size, false, 0.0)
        self.Container!.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let viewSnapshot : UIView = UIImageView(image: image)
        viewSnapshot.layer.masksToBounds = false
        viewSnapshot.layer.cornerRadius = 0.0
        viewSnapshot.layer.shadowOffset = CGSize(width:-5.0, height:0.0)
        viewSnapshot.layer.shadowRadius = 5.0
        viewSnapshot.layer.shadowOpacity = 0.4
        return viewSnapshot
    }
    
    func addTapGestures(){
       // self.menuContainer!.view.userInteractionEnabled = false
        
        let tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapMainAction))
        self.Container!.view.addGestureRecognizer(tapGestureRecognizer)
    }
    func removeGesture(){
        for recognizer in  self.Container!.view.gestureRecognizers ?? [] {
            if (recognizer .isKindOfClass(UITapGestureRecognizer)){
                self.Container!.view.removeGestureRecognizer(recognizer)
            }
        }
    }
    func tapMainAction(){
        closeMenu()
    }
    
    func toggleMenu(){
        let fMain : CGRect = self.Container!.view.frame
        if (CGRectGetMinX(fMain) == self.distanceOpenMenu) {
            closeMenu()
        }else{
            openMenu()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCellWithIdentifier(
            "kCell", forIndexPath: indexPath)
        let aLabel : UILabel = aCell.viewWithTag(10) as! UILabel
        aLabel.text = items[indexPath.row].name!
        return aCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectRowAtIndexPathHandler!(indexPath: indexPath.row)
        if indexPath == 0 {
            self.getParentViewController()!.NavPush("GameController")
        } else if indexPath == 1 {
            self.getParentViewController()!.NavPush("FriendsTable")
        } else if indexPath == 2 {
            self.getParentViewController()!.NavPush("ProfileViewController")
        } else if indexPath == 3 {
            self.getParentViewController()!.NavPush("RequestTable")
        } else if indexPath == 4 {
            self.getParentViewController()!.NavPush("InviteTable")
        }
    }
}



