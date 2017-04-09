//
//  Login.swift
//  RPSavas
//
//  Created by Dillon Murphy on 1/30/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Foundation
import Parse
import ParseUI
import FBSDKCoreKit
import ParseFacebookUtilsV4
import ParseTwitterUtils


let defaults = NSUserDefaults.standardUserDefaults()

class Login: UIViewController, UITextFieldDelegate, BEMCheckBoxDelegate {
    
    
    private var idx: Int = 0
    private let backGroundArray = [UIImage(named:"rock"),UIImage(named:"paper"),UIImage(named:"scissors")]
    
    //MARK: Outlets for UI Elements.
    @IBOutlet weak var emailField: ImageTextField!
    @IBOutlet weak var imageView:       UIImageView!
    @IBOutlet weak var passwordField:   ImageTextField!
    
    @IBOutlet weak var LoginButton: GradientButton!
    @IBOutlet weak var signupButton: GradientButton!
    @IBOutlet weak var TextFieldsStack: UIStackView!
    @IBOutlet weak var StackLogin: UIStackView!
    @IBOutlet weak var FacebookButton: UIButton!
    @IBOutlet weak var TwitterButton: UIButton!
    @IBOutlet weak var customCheckbox: BEMCheckBox!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var LogoConstraint: NSLayoutConstraint!
    
    func didTapCheckBox(checkBox:BEMCheckBox) {
    }
    
    func animationDidStopForCheckBox(checkBox:BEMCheckBox) {
        
    }
    
    func loginsignupEmailSaveCheck() {
        if customCheckbox.on == true {
            defaults.setValue(PFUser.currentUser()!.email!, forKey: "userEmail")
        } else {
            defaults.removeObjectForKey("userEmail")
        }
    }
    
    @IBAction func twitLog(sender: UIButton) {
        PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    if !PFFacebookUtils.isLinkedWithUser(user) {
                        PFFacebookUtils.linkUserInBackground(user, withReadPermissions: nil, block: {
                            (succeeded: Bool?, error: NSError?) -> Void in
                            if error != nil {
                                ProgressHUD.showError(error?.localizedDescription)
                            } else {
                                if succeeded == true {}
                            }
                        })
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    if !PFFacebookUtils.isLinkedWithUser(user) {
                        PFFacebookUtils.linkUserInBackground(user, withReadPermissions: nil, block: {
                            (succeeded: Bool?, error: NSError?) -> Void in
                            if error != nil {
                                ProgressHUD.showError(error?.localizedDescription)
                            } else {
                                if succeeded == true {}
                            }
                        })
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                ProgressHUD.showError("Twitter Login Failed")
            }
        }
    }
    
