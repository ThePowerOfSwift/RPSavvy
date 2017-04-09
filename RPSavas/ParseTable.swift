//
//  ParseTable.swift
//  RPSavvy
//
//  Created by Dillon Murphy on 10/14/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI
import ParseFacebookUtilsV4


class  FriendsTable: ParseTable, MGSwipeTableCellDelegate {
    
    override func viewDidAppear(animated: Bool) {
        PFUser.currentUser()!["friendAccepted"] = 0
        PFUser.currentUser()!.saveInBackground()
        for visibleCell in tableView.visibleCells {
            guard let indexPath = tableView.indexPathForCell(visibleCell) else {
                return
            }
            let friend = FriendsList[indexPath.row]
            let query = PFQuery(className: "Chat")
            let id1: String = friend.objectId!
            let id2: String = PFUser.currentUser()!.objectId!
            let groupId: String = (id1 < id2) ? "\(id1),\(id2)" : "\(id2),\(id1)"
            query.whereKey("groupId", equalTo: groupId)
            query.orderByDescending("createdAt")
            query.getFirstObjectInBackgroundWithBlock({ (object, error) in
                if error == nil && object != nil {
                    if (visibleCell as! SwipeCell).Details!.text != object!["text"] as? String {
                        (visibleCell as! SwipeCell).Details!.text = object!["text"] as! String
                        (visibleCell as! SwipeCell).Details!.hidden = false
                    } else if object!["text"] == nil {
                        (visibleCell as! SwipeCell).Details!.hidden = true
                    }
                } else {
                    (visibleCell as! SwipeCell).Details!.text = nil
                    (visibleCell as! SwipeCell).Details!.hidden = true
                }
            })
        }
    }
}


