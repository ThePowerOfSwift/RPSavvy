//
//  AppDelegate.swift
//  RPS
//
//  Created by Dillon Murphy on 12/16/15.
//  Copyright © 2015 StrategynMobilePros. All rights reserved.
//

import ParseUI
import Parse
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4
import TwitterKit
import Fabric
import Crashlytics
import ParseTwitterUtils
import UIKit
import Foundation


let facebookLogin = FBSDKLoginManager()

public var sideMenuNavigationController : UINavigationController?

let kConstantObj = kConstant()

let lobby: Lobby = (UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Lobby") as? Lobby)!

let activityIndicatorView: ActivityIndicatorAnimationImagesTrianglePath = ActivityIndicatorAnimationImagesTrianglePath.sharedInstance

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    var shortcutItem: UIApplicationShortcutItem?
    var devicePushToken: NSData!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "fHbRTxXoHWO5hvekgxjTtKHbzA3YfscitEOVV7IY"
            $0.clientKey = "NqYUndIvjTTMEwxBOfnfDqSkeAW2ozPUdmbPKAOz"
            $0.server = "https://parseapi.back4app.com"
            $0.localDatastoreEnabled = false // If you need to enable local data store
        }
        Parse.initializeWithConfiguration(configuration)
        PFUser.enableRevocableSessionInBackground() // If you're using Legacy Sessions
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        PFTwitterUtils.initializeWithConsumerKey("APpi9A571ENucSyqb1MMI1kAA",  consumerSecret:"k66zw9hfJFJ7LYJiwDGdDqPsfCMcoqHuwLJMXtmAf8HvyLaQa1")
        kConstantObj.appDelegateSetup()
        configSettings()
        Fabric.with([Twitter.self, Crashlytics.self])
        var performShortcutDelegate = true
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            self.shortcutItem = shortcutItem
            performShortcutDelegate = false
        } else {
            return performShortcutDelegate
        }
        if let dict: NSDictionary = launchOptions {
            handePush(dict)
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        let installation = PFInstallation.currentInstallation()
        installation!.badge = 0
        installation!.saveInBackground()
        guard let shortcut = shortcutItem else { return }
        handleShortcut(shortcut)
        self.shortcutItem = nil
        FBSDKAppEvents.activateApp()
    }
    
    func handleShortcut( shortcutItem:UIApplicationShortcutItem ) -> Bool {
        var succeeded = false
        if sideMenuNavigationController != nil {
            if( shortcutItem.type == "QuickMatch" ) {
                sideMenuNavigationController!.NavPush("GameController", completion: nil)
                succeeded = true
            } else if( shortcutItem.type == "InviteFriend" ) {
                sideMenuNavigationController!.NavPush("InviteTable", completion: nil)
                succeeded = true
            } else if( shortcutItem.type == "FriendRequests" ) {
                sideMenuNavigationController!.NavPush("RequestTable", completion: nil)
                succeeded = true
            }
        }
        return succeeded
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler( handleShortcut(shortcutItem) )
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        completionHandler(.NewData)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        //PFUser.logOut()
    }
    
    func configSettings() {
        window?.tintColor = AppConfiguration.navColor
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([UINavigationController.self]).titleTextAttributes = (UIScreen.mainScreen().bounds.width <= 320) ?[NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 22)!] : [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 25)!]
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([UINavigationController.self]).barTintColor = AppConfiguration.navColor
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([UINavigationController.self]).tintColor = AppConfiguration.navText
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UINavigationBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : (UIScreen.mainScreen().bounds.width <= 320) ? UIFont(name: "AmericanTypewriter-Bold", size: 15)! : UIFont(name: "AmericanTypewriter-Bold", size: 17)!], forState: .Normal)
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : (UIScreen.mainScreen().bounds.width <= 320) ? UIFont(name: "AmericanTypewriter-Bold", size: 15)! : UIFont(name: "AmericanTypewriter-Bold", size: 18)!], forState: .Normal)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation!.setDeviceTokenFromData(deviceToken)
        installation!["User"] = PFUser.currentUser()
        installation!.saveInBackground()
    }
    
    func handePush(dict: NSDictionary) {
        let ap = (dict["aps"] as? NSDictionary)!
        let type: String = (dict["type"] as? String)!
        let alertMessage: String = (ap["alert"] as? String)!
        hambutton.increment()
        PFUser.currentUser()!.incrementKey(type)
        if type == "friendAccepted" {
            if PFUser.currentUser()!["Friends"] != nil {
                var friends: [String] = PFUser.currentUser()!["Friends"] as! [String]
                if !friends.contains(dict["ObjID"] as! String) {
                    friends.append(dict["ObjID"] as! String)
                    PFUser.currentUser()!["Friends"] = friends
                    PFUser.currentUser()!.saveInBackground()
                } else {
                    PFUser.currentUser()!["Friends"] = friends
                    PFUser.currentUser()!.saveInBackground()
                }
            } else {
                PFUser.currentUser()!["Friends"] = [dict["ObjID"] as! String]
                PFUser.currentUser()!.saveInBackground()
            }
        }
        guard let vc = sideMenuNavigationController!.topViewController else {
            return
        }
        if vc is RequestTable {
            let vc = vc as! RequestTable
            vc.forceFetchData()
        } else if vc is InviteTable {
            let vc = vc as! InviteTable
            vc.forceFetchData()
        } else if vc is FriendsTable {
            let vc = vc as! FriendsTable
            if vc.searching == false {
                vc.forceFetchData()
            } else {
                self.pushHandling(vc, alertMessage: alertMessage, type: type, dict: dict)
            }
        } else {
            self.pushHandling(vc, alertMessage: alertMessage, type: type, dict: dict)
        }/* else if vc is MessagesViewController {
            let vc = vc as! MessagesViewController
            if AppConfiguration.groupPass == (dict["messageID"] as? String)! {
                vc.reloadMessages()
            }
        }*/
    }
    
    struct Dimensions {
        static let height: CGFloat = 24
        static let offsetHeight: CGFloat = height * 2
        static let imageSize: CGFloat = 14
        static let loaderTitleOffset: CGFloat = 5
    }
    
    func pushHandling(vc: UIViewController, alertMessage: String, type: String, dict: NSDictionary) {
        let titleLabel = CGRect(x: (UIScreen.mainScreen().bounds.width - UIScreen.mainScreen().bounds.width - 60) / 2 + 20, y: 0, width: UIScreen.mainScreen().bounds.width - 60, height: UIScreen.mainScreen().bounds.height)
        let imageBounds = CGRect(x: titleLabel.origin.x - Dimensions.imageSize - Dimensions.loaderTitleOffset, y: (Dimensions.height - Dimensions.imageSize) / 2, width: Dimensions.imageSize, height: Dimensions.imageSize)
        PFUser.query()?.getObjectInBackgroundWithId(dict["ObjID"] as! String, block: { user, error in
            if error == nil {
                let thisUser: PFUser = user as! PFUser
                thisUser.getProfPic(imageBounds) { (image) in
                    if image != nil {
                        let systemSoundID: SystemSoundID = 1003
                        AudioServicesPlaySystemSound (systemSoundID)
                        /*if type == "chat" {
                            let announcement: Announcement = Announcement(title: "RPSavvy", subtitle: "\(thisUser.Fullname()): \(alertMessage)", image: image, action: {
                                Messages.startPrivateChat(thisUser, user2: PFUser.currentUser()!)
                                return
                            })
                            Shout(announcement, to: vc)
                        } else {*/
                            let announcement: Announcement = Announcement(title: "RPSavvy", subtitle: alertMessage, image: image, action: {
                                if type == "gameInvite" {
                                    self.NavPush("RequestTable", completion: nil)
                                } else if type == "accepted" {
                                    PFQuery(className: "ActiveSessions").getObjectInBackgroundWithId((dict["gameID"] as? String)!, block: {
                                        object, error in
                                        if error == nil {
                                            AppConfiguration.activeSession = object!
                                            AppConfiguration.activeSession!["callerTitle"] = "\(PFUser.currentUser()!.Fullname()) joined your game"
                                            AppConfiguration.activeSession!["Accepted"] = true
                                            AppConfiguration.activeSession!.saveInBackgroundWithBlock({success, error in
                                                if error == nil && success == true {
                                                    if thisUser.objectId! != (object!["receiver"] as! PFUser).objectId! {
                                                        let push = PFPush()
                                                        let data = [
                                                            "alert" : "\(PFUser.currentUser()!.Fullname()) joined your game",
                                                            "badge" : "Increment",
                                                            "ObjID" : (PFUser.currentUser()?.objectId!)! as String,
                                                            "gameID" : object!.objectId!,
                                                            "type" : "accepted"]
                                                        let installQuery = PFInstallation.query()
                                                        installQuery?.whereKey("User", equalTo: thisUser)
                                                        push.setQuery(installQuery)
                                                        push.setData(data)
                                                        push.sendPushInBackgroundWithBlock({ success, error in
                                                            if error != nil && success == false {
                                                                ProgressHUD.showError("Error sending opponent notification")
                                                            } else {
                                                                sideMenuNavigationController!.NavPush("FriendGame") { _ in
                                                                    
                                                                }
                                                            }
                                                        })
                                                    } else {
                                                        sideMenuNavigationController!.NavPush("FriendGame") { _ in
                                                            
                                                        }
                                                    }
                                                }
                                                activityIndicatorView.stopAnimation()
                                            })
                                            //self.NavPush("RequestTable", completion: nil)
                                        }
                                    })
                                } else if type == "friendInvite" {
                                    self.NavPush("InviteTable", completion: nil)
                                } else if type == "friendAccepted" {
                                    self.NavPush("FriendsTable", completion: nil)
                                }
                                return
                            })
                            Shout(announcement, to: vc)
                       // }
                    }
                }
            }
        })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFail! with error: \(error)")
    }
    
    /*func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
     handePush(userInfo as NSDictionary)
     }
     
     func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void){
     if identifier == "chatReply"{
     if let responseText = responseInfo[UIUserNotificationActionResponseTypedTextKey] as? String {
     NSLog(responseText)
     //do your API call magic!!
     }
     }
     completionHandler()
     }
     
     
     func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
     switch identifier! {
     case "chatReply":
     print("Tapped Chat Reply")
     case "chatDismiss":
     print("Tapped Chat Dismiss")
     default:
     break
     }
     
     completionHandler()
     }
     
     func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
     //
     }
     */
    
    //MARK: - Push Handling
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let UserInfo: NSDictionary = userInfo as NSDictionary
        /*guard let aps: NSDictionary = userInfo["aps"] as? NSDictionary else {
            completionHandler(.NoData)
            return
        }
        guard let contentAvailable: Int = aps["content-available"] as? Int else {
            handePush(UserInfo)
            return
        }
        print("Content Available: \(contentAvailable)")
        if contentAvailable == 1 {
            guard let pushType: String = UserInfo["type"] as? String  else {
                handePush(UserInfo)
                return
            }
            if pushType == "chatTyping" {
                guard let messagesVC: MessagesViewController = sideMenuNavigationController!.topViewController as? MessagesViewController else {
                    completionHandler(.NoData)
                    return
                }
                if AppConfiguration.groupPass == UserInfo["messageID"] as! String {
                    messagesVC.showUserTypingIndicator()
                }
                completionHandler(.NoData)
            } else if pushType == "chatTypingEnd" {
                guard let messagesVC: MessagesViewController = sideMenuNavigationController!.topViewController as? MessagesViewController else {
                    completionHandler(.NoData)
                    return
                }
                if AppConfiguration.groupPass == UserInfo["messageID"] as! String {
                    messagesVC.hideUserTypingIndicator()
                }
                completionHandler(.NoData)
            }
        } else  {
            handePush(UserInfo)
            completionHandler(.NewData)
        }*/
        handePush(UserInfo)
        completionHandler(.NewData)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
}

