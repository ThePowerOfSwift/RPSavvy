//
//  GameView.swift
//  RPSavvy
//
//  Created by Dillon Murphy on 7/27/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import Parse
import ParseUI

extension GameView: CountdownDelegate {
    
    func countdownFinished(view: CountdownView) {
        self.Rock.enabled = false
        self.Paper.enabled = false
        self.Scissors.enabled = false
        self.delay(0.6, closure: {
            var maybeError : OTError?
            self.session?.signalWithType("Choice", string: self.choice.description, connection: self.OppConnect, error:  &maybeError)
            if (maybeError != nil) {
                self.delay(3.0, closure: {
                    self.session?.signalWithType("Choice", string: self.choice.description, connection: self.OppConnect, error:  nil)
                })
            }
            self.opponentStatus = false
            self.readyStatus = false
        })
    }
    
    func addCountdown() {
        countdown.start(self)
    }
}


extension GameView: OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate {
    
    // MARK: - OTSession delegate callbacks

    func disconnect() {
        if self.session != nil {
            var maybeError : OTError?
            self.session?.signalWithType("Disconnect", string: "Disconnect", connection: self.OppConnect, error: &maybeError)
            if (maybeError != nil) {
                activityIndicatorView.startAnimation()
                self.delay(3.0, closure: {
                    self.session?.signalWithType("Disconnect", string: "Disconnect", connection: self.OppConnect, error: nil)
                    activityIndicatorView.stopAnimation()
                })
            }
            self.session?.disconnect(nil)
            self.session = nil
        }
        let query = PFQuery(className: "ActiveSessions")
        if AppConfiguration.SessionID != nil {
            query.whereKey("sessionID", equalTo: AppConfiguration.SessionID!)
        }
        query.getFirstObjectInBackgroundWithBlock({
            object, error in
            if error == nil {
                object?.deleteEventually()
            }
        })
        sideMenuNavigationController!.popViewControllerAnimated(true)
        self.rematchView.hide()
    }
    
