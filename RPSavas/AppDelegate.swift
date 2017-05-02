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
import UserNotifications

let facebookLogin = FBSDKLoginManager()

public var sideMenuNavigationController : UINavigationController?

let kConstantObj = kConstant()

let lobby: Lobby = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Lobby") as? Lobby)!

let activityIndicatorView: ActivityIndicatorAnimationImagesTrianglePath = ActivityIndicatorAnimationImagesTrianglePath.sharedInstance

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    var shortcutItem: UIApplicationShortcutItem?
    var devicePushToken: Data!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        
        /*let configuration = ParseClientConfiguration {
            $0.applicationId = "fHbRTxXoHWO5hvekgxjTtKHbzA3YfscitEOVV7IY"
            $0.clientKey = "PH36lMNiNYsJIvmDwnWibJL90D6bJ0290b8pypWe"
            $0.server = "https://rpsavas.herokuapp.com/parse"
            $0.isLocalDatastoreEnabled = false // If you need to enable local data store
         //mongodb://admin:c4d9cRBHB9ewKPYpvxRDHECJ@mongodb7.back4app.com:27017/a01c52002fcb419e8c44e386472c294b?ssl=true
        }*/
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "fHbRTxXoHWO5hvekgxjTtKHbzA3YfscitEOVV7IY"
            $0.clientKey = "NqYUndIvjTTMEwxBOfnfDqSkeAW2ozPUdmbPKAOz"
            $0.server = "https://parseapi.back4app.com"
            $0.isLocalDatastoreEnabled = false // If you need to enable local data store
        }
        
        Parse.initialize(with: configuration)
        PFUser.enableRevocableSessionInBackground() // If you're using Legacy Sessions
        
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        PFTwitterUtils.initialize(withConsumerKey: "APpi9A571ENucSyqb1MMI1kAA",  consumerSecret:"k66zw9hfJFJ7LYJiwDGdDqPsfCMcoqHuwLJMXtmAf8HvyLaQa1")
        kConstantObj.appDelegateSetup()
        configSettings()
        Fabric.with([Twitter.self, Crashlytics.self])
        var performShortcutDelegate = true
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            self.shortcutItem = shortcutItem
            performShortcutDelegate = false
        } else {
            return performShortcutDelegate
        }
        guard let dict: NSDictionary = launchOptions as NSDictionary? else {
            return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        handePush(dict)
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let installation = PFInstallation.current()
        if PFUser.current() != nil {
            installation!["User"] = PFUser.current()!
        }
        installation!.badge = 0
        installation!.saveInBackground()
        guard let shortcut = shortcutItem else { return }
        _ = handleShortcut(shortcut)
        self.shortcutItem = nil
        FBSDKAppEvents.activateApp()
    }
    
    func handleShortcut( _ shortcutItem:UIApplicationShortcutItem ) -> Bool {
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
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler( handleShortcut(shortcutItem) )
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        //PFUser.logOut()
    }
    
    func configSettings() {
        window?.tintColor = AppConfiguration.navColor
        UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).titleTextAttributes = (UIScreen.main.bounds.width <= 320) ?[NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 22)!] : [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 25)!]
        UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).barTintColor = AppConfiguration.navColor
        UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = AppConfiguration.navText
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : (UIScreen.main.bounds.width <= 320) ? UIFont(name: "AmericanTypewriter-Bold", size: 15)! : UIFont(name: "AmericanTypewriter-Bold", size: 17)!], for: UIControlState())
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : (UIScreen.main.bounds.width <= 320) ? UIFont(name: "AmericanTypewriter-Bold", size: 15)! : UIFont(name: "AmericanTypewriter-Bold", size: 18)!], for: UIControlState())
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation!.setDeviceTokenFrom(deviceToken)
        if PFUser.current() != nil {
            installation!["User"] = PFUser.current()
        }
        installation!.saveInBackground()
    }
    
    func handePush(_ dict: NSDictionary) {
        let ap = (dict["aps"] as? NSDictionary)!
        let type: String = (dict["type"] as? String)!
        let alertMessage: String = (ap["alert"] as? String)!
        hambutton.increment()
        PFUser.current()!.incrementKey(type)
        if type == "friendAccepted" {
            if PFUser.current()!["Friends"] != nil {
                var friends: [String] = PFUser.current()!["Friends"] as! [String]
                if !friends.contains(dict["ObjID"] as! String) {
                    friends.append(dict["ObjID"] as! String)
                    PFUser.current()!["Friends"] = friends
                    PFUser.current()!.saveInBackground()
                } else {
                    PFUser.current()!["Friends"] = friends
                    PFUser.current()!.saveInBackground()
                }
            } else {
                PFUser.current()!["Friends"] = [dict["ObjID"] as! String]
                PFUser.current()!.saveInBackground()
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
    
    func pushHandling(_ vc: UIViewController, alertMessage: String, type: String, dict: NSDictionary) {
        let titleLabel = CGRect(x: (UIScreen.main.bounds.width - UIScreen.main.bounds.width - 60) / 2 + 20, y: 0, width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.height)
        let imageBounds = CGRect(x: titleLabel.origin.x - Dimensions.imageSize - Dimensions.loaderTitleOffset, y: (Dimensions.height - Dimensions.imageSize) / 2, width: Dimensions.imageSize, height: Dimensions.imageSize)
        PFUser.query()?.getObjectInBackground(withId: dict["ObjID"] as! String, block: { user, error in
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
                                    PFQuery(className: "ActiveSessions").getObjectInBackground(withId: (dict["gameID"] as? String)!, block: {
                                        object, error in
                                        if error == nil {
                                            AppConfiguration.activeSession = object!
                                            AppConfiguration.activeSession!["callerTitle"] = "\(PFUser.current()!.Fullname()) joined your game"
                                            AppConfiguration.activeSession!["Accepted"] = true
                                            AppConfiguration.activeSession!.saveInBackground(block: {success, error in
                                                if error == nil && success == true {
                                                    if thisUser.objectId! != (object!["receiver"] as! PFUser).objectId! {
                                                        let push = PFPush()
                                                        let data = [
                                                            "alert" : "\(PFUser.current()!.Fullname()) joined your game",
                                                            "badge" : "Increment",
                                                            "ObjID" : (PFUser.current()?.objectId!)! as String,
                                                            "gameID" : object!.objectId!,
                                                            "type" : "accepted"]
                                                        let installQuery = PFInstallation.query()
                                                        installQuery?.whereKey("User", equalTo: thisUser)
                                                        push.setQuery(installQuery as? PFQuery<PFInstallation>)
                                                        push.setData(data)
                                                        push.sendInBackground(block: { success, error in
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
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let dict: NSDictionary = userInfo as NSDictionary? else {
            completionHandler(.newData)
            return 
        }
        handePush(dict)
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
}

public struct AppConfiguration {
    
    public static var cachePolicy: PFCachePolicy = PFCachePolicy.networkElseCache
    public static let ApiKey = "45441312"
    public static var SessionID: String?
    public static var publisherToken: String?
    public static var subscriberToken: String?
    fileprivate static var session: PFObject?
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
    
    public static var startingColor: Color = Color.gray.darkenedColor(0.5)
    
    public static var navColor: UIColor = UIColor.gray.darkenedColor(0.5)
    public static var navSelectedColor: UIColor = UIColor(red: 0.497982442378998, green: 0.498071908950806, blue: 0.497976779937744, alpha: 1.0)
    public static var navText: UIColor =  UIColor.white
    public static var backgroundColor = UIColor.peachColor()
    public static var appFont = UIFont(name: "AmericanTypewriter", size: 18)!
    public static var appFontSmall = UIFont(name: "AmericanTypewriter", size: 12)!
    public static var appFontSmallBold = UIFont(name: "AmericanTypewriter-Bold", size: 12)!
    public static var sideMenuColor = UIColor.yellow.complementaryColor()
    public static var sideMenuText: UIColor =  UIColor.antiqueWhiteColor()
    public static var textAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont(name: "AmericanTypewriter", size: 18)!] as [String : AnyObject]
    public static var smallTextAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.lightGray, NSFontAttributeName : UIFont(name: "AmericanTypewriter", size: 14)!] as [String : AnyObject]
    
    /*public static func SendGamePush(user: PFUser) {
        print("Sending Game Push!!!!")
        // Find users near a given location
        //let userQuery = PFUser.query()
        //userQuery.whereKey("location", nearGeoPoint: stadiumLocation, withinMiles: 1)
        // Find devices associated with these users
        guard let pushQuery: PFQuery<PFInstallation> = PFInstallation.query() as? PFQuery<PFInstallation> else {
            return
        }
        pushQuery.whereKey("User", equalTo: user)
        
        let push = PFPush()
        push.setQuery(pushQuery)
        push.setMessage("\(PFUser.current()!.Fullname()) sent you a game request!")
        push.sendInBackground { (success, error) in
            if error == nil && success == true {
                print("Success: \(success)")
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        }
    }*/
    
}