public struct AppConfiguration {
    
    public static var cachePolicy: PFCachePolicy = PFCachePolicy.NetworkElseCache
    public static let ApiKey = "45441312"
    public static var SessionID: String?
    public static var publisherToken: String?
    public static var subscriberToken: String?
    private static var session: PFObject?
    public static var activeSession: PFObject? {
        get {
            return AppConfiguration.session
        }
        set (newVal) {
            if newVal != nil {
                AppConfiguration.SessionID = newVal!["sessionID"] as? String
                AppConfiguration.publisherToken = newVal!["publisherToken"] as? String
                AppConfiguration.subscriberToken = newVal!["subscriberToken"] as? String
            } else {
                AppConfiguration.SessionID = nil
                AppConfiguration.subscriberToken = nil
                AppConfiguration.publisherToken = nil
            }
            AppConfiguration.session = newVal
        }
    }
    
    public static var currentLocation: PFGeoPoint?
    
    public static var groupPass = ""
    
    public static var scheme : [Color]!
    public static var schemeSame : [Color]!
    public static var complement: Color!
    
    public static var userImage: UIImage = UIImage(named: "profile_blank")!
    public static var navTitle = ""
    
    public static var startingColor: Color = Color.grayColor().darkenedColor(0.5)
    
    public static var navColor: UIColor = UIColor.grayColor().darkenedColor(0.5)
    public static var navSelectedColor: UIColor = UIColor(red: 0.497982442378998, green: 0.498071908950806, blue: 0.497976779937744, alpha: 1.0)
    public static var navText: UIColor =  UIColor.whiteColor()
    public static var backgroundColor = UIColor.peachColor()
    public static var appFont = UIFont(name: "AmericanTypewriter", size: 18)!
    public static var appFontSmall = UIFont(name: "AmericanTypewriter", size: 12)!
    public static var appFontSmallBold = UIFont(name: "AmericanTypewriter-Bold", size: 12)!
    public static var sideMenuColor = UIColor.yellowColor().complementaryColor()
    public static var sideMenuText: UIColor =  UIColor.antiqueWhiteColor()
    public static var textAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter", size: 18)!] as [String : AnyObject]
    public static var smallTextAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.lightGrayColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter", size: 14)!] as [String : AnyObject]
    
}