    public func sessionDidConnect(session: OTSession) {
        self.Connect = session.connection
        publisher = OTPublisher(delegate: self, name: PFUser.currentUser()!.Fullname())
        var maybeError : OTError?
        session.publish(publisher!, error: &maybeError)
        if (maybeError != nil) {
            ProgressHUD.showError("Error Connecting")
            self.disconnect()
        }
        publisher!.view!.layer.borderColor = UIColor.redColor().CGColor
        publisher!.view!.layer.cornerRadius = 8.0
        publisher!.view!.layer.borderWidth = 1.0
        publisher!.view!.backgroundColor = UIColor.clearColor()
        publisher!.view!.layer.backgroundColor = UIColor.clearColor().CGColor
        publisher!.view!.layer.masksToBounds = true
        publisher!.view!.frame = viewPanel.frame
        publisher!.view!.alpha = 0.0
        addSubview(publisher!.view!)
        UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.publisher!.view!.alpha = 1.0
        }, completion: nil)
    }
    
    public func sessionDidDisconnect(session : OTSession) {
    }
    
    public func session(session: OTSession, streamCreated stream: OTStream) {
        if (stream.connection.connectionId != Connect.connectionId) {
            subscriber = OTSubscriber(stream: stream, delegate: self)
            var maybeError : OTError?
            session.subscribe(subscriber!, error: &maybeError)
            if (maybeError != nil) {
                ProgressHUD.showError("Error Receiving Opponent Video Feed")
            }
        }
    }
    
    public func session(session: OTSession, streamDestroyed stream: OTStream) {
        if subscriber?.stream!.streamId == stream.streamId {
            var maybeError : OTError?
            session.unsubscribe(subscriber!, error: &maybeError)
            if (maybeError != nil) {
                self.disconnect()
            }
            subscriber!.view!.removeFromSuperview()
            self.subscriber = nil
        }
    }
    
    public func session(session: OTSession, connectionCreated connection : OTConnection) {
        self.OppConnect = connection
    }
    
    public func session(session: OTSession, connectionDestroyed connection : OTConnection) {
        //NSLog("session connectionDestroyed (\(connection.connectionId))")
    }
    
    public func session(session: OTSession, didFailWithError error: OTError) {
        self.session = nil
        ProgressHUD.showError(error.localizedDescription)
        if AppConfiguration.SessionID != nil {
            let query = PFQuery(className: "ActiveSessions")
            query.whereKey("sessionID", equalTo: AppConfiguration.SessionID!)
            query.getFirstObjectInBackgroundWithBlock({
                object, error in
                if error == nil {
                    object?.deleteEventually()
                }
            })
        }
        sideMenuNavigationController!.popViewControllerAnimated(true)
    }
    
    // MARK: - OTSubscriber delegate callbacks
    
    public func subscriberDidConnectToStream(subscriberKit: OTSubscriberKit) {
        let subscriber:OTSubscriber = subscriberKit as! OTSubscriber
        var maybeError : OTError?
        self.session?.signalWithType("user", string: PFUser.currentUser()!.objectId!, connection: self.OppConnect, error: &maybeError)
        if (maybeError != nil) {
            activityIndicatorView.startAnimation()
            self.delay(3.0, closure: {
                self.session?.signalWithType("user", string: PFUser.currentUser()!.objectId!, connection: self.OppConnect, error: nil)
                activityIndicatorView.stopAnimation()
            })
        }
        self.readyPlayButton.selected = !self.readyPlayButton.selected
        self.readyPlayButton.enabled = true
        PFQuery(className:"ActiveSessions").getObjectInBackgroundWithId(AppConfiguration.activeSession!.objectId!, block: { object, error in
            if error == nil {
                object!.deleteInBackground()
            }
        })
        subscriber.view!.frame = self.vsPanel.frame
        subscriber.view!.layer.cornerRadius = 8.0
        subscriber.view!.backgroundColor = UIColor.clearColor()
        subscriber.view!.layer.backgroundColor = UIColor.clearColor().CGColor
        subscriber.view!.layer.borderColor = UIColor.redColor().CGColor
        subscriber.view!.layer.borderWidth = 1.0
        subscriber.view!.layer.masksToBounds = true
        subscriber.view!.alpha = 0.0
        addSubview(subscriber.view!)
        UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            subscriber.view!.alpha = 1.0
            }, completion: {_ in
                activityIndicatorView.stopAnimation()
        })
    }
    
    
    public func subscriberVideoDisabled(subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        self.subscriber!.view!.alpha = 1.0
        UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.subscriber!.view!.alpha = 0.0
            }, completion: nil)
    }
    
    public func subscriberVideoEnabled(subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        self.subscriber!.view!.alpha = 0.0
        UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.subscriber!.view!.alpha = 1.0
            }, completion: nil)
    }
    
    public func subscriber(subscriber: OTSubscriberKit, didFailWithError error : OTError) {
        NSLog("subscriber %@ didFailWithError %@", subscriber.stream!.streamId, error)
    }
    
    // MARK: - OTPublisher delegate callbacks
    
    public func publisher(publisher: OTPublisherKit, streamCreated stream: OTStream) {
        //NSLog("publisher streamCreated %@", stream)
    }
    
    public func publisher(publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        //NSLog("publisher streamDestroyed %@", stream)
    }
    
    public func publisher(publisher: OTPublisherKit, didFailWithError error: OTError) {
        NSLog("publisher didFailWithError %@", error)
    }
    
    public func session(session: OTSession, receivedSignalType type: String?, fromConnection connection: OTConnection?, withString string: String?) {
        if (connection!.connectionId == OppConnect.connectionId) {
            if type == "user"{
                PFUser.query()?.getObjectInBackgroundWithId(string!, block: { (object, error) in
                    if error == nil && object != nil {
                        if object!["fullname"] != nil {
                            self.opponentName.LoadingText = object!["fullname"] as! String
                        }
                        if object!["picture"] != nil {
                            self.vsPanel.file = object!["picture"] as? PFFile
                            self.vsPanel.loadInBackground()
                        } else {
                            if object!["fullname"] != nil {
                                self.vsPanel.imageWithString(object!["fullname"] as! String, color: self.opponentColor, circular: false, fontAttributes: nil)
                            } else {
                                self.vsPanel.imageWithString("R P S", color: self.opponentColor, circular: false, fontAttributes: nil)
                            }
                        }
                    }
                    //activityIndicatorView.stopAnimation()
                })
            } else if type == "rematch" {
                self.opponentRematch = true
                if self.rematch == true {
                    self.resetMatch()
                }
            } else if type == "score" {
                let scores = string!.componentsSeparatedByString(":OppScore:")
                let oppScore : Int = Int(scores[0].stringByReplacingOccurrencesOfString("MyScore:", withString: ""))!
                let myScore : Int = Int(scores[1])!
                let total : Int = oppScore + myScore
                if total < (userScoreInt + opponentScoreInt) {
                    if oppScore > opponentScoreInt {
                        resetScore = true
                        opponentScoreInt = oppScore
                    }
                    if myScore > userScoreInt {
                        resetScore = true
                        userScoreInt = myScore
                    }
                }
            } else if type == "Disconnect" {
                PFQuery(className: "ActiveSessions").getObjectInBackgroundWithId(AppConfiguration.activeSession!.objectId!, block: { object, error in
                    if error == nil {
                        object?.deleteEventually()
                    }
                })
                let AddMenu = UIAlertController(title:nil , message: nil, preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "Opponent has left", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
                    //self.session?.disconnect(nil)
                    sideMenuNavigationController!.popViewControllerAnimated(true)
                    self.rematchView.hide()
                })
                AddMenu.addAction(cancelAction)
                if self.getParentViewController() != nil {
                    self.getParentViewController()!.presentViewController(AddMenu, animated: true, completion: nil)
                }
            } else if type == "readyStatus" {
                self.opponentStatus = true
                if self.readyStatus == true {
                    self.startGame()
                }
            } else if type == "Choice" {
                self.delay(0.2, closure: {
                    switch string! {
                    case RPSChoice.Rock.description: self.opponentChoice = .Rock
                    case RPSChoice.Paper.description: self.opponentChoice = .Paper
                    case RPSChoice.Scissors.description: self.opponentChoice = .Scissors
                    case RPSChoice.Empty.description: self.opponentChoice = .Empty
                    default: break
                    }
                    self.checkWin({ (results) in
                        switch results {
                        case .Win: self.userScoreInt += 1
                        case .Lose: self.opponentScoreInt += 1
                        case .Tie: self.showResultLabel("Tied!")
                        }
                        var maybeError : OTError?
                        self.session?.signalWithType("score", string: "MyScore:\(self.userScoreInt):OppScore:\(self.opponentScoreInt)", connection: self.OppConnect, error: &maybeError)
                        if (maybeError != nil) {
                            activityIndicatorView.startAnimation()
                            self.delay(3.0, closure: {
                                self.session?.signalWithType("score", string: "MyScore:\(self.userScoreInt):OppScore:\(self.opponentScoreInt)", connection: self.OppConnect, error: nil)
                                activityIndicatorView.stopAnimation()
                            })
                        }
                    })
                })
            }
        }
    }
}

