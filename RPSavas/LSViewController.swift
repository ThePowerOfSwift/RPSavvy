//
//  LSViewController.swift
//  RPSavvy
//
//  Created by Dillon Murphy on 10/4/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//
import UIKit
import Foundation
import Parse
import ParseUI

class LSViewController: ParseTable {
    
    override func viewDidLoad() {
        title = "Nearby"
        //self.appTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target:self, selector:#selector(onTick(_:)), userInfo:nil, repeats:true)
        PFGeoPoint.geoPointForCurrentLocationInBackground({ (point, error) in
            if error == nil {
                PFUser.currentUser()!["Location"] = point
                PFUser.currentUser()!.saveInBackground()
                self.currentLocation = point
                AppConfiguration.currentLocation = point
                self.forceFetchData()
            } else {
                activityIndicatorView.stopAnimation()
            }
        })
    }
    
    override func fetchData() {
        if (!requestInProgress && !stopFetching) {
            requestInProgress = true
            activityIndicatorView.startAnimation()
            let query = PFUser.query()
            query!.limit = 20
            query!.skip = pageNumber*20
            query!.cachePolicy = AppConfiguration.cachePolicy
            query!.maxCacheAge = 3600
            if AppConfiguration.currentLocation != nil {
                query!.whereKey("Location", nearGeoPoint: AppConfiguration.currentLocation!, withinMiles: 20.0)
                query!.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
                query!.orderByDescending("fullname")
                query!.findObjectsInBackgroundWithBlock({
                    objects, error in
                    if error == nil {
                        if self.pageNumber == 0 {
                            self.FriendsList.removeAll()
                        }
                        var array : [PFUser] = [PFUser]()
                        if (self.forceRefresh) {
                            for follow in objects! {
                                array.append(follow as! PFUser)
                            }
                        }
                        self.FriendsList.appendContentsOf(array)
                        self.tableView.reloadData()
                        activityIndicatorView.stopAnimation()
                        self.requestInProgress = false
                        self.forceRefresh = false
                        if (self.FriendsList.count<20) {
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
        } else {
            activityIndicatorView.stopAnimation()
        }
    }
    
    
    override func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        let viewBounds = scrollView.bounds
        var image: UIImageView!
        let imageForEmpty = UIImage(named: "RPSLogo")
        if UIScreen.mainScreen().bounds.width > 320 {
            image = UIImageView(image: imageForEmpty)
            image.frame = CGRect(x: self.view.bounds.midX - ((viewBounds.width * 0.8) / 2), y: viewBounds.height / 5 , width: viewBounds.width * 0.8 , height: viewBounds.width * 0.8)
            image.contentMode = .ScaleAspectFit
        } else {
            let newImage = Images.resizeImage(imageForEmpty!, width: viewBounds.width / 2.5, height: viewBounds.width / 2.5)
            image = UIImageView(image: newImage)
            image.frame = CGRect(x: self.view.bounds.midX - ((viewBounds.width / 2.5) / 2), y: viewBounds.height / 4.5 , width: viewBounds.width / 2.5, height: viewBounds.width / 2.5)
            image.contentMode = .ScaleAspectFit
        }
        let label = UILabel(frame: CGRect(x: 20, y: image.frame.maxY + 5, width: viewBounds.width - 40, height: 50))
        label.text = "No Nearby Opponents"
        label.font = UIFont.boldSystemFontOfSize(18.0)
        label.textColor = .whiteColor()
        label.textAlignment = .Center
        let label2 = UILabel(frame: CGRect(x: 20, y: label.frame.maxY + 5, width: viewBounds.width - 40, height: 80))
        label2.text = "Send a Friend Request to a Friend or use Facebook to find your Friends"
        label2.font = UIFont.boldSystemFontOfSize(14.0)
        label2.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label2.textAlignment = .Center
        label2.numberOfLines = 3
        label2.textColor = .lightGrayColor()
        let QuickMatch = GradientButton(frame: CGRect(x: 20, y: label2 .frame.maxY + 15, width: viewBounds.width - 40, height: 40))
        QuickMatch.addTarget(self, action: #selector(self.findFriendsPressed), forControlEvents: .TouchUpInside)
        QuickMatch.setTitle("Find Friends", forState: UIControlState.Normal)
        QuickMatch.useBlackStyle()
        QuickMatch.layer.cornerRadius = 8.0
        QuickMatch.layer.masksToBounds = true
        let bottomView = UIView(frame: viewBounds)
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! SwipeCell).setupNearbyUser(self)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SwipeCell", forIndexPath: indexPath) as! SwipeCell
        cell.index = indexPath
        cell.table = self
        cell.nearbyUser = FriendsList[indexPath.row]
        return cell
    }
    
}
