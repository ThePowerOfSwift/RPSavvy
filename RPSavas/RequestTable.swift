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

let inviteRequestsbutton: MIBadgeButton = MIBadgeButton(type: .custom)
var evapTitle: UILabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.midX - 100, y: 0, width: 200, height: 55))

extension RequestTable {
    
    func addInviteRequest() {
        inviteRequestsbutton.frame = CGRect(x:sideMenuNavigationController!.navigationBar.frame.width - (sideMenuNavigationController!.navigationBar.frame.height + 15),y:0,width:sideMenuNavigationController!.navigationBar.frame.height,height:sideMenuNavigationController!.navigationBar.frame.height)
        inviteRequestsbutton.badgeTextColor = UIColor.white
        inviteRequestsbutton.badgeBackgroundColor = UIColor.red
        inviteRequestsbutton.badgeEdgeInsets = UIEdgeInsetsMake(15, 0, 0, 10)
        inviteRequestsbutton.setImage(UIImage(named: "Switch")!, for: UIControlState())
        inviteRequestsbutton.tintColor = .white
        inviteRequestsbutton.addTarget(self, action:  #selector(self.tappedInviteRequest), for: .touchUpInside)
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: inviteRequestsbutton), animated: false)
    }
    
    func addTitleView() {
        evapTitle.textAlignment = NSTextAlignment.center
        evapTitle.adjustsFontSizeToFitWidth = true
        evapTitle.minimumScaleFactor = 0.5
        evapTitle.font = (UIScreen.main.bounds.width <= 320) ? UIFont(name: "AmericanTypewriter-Semibold", size: 22)! : UIFont(name: "AmericanTypewriter-Semibold", size: 25)
        evapTitle.textColor = UIColor.white
        self.navigationItem.titleView = evapTitle
        evapTitle.evap("Game Requests")
    }
    
    func tappedInviteRequest(_ sender: MIBadgeButton) {
        self.GameList.removeAll()
        inviteRequestsbutton.badgeString = 0
        sender.spin() {
            self.requestsList = !self.requestsList
        }
    }
}

class  RequestTable: ParseTable, MGSwipeTableCellDelegate {
    
    var predicate: NSPredicate = NSPredicate(format: "receiver = %@", PFUser.current()!)
    var GameList: [PFObject] = [PFObject]()
    var requestsList: Bool = false {
        didSet {
            if self.requestsList {
                self.accepted = 0
                self.predicate = NSPredicate(format: "caller = %@", PFUser.current()!)
                if evapTitle.text != "Game Invites" {
                    evapTitle.evap("Game Invites")
                }
                inviteRequestsbutton.badgeString = self.gameInvite
            } else {
                self.gameInvite = 0
                self.predicate = NSPredicate(format: "receiver = %@", PFUser.current()!)
                if evapTitle.text != "Game Requests" {
                    evapTitle.evap("Game Requests")
                }
                inviteRequestsbutton.badgeString = self.accepted
            }
            self.forceFetchData()
        }
    }
    
    var accepted: Int {
        get {
            if PFUser.current()!["accepted"] != nil {
                return PFUser.current()!["accepted"] as! Int
            } else {
                return 0
            }
        }
        set {
            PFUser.current()!["accepted"] = newValue
            PFUser.current()!.saveInBackground()
        }
    }
    
    var gameInvite: Int {
        get {
            if PFUser.current()!["gameInvite"] != nil {
                return PFUser.current()!["gameInvite"] as! Int
            } else {
                return 0
            }
        }
        set {
            PFUser.current()!["gameInvite"] = newValue
            PFUser.current()!.saveInBackground()
        }
    }
    