extension GameView : SAConfettiViewDelegate {
    public func confettiViewTapped(view: SAConfettiView) {
        self.confetti.stopConfetti(self)
    }
}


extension GameView: RematchDelegate {
    public func RematchTapped(rematchview: RematchView, quit: Bool) {
        if quit == false {
            self.rematch = true
            self.confetti.stop(self)
            var maybeError : OTError?
            self.session?.signalWithType("rematch", string: "true", connection: self.OppConnect, error: &maybeError)
            if (maybeError != nil) {
                activityIndicatorView.startAnimation()
                self.delay(3.0, closure: {
                    self.session?.signalWithType("rematch", string: "true", connection: self.OppConnect, error: nil)
                    activityIndicatorView.stopAnimation()
                })
            }
            if self.opponentRematch == true {
                self.resetMatch()
            }
        } else {
            self.disconnect()
        }
    }
}

public class GameView: UIView {

    let rematchView: RematchView = RematchView.sharedInstance

    //var myAudioDevice: OTAudioDeviceRingtone = OTAudioDeviceRingtone()
    //var firstDevice: OTAudioDevice!
    
    lazy var countdown: CountdownView = {
        let count = CountdownView(frame: self.frame)
        count.delegate = self
        count.updateAppearance()
        return count
    }()
    
    var session: OTSession? {
        didSet {
            if self.session != nil {
                var maybeError : OTError?
                self.session!.connectWithToken(AppConfiguration.publisherToken!, error: &maybeError)
                if (maybeError != nil) {
                    ProgressHUD.showError("Error Connecting To Session")
                }
            }
        }
    }
    
    var publisher: OTPublisher?
    
    var subscriber: OTSubscriber?
    
    var Connect: OTConnection!
    
    var OppConnect: OTConnection!
    
    // These variables track both users' ready status.
    var readyStatus: Bool = false {
        didSet {
            if self.publisher != nil {
                if readyStatus {
                    self.publisher!.view!.layer.borderColor = UIColor.greenColor().CGColor
                } else {
                    self.publisher!.view!.layer.borderColor = UIColor.redColor().CGColor
                }
            }
        }
    }
    
    var opponentStatus: Bool = false {
        didSet {
            if self.subscriber != nil {
                if opponentStatus {
                    self.subscriber!.view!.layer.borderColor = UIColor.greenColor().CGColor
                } else {
                    self.subscriber!.view!.layer.borderColor = UIColor.redColor().CGColor
                }
            }
        }
    }
    
    func startGame() {
        self.choice = .Empty
        self.opponentChoice = .Empty
        self.Rock.enabled = true
        self.Paper.enabled = true
        self.Scissors.enabled = true
        self.addCountdown()
    }

    var opponentRematch: Bool = false
    
    var rematch: Bool = false
    
    func resetMatch() {
        self.userScoreInt = 0
        self.opponentScoreInt = 0
        self.choice = .Empty
        self.opponentChoice = .Empty
        self.opponentChoiceImage.image = nil
        self.userChoiceImage.image = nil
        self.prevOpponentChoiceImage.image = nil
        self.lastOpponentChoiceImage.image = nil
        self.prevUserChoiceImage.image = nil
        self.lastUserChoiceImage.image = nil
        self.rematch = false
        self.opponentRematch = false
        self.readyStatus = false
        self.opponentStatus = false
        self.showReadyPlay()
    }
    
    // These store both users' choices for that round.
    var opponentChoice: RPSChoice = .Empty
    
    var choice: RPSChoice = .Empty
    
    var resetScore: Bool = false
    
    // These ints track both users' scores.
    var userScoreInt: Int = 0 {
        didSet {
            userScore.evaporate(userScoreInt.description)
            if !resetScore {
                if self.userScoreInt > 4 {
                    PFUser.currentUser()!.incrementKey("Wins")
                    PFUser.currentUser()!.incrementKey("WinStreak")
                    PFUser.currentUser()!.saveInBackground()
                    self.rematchView.result = .Win
                    self.confetti.startFinalConfetti(self)
                } else if self.userScoreInt != 0 {
                    self.confetti.startConfetti(self)
                }
            } else {
                resetScore = false
            }
        }
    }
    
    var opponentScoreInt: Int = 0 {
        didSet {
            opponentScore.evaporate(opponentScoreInt.description)
            if !resetScore {
                if self.opponentScoreInt > 4 {
                    PFUser.currentUser()!.incrementKey("Losses")
                    PFUser.currentUser()!["WinStreak"] = 0
                    PFUser.currentUser()!.saveInBackground()
                    self.rematchView.result = .Lose
                    self.rematchView.showRematch()
                } else if opponentScoreInt != 0 {
                    self.showResultLabel("You Lost")
                }
            } else {
                resetScore = false
            }
        }
    }
    
