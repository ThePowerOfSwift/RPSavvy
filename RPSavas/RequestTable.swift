//
//  RequestTable.swift
//  RPSavas
//
//  Created by Dillon Murphy on 3/14/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//


import Foundation
import UIKit
import Parse
import ParseUI
import ParseFacebookUtilsV4

let inviteRequestsbutton: MIBadgeButton = MIBadgeButton(type: .Custom)
var evapTitle: UILabel = UILabel(frame: CGRect(x: UIScreen.mainScreen().bounds.midX - 100, y: 0, width: 200, height: 55))

extension RequestTable {
    
    func addInviteRequest() {
        inviteRequestsbutton.frame = CGRect(x:sideMenuNavigationController!.navigationBar.frame.width - (sideMenuNavigationController!.navigationBar.frame.height + 15),y:0,width:sideMenuNavigationController!.navigationBar.frame.height,height:sideMenuNavigationController!.navigationBar.frame.height)
        inviteRequestsbutton.badgeTextColor = UIColor.whiteColor()
        inviteRequestsbutton.badgeBackgroundColor = UIColor.redColor()
        inviteRequestsbutton.badgeEdgeInsets = UIEdgeInsetsMake(15, 0, 0, 10)
        inviteRequestsbutton.setImage(UIImage(named: "Switch")!, forState: .Normal)
        inviteRequestsbutton.tintColor = .whiteColor()
        inviteRequestsbutton.addTarget(self, action:  #selector(self.tappedInviteRequest), forControlEvents: .TouchUpInside)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: inviteRequestsbutton), animated: false)
    }
    
    func addTitleView() {
        evapTitle.textAlignment = NSTextAlignment.Center
        evapTitle.adjustsFontSizeToFitWidth = true
        evapTitle.minimumScaleFactor = 0.5
        evapTitle.font = (UIScreen.mainScreen().bounds.width <= 320) ? UIFont(name: "AmericanTypewriter-Semibold", size: 22)! : UIFont(name: "AmericanTypewriter-Semibold", size: 25)
        evapTitle.textColor = UIColor.whiteColor()
        self.navigationItem.titleView = evapTitle
        evapTitle.evap("Game Requests")
    }
    
    func tappedInviteRequest(sender: MIBadgeButton) {
        self.GameList.removeAll()
        requestsList = !requestsList
        if requestsList {
            PFUser.currentUser()!["accepted"] = 0
        } else {
            PFUser.currentUser()!["gameInvite"] = 0
        }
        PFUser.currentUser()!.saveInBackground()
        inviteRequestsbutton.badgeString = 0
        sender.spin() {
            self.predicate = self.requestsList ? NSPredicate(format: "caller = %@", PFUser.currentUser()!) : NSPredicate(format: "receiver = %@", PFUser.currentUser()!)
            evapTitle.evap(self.requestsList ? "Game Invites" : "Game Requests")
            self.forceFetchData()
        }
    }
}

class  RequestTable: ParseTable, MGSwipeTableCellDelegate {
    
    var predicate: NSPredicate = NSPredicate(format: "receiver = %@", PFUser.currentUser()!)
    var GameList: [PFObject] = [PFObject]()
    var requestsList: Bool = false
    
    override func viewDidLoad() {
        addInviteRequest()
        addTitleView()
    }
    
    override func viewDidAppear(animated: Bool) {
        if !self.requestsList {
            self.predicate = NSPredicate(format: "receiver = %@", PFUser.currentUser()!)
            PFUser.currentUser()!["gameInvite"] = 0
            PFUser.currentUser()!.saveInBackground()
            inviteRequestsbutton.badgeString = PFUser.currentUser()!["accepted"] as! Int
        } else {
            self.predicate = NSPredicate(format: "caller = %@", PFUser.currentUser()!)
            PFUser.currentUser()!["accepted"] = 0
            PFUser.currentUser()!.saveInBackground()
            inviteRequestsbutton.badgeString = PFUser.currentUser()!["gameInvite"] as! Int
        }
        self.forceFetchData()
    }
    