    override func viewDidLoad() {
        addInviteRequest()
        addTitleView()
        predicate = NSPredicate(format: "receiver = %@", PFUser.current()!)
        if evapTitle.text != "Game Requests" {
            evapTitle.evap("Game Requests")
        }
        self.forceFetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !self.requestsList {
            gameInvite = 0
            inviteRequestsbutton.badgeString = self.accepted
        } else {
            accepted = 0
            inviteRequestsbutton.badgeString = self.gameInvite
        }
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
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground(block: {
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
                    self.GameList.append(contentsOf: array)
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
    
    override func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let viewBounds = scrollView.bounds
        let bottomView = UIView(frame: viewBounds)
        bottomView.GradLayer()
        let imager : UIImage = (UIScreen.main.bounds.width <= 320) ? Images.resizeImage(UIImage(named: "RPSLogo")!, width: UIImage(named: "RPSLogo")!.size.width*0.6, height: UIImage(named: "RPSLogo")!.size.height*0.6)! : Images.resizeImage(UIImage(named: "RPSLogo")!, width: UIImage(named: "RPSLogo")!.size.width*0.8, height: UIImage(named: "RPSLogo")!.size.height*0.8)!
        let imageView: UIImageView = UIImageView(image: imager)
        imageView.frame = (UIScreen.main.bounds.width <= 320) ? CGRect(x: self.view.bounds.midX - ((viewBounds.width * 0.6) / 2), y: viewBounds.height / 8 , width: viewBounds.width * 0.6 , height: viewBounds.width * 0.6) : CGRect(x: self.view.bounds.midX - ((viewBounds.width * 0.8) / 2), y: viewBounds.height / 8 , width: viewBounds.width * 0.8 , height: viewBounds.width * 0.8)
        imageView.contentMode = .scaleAspectFit
        let label = UILabel(frame: CGRect(x: 20, y: imageView.frame.maxY, width: viewBounds.width - 40, height: 50))
        label.attributedText = !requestsList ? NSAttributedString(string: "No Game Requests", attributes: [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 20)!]) : NSAttributedString(string: "No Game Invites", attributes: [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 20)!])
        label.textAlignment = .center
        let label2 = UILabel(frame: CGRect(x: 20, y: label.frame.maxY, width: viewBounds.width - 40, height: 80))
        label2.attributedText = NSAttributedString(string: "Send a Game Request to a Friend to start a new game or try out our Quick Match mode and play against a random opponent", attributes: AppConfiguration.smallTextAttributes)
        label2.lineBreakMode = NSLineBreakMode.byWordWrapping
        label2.textAlignment = .center
        label2.numberOfLines = 3
        let QuickMatch = GradientButton(frame: CGRect(x: 20, y: label2.frame.maxY + 15, width: viewBounds.width - 40, height: 50))
        QuickMatch.addTarget(self, action: #selector(self.quickMatchPressed(_:)), for: .touchUpInside)
        QuickMatch.setAttributedTitle(NSAttributedString(string: "Quick Match", attributes: AppConfiguration.textAttributes), for:  UIControlState())
        QuickMatch.useBlackStyle()
        QuickMatch.layer.cornerRadius = 8.0
        QuickMatch.layer.masksToBounds = true
        let GameRequest = GradientButton(frame: CGRect(x: 20, y: QuickMatch.frame.maxY + 15, width: viewBounds.width - 40, height: 50))
        GameRequest.setAttributedTitle(NSAttributedString(string: "Send a Game Request to a Friend", attributes: AppConfiguration.textAttributes), for:  UIControlState())
        GameRequest.addTarget(self, action: #selector(self.gameRequestPressed(_:)), for: .touchUpInside)
        GameRequest.useBlackStyle()
        GameRequest.layer.cornerRadius = 8.0
        GameRequest.layer.masksToBounds = true
        GameRequest.titleLabel?.numberOfLines = 2
        GameRequest.titleLabel?.lineBreakMode = .byWordWrapping
        GameRequest.titleLabel?.textAlignment = NSTextAlignment.center
        bottomView.addSubview(imageView)
        bottomView.addSubview(label)
        bottomView.addSubview(label2)
        bottomView.addSubview(QuickMatch)
        bottomView.addSubview(GameRequest)
        return bottomView
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! SwipeCell).setupUserRequest(self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GameList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwipeCell", for: indexPath) as? SwipeCell
        cell!.index = indexPath
        cell!.table = self
        cell!.UserRequest = self.GameList[indexPath.row]
        return cell!
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.GameList.removeAll()
    }
    
}
