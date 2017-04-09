//
//  ProfileViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/20/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var userImageView: PFImageView!
    @IBOutlet var nameField: KaedeTextField!
    
    @IBOutlet weak var Loses: LTMorphingLabel!
    @IBOutlet weak var Wins: LTMorphingLabel!
    @IBOutlet weak var Streak: LTMorphingLabel!
    
    @IBOutlet weak var SaveButton: GradientButton!
    @IBOutlet weak var ResetButton : GradientButton!
    
    var saveChanges: Bool = false {
        didSet {
            self.SaveButton.isHidden = !self.saveChanges
            self.SaveButton.useBlueStyle()
            self.SaveButton.setNeedsDisplay()
        }
    }
    
    fileprivate var profileUser: PFUser = PFUser.current()!
    var user: PFUser {
        get {
            return profileUser
        }
        set {
            self.profileUser = newValue
        }
    }
    
    func tappedReset(_ sender: GradientButton) {
        ResetButton.toggleAnimation({
            self.Wins.text = "Wins: 0"
            self.Loses.text = "Losses: 0"
            self.Streak.text = "Win Streak: 0"
            PFUser.current()!["Wins"] = 0
            PFUser.current()!["Losses"] = 0
            PFUser.current()!["WinStreak"] = 0
            PFUser.current()!.saveInBackground()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dismissKeyboard()
        activityIndicatorView.stopAnimation()
        if self.user["picture"] != nil {
            self.userImageView.file = self.user["picture"] as? PFFile
            self.userImageView.loadInBackground()
            if self.user["fullname"] != nil {
                self.nameField.text = self.user.Fullname()
            }
        } else {
            if self.user["fullname"] != nil {
                self.userImageView.imageWithString(self.user.Fullname(), color: .charcoalColor(), circular: false, fontAttributes: nil)
                self.nameField.text = self.user.Fullname()
            } else {
                self.userImageView.imageWithString("R P S", color: .charcoalColor(), circular: false, fontAttributes: nil)
            }
        }
        if self.user["Wins"] != nil {
            self.Wins.text = "Wins: \(self.user["Wins"] as! Int)"
        }
        if self.user["Losses"] != nil {
            self.Loses.text = "Losses: \(self.user["Losses"] as! Int)"
        }
        if self.user["WinStreak"] != nil {
            self.Streak.text = "Win Streak: \(self.user["WinStreak"] as! Int)"
        }
        if self.user == PFUser.current()! {
            ResetButton.isHidden = false
            ResetButton.setNeedsDisplay()
            nameField.setNeedsLayout()
            //SaveButton.hidden = false
            addLogOut()
            navigationItem.title = "Edit Profile"
            view.isUserInteractionEnabled = true
        } else {
            ResetButton.isHidden = true
            SaveButton.isHidden = true
            navigationItem.title = "RPSavvy"
            view.isUserInteractionEnabled = false
            navigationItem.setRightBarButton(UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil), animated: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveChanges = true
        return true
    }
    
    func setup() {
        nameField.adjustsFontSizeToFitWidth = true
        addBackButton()
        ResetButton.useRedStyle()
        SaveButton.useBlueStyle()
        addGradLayer()
        ResetButton.addTarget(self, action: #selector(self.tappedReset), for: UIControlEvents.touchUpInside)
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.photoButtonPressed)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard)))
    }
    
    override func viewDidLoad() {
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveUser() {
        if saveChanges == true {
            saveChanges = false
            PFUser.current()!["fullname"] = nameField.text!
            PFUser.current()!.saveInBackground(block: {
                succeeded, error in
                if error == nil {
                    ProgressHUD.showSuccess("Updated Profile")
                } else {
                    ProgressHUD.showError(error?.localizedDescription)
                }
            })
        } else {
            ProgressHUD.showError("No Changes To Save")
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: GradientButton) {
        self.dismissKeyboard()
        SaveButton.toggleAnimation({
            self.saveUser()
        })
    }

    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as! UIImage
        if image.size.width > 280 {
            image = Images.resizeImage(image, width: 280, height: 280)!
        }
        let pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
        pictureFile!.saveInBackground()
        PFUser.current()!["picture"] = pictureFile
        picker.dismiss(animated: true, completion: nil)
        saveChanges = true
        SaveButton.isHidden = false
    }

}