    var Muted:Bool = true {
        didSet {
            let cell: SideMenuCell = sideMenuObj.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! SideMenuCell
            if subscriber != nil {
                subscriber!.subscribeToAudio = self.Muted
            }
            if publisher != nil {
                publisher!.publishAudio = self.Muted
            }
            if self.MutedMe != self.Muted {
                self.MutedMe = self.Muted
            }
            self.countdown.Muted = self.Muted
            cell.evap(self.Muted ? "Mute" : "Unmute")
        }
    }
    
    var MutedVid:Bool = true {
        didSet {
            let cell: SideMenuCell = sideMenuObj.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! SideMenuCell
            if publisher != nil {
                publisher!.publishVideo = self.MutedVid
                publisher!.view!.hidden = !self.MutedVid
            }
            cell.evap(self.MutedVid ? "Mute Video" : "Unmute Video")
        }
    }
    
    var MutedOpp:Bool = true {
        didSet {
            let cell: SideMenuCell = sideMenuObj.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as! SideMenuCell
            if subscriber != nil {
                subscriber!.subscribeToAudio = self.MutedOpp
                subscriber!.subscribeToVideo = self.MutedOpp
                subscriber!.view!.hidden = !self.MutedOpp
                cell.evap(self.MutedOpp ? "Mute Opponent" : "Unmute Opponent")
            }
        }
    }
    
    var MutedMe:Bool = true {
        didSet {
            let cell: SideMenuCell = sideMenuObj.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! SideMenuCell
            if publisher != nil {
                publisher!.publishAudio = self.MutedMe
                cell.evap(self.MutedMe ? "Mute Mic" : "Unmute Mic")
            }
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        //firstDevice = OTAudioDeviceManager.currentAudioDevice()
        //OTAudioDeviceManager.setAudioDevice(myAudioDevice)

        [userName,opponentName,viewPanel,vsPanel,userChoiceImage,Score,userScore,Dash,opponentScore,opponentChoiceImage,prevUserChoice,prevOpponentChoice,prevUserChoiceImage,lastUserChoiceImage,lastOpponentChoiceImage,prevOpponentChoiceImage,readyPlayButton,Rock,Paper,Scissors].forEach { (view) in
            self.addSubview(view)
        }
        self.addBlurBackground(CGRect(origin: CGPoint(x: viewPanel.frame.minX, y:viewPanel.frame.minY), size: CGSize(width: frame.width - 6, height: viewPanel.frame.height)))
        
        self.userName.evap(PFUser.currentUser()!.Fullname())
        if PFUser.currentUser()!["picture"] != nil {
            self.viewPanel.file = PFUser.currentUser()!["picture"] as? PFFile
            self.viewPanel.loadInBackground()
        } else {
            if PFUser.currentUser()!["fullname"] != nil {
                self.viewPanel.imageWithString(PFUser.currentUser()!["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
            } else {
                self.viewPanel.imageWithString("R P S", color: .charcoalColor(), circular: false, fontAttributes: nil)
            }
        }
    }
    
    func addBlurBackground(frame: CGRect) {
        let rect = CGRect(x: frame.minX - 1, y: frame.minY - 1, width: frame.width + 2, height: frame.height + 2)
        let visualEffectView:VisualEffectView = VisualEffectView(frame: rect)
        visualEffectView.colorTint = AppConfiguration.startingColor
        visualEffectView.colorTintAlpha = 0.3
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        visualEffectView.layer.cornerRadius = 8.0
        visualEffectView.layer.masksToBounds = true
        self.insertSubview(visualEffectView, atIndex: 0)
    }
    
    var type : GameType? {
        didSet {
            rematchView.delegate = self
            if self.type != nil {
                switch self.type! {
                case .Random: self.sessionQuery()
                case .Nearby: self.session = OTSession(apiKey: AppConfiguration.ApiKey, sessionId: AppConfiguration.SessionID!, delegate: self)
                case .Friend: self.session = OTSession(apiKey: AppConfiguration.ApiKey, sessionId: AppConfiguration.SessionID!, delegate: self)
                }
            }
        }
    }
    
    func sessionQuery() {
        activityIndicatorView.startAnimation()
        AppConfiguration.activeSession = nil
        let query = PFQuery(className: "ActiveSessions")
        query.whereKey("receiverID", equalTo: "Quick")
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
            if error == nil && object != nil {
                AppConfiguration.activeSession = object!
                self.session = OTSession(apiKey: AppConfiguration.ApiKey, sessionId: AppConfiguration.SessionID!, delegate: self)
            } else {
                let activeSession:PFObject = PFObject(className: "ActiveSessions")
                activeSession["caller"] = PFUser.currentUser()!
                activeSession["receiverID"] = "Quick"
                activeSession["callerTitle"] = "\(PFUser.currentUser()!.Fullname()) sent you a game request!"
                activeSession.saveInBackgroundWithBlock({(succeeded: Bool?, error: NSError?) -> Void in
                    if error == nil {
                        AppConfiguration.activeSession = activeSession
                        self.session = OTSession(apiKey: AppConfiguration.ApiKey, sessionId: AppConfiguration.SessionID!, delegate: self)
                    } else {
                        AppConfiguration.activeSession = nil
                        ProgressHUD.showError("Couldn't Create Game")
                        sideMenuNavigationController!.popViewControllerAnimated(true)
                    }
                })
            }
        }
    }
 
    func TappedRock(sender: UIButton) {
        choice = .Rock
        userChoiceImage.image = UIImage(named: "rock")!
    }
    
    func TappedPaper(sender: UIButton) {
        choice = .Paper
        userChoiceImage.image = UIImage(named: "paper")!
    }
    
    func TappedScissors(sender: UIButton) {
        choice = .Scissors
        userChoiceImage.image = UIImage(named: "scissors")!
    }
    
    lazy var readyPlayButton: GradientButton = {
        let button:GradientButton = GradientButton(frame: CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY + 90, width: UIScreen.mainScreen().bounds.width - 10, height: 80))
        button.backgroundColor = UIColor.clearColor()
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 1.0
        button.enabled = false
        button.layer.cornerRadius = 8.0
        button.useGreenStyle()
        button.layer.masksToBounds = true
        button.setAttributedTitle(NSAttributedString(string: "Ready to Play!", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 30)!]), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.readyUp), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
    
