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
            query.whereKey("User", equalTo: PFUser.current()!)
            query.whereKey("Type", equalTo: "friendInvite")
            query.cachePolicy = AppConfiguration.cachePolicy
            query.maxCacheAge = 3600
            query.findObjectsInBackground(block: {
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
                    self.invitesList.append(contentsOf: array)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.invitesList.removeAll()
    }
    
    override func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let viewBounds = scrollView.bounds
        let image: UIImageView = UIImageView(image: UIImage(named: "RPSLogo"))
        image.frame = UIScreen.main.bounds.width > 320 ? CGRect(x: self.view.bounds.midX - ((viewBounds.width * 0.8) / 2), y: viewBounds.height / 5 , width: viewBounds.width * 0.8 , height: viewBounds.width * 0.8) : CGRect(x: self.view.bounds.midX - ((viewBounds.width / 2.5) / 2), y: viewBounds.height / 4.5 , width: viewBounds.width / 2.5, height: viewBounds.width / 2.5)
        image.contentMode = .scaleAspectFit
        let label = UILabel(frame: CGRect(x: 20, y: image.frame.maxY + 5, width: viewBounds.width - 40, height: 50))
        label.text = "No Friend Requests"
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textColor = .white
        label.textAlignment = .center
        let label2 = UILabel(frame: CGRect(x: 20, y: label.frame.maxY + 5, width: viewBounds.width - 40, height: 80))
        label2.text = "Send a Friend Request to a Friend or use Facebook to find your Friends"
        label2.font = UIFont.boldSystemFont(ofSize: 14.0)
        label2.lineBreakMode = NSLineBreakMode.byWordWrapping
        label2.textAlignment = .center
        label2.numberOfLines = 2
        label2.textColor = .lightGray
        let QuickMatch = GradientButton(frame: CGRect(x: 20, y: label2 .frame.maxY + 15, width: viewBounds.width - 40, height: 40))
        QuickMatch.addTarget(self, action: #selector(InviteTable.findFriendsPressed(_:)), for: .touchUpInside)
        QuickMatch.setTitle("Find Friends", for: UIControlState())
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
    
    func findFriendsPressed(_ sender: UIBarButtonItem) {
        self.NavPush("FriendsTable", completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        PFUser.current()!["friendInvite"] = 0
        PFUser.current()!.saveInBackground()
        self.forceFetchData()
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Friend Requests"
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitesList.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! SwipeCell).setUpUserInvite(self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwipeCell", for: indexPath) as? SwipeCell
        cell!.index = indexPath
        cell!.table = self
        cell!.UserInvite = self.invitesList[indexPath.row]//["SentFrom"] as? PFUser
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:SwipeCell = (tableView.cellForRow(at: indexPath) as? SwipeCell)!
        if cell.swipeState == MGSwipeState.swipingRightToLeft {
            cell.hideSwipe(animated: true)
        } else {
            cell.showSwipe(MGSwipeDirection.rightToLeft, animated: true, completion: nil)
        }
    }
}
