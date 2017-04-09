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
    
    override func viewWillAppear(animated: Bool) {
        activityIndicatorView.stopAnimation()
    }
    
    override func viewDidLoad() {
        navigationItem.title = "RPSavvy"
        AppConfiguration.scheme = AppConfiguration.startingColor.colorScheme(Color.ColorScheme.Monochromatic)
        AppConfiguration.schemeSame = AppConfiguration.startingColor.colorScheme(Color.ColorScheme.Analagous)
        AppConfiguration.complement = AppConfiguration.startingColor.complementaryColor()
        view.GradLayer()
        if PFUser.currentUser() != nil {
            addHamMenu()
            addSwipers()
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedMenu)))
            
            /*let currentSettings: UIUserNotificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()!
            let currentType: UIUserNotificationType = currentSettings.types
            print("Type: \(currentType)")*/
            
            let application = UIApplication.sharedApplication()
            if !application.isRegisteredForRemoteNotifications() {
                
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
                let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)//[notificationCategory])
                application.registerForRemoteNotifications()
                application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
                application.registerUserNotificationSettings(settings)
            }
            self.signInButton.hidden = true
        } else {
            self.signInButton.hidden = false
        }
    }
    
    @IBAction func TappedLoginSignup(sender: GradientButton) {
        sender.toggleAnimation() {
            self.NavPush("Login", completion: nil)
        }
    }
    
}