    func readyUp(sender: GradientButton) {
        sender.selected = !sender.selected
        self.delay(0.3, closure: {
            sender.selected = !sender.selected
            self.readyStatus = true
            self.confetti.removeFromSuperview()
            if self.publisher != nil {
                self.publisher!.view!.layer.borderColor = UIColor.greenColor().CGColor
            }
            self.showRPS()
        })
    }
    
    func showReadyPlay() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Rock.frame = self.Rock.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Paper.frame = self.Paper.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Scissors.frame = self.Scissors.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.readyPlayButton.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY - 150, width: UIScreen.mainScreen().bounds.width - 10, height: 80)
                    }, completion: {_ in
                        self.readyPlayButton.enabled = true
                })
        })
    }
    
    func presentReady() {
        self.readyPlayButton.selected = !self.readyPlayButton.selected
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Rock.frame = self.Rock.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Paper.frame = self.Paper.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Scissors.frame = self.Scissors.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.readyPlayButton.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY - 150, width: UIScreen.mainScreen().bounds.width - 10, height: 80)
                    }, completion: {_ in
                        //self.readyPlayButton.enabled = true
                })
        })
    }
    
    func showRPS() {
        self.readyPlayButton.enabled = false
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.readyPlayButton.frame = self.readyPlayButton.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.Rock.frame = self.getRects()[0]
                    }, completion: nil)
                UIView.animateWithDuration(0.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.Paper.frame = self.getRects()[1]
                    }, completion: nil)
                UIView.animateWithDuration(0.5, delay: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.Scissors.frame = self.getRects()[2]
                    }, completion: {_ in
                        var maybeError : OTError?
                        self.session?.signalWithType("readyStatus", string: "true", connection: self.OppConnect, error: &maybeError)
                        if (maybeError != nil) {
                            activityIndicatorView.startAnimation()
                            self.delay(3.0, closure: {
                                self.session?.signalWithType("readyStatus", string: "true", connection: self.OppConnect, error: nil)
                                activityIndicatorView.stopAnimation()
                            })
                        }
                        if self.opponentStatus == true {
                            self.startGame()
                        }
                })
        })
    }
    
    lazy var Rock: UIButton = {
        let button:UIButton = UIButton(frame: self.getRects()[0])
        button.backgroundColor = UIColor.clearColor()
        button.enabled = false
        button.setImage(UIImage(named: "rock"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.TappedRock), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
    
    lazy var Paper: UIButton = {
        let button:UIButton = UIButton(frame: self.getRects()[1])
        button.backgroundColor = UIColor.clearColor()
        button.enabled = false
        button.setImage(UIImage(named: "paper"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.TappedPaper), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
    
    lazy var Scissors: UIButton = {
        let button:UIButton = UIButton(frame: self.getRects()[2])
        button.backgroundColor = UIColor.clearColor()
        button.enabled = false
        button.setImage(UIImage(named: "scissors"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.TappedScissors), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
    
    let userColor: UIColor = UIColor.infoBlueColor()
    let opponentColor: UIColor = UIColor.peachColor()
    
    lazy var confetti: SAConfettiView = {
        let view:SAConfettiView = SAConfettiView(frame: self.bounds)
        view.type = .Confetti
        view.delegate = self
        view.colors = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor()]
        view.intensity = 1.0
        return view
    }()
    
    lazy var viewPanel: PFImageView = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 2.0) - 6.0
        let view: PFImageView = PFImageView(frame: CGRect(x: 3, y: self.userName.frame.maxY + 5, width: widther, height: widther))
        view.backgroundColor = self.userColor
        view.imageWithString("R P S", color: self.userColor, circular: false, fontAttributes: nil)
        view.layer.borderColor = UIColor.redColor().CGColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var vsPanel: PFImageView = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 2.0) - 6.0
        let view: PFImageView = PFImageView(frame: CGRect(x: self.viewPanel.frame.maxX + 6, y: self.userName.frame.maxY + 5, width: widther, height: widther))
        view.backgroundColor = self.opponentColor
        view.imageWithString("R P S", color: self.opponentColor, circular: false, fontAttributes: nil)
        view.layer.borderColor = UIColor.redColor().CGColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var userName: UILabel = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 2.0) - 6.0
        let view: UILabel = UILabel(frame: CGRect(x: 3, y: 5, width: widther, height: 20))
        view.textColor = self.userColor.lightenedColor(0.4)
        view.text = PFUser.currentUser()!["fullname"] as? String
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 18)
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = NSTextAlignment.Right
        return view
    }()
    
    lazy var opponentName: loadingLabel = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 2.0) - 6.0
        let view: loadingLabel = loadingLabel(frame: CGRect(x: self.userName.frame.maxX + 6, y: 5, width: widther, height: 20))
        view.textColor = self.opponentColor
        view.text = "Waiting for Opponent."
        view.font = (UIScreen.mainScreen().bounds.width <= 320) ? UIFont(name: "AmericanTypewriter-Bold", size: 13) : UIFont(name: "AmericanTypewriter-Bold", size: 18)
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = NSTextAlignment.Left
        return view
    }()
    
    lazy var prevUserChoice: UILabel = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 4.0) - 10.0
        let view: UILabel = UILabel(frame: CGRect(x: self.userChoiceImage.frame.minX, y: self.userChoiceImage.frame.maxY + 7, width: widther, height: 26))
        view.textColor = self.userColor
        view.text = "Prev"
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 30)
        view.textAlignment = NSTextAlignment.Center
        return view
    }()
    
    lazy var prevOpponentChoice: UILabel = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 4.0) - 10.0
        let view: UILabel = UILabel(frame: CGRect(x: self.opponentChoiceImage.frame.maxX - (widther + 2), y: self.prevUserChoice.frame.minY, width: widther, height: 26))
        view.textColor = self.opponentColor
        view.text = "Prev"
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 30)
        view.textAlignment = NSTextAlignment.Center
        return view
    }()
    
    lazy var lastOpponentChoiceImage: UIImageView = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 4.0) - 10.0
        let imageView:UIImageView = UIImageView(frame: CGRect(x: self.prevOpponentChoiceImage.frame.minX - (widther + 2), y: self.prevUserChoiceImage.frame.minY, width: widther, height: widther))
        imageView.backgroundColor = self.opponentColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var prevOpponentChoiceImage: UIImageView = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 4.0) - 10.0
        let imageView:UIImageView = UIImageView(frame: CGRect(x: self.opponentChoiceImage.frame.maxX - (widther + 2), y: self.prevUserChoiceImage.frame.minY, width: widther, height: widther))
        imageView.backgroundColor = self.opponentColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var userChoiceImage: UIImageView = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 3.0) - 6.0
        var userChoiceframe: CGRect!
        if UIScreen.mainScreen().bounds.size.height >= 736 {
            userChoiceframe = CGRect(x: 3, y: self.viewPanel.frame.maxY + 25, width: widther, height: widther)
        } else if UIScreen.mainScreen().bounds.size.height < 736 && UIScreen.mainScreen().bounds.size.height >= 667 {
            userChoiceframe = CGRect(x: 3, y: self.viewPanel.frame.maxY + 15, width: widther, height: widther)
        } else {
            userChoiceframe = CGRect(x: 3, y: self.viewPanel.frame.maxY + 5, width: widther, height: widther)
        }
        let imageView:UIImageView = UIImageView(frame: userChoiceframe)//CGRect(x: 3, y: self.viewPanel.frame.maxY + 5, width: widther, height: widther))
        imageView.backgroundColor = self.userColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var prevUserChoiceImage: UIImageView = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 4.0) - 10.0
        let imageView:UIImageView = UIImageView(frame: CGRect(x: self.userChoiceImage.frame.minX, y: self.prevUserChoice.frame.maxY + 10, width: widther, height: widther))
        imageView.backgroundColor = self.userColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var lastUserChoiceImage: UIImageView = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 4.0) - 10.0
        let imageView:UIImageView = UIImageView(frame: CGRect(x: self.prevUserChoiceImage.frame.maxX + 2, y: self.prevUserChoiceImage.frame.minY, width: widther, height: widther))
        imageView.backgroundColor = self.userColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var Score: UILabel = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 3.0) - 6.0
        let view: UILabel = UILabel(frame: CGRect(x: self.userChoiceImage.frame.maxX + 6, y: self.userChoiceImage.frame.minY, width: widther, height: 30))
        view.textColor = .whiteColor()
        view.text = "Score"
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 30)
        view.textAlignment = NSTextAlignment.Center
        return view
    }()
    
    lazy var userScore: UILabel = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 3.0) - 6.0
        let view: UILabel = UILabel(frame: CGRect(x: (self.Score.frame.midX - 10) - ((self.Score.frame.width/2) - 10), y: self.Score.frame.maxY + 2, width: (self.Score.frame.width/2) - 10, height: widther - 34))
        view.textColor = self.userColor
        view.text = "0"
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 70)
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = NSTextAlignment.Right
        return view
    }()
    
    lazy var Dash: UILabel = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 3.0) - 6.0
        let view: UILabel = UILabel(frame: CGRect(x: self.frame.midX - 10, y: self.userScore.frame.midY - 30, width: 20, height: 40))
        view.textColor = UIColor.whiteColor()
        view.text = "-"
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 70)
        view.textAlignment = NSTextAlignment.Center
        return view
    }()
    
    lazy var opponentScore: UILabel = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 3.0) - 6.0
        let view: UILabel = UILabel(frame: CGRect(x: (self.Score.frame.midX + 10), y: self.Score.frame.maxY + 2, width: (self.Score.frame.width/2) - 10, height: widther - 34))
        view.textColor = self.opponentColor
        view.text = "0"
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 70)
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = NSTextAlignment.Left
        return view
    }()
    
    lazy var opponentChoiceImage: UIImageView = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 3.0) - 6.0
        let imageView:UIImageView = UIImageView(frame: CGRect(x: self.frame.maxX - (widther + 3), y: self.userChoiceImage.frame.minY, width: widther, height: widther))
        imageView.backgroundColor = self.opponentColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var ResultLabel: UILabel = {
        let widther: CGFloat = (UIScreen.mainScreen().bounds.width / 3.0) - 8.0
        let view: UILabel = UILabel(frame:CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY + 90, width: UIScreen.mainScreen().bounds.width - 10, height: 80))
        view.text = "You Lost"
        view.textColor = UIColor.peachColor()
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 50)
        view.backgroundColor = UIColor.whiteColor()
        view.layer.borderColor = UIColor.peachColor().CGColor
        view.layer.borderWidth = 3.0
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        view.adjustsFontSizeToFitWidth = true
        view.userInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedLose)))
        view.textAlignment = NSTextAlignment.Center
        return view
    }()
    
    func tappedLose() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.ResultLabel.frame = self.ResultLabel.frame.offsetBy(dx: 0, dy: 270)
            self.readyPlayButton.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY - 150, width: UIScreen.mainScreen().bounds.width - 10, height: 80)
            }, completion: {_ in
                self.readyPlayButton.enabled = true
        })
    }
    
    func showResultLabel(text: String) {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Rock.frame = self.Rock.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Paper.frame = self.Paper.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Scissors.frame = self.Scissors.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                if !self.subviews.contains(self.ResultLabel) {
                    self.addSubview(self.ResultLabel)
                }
                self.ResultLabel.text = text
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.ResultLabel.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY - 150, width: UIScreen.mainScreen().bounds.width - 10, height: 80)
                    }, completion: nil)
        })
    }
    
}