class ParseTable: UITableViewController, MAGearRefreshDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    var searching : Bool = false
    var refresherControl : MAGearRefreshControl!
    var FriendsList:[PFUser] = [PFUser]()
    var currentLocation: PFGeoPoint?
    var requestInProgress = false
    var forceRefresh = false
    var stopFetching = false
    var pageNumber = 0
    var appTimer: NSTimer?
    var initialLoad: Bool = false
    
    lazy var SearchControl: UISearchController? = {
        var searchControl: UISearchController = UISearchController(searchResultsController: nil)
        searchControl.searchResultsUpdater = self
        searchControl.hidesNavigationBarDuringPresentation = false
        searchControl.dimsBackgroundDuringPresentation = false
        searchControl.searchBar.backgroundColor = AppConfiguration.startingColor.darkenedColor(0.2)
        searchControl.searchBar.barTintColor = AppConfiguration.startingColor.darkenedColor(0.2)
        searchControl.searchBar.delegate = self
        searchControl.searchBar.layer.shadowColor = AppConfiguration.startingColor.darkenedColor(0.2).CGColor
        searchControl.searchBar.layer.shadowOpacity = 0.5
        searchControl.searchBar.layer.masksToBounds = true
        searchControl.searchBar.showsCancelButton = false
        searchControl.searchBar.showsBookmarkButton = false
        searchControl.searchBar.showsSearchResultsButton = false
        searchControl.searchBar.searchBarStyle = UISearchBarStyle.Default
        searchControl.searchBar.placeholder = "Search User.."
        searchControl.searchBar.tintColor = UIColor.whiteColor()
        self.definesPresentationContext = true
        return searchControl
    }()
    
    func startReloadTimer() {
        if appTimer == nil {
            appTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target:self, selector:#selector(onTick(_:)), userInfo:nil, repeats:true)
        }
    }
    
    func stopReloadTimer() {
        if self.appTimer != nil {
            self.appTimer!.invalidate()
            self.appTimer = nil
        }
    }
    
    func onTick(timer: NSTimer) {
        self.forceFetchData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = SearchControl!.searchBar
        navigationItem.title = "Friends List"
        addFriendsButton()
    }
   
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = AppConfiguration.startingColor
        addRefresher()
        addBackButton()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func forceFetchData() {
        forceRefresh = true
        stopFetching = false
        pageNumber = 0
        fetchData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchingName(searchController.searchBar.text!, searchBar: searchController.searchBar)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
        FriendsList.removeAll()
        searching = false
        searchBar.text = ""
        searchBar.placeholder = "Search User.."
        addFriendsButton()
        forceFetchData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchingName(searchBar.text!, searchBar: searchBar)
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchingName(name: String, searchBar: UISearchBar) {
        activityIndicatorView.startAnimation()
        let query = PFUser.query()
        query!.limit = 999
        if searching == true {
            query!.whereKey("fullname", hasPrefix: searchBar.text)
            query!.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
            if PFUser.currentUser()!["Friends"] != nil {
                query!.whereKey("objectId", notContainedIn: PFUser.currentUser()!["Friends"] as! [String])
            }
        } else if searching == false {
            query!.whereKey("fullname", hasPrefix: searchBar.text)
            query!.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
            if PFUser.currentUser()!["Friends"] != nil {
                query!.whereKey("objectId", containedIn: PFUser.currentUser()!["Friends"] as! [String])
            }
        }
        query!.cachePolicy = AppConfiguration.cachePolicy
        query!.maxCacheAge = 3600
        query!.orderByDescending("fullname")
        query!.findObjectsInBackgroundWithBlock({
            objects, error in
            if error == nil {
                self.FriendsList = objects! as! [PFUser]
                self.tableView.reloadData()
                activityIndicatorView.stopAnimation()
            } else {
                self.FriendsList.removeAll()
                activityIndicatorView.stopAnimation()
            }
        })
    }
    
    func addRefresher() {
        self.tableView.tableFooterView = UIView()
        refresherControl = MAGearRefreshControl(frame: CGRectMake(0, -self.tableView.bounds.height, self.view.frame.width, self.tableView.bounds.height))
        refresherControl.backgroundColor =  UIColor.blackColor()
        refresherControl.addInitialGear(nbTeeth:12, color: UIColor.coolGrayColor(), radius:16)
        refresherControl.addLinkedGear(0, nbTeeth:45, color: UIColor.coolGrayColor(), angleInDegree: 0, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(0, nbTeeth:25, color: UIColor.coolGrayColor(), angleInDegree: 180, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(1, nbTeeth:14, color: UIColor.coolGrayColor(), angleInDegree: 0, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(2, nbTeeth:14, color: UIColor.coolGrayColor(), angleInDegree: 180, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(3, nbTeeth:25, color: UIColor.coolGrayColor(), angleInDegree: 0, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(4, nbTeeth:18, color: UIColor.coolGrayColor(), angleInDegree: 195, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(6, nbTeeth:30, color: UIColor.coolGrayColor(), angleInDegree: 170, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(6, nbTeeth:25, color: UIColor.coolGrayColor(), angleInDegree: 80, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(0, nbTeeth:45, color: UIColor.coolGrayColor(), angleInDegree: -100, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(2, nbTeeth:50, color: UIColor.coolGrayColor(), angleInDegree: 90, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(1, nbTeeth:20, color: UIColor.coolGrayColor(), angleInDegree: 110, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(1, nbTeeth:14, color: UIColor.coolGrayColor(), angleInDegree: 150, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(5, nbTeeth:34, color: UIColor.coolGrayColor(), angleInDegree: 130, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(5, nbTeeth:54, color: UIColor.coolGrayColor(), angleInDegree: -115, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(4, nbTeeth:28, color: UIColor.coolGrayColor(), angleInDegree: -90, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(7, nbTeeth:35, color: UIColor.coolGrayColor(), angleInDegree: 90, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(15, nbTeeth:47, color: UIColor.coolGrayColor(), angleInDegree: -150, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(15, nbTeeth:18, color: UIColor.coolGrayColor(), angleInDegree: -80, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(14, nbTeeth:18, color: UIColor.coolGrayColor(), angleInDegree: 180, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(1, nbTeeth:18, color: UIColor.coolGrayColor(), angleInDegree: 82, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(19, nbTeeth:42, color: UIColor.coolGrayColor(), angleInDegree: -90, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(17, nbTeeth:42, color: UIColor.coolGrayColor(), angleInDegree: -40, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(9, nbTeeth:23, color: UIColor.coolGrayColor(), angleInDegree: -95, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(20, nbTeeth:42, color: UIColor.coolGrayColor(), angleInDegree: 110, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(14, nbTeeth:50, color: UIColor.coolGrayColor(), angleInDegree: -90, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(13, nbTeeth:24, color: UIColor.coolGrayColor(), angleInDegree: 65, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(13, nbTeeth:18, color: UIColor.coolGrayColor(), angleInDegree: 110, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(16, nbTeeth:19, color: UIColor.coolGrayColor(), angleInDegree: 20, gearStyle: .WithBranchs)
        refresherControl.delegate = self
        self.tableView.addSubview(refresherControl)
    }
    
    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return .charcoalColor()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        refresherControl.MAGearRefreshScrollViewDidScroll(scrollView)
    }
    
    func quickMatchPressed(sender: UIBarButtonItem) {
        self.NavPush("GameController", completion: nil)
    }
    
    func gameRequestPressed(sender: UIBarButtonItem) {
        self.NavPush("FriendsTable", completion: nil)
    }
    
    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
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
        label.text = "No Friends"
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
        QuickMatch.addTarget(self, action: #selector(self.AddFriends), forControlEvents: .TouchUpInside)
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
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refresherControl.MAGearRefreshScrollViewDidEndDragging(scrollView)
    }
    
    func MAGearRefreshTableHeaderDataSourceIsLoading(view: MAGearRefreshControl) -> Bool {
        return requestInProgress
    }
    
    func MAGearRefreshTableHeaderDidTriggerRefresh(view: MAGearRefreshControl) {
        self.forceFetchData()
    }

    func fetchData() {
        if (!requestInProgress && !stopFetching) {
            requestInProgress = true
            activityIndicatorView.startAnimation()
            let query = PFUser.query()
            query!.limit = 20
            query!.skip = pageNumber*20
            if PFUser.currentUser()!["Friends"] != nil {
                query!.whereKey("objectId", containedIn: PFUser.currentUser()!["Friends"] as! [String])
            } else if PFUser.currentUser()!["Friends"] == nil || (PFUser.currentUser()!["Friends"] as! [String]).isEmpty {
                activityIndicatorView.stopAnimation()
                return
            }
            query!.cachePolicy = AppConfiguration.cachePolicy
            query!.maxCacheAge = 3600
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
    }
    
    func addFriendsButton() {
        let FriendButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "add")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.AddFriends))
        FriendButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(FriendButton, animated: true)
    }
    
    func AddFriends() {
        let alertVC = UIAlertController(title: "Add A Friend", message: "How would you like to add a friend?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let Facebook = UIAlertAction(title: "Load Facebook Friends", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            activityIndicatorView.startAnimation()
            let friendRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil)
            friendRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                if error != nil {
                    ProgressHUD.showError(error.localizedDescription)
                    activityIndicatorView.stopAnimation()
                    return
                } else {
                    guard let resultdict = result as? NSDictionary else {
                        ProgressHUD.showError("No Facebook Friends Found")
                        activityIndicatorView.stopAnimation()
                        return
                    }
                    let data : NSArray = resultdict.objectForKey("data") as! NSArray
                    if data.count == 0 {
                        ProgressHUD.showError("No Facebook Friends Found")
                        activityIndicatorView.stopAnimation()
                    } else {
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
                                if i == (data.count - 1) {
                                    ProgressHUD.showSuccess("Loaded Facebook Friends")
                                    activityIndicatorView.stopAnimation()
                                    self.tableView.reloadData()
                                }
                            })
                        }
                    }
                }
            }
        }
        let Search = UIAlertAction(title: "Search Friends By Username", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.searching = true
            self.SearchControl!.active = true
            self.SearchControl!.searchBar.placeholder = "Enter username.."
            self.searchingName(self.SearchControl!.searchBar.text!, searchBar: self.SearchControl!.searchBar)
            self.navigationItem.setRightBarButtonItem(nil, animated: true)
        }
        let Cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in}
        alertVC.addAction(Facebook)
        alertVC.addAction(Search)
        alertVC.addAction(Cancel)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendsList.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! SwipeCell).setupUser(self)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SwipeCell", forIndexPath: indexPath) as! SwipeCell
        if indexPath.row <= (FriendsList.count - 1) {
            cell.index = indexPath
            cell.table = self
            cell.User = FriendsList[indexPath.row]
        }
        return cell
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