    func fabo() {
        let requestParameters = ["fields": "id, email, first_name, last_name"]
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        userDetails.startWithCompletionHandler { (connection, result, error:NSError!) -> Void in
            if(error != nil) {
                PFUser.currentUser()!.deleteInBackground()
                PFUser.logOut()
                
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            if(result != nil) {
                let myresult = (result as? NSDictionary)!
                let user : PFUser = PFUser.currentUser()!
                let userId: String = (myresult["id"] as? String)!
                let userFirstName: String = (myresult["first_name"] as? String)!
                let userLastName: String = (myresult["last_name"] as? String)!
                let userEmail: String = (myresult["email"] as? String)!
                user.username = userEmail
                user.email = userEmail
                user["FacebookID"] = userId
                user["Groups"] = []
                let fullName = "\(userFirstName) \(userLastName)"
                if fullName.characters.count > 0 {
                    user["fullname"] = fullName
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    let profilePictureUrl = NSURL(string: userProfile)
                    let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                    if(profilePictureData != nil) {
                        var image = UIImage(data: profilePictureData!)
                        if image!.size.width > 280 {
                            image = Images.resizeImage(image!, width: 280, height: 280)!
                        }
                        let pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image!, 0.6)!)
                        pictureFile!.saveInBackground()
                        user["picture"] = pictureFile
                        user.saveInBackground()
                    }
                }
                let friendRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil)
                friendRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                    guard let resultdict = result as? NSDictionary else {
                        return
                    }
                    let data : NSArray = resultdict.objectForKey("data") as! NSArray
                    for i in 0 ..< data.count {
                        let valueDict : NSDictionary = data[i] as! NSDictionary
                        let id = valueDict.objectForKey("id") as! String
                        let Querier = PFUser.query()
                        Querier!.whereKey("FacebookID", equalTo: id)
                        Querier!.getFirstObjectInBackgroundWithBlock( { (object, error) in
                            if error == nil  {
                                if PFUser.currentUser()!["Friends"] != nil {
                                    var friends: [String] = PFUser.currentUser()!["Friends"] as! [String]
                                    if !friends.contains(object!.objectId!) {
                                        friends.append(object!.objectId!)
                                        PFUser.currentUser()!["Friends"] = friends
                                        PFUser.currentUser()!.saveInBackground()
                                    }
                                } else {
                                    PFUser.currentUser()!["Friends"] = [object!.objectId!]
                                    PFUser.currentUser()!.saveInBackground()
                                }
                            }
                        })
                    }
                }
                user.saveInBackgroundWithBlock({
                    succeeded, error in
                    if error != nil {
                        PFUser.currentUser()!.deleteInBackground()
                        PFUser.logOut()
                        ProgressHUD.showError(error?.localizedDescription)
                    } else {
                        kConstantObj.appDelegateSetup()
                        self.loginsignupEmailSaveCheck()
                    }
                })
            }
        }
    }
    
    @IBAction func FacebookTapped(sender: UIButton) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email"]) {
            (user: PFUser?, error: NSError?) -> Void in
            if error == nil {
                if let user = user {
                    if user.isNew {
                        self.fabo()
                    } else {
                        kConstantObj.appDelegateSetup()
                        self.loginsignupEmailSaveCheck()
                    }
                } else {
                    ProgressHUD.showError("Facebook Login Failed")
                }
            } else {
                ProgressHUD.showError("Facebook Login Failed")
            }
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        /*dispatch_async(dispatch_get_main_queue()) {
            self.emailField.alpha = 0
            self.passwordField.alpha = 0
            self.LoginButton.alpha = 0
            self.FacebookButton.alpha = 0
            self.signupButton.alpha = 0
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.emailField.alpha = 1.0
                self.passwordField.alpha = 1.0
                self.LoginButton.alpha = 0.9
                self.FacebookButton.alpha = 0.9
                self.signupButton.alpha = 0.9
                }, completion: nil)
        }*/
        addKeyboard()
        guard let userEmail: String = defaults.valueForKey("userEmail") as? String else {
            return
        }
        emailField.text = userEmail
        customCheckbox.setOn(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeKeyboard()
    }
    
    override func viewWillAppear(animated: Bool) {
        facebookLogin.logOut()
        PFUser.logOut()
    }
    
    override func viewDidLoad() {
        //StackLogin.spacing = (UIScreen.mainScreen().bounds.width <= 320) ? 10 : 25
        //TextFieldsStack.spacing = (UIScreen.mainScreen().bounds.width <= 320) ? 5 : 10
        setup()
    }

    func setup() {
        //self.view.layoutIfNeeded()
        UIView.animateWithDuration(1, animations: {
            self.LogoConstraint.constant = (UIScreen.mainScreen().bounds.width <= 320) ? 100 : 220
            self.heightConstraint.constant = (UIScreen.mainScreen().bounds.width <= 320) ? 40 : 50
            //self.view.layoutIfNeeded()
        })
        LoginButton.useLoginStyle()
        signupButton.useLoginStyle()
        LoginButton.enabled = false
        signupButton.enabled = false
        let forgotButton = UIButton(type: .System)
        forgotButton.setTitle("Forgot Password?", forState: .Normal)
        forgotButton.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: 15)!
        forgotButton.addTarget(self, action: #selector(Login.forgot(_:)), forControlEvents: .TouchUpInside)
        forgotButton.setTitleColor(.whiteColor(), forState: .Normal)
        self.TextFieldsStack.addArrangedSubview(forgotButton)
        addDismissGesture()
        addGradLayer()
        addBackButton()
        imageView.image = UIImage(named:"rock")
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(Login.changeImage), userInfo: nil, repeats: true)
    }
    
    func forgot(sender: UIButton) {
        let alerter = UIAlertController(title: "Enter Email", message: nil, preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in}
        alerter.addAction(cancelAction)
        let nextAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            let text: String = (alerter.textFields?.first?.text)!
            PFUser.requestPasswordResetForEmailInBackground(text)
            let alerter2 = UIAlertController(title: "Request Sent", message: nil, preferredStyle: .Alert)
            let cancelAction2: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in}
            alerter2.addAction(cancelAction2)
            self.presentViewController(alerter2, animated: true, completion: nil)
        }
        alerter.addAction(nextAction)
        alerter.addTextFieldWithConfigurationHandler { (textField) -> Void in}
        presentViewController(alerter, animated: true, completion: nil)
    }
    
    func logsignButton() {
        if emailField.text!.isEmpty || passwordField.text!.isEmpty {
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.LoginButton.normalGradients = [UIColor(red: 0.667, green: 0.15, blue: 0.152, alpha: 1.0),UIColor(red: 0.841, green: 0.566, blue: 0.566, alpha: 1.0),UIColor(red: 0.75, green: 0.341, blue: 0.345, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0)]
                self.signupButton.normalGradients = [UIColor(red: 0.667, green: 0.15, blue: 0.152, alpha: 1.0),UIColor(red: 0.841, green: 0.566, blue: 0.566, alpha: 1.0),UIColor(red: 0.75, green: 0.341, blue: 0.345, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0)]
                }, completion: nil)
            LoginButton.enabled = false
            signupButton.enabled = false
        } else {
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.LoginButton.normalGradients = [UIColor(red: 0.15, green: 0.667, blue: 0.152, alpha: 1.0),UIColor(red: 0.566, green: 0.841, blue: 0.566, alpha: 1.0),UIColor(red: 0.341, green: 0.75, blue: 0.345, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0)]
                self.signupButton.normalGradients = [UIColor(red: 0.15, green: 0.667, blue: 0.152, alpha: 1.0),UIColor(red: 0.566, green: 0.841, blue: 0.566, alpha: 1.0),UIColor(red: 0.341, green: 0.75, blue: 0.345, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0)]
                }, completion: nil)
            LoginButton.enabled = true
            signupButton.enabled = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.logsignButton()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailField {
            if passwordField.text == "" {
                passwordField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func changeImage(){
        idx = idx == backGroundArray.count-1 ? 0 : idx + 1
        UIView.transitionWithView(self.imageView, duration: 1, options: .TransitionCrossDissolve, animations: {self.imageView.image = self.backGroundArray[self.idx]}, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func LoginPressed(sender: GradientButton) {
        activityIndicatorView.startAnimation()
        PFUser.logInWithUsernameInBackground(self.emailField.text!, password:self.passwordField.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                activityIndicatorView.stopAnimation()
                kConstantObj.appDelegateSetup()
                self.loginsignupEmailSaveCheck()
            } else {
                activityIndicatorView.stopAnimation()
                ProgressHUD.showError("Please Enter Valid Username/Password")
            }
        }
    }
    
    @IBAction func SignupPressed(sender: GradientButton) {
        activityIndicatorView.startAnimation()
        let user = PFUser()
        user.username = self.emailField.text!
        user.password = self.passwordField.text!
        user.email = self.emailField.text!
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString: String = (error.userInfo["error"] as? String)!
                activityIndicatorView.stopAnimation()
                ProgressHUD.showError(errorString)
            } else {
                activityIndicatorView.stopAnimation()
                kConstantObj.appDelegateSetup()
                self.loginsignupEmailSaveCheck()
                self.NavPush("ProfileViewController", completion: {
                    vc in
                    (vc as! ProfileViewController).user = PFUser.currentUser()!
                })
            }
        }
    }
}