public protocol RematchDelegate {
    func RematchTapped(rematchview: RematchView, quit: Bool)
}

public class RematchView: UIView {
    
    var delegate: RematchDelegate!
    
    var showing: Bool = false
    
    let userColor: UIColor = UIColor.infoBlueColor()
    let opponentColor: UIColor = UIColor.peachColor()
    
    class var sharedInstance: RematchView {
        struct Singleton {
            static let instance = RematchView(frame: CGRect(x: 15, y: (UIScreen.mainScreen().bounds.midY - 75) + UIScreen.mainScreen().bounds.height, width: UIScreen.mainScreen().bounds.width - 30, height: 150))
        }
        return Singleton.instance
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        (UIApplication.sharedApplication().delegate as! AppDelegate).window!.addSubview(self)
        self.addSubview(TopView)
        self.addSubview(backButton)
        self.addSubview(rematchButton)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        setup()
    }
    
    func setup() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
        }
        backgroundColor = self.userColor
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.cornerRadius = 8.0
        layer.borderWidth = 2.0
        layer.masksToBounds = true
    }
    
    var result: Results = .Win {
        didSet {
            if self.result == .Win {
                TopView.text = "You Won!"
                TopView.backgroundColor = self.userColor
                self.backgroundColor = self.userColor
            } else {
                TopView.text = "You Lost"
                TopView.backgroundColor = self.opponentColor
                self.backgroundColor = self.opponentColor
            }
        }
    }
    
    lazy var TopView: UILabel = {
        let view: UILabel = UILabel(frame:CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width - 30, height: 75))
        view.text = "You Won!"
        view.backgroundColor = self.userColor
        self.backgroundColor = self.userColor
        view.textColor = UIColor.whiteColor()
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 50)
        view.backgroundColor = .clearColor()
        view.layer.masksToBounds = true
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = NSTextAlignment.Center
        return view
    }()
    
    lazy var backButton : GradientButton = {
        let NoLabel: GradientButton = GradientButton(frame:CGRect(x: 0, y: 75, width: ((UIScreen.mainScreen().bounds.width - 30) / 2), height: 80))
        NoLabel.useRedStyle()
        NoLabel.setAttributedTitle(NSAttributedString(string: "Quit", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 30)!]), forState: UIControlState.Normal)
        NoLabel.addTarget(self, action: #selector(self.tappedQuit), forControlEvents: UIControlEvents.TouchUpInside)
        NoLabel.layer.borderColor = UIColor.whiteColor().CGColor
        NoLabel.layer.borderWidth = 1.0
        NoLabel.layer.cornerRadius = 0.0
        NoLabel.layer.masksToBounds = true
        NoLabel.userInteractionEnabled = true
        return NoLabel
    }()
    
    lazy var rematchButton : GradientButton = {
        let YesLabel: GradientButton = GradientButton(frame:CGRect(x: (UIScreen.mainScreen().bounds.width - 30) / 2, y: 75, width: ((UIScreen.mainScreen().bounds.width - 30) / 2), height: 80))
        YesLabel.useGreenStyle()
        YesLabel.setAttributedTitle(NSAttributedString(string: "Rematch", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 30)!]), forState: UIControlState.Normal)
        YesLabel.addTarget(self, action: #selector(self.tappedRematch), forControlEvents: UIControlEvents.TouchUpInside)
        YesLabel.layer.borderColor = UIColor.whiteColor().CGColor
        YesLabel.layer.borderWidth = 1.0
        YesLabel.layer.cornerRadius = 0.0
        YesLabel.layer.masksToBounds = true
        YesLabel.userInteractionEnabled = true
        return YesLabel
    }()
    
    func showRematch() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.frame = CGRect(x: 15, y: (UIScreen.mainScreen().bounds.midY), width: UIScreen.mainScreen().bounds.width - 30, height: 150)
        }, completion: {_ in self.showing = true})
    }
    
    func tappedQuit(sender : GradientButton) {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.frame = self.frame.offsetBy(dx: 0, dy: UIScreen.mainScreen().bounds.height)
            }, completion: {_ in
                self.showing = false
                self.delegate.RematchTapped(self, quit: true)
        })
    }
    
    func tappedRematch(sender : GradientButton) {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.frame = self.frame.offsetBy(dx: 0, dy: UIScreen.mainScreen().bounds.height)
            }, completion: {_ in
                self.showing = false
                self.delegate.RematchTapped(self, quit: false)
        })
    }
    
    func hide() {
        if self.showing {
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.frame = self.frame.offsetBy(dx: 0, dy: UIScreen.mainScreen().bounds.height)
                }, completion: {_ in self.showing = false})
        }
    }
    
}

