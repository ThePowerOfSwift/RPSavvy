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


let defaults = UserDefaults.standard

class Login: UIViewController, UITextFieldDelegate, BEMCheckBoxDelegate {
    
    
    fileprivate var idx: Int = 0
    fileprivate let backGroundArray = [UIImage(named:"rock"),UIImage(named:"paper"),UIImage(named:"scissors")]
    
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
    
    func didTap(_ checkBox:BEMCheckBox) {
    }
    
    func animationDidStop(for checkBox:BEMCheckBox) {
        
    }
    
    func loginsignupEmailSaveCheck() {
        if customCheckbox.on == true {
            defaults.setValue(PFUser.current()!.email!, forKey: "userEmail")
        } else {
            defaults.removeObject(forKey: "userEmail")
        }
    }
    
    @IBAction func twitLog(_ sender: UIButton) {
        PFTwitterUtils.logIn {
            (user: PFUser?, error: Error?) -> Void in
            if let user = user {
                if user.isNew {
                    if !PFFacebookUtils.isLinked(with: user) {
                        PFFacebookUtils.linkUser(inBackground: user, withReadPermissions: nil, block: {
                            (succeeded: Bool?, error: Error?) -> Void in
                            if error != nil {
                                ProgressHUD.showError(error?.localizedDescription)
                            } else {
                                if succeeded == true {}
                            }
                        })
                    }
                    self.dismiss(animated: true, completion: nil)
                } else {
                    if !PFFacebookUtils.isLinked(with: user) {
                        PFFacebookUtils.linkUser(inBackground: user, withReadPermissions: nil, block: {
                            (succeeded: Bool?, error: Error?) -> Void in
                            if error != nil {
                                ProgressHUD.showError(error?.localizedDescription)
                            } else {
                                if succeeded == true {}
                            }
                        })
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                ProgressHUD.showError("Twitter Login Failed")
            }
        }
    }
    
    func fabo() {
        let requestParameters = ["fields": "id, email, first_name, last_name"]
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        userDetails?.start { (connection, result, error:Error!) -> Void in
            if(error != nil) {
                PFUser.current()!.deleteInBackground()
                PFUser.logOut()
                
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            if(result != nil) {
                let myresult = (result as? NSDictionary)!
                let user : PFUser = PFUser.current()!
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
                
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    let profilePictureUrl = URL(string: userProfile)
                    let profilePictureData = try? Data(contentsOf: profilePictureUrl!)
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
                friendRequest?.start { (connection : FBSDKGraphRequestConnection!, result : Any!, error : Error!) -> Void in
                    guard let resultdict = result as? NSDictionary else {
                        return
                    }
                    let data : NSArray = resultdict.object(forKey: "data") as! NSArray
                    for i in 0 ..< data.count {
                        let valueDict : NSDictionary = data[i] as! NSDictionary
                        let id = valueDict.object(forKey: "id") as! String
                        let Querier = PFUser.query()
                        Querier!.whereKey("FacebookID", equalTo: id)
                        Querier!.getFirstObjectInBackground( block: { (object, error) in
                            if error == nil  {
                                if PFUser.current()!["Friends"] != nil {
                                    var friends: [String] = PFUser.current()!["Friends"] as! [String]
                                    if !friends.contains(object!.objectId!) {
                                        friends.append(object!.objectId!)
                                        PFUser.current()!["Friends"] = friends
                                        PFUser.current()!.saveInBackground()
                                    }
                                } else {
                                    PFUser.current()!["Friends"] = [object!.objectId!]
                                    PFUser.current()!.saveInBackground()
                                }
                            }
                        })
                    }
                }
                user.saveInBackground(block: {
                    succeeded, error in
                    if error != nil {
                        PFUser.current()!.deleteInBackground()
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
    
    @IBAction func FacebookTapped(_ sender: UIButton) {
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile", "email"]) {
            (user: PFUser?, error: Error?) -> Void in
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
    
    
    override func viewDidAppear(_ animated: Bool) {
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
        guard let userEmail: String = defaults.value(forKey: "userEmail") as? String else {
            return
        }
        emailField.text = userEmail
        customCheckbox.setOn(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        UIView.animate(withDuration: 1, animations: {
            self.LogoConstraint.constant = (UIScreen.main.bounds.width <= 320) ? 100 : 220
            self.heightConstraint.constant = (UIScreen.main.bounds.width <= 320) ? 40 : 50
            //self.view.layoutIfNeeded()
        })
        LoginButton.useLoginStyle()
        signupButton.useLoginStyle()
        LoginButton.isEnabled = false
        signupButton.isEnabled = false
        let forgotButton = UIButton(type: .system)
        forgotButton.setTitle("Forgot Password?", for: UIControlState())
        forgotButton.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: 15)!
        forgotButton.addTarget(self, action: #selector(Login.forgot(_:)), for: .touchUpInside)
        forgotButton.setTitleColor(.white, for: UIControlState())
        self.TextFieldsStack.addArrangedSubview(forgotButton)
        addDismissGesture()
        addGradLayer()
        addBackButton()
        imageView.image = UIImage(named:"rock")
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(Login.changeImage), userInfo: nil, repeats: true)
    }
    
    func forgot(_ sender: UIButton) {
        let alerter = UIAlertController(title: "Enter Email", message: nil, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in}
        alerter.addAction(cancelAction)
        let nextAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            let text: String = (alerter.textFields?.first?.text)!
            PFUser.requestPasswordResetForEmail(inBackground: text)
            let alerter2 = UIAlertController(title: "Request Sent", message: nil, preferredStyle: .alert)
            let cancelAction2: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel) { action -> Void in}
            alerter2.addAction(cancelAction2)
            self.present(alerter2, animated: true, completion: nil)
        }
        alerter.addAction(nextAction)
        alerter.addTextField { (textField) -> Void in}
        present(alerter, animated: true, completion: nil)
    }
    
    func logsignButton() {
        if emailField.text!.isEmpty || passwordField.text!.isEmpty {
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.LoginButton.normalGradients = [UIColor(red: 0.667, green: 0.15, blue: 0.152, alpha: 1.0),UIColor(red: 0.841, green: 0.566, blue: 0.566, alpha: 1.0),UIColor(red: 0.75, green: 0.341, blue: 0.345, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0)]
                self.signupButton.normalGradients = [UIColor(red: 0.667, green: 0.15, blue: 0.152, alpha: 1.0),UIColor(red: 0.841, green: 0.566, blue: 0.566, alpha: 1.0),UIColor(red: 0.75, green: 0.341, blue: 0.345, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0),UIColor(red: 0.592, green: 0.0, blue: 0.0, alpha: 1.0)]
                }, completion: nil)
            LoginButton.isEnabled = false
            signupButton.isEnabled = false
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.LoginButton.normalGradients = [UIColor(red: 0.15, green: 0.667, blue: 0.152, alpha: 1.0),UIColor(red: 0.566, green: 0.841, blue: 0.566, alpha: 1.0),UIColor(red: 0.341, green: 0.75, blue: 0.345, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0)]
                self.signupButton.normalGradients = [UIColor(red: 0.15, green: 0.667, blue: 0.152, alpha: 1.0),UIColor(red: 0.566, green: 0.841, blue: 0.566, alpha: 1.0),UIColor(red: 0.341, green: 0.75, blue: 0.345, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0),UIColor(red: 0.0, green: 0.592, blue: 0.0, alpha: 1.0)]
                }, completion: nil)
            LoginButton.isEnabled = true
            signupButton.isEnabled = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.logsignButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        UIView.transition(with: self.imageView, duration: 1, options: .transitionCrossDissolve, animations: {self.imageView.image = self.backGroundArray[self.idx]}, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func LoginPressed(_ sender: GradientButton) {
        activityIndicatorView.startAnimation()
        PFUser.logInWithUsername(inBackground: self.emailField.text!, password:self.passwordField.text!) {
            (user: PFUser?, error: Error?) -> Void in
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
    
    @IBAction func SignupPressed(_ sender: GradientButton) {
        activityIndicatorView.startAnimation()
        let user = PFUser()
        user.username = self.emailField.text!
        user.password = self.passwordField.text!
        user.email = self.emailField.text!
        user.signUpInBackground {
            (succeeded: Bool, error: Error?) -> Void in
            if let error = error {
                let errorString: String = ((error as NSError).userInfo["error"] as? String)!
                activityIndicatorView.stopAnimation()
                ProgressHUD.showError(errorString)
            } else {
                activityIndicatorView.stopAnimation()
                kConstantObj.appDelegateSetup()
                self.loginsignupEmailSaveCheck()
                self.NavPush("ProfileViewController", completion: {
                    vc in
                    (vc as! ProfileViewController).user = PFUser.current()!
                })
            }
        }
    }
}


