//
//  InviteTable.swift
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

class  InviteTable: ParseTable, MGSwipeTableCellDelegate {
    
    var invitesList: [PFObject] = [PFObject]()
    
    override func fetchData() {
        if (!requestInProgress && !stopFetching) {
            requestInProgress = true
            activityIndicatorView.startAnimation()
            let query = PFQuery(className: "Notification")
            query.limit = 20
            query.skip = pageNumber*20
            query.whereKey("User", equalTo: PFUser.currentUser()!)
            query.whereKey("Type", equalTo: "friendInvite")
            query.cachePolicy = AppConfiguration.cachePolicy
            query.maxCacheAge = 3600
            query.findObjectsInBackgroundWithBlock({
                objects, error in
                if error == nil {
                    if self.pageNumber == 0 {
                        self.invitesList.removeAll()
                    }
                    var array : [PFObject] = [PFObject]()
                    if (self.forceRefresh) {
                        for follow in objects! {
                            array.append(follow)
                        }
                    }
                    self.invitesList.appendContentsOf(array)
                    self.tableView.reloadData()
                    activityIndicatorView.stopAnimation()
                    self.requestInProgress = false
                    self.forceRefresh = false
                    if (self.invitesList.count<20) {
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
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.invitesList.removeAll()
    }
    
    override func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        let viewBounds = scrollView.bounds
        let image: UIImageView = UIImageView(image: UIImage(named: "RPSLogo"))
        image.frame = UIScreen.mainScreen().bounds.width > 320 ? CGRect(x: self.view.bounds.midX - ((viewBounds.width * 0.8) / 2), y: viewBounds.height / 5 , width: viewBounds.width * 0.8 , height: viewBounds.width * 0.8) : CGRect(x: self.view.bounds.midX - ((viewBounds.width / 2.5) / 2), y: viewBounds.height / 4.5 , width: viewBounds.width / 2.5, height: viewBounds.width / 2.5)
        image.contentMode = .ScaleAspectFit
        let label = UILabel(frame: CGRect(x: 20, y: image.frame.maxY + 5, width: viewBounds.width - 40, height: 50))
        label.text = "No Friend Requests"
        label.font = UIFont.boldSystemFontOfSize(18.0)
        label.textColor = .whiteColor()
        label.textAlignment = .Center
        let label2 = UILabel(frame: CGRect(x: 20, y: label.frame.maxY + 5, width: viewBounds.width - 40, height: 80))
        label2.text = "Send a Friend Request to a Friend or use Facebook to find your Friends"
        label2.font = UIFont.boldSystemFontOfSize(14.0)
        label2.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label2.textAlignment = .Center
        label2.numberOfLines = 2
        label2.textColor = .lightGrayColor()
        let QuickMatch = GradientButton(frame: CGRect(x: 20, y: label2 .frame.maxY + 15, width: viewBounds.width - 40, height: 40))
        QuickMatch.addTarget(self, action: #selector(InviteTable.findFriendsPressed(_:)), forControlEvents: .TouchUpInside)
        QuickMatch.setTitle("Find Friends", forState: UIControlState.Normal)
        QuickMatch.useBlackStyle()
        QuickMatch.layer.cornerRadius = 8.0
        QuickMatch.layer.masksToBounds = true
        let bottomView = UIView(frame: viewBounds)
        bottomView.backgroundColor = .charcoalColor()
        bottomView.GradLayer()
        bottomView.addSubview(image)
        bottomView.addSubview(label)
        bottomView.addSubview(label2)
        bottomView.addSubview(QuickMatch)
        return bottomView
    }
    
    func findFriendsPressed(sender: UIBarButtonItem) {
        self.NavPush("FriendsTable", completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertAction = "Testing inline reply notificaions on iOS9"
        localNotification.alertBody = "Woww it works!!"
        localNotification.alertLaunchImage = "star"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
        localNotification.category = "CHAT_CATEGORY"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        PFUser.currentUser()!["friendInvite"] = 0
        PFUser.currentUser()!.saveInBackground()
        self.forceFetchData()
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Friend Requests"
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitesList.count
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! SwipeCell).setUpUserInvite(self)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SwipeCell", forIndexPath: indexPath) as? SwipeCell
        cell!.index = indexPath
        cell!.table = self
        cell!.UserInvite = self.invitesList[indexPath.row]//["SentFrom"] as? PFUser
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell:SwipeCell = (tableView.cellForRowAtIndexPath(indexPath) as? SwipeCell)!
        if cell.swipeState == MGSwipeState.SwipingRightToLeft {
            cell.hideSwipeAnimated(true)
        } else {
            cell.showSwipe(MGSwipeDirection.RightToLeft, animated: true, completion: nil)
        }
    }
}