extension UIImageView {
    func createImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView(frame: self.frame)
        imageView.layer.cornerRadius = self.frame.height / 2
        imageView.layer.masksToBounds = true
        if self.image != nil {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                imageView.image = UIImage(CGImage: image.CGImage!)
            } else {
                UIGraphicsEndImageContext()
            }
            self.image = nil
        }
        self.superview!.addSubview(imageView)
        return imageView
    }
}

extension GameView {
    
    func moveImages() {
        self.opponentChoiceImage.image = UIImage(named: self.opponentChoice.description)
        self.userChoiceImage.image = UIImage(named: self.choice.description)
        let userImg = self.userChoiceImage.createImageView()
        let oppImg = self.opponentChoiceImage.createImageView()
        let prevUserImg = self.prevUserChoiceImage.createImageView()
        let prevOppImg = self.prevOpponentChoiceImage.createImageView()
        let lastUserImg = self.lastUserChoiceImage.createImageView()
        let lastOppImg = self.lastOpponentChoiceImage.createImageView()
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            userImg.frame = self.prevUserChoiceImage.frame
            userImg.layer.cornerRadius = self.prevUserChoiceImage.frame.height/2
            oppImg.frame = self.prevOpponentChoiceImage.frame
            oppImg.layer.cornerRadius = self.prevOpponentChoiceImage.frame.height/2
            prevUserImg.frame = self.lastUserChoiceImage.frame
            prevOppImg.frame = self.lastOpponentChoiceImage.frame
            lastUserImg.frame = self.lastUserChoiceImage.frame.offsetBy(dx: lastUserImg.frame.width, dy: 0)
            lastOppImg.frame = self.lastOpponentChoiceImage.frame.offsetBy(dx: -lastOppImg.frame.width, dy: 0)
            lastUserImg.alpha = 0
            lastOppImg.alpha = 0
            }, completion: {_ in
                self.prevUserChoiceImage.image = userImg.image
                self.prevOpponentChoiceImage.image = oppImg.image
                self.lastUserChoiceImage.image = prevUserImg.image
                self.lastOpponentChoiceImage.image = prevOppImg.image
                userImg.removeFromSuperview()
                oppImg.removeFromSuperview()
                prevUserImg.removeFromSuperview()
                prevOppImg.removeFromSuperview()
                lastUserImg.removeFromSuperview()
                lastOppImg.removeFromSuperview()
        })
    }
    
    typealias WinCheckClosure = (Results) -> Void
    
    func checkWin(completion: WinCheckClosure) {
        self.Rock.enabled = false
        self.Paper.enabled = false
        self.Scissors.enabled = false
        self.moveImages()
        self.opponentStatus = false
        self.readyStatus = false
        self.subscriber!.view!.layer.borderColor = UIColor.redColor().CGColor
        self.publisher!.view!.layer.borderColor = UIColor.redColor().CGColor
        if self.choice == self.opponentChoice {
            completion(Results.Tie)
        } else {
            switch self.choice {
            case .Rock:
                if self.opponentChoice == .Empty || self.opponentChoice == .Scissors {
                    completion(Results.Win)
                } else {
                    completion(Results.Lose)
                }
            case .Paper:
                if self.opponentChoice == .Empty || self.opponentChoice == .Rock {
                    completion(Results.Win)
                } else {
                    completion(Results.Lose)
                }
            case .Scissors:
                if self.opponentChoice == .Empty || self.opponentChoice == .Paper {
                    completion(Results.Win)
                } else {
                    completion(Results.Lose)
                }
            case .Empty:
                if self.opponentChoice == .Empty {
                    completion(Results.Tie)
                } else {
                    completion(Results.Lose)
                }
            }
        }
    }
}