    override func fetchData() {
        if (!requestInProgress && !stopFetching) {
            requestInProgress = true
            activityIndicatorView.startAnimation()
            let query = PFQuery(className: "ActiveSessions", predicate: predicate)
            query.limit = 20
            query.skip = pageNumber*20
            query.cachePolicy = AppConfiguration.cachePolicy
            query.maxCacheAge = 3600
            query.whereKey("receiverID", notEqualTo: "Quick")
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock({
                objects, error in
                if error == nil {
                    if self.pageNumber == 0 {
                        self.GameList.removeAll()
                    }
                    var array : [PFObject] = [PFObject]()
                    if (self.forceRefresh) {
                        for follow in objects! {
                            array.append(follow)
                        }
                    }
                    self.GameList.appendContentsOf(array)
                    self.tableView.reloadData()
                    activityIndicatorView.stopAnimation()
                    self.requestInProgress = false
                    self.forceRefresh = false
                    if (self.GameList.count<20) {
                        self.stopFetching = false
                    }
                    self.pageNumber += 1
                } else {
                    self.requestInProgress = false
                    self.forceRefresh = false
                    activityIndicatorView.stopAnimation()
                }
            })
        } else {
            activityIndicatorView.stopAnimation()
        }
    }
    
    override func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        let viewBounds = scrollView.bounds
        let bottomView = UIView(frame: viewBounds)
        bottomView.GradLayer()
        let imager : UIImage = (UIScreen.mainScreen().bounds.width <= 320) ? Images.resizeImage(UIImage(named: "RPSLogo")!, width: UIImage(named: "RPSLogo")!.size.width*0.6, height: UIImage(named: "RPSLogo")!.size.height*0.6)! : Images.resizeImage(UIImage(named: "RPSLogo")!, width: UIImage(named: "RPSLogo")!.size.width*0.8, height: UIImage(named: "RPSLogo")!.size.height*0.8)!
        let imageView: UIImageView = UIImageView(image: imager)
        imageView.frame = (UIScreen.mainScreen().bounds.width <= 320) ? CGRect(x: self.view.bounds.midX - ((viewBounds.width * 0.6) / 2), y: viewBounds.height / 8 , width: viewBounds.width * 0.6 , height: viewBounds.width * 0.6) : CGRect(x: self.view.bounds.midX - ((viewBounds.width * 0.8) / 2), y: viewBounds.height / 8 , width: viewBounds.width * 0.8 , height: viewBounds.width * 0.8)
        imageView.contentMode = .ScaleAspectFit
        let label = UILabel(frame: CGRect(x: 20, y: imageView.frame.maxY, width: viewBounds.width - 40, height: 50))
        label.attributedText = evapTitle.text == "Game Invites" ? NSAttributedString(string: "No Game Requests", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 20)!]) : NSAttributedString(string: "No Game Invites", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 20)!])
        label.textAlignment = .Center
        let label2 = UILabel(frame: CGRect(x: 20, y: label.frame.maxY, width: viewBounds.width - 40, height: 80))
        label2.attributedText = NSAttributedString(string: "Send a Game Request to a Friend to start a new game or try out our Quick Match mode and play against a random opponent", attributes: AppConfiguration.smallTextAttributes)
        label2.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label2.textAlignment = .Center
        label2.numberOfLines = 3
        let QuickMatch = GradientButton(frame: CGRect(x: 20, y: label2.frame.maxY + 15, width: viewBounds.width - 40, height: 50))
        QuickMatch.addTarget(self, action: #selector(self.quickMatchPressed(_:)), forControlEvents: .TouchUpInside)
        QuickMatch.setAttributedTitle(NSAttributedString(string: "Quick Match", attributes: AppConfiguration.textAttributes), forState:  UIControlState.Normal)
        QuickMatch.useBlackStyle()
        QuickMatch.layer.cornerRadius = 8.0
        QuickMatch.layer.masksToBounds = true
        let GameRequest = GradientButton(frame: CGRect(x: 20, y: QuickMatch.frame.maxY + 15, width: viewBounds.width - 40, height: 50))
        GameRequest.setAttributedTitle(NSAttributedString(string: "Send a Game Request to a Friend", attributes: AppConfiguration.textAttributes), forState:  UIControlState.Normal)
        GameRequest.addTarget(self, action: #selector(self.gameRequestPressed(_:)), forControlEvents: .TouchUpInside)
        GameRequest.useBlackStyle()
        GameRequest.layer.cornerRadius = 8.0
        GameRequest.layer.masksToBounds = true
        GameRequest.titleLabel?.numberOfLines = 2
        GameRequest.titleLabel?.lineBreakMode = .ByWordWrapping
        GameRequest.titleLabel?.textAlignment = NSTextAlignment.Center
        bottomView.addSubview(imageView)
        bottomView.addSubview(label)
        bottomView.addSubview(label2)
        bottomView.addSubview(QuickMatch)
        bottomView.addSubview(GameRequest)
        return bottomView
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! SwipeCell).setupUserRequest(self)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GameList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SwipeCell", forIndexPath: indexPath) as? SwipeCell
        cell!.index = indexPath
        cell!.table = self
        cell!.UserRequest = self.GameList[indexPath.row]
        return cell!
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.GameList.removeAll()
    }
    
}
