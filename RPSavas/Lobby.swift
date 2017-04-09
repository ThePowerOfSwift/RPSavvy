//
//  Lobby.swift
//  RPSavas
//
//  Created by Dillon Murphy on 12/16/15.
//  Copyright © 2015 StrategynMobilePros. All rights reserved.
//


import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Parse
import ParseUI


var badgeview: BadgeView = BadgeView()

class Lobby: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var signInButton: GradientButton!
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicatorView.stopAnimation()
    }
    
    override func viewDidLoad() {
        navigationItem.title = "RPSavvy"
        AppConfiguration.scheme = AppConfiguration.startingColor.colorScheme(Color.ColorScheme.monochromatic)
        AppConfiguration.schemeSame = AppConfiguration.startingColor.colorScheme(Color.ColorScheme.analagous)
        AppConfiguration.complement = AppConfiguration.startingColor.complementaryColor()
        view.GradLayer()
        if PFUser.current() != nil {
            addHamMenu()
            addSwipers()
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedMenu)))
            
            /*let currentSettings: UIUserNotificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()!
            let currentType: UIUserNotificationType = currentSettings.types
            print("Type: \(currentType)")*/
            
            let application = UIApplication.shared
            if !application.isRegisteredForRemoteNotifications {
                
                /*let replyAction = UIMutableUserNotificationAction()
                replyAction.title = "Reply"
                replyAction.identifier = "chatReply"
                replyAction.activationMode = .Background
                replyAction.authenticationRequired = false
                replyAction.behavior = .TextInput
                
                let dismissAction = UIMutableUserNotificationAction()
                dismissAction.title = "Dismiss"
                dismissAction.identifier = "chatDismiss"
                dismissAction.activationMode = .Background
                dismissAction.authenticationRequired = false
                dismissAction.behavior = .Default
                
                //creating a category
                let notificationCategory:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
                notificationCategory.identifier = "CHAT_CATEGORY"
                notificationCategory .setActions([replyAction,dismissAction], forContext: UIUserNotificationActionContext.Default)
                */
                let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)//[notificationCategory])
                application.registerForRemoteNotifications()
                application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
                application.registerUserNotificationSettings(settings)
            }
            self.signInButton.isHidden = true
        } else {
            self.signInButton.isHidden = false
        }
    }
    
    @IBAction func TappedLoginSignup(_ sender: GradientButton) {
        sender.toggleAnimation() {
            self.NavPush("Login", completion: nil)
        }
    }
    
}

