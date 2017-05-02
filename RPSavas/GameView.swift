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
    
    func countdownFinished(_ view: CountdownView) {
        self.Rock.isEnabled = false
        self.Paper.isEnabled = false
        self.Scissors.isEnabled = false
        self.delay(0.6, closure: {
            var maybeError : OTError?
            self.session?.signal(withType: "Choice", string: self.choice.description, connection: self.OppConnect, error:  &maybeError)
            if (maybeError != nil) {
                self.delay(3.0, closure: {
                    self.session?.signal(withType: "Choice", string: self.choice.description, connection: self.OppConnect, error:  nil)
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
            self.session?.signal(withType: "Disconnect", string: "Disconnect", connection: self.OppConnect, error: &maybeError)
            if (maybeError != nil) {
                activityIndicatorView.startAnimation()
                self.delay(3.0, closure: {
                    self.session?.signal(withType: "Disconnect", string: "Disconnect", connection: self.OppConnect, error: nil)
                    activityIndicatorView.stopAnimation()
                })
            }
            self.session?.disconnect(nil)
            self.session = nil
        }
        let query = PFQuery(className: "ActiveSessions")
        if AppConfiguration.SessionID != nil {
            query.whereKey("sessionID", equalTo: AppConfiguration.SessionID)
        }
        query.getFirstObjectInBackground(block: {
            object, error in
            if error == nil {
                //TODO: - Remove comment to delete
                //object?.deleteEventually()
            }
        })
        sideMenuNavigationController!.popViewController(animated: true)
        self.rematchView.hide()
    }
    
    public func sessionDidConnect(_ session: OTSession) {
        self.Connect = session.connection
        publisher = OTPublisher(delegate: self, name: PFUser.current()!.Fullname())
        var maybeError : OTError?
        session.publish(publisher!, error: &maybeError)
        if (maybeError != nil) {
            ProgressHUD.showError("Error Connecting")
            self.disconnect()
        }
        publisher!.view!.layer.borderColor = UIColor.red.cgColor
        publisher!.view!.layer.cornerRadius = 8.0
        publisher!.view!.layer.borderWidth = 1.0
        publisher!.view!.backgroundColor = UIColor.clear
        publisher!.view!.layer.backgroundColor = UIColor.clear.cgColor
        publisher!.view!.layer.masksToBounds = true
        publisher!.view!.frame = viewPanel.frame
        publisher!.view!.alpha = 0.0
        addSubview(publisher!.view!)
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.publisher!.view!.alpha = 1.0
        }, completion: nil)
    }
    
    public func sessionDidDisconnect(_ session : OTSession) {
    }
    
    public func session(_ session: OTSession, streamCreated stream: OTStream) {
        if (stream.connection.connectionId != Connect.connectionId) {
            subscriber = OTSubscriber(stream: stream, delegate: self)
            var maybeError : OTError?
            session.subscribe(subscriber!, error: &maybeError)
            if (maybeError != nil) {
                ProgressHUD.showError("Error Receiving Opponent Video Feed")
            }
        }
    }
    
    public func session(_ session: OTSession, streamDestroyed stream: OTStream) {
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
    
    public func session(_ session: OTSession, connectionCreated connection : OTConnection) {
        self.OppConnect = connection
    }
    
    public func session(_ session: OTSession, connectionDestroyed connection : OTConnection) {
        //NSLog("session connectionDestroyed (\(connection.connectionId))")
    }
    
    public func session(_ session: OTSession, didFailWithError error: OTError) {
        self.session = nil
        ProgressHUD.showError(error.localizedDescription)
        if AppConfiguration.SessionID != nil {
            let query = PFQuery(className: "ActiveSessions")
            query.whereKey("sessionID", equalTo: AppConfiguration.SessionID)
            query.getFirstObjectInBackground(block: {
                object, error in
                if error == nil {
                    object?.deleteEventually()
                }
            })
        }
        sideMenuNavigationController!.popViewController(animated: true)
    }
    
    // MARK: - OTSubscriber delegate callbacks
    
    public func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        let subscriber:OTSubscriber = subscriberKit as! OTSubscriber
        var maybeError : OTError?
        self.session?.signal(withType: "user", string: PFUser.current()!.objectId!, connection: self.OppConnect, error: &maybeError)
        if (maybeError != nil) {
            activityIndicatorView.startAnimation()
            self.delay(3.0, closure: {
                self.session?.signal(withType: "user", string: PFUser.current()!.objectId!, connection: self.OppConnect, error: nil)
                activityIndicatorView.stopAnimation()
            })
        }
        self.readyPlayButton.isSelected = !self.readyPlayButton.isSelected
        self.readyPlayButton.isEnabled = true
        PFQuery(className:"ActiveSessions").getObjectInBackground(withId: AppConfiguration.activeSession!.objectId!, block: { object, error in
            if error == nil {
                object!.deleteInBackground()
            }
        })
        subscriber.view!.frame = self.vsPanel.frame
        subscriber.view!.layer.cornerRadius = 8.0
        subscriber.view!.backgroundColor = UIColor.clear
        subscriber.view!.layer.backgroundColor = UIColor.clear.cgColor
        subscriber.view!.layer.borderColor = UIColor.red.cgColor
        subscriber.view!.layer.borderWidth = 1.0
        subscriber.view!.layer.masksToBounds = true
        subscriber.view!.alpha = 0.0
        addSubview(subscriber.view!)
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            subscriber.view!.alpha = 1.0
            }, completion: {_ in
                activityIndicatorView.stopAnimation()
        })
    }
    
    
    public func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        self.subscriber!.view!.alpha = 1.0
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.subscriber!.view!.alpha = 0.0
            }, completion: nil)
    }
    
    public func subscriberVideoEnabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        self.subscriber!.view!.alpha = 0.0
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.subscriber!.view!.alpha = 1.0
            }, completion: nil)
    }
    
    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error : OTError) {
        NSLog("subscriber %@ didFailWithError %@", subscriber.stream!.streamId, error)
    }
    
    // MARK: - OTPublisher delegate callbacks
    
    public func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        //NSLog("publisher streamCreated %@", stream)
    }
    
    public func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        //NSLog("publisher streamDestroyed %@", stream)
    }
    
    public func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        NSLog("publisher didFailWithError %@", error)
    }
    
    public func session(_ session: OTSession, receivedSignalType type: String?, from connection: OTConnection?, with string: String?) {
        if (connection!.connectionId == OppConnect.connectionId) {
            if type == "user"{
                PFUser.query()?.getObjectInBackground(withId: string!, block: { (object, error) in
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
                let scores = string!.components(separatedBy: ":OppScore:")
                let oppScore : Int = Int(scores[0].replacingOccurrences(of: "MyScore:", with: ""))!
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
                PFQuery(className: "ActiveSessions").getObjectInBackground(withId: AppConfiguration.activeSession!.objectId!, block: { object, error in
                    if error == nil {
                        object?.deleteEventually()
                    }
                })
                let AddMenu = UIAlertController(title:nil , message: nil, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Opponent has left", style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction!) -> Void in
                    //self.session?.disconnect(nil)
                    sideMenuNavigationController!.popViewController(animated: true)
                    self.rematchView.hide()
                })
                AddMenu.addAction(cancelAction)
                if self.getParentViewController() != nil {
                    self.getParentViewController()!.present(AddMenu, animated: true, completion: nil)
                }
            } else if type == "readyStatus" {
                self.opponentStatus = true
                if self.readyStatus == true {
                    self.startGame()
                }
            } else if type == "Choice" {
                self.delay(0.2, closure: {
                    switch string! {
                    case RPSChoice.rock.description: self.opponentChoice = .rock
                    case RPSChoice.paper.description: self.opponentChoice = .paper
                    case RPSChoice.scissors.description: self.opponentChoice = .scissors
                    case RPSChoice.empty.description: self.opponentChoice = .empty
                    default: break
                    }
                    self.checkWin({ (results) in
                        switch results {
                        case .win: self.userScoreInt += 1
                        case .lose: self.opponentScoreInt += 1
                        case .tie: self.showResultLabel("Tied!")
                        }
                        var maybeError : OTError?
                        self.session?.signal(withType: "score", string: "MyScore:\(self.userScoreInt):OppScore:\(self.opponentScoreInt)", connection: self.OppConnect, error: &maybeError)
                        if (maybeError != nil) {
                            activityIndicatorView.startAnimation()
                            self.delay(3.0, closure: {
                                self.session?.signal(withType: "score", string: "MyScore:\(self.userScoreInt):OppScore:\(self.opponentScoreInt)", connection: self.OppConnect, error: nil)
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
    public func confettiViewTapped(_ view: SAConfettiView) {
        self.confetti.stopConfetti(self)
    }
}


extension GameView: RematchDelegate {
    public func RematchTapped(_ rematchview: RematchView, quit: Bool) {
        if quit == false {
            self.rematch = true
            self.confetti.stop(self)
            var maybeError : OTError?
            self.session?.signal(withType: "rematch", string: "true", connection: self.OppConnect, error: &maybeError)
            if (maybeError != nil) {
                activityIndicatorView.startAnimation()
                self.delay(3.0, closure: {
                    self.session?.signal(withType: "rematch", string: "true", connection: self.OppConnect, error: nil)
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

open class GameView: UIView {

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
                self.session!.connect(withToken: AppConfiguration.publisherToken!, error: &maybeError)
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
                    self.publisher!.view!.layer.borderColor = UIColor.green.cgColor
                } else {
                    self.publisher!.view!.layer.borderColor = UIColor.red.cgColor
                }
            }
        }
    }
    
    var opponentStatus: Bool = false {
        didSet {
            if self.subscriber != nil {
                if opponentStatus {
                    self.subscriber!.view!.layer.borderColor = UIColor.green.cgColor
                } else {
                    self.subscriber!.view!.layer.borderColor = UIColor.red.cgColor
                }
            }
        }
    }
    
    func startGame() {
        self.choice = .empty
        self.opponentChoice = .empty
        self.Rock.isEnabled = true
        self.Paper.isEnabled = true
        self.Scissors.isEnabled = true
        self.addCountdown()
    }

    var opponentRematch: Bool = false
    
    var rematch: Bool = false
    
    func resetMatch() {
        self.userScoreInt = 0
        self.opponentScoreInt = 0
        self.choice = .empty
        self.opponentChoice = .empty
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
    var opponentChoice: RPSChoice = .empty
    
    var choice: RPSChoice = .empty
    
    var resetScore: Bool = false
    
    // These ints track both users' scores.
    var userScoreInt: Int = 0 {
        didSet {
            userScore.evaporate(userScoreInt.description)
            if !resetScore {
                if self.userScoreInt > 4 {
                    PFUser.current()!.incrementKey("Wins")
                    PFUser.current()!.incrementKey("WinStreak")
                    PFUser.current()!.saveInBackground()
                    self.rematchView.result = .win
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
                    PFUser.current()!.incrementKey("Losses")
                    PFUser.current()!["WinStreak"] = 0
                    PFUser.current()!.saveInBackground()
                    self.rematchView.result = .lose
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
            let cell: SideMenuCell = sideMenuObj.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SideMenuCell
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
            let cell: SideMenuCell = sideMenuObj.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! SideMenuCell
            if publisher != nil {
                publisher!.publishVideo = self.MutedVid
                publisher!.view!.isHidden = !self.MutedVid
            }
            cell.evap(self.MutedVid ? "Mute Video" : "Unmute Video")
        }
    }
    
    var MutedOpp:Bool = true {
        didSet {
            let cell: SideMenuCell = sideMenuObj.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! SideMenuCell
            if subscriber != nil {
                subscriber!.subscribeToAudio = self.MutedOpp
                subscriber!.subscribeToVideo = self.MutedOpp
                subscriber!.view!.isHidden = !self.MutedOpp
                cell.evap(self.MutedOpp ? "Mute Opponent" : "Unmute Opponent")
            }
        }
    }
    
    var MutedMe:Bool = true {
        didSet {
            let cell: SideMenuCell = sideMenuObj.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! SideMenuCell
            if publisher != nil {
                publisher!.publishAudio = self.MutedMe
                cell.evap(self.MutedMe ? "Mute Mic" : "Unmute Mic")
            }
        }
    }
    
    override open func awakeFromNib() {
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
        
        self.userName.evap(PFUser.current()!.Fullname())
        if PFUser.current()!["picture"] != nil {
            self.viewPanel.file = PFUser.current()!["picture"] as? PFFile
            self.viewPanel.loadInBackground()
        } else {
            if PFUser.current()!["fullname"] != nil {
                self.viewPanel.imageWithString(PFUser.current()!["fullname"] as! String, color: .charcoalColor(), circular: false, fontAttributes: nil)
            } else {
                self.viewPanel.imageWithString("R P S", color: .charcoalColor(), circular: false, fontAttributes: nil)
            }
        }
    }
    
    func addBlurBackground(_ frame: CGRect) {
        let rect = CGRect(x: frame.minX - 1, y: frame.minY - 1, width: frame.width + 2, height: frame.height + 2)
        let visualEffectView:VisualEffectView = VisualEffectView(frame: rect)
        visualEffectView.colorTint = AppConfiguration.startingColor
        visualEffectView.colorTintAlpha = 0.3
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        visualEffectView.layer.cornerRadius = 8.0
        visualEffectView.layer.masksToBounds = true
        self.insertSubview(visualEffectView, at: 0)
    }
    
    var type : GameType? {
        didSet {
            rematchView.delegate = self
            if self.type != nil {
                switch self.type! {
                case .random: self.sessionQuery()
                case .nearby: self.session = OTSession(apiKey: AppConfiguration.ApiKey, sessionId: AppConfiguration.SessionID, delegate: self)
                case .friend: self.session = OTSession(apiKey: AppConfiguration.ApiKey, sessionId: AppConfiguration.SessionID, delegate: self)
                }
            }
        }
    }
    
    func createQuickGame() {
        let activeSession:PFObject = PFObject(className: "ActiveSessions")
        activeSession["caller"] = PFUser.current()!
        activeSession["receiverID"] = "Quick"
        activeSession["callerTitle"] = "\(PFUser.current()!.Fullname()) sent you a game request!"
        activeSession.saveInBackground(block: {(succeeded: Bool?, error: Error?) -> Void in
            if error == nil {
                AppConfiguration.activeSession = activeSession
                self.session = OTSession(apiKey: AppConfiguration.ApiKey, sessionId: AppConfiguration.SessionID, delegate: self)
            } else {
                AppConfiguration.activeSession = nil
                ProgressHUD.showError("Couldn't Create Game")
                sideMenuNavigationController!.popViewController(animated: true)
            }
        })
    }
    
    func sessionQuery() {
        activityIndicatorView.startAnimation()
        AppConfiguration.activeSession = nil
        let query = PFQuery(className: "ActiveSessions")
        query.whereKey("receiverID", equalTo: "Quick")
        query.getFirstObjectInBackground { (object, error) in
            if error == nil && object != nil {
                AppConfiguration.activeSession = object!
                self.session = OTSession(apiKey: AppConfiguration.ApiKey, sessionId: AppConfiguration.SessionID, delegate: self)
            } else {
                self.createQuickGame()
            }
        }
    }
 
    func TappedRock(_ sender: UIButton) {
        choice = .rock
        userChoiceImage.image = UIImage(named: "rock")!
    }
    
    func TappedPaper(_ sender: UIButton) {
        choice = .paper
        userChoiceImage.image = UIImage(named: "paper")!
    }
    
    func TappedScissors(_ sender: UIButton) {
        choice = .scissors
        userChoiceImage.image = UIImage(named: "scissors")!
    }
    
    lazy var readyPlayButton: GradientButton = {
        let button:GradientButton = GradientButton(frame: CGRect(x: 5, y: UIScreen.main.bounds.maxY + 90, width: UIScreen.main.bounds.width - 10, height: 80))
        button.backgroundColor = UIColor.clear
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.isEnabled = false
        button.layer.cornerRadius = 8.0
        button.useGreenStyle()
        button.layer.masksToBounds = true
        button.setAttributedTitle(NSAttributedString(string: "Ready to Play!", attributes: [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 30)!]), for: UIControlState())
        button.addTarget(self, action: #selector(self.readyUp), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    func readyUp(_ sender: GradientButton) {
        sender.isSelected = !sender.isSelected
        self.delay(0.3, closure: {
            sender.isSelected = !sender.isSelected
            self.readyStatus = true
            self.confetti.removeFromSuperview()
            if self.publisher != nil {
                self.publisher!.view!.layer.borderColor = UIColor.green.cgColor
            }
            self.showRPS()
        })
    }
    
    func showReadyPlay() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.Rock.frame = self.Rock.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions(), animations: {
            self.Paper.frame = self.Paper.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.4, options: UIViewAnimationOptions(), animations: {
            self.Scissors.frame = self.Scissors.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.readyPlayButton.frame = CGRect(x: 5, y: UIScreen.main.bounds.maxY - 150, width: UIScreen.main.bounds.width - 10, height: 80)
                    }, completion: {_ in
                        self.readyPlayButton.isEnabled = true
                })
        })
    }
    
    func presentReady() {
        self.readyPlayButton.isSelected = !self.readyPlayButton.isSelected
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.Rock.frame = self.Rock.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions(), animations: {
            self.Paper.frame = self.Paper.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.4, options: UIViewAnimationOptions(), animations: {
            self.Scissors.frame = self.Scissors.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.readyPlayButton.frame = CGRect(x: 5, y: UIScreen.main.bounds.maxY - 150, width: UIScreen.main.bounds.width - 10, height: 80)
                    }, completion: {_ in
                        //self.readyPlayButton.enabled = true
                })
        })
    }
    
    func showRPS() {
        self.readyPlayButton.isEnabled = false
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.readyPlayButton.frame = self.readyPlayButton.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.Rock.frame = self.getRects()[0]
                    }, completion: nil)
                UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions(), animations: {
                    self.Paper.frame = self.getRects()[1]
                    }, completion: nil)
                UIView.animate(withDuration: 0.5, delay: 0.4, options: UIViewAnimationOptions(), animations: {
                    self.Scissors.frame = self.getRects()[2]
                    }, completion: {_ in
                        var maybeError : OTError?
                        self.session?.signal(withType: "readyStatus", string: "true", connection: self.OppConnect, error: &maybeError)
                        if (maybeError != nil) {
                            activityIndicatorView.startAnimation()
                            self.delay(3.0, closure: {
                                self.session?.signal(withType: "readyStatus", string: "true", connection: self.OppConnect, error: nil)
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
        button.backgroundColor = UIColor.clear
        button.isEnabled = false
        button.setImage(UIImage(named: "rock"), for: UIControlState())
        button.addTarget(self, action: #selector(self.TappedRock), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var Paper: UIButton = {
        let button:UIButton = UIButton(frame: self.getRects()[1])
        button.backgroundColor = UIColor.clear
        button.isEnabled = false
        button.setImage(UIImage(named: "paper"), for: UIControlState())
        button.addTarget(self, action: #selector(self.TappedPaper), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var Scissors: UIButton = {
        let button:UIButton = UIButton(frame: self.getRects()[2])
        button.backgroundColor = UIColor.clear
        button.isEnabled = false
        button.setImage(UIImage(named: "scissors"), for: UIControlState())
        button.addTarget(self, action: #selector(self.TappedScissors), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    let userColor: UIColor = UIColor.infoBlueColor()
    let opponentColor: UIColor = UIColor.peachColor()
    
    lazy var confetti: SAConfettiView = {
        let view:SAConfettiView = SAConfettiView(frame: self.bounds)
        view.type = .confetti
        view.delegate = self
        view.colors = [UIColor.red, UIColor.green, UIColor.blue]
        view.intensity = 1.0
        return view
    }()
    
    lazy var viewPanel: PFImageView = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 2.0) - 6.0
        let view: PFImageView = PFImageView(frame: CGRect(x: 3, y: self.userName.frame.maxY + 5, width: widther, height: widther))
        view.backgroundColor = self.userColor
        view.imageWithString("R P S", color: self.userColor, circular: false, fontAttributes: nil)
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var vsPanel: PFImageView = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 2.0) - 6.0
        let view: PFImageView = PFImageView(frame: CGRect(x: self.viewPanel.frame.maxX + 6, y: self.userName.frame.maxY + 5, width: widther, height: widther))
        view.backgroundColor = self.opponentColor
        view.imageWithString("R P S", color: self.opponentColor, circular: false, fontAttributes: nil)
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var userName: UILabel = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 2.0) - 6.0
        let view: UILabel = UILabel(frame: CGRect(x: 3, y: 5, width: widther, height: 20))
        view.textColor = self.userColor.lightenedColor(0.4)
        view.text = PFUser.current()!["fullname"] as? String
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 18)
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = NSTextAlignment.right
        return view
    }()
    
    lazy var opponentName: loadingLabel = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 2.0) - 6.0
        let view: loadingLabel = loadingLabel(frame: CGRect(x: self.userName.frame.maxX + 6, y: 5, width: widther, height: 20))
        view.textColor = self.opponentColor
        view.text = "Waiting for Opponent."
        view.font = (UIScreen.main.bounds.width <= 320) ? UIFont(name: "AmericanTypewriter-Bold", size: 13) : UIFont(name: "AmericanTypewriter-Bold", size: 18)
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = NSTextAlignment.left
        return view
    }()
    
    lazy var prevUserChoice: UILabel = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 4.0) - 10.0
        let view: UILabel = UILabel(frame: CGRect(x: self.userChoiceImage.frame.minX, y: self.userChoiceImage.frame.maxY + 7, width: widther, height: 26))
        view.textColor = self.userColor
        view.text = "Prev"
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 30)
        view.textAlignment = NSTextAlignment.center
        return view
    }()
    
    lazy var prevOpponentChoice: UILabel = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 4.0) - 10.0
        let view: UILabel = UILabel(frame: CGRect(x: self.opponentChoiceImage.frame.maxX - (widther + 2), y: self.prevUserChoice.frame.minY, width: widther, height: 26))
        view.textColor = self.opponentColor
        view.text = "Prev"
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 30)
        view.textAlignment = NSTextAlignment.center
        return view
    }()
    
    lazy var lastOpponentChoiceImage: UIImageView = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 4.0) - 10.0
        let imageView:UIImageView = UIImageView(frame: CGRect(x: self.prevOpponentChoiceImage.frame.minX - (widther + 2), y: self.prevUserChoiceImage.frame.minY, width: widther, height: widther))
        imageView.backgroundColor = self.opponentColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var prevOpponentChoiceImage: UIImageView = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 4.0) - 10.0
        let imageView:UIImageView = UIImageView(frame: CGRect(x: self.opponentChoiceImage.frame.maxX - (widther + 2), y: self.prevUserChoiceImage.frame.minY, width: widther, height: widther))
        imageView.backgroundColor = self.opponentColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var userChoiceImage: UIImageView = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 3.0) - 6.0
        var userChoiceframe: CGRect!
        if UIScreen.main.bounds.size.height >= 736 {
            userChoiceframe = CGRect(x: 3, y: self.viewPanel.frame.maxY + 25, width: widther, height: widther)
        } else if UIScreen.main.bounds.size.height < 736 && UIScreen.main.bounds.size.height >= 667 {
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
        let widther: CGFloat = (UIScreen.main.bounds.width / 4.0) - 10.0
        let imageView:UIImageView = UIImageView(frame: CGRect(x: self.userChoiceImage.frame.minX, y: self.prevUserChoice.frame.maxY + 10, width: widther, height: widther))
        imageView.backgroundColor = self.userColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var lastUserChoiceImage: UIImageView = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 4.0) - 10.0
        let imageView:UIImageView = UIImageView(frame: CGRect(x: self.prevUserChoiceImage.frame.maxX + 2, y: self.prevUserChoiceImage.frame.minY, width: widther, height: widther))
        imageView.backgroundColor = self.userColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var Score: UILabel = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 3.0) - 6.0
        let view: UILabel = UILabel(frame: CGRect(x: self.userChoiceImage.frame.maxX + 6, y: self.userChoiceImage.frame.minY, width: widther, height: 30))
        view.textColor = .white
        view.text = "Score"
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 30)
        view.textAlignment = NSTextAlignment.center
        return view
    }()
    
    lazy var userScore: UILabel = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 3.0) - 6.0
        let view: UILabel = UILabel(frame: CGRect(x: (self.Score.frame.midX - 10) - ((self.Score.frame.width/2) - 10), y: self.Score.frame.maxY + 2, width: (self.Score.frame.width/2) - 10, height: widther - 34))
        view.textColor = self.userColor
        view.text = "0"
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 70)
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = NSTextAlignment.right
        return view
    }()
    
    lazy var Dash: UILabel = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 3.0) - 6.0
        let view: UILabel = UILabel(frame: CGRect(x: self.frame.midX - 10, y: self.userScore.frame.midY - 30, width: 20, height: 40))
        view.textColor = UIColor.white
        view.text = "-"
        view.adjustsFontSizeToFitWidth = true
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 70)
        view.textAlignment = NSTextAlignment.center
        return view
    }()
    
    lazy var opponentScore: UILabel = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 3.0) - 6.0
        let view: UILabel = UILabel(frame: CGRect(x: (self.Score.frame.midX + 10), y: self.Score.frame.maxY + 2, width: (self.Score.frame.width/2) - 10, height: widther - 34))
        view.textColor = self.opponentColor
        view.text = "0"
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 70)
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = NSTextAlignment.left
        return view
    }()
    
    lazy var opponentChoiceImage: UIImageView = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 3.0) - 6.0
        let imageView:UIImageView = UIImageView(frame: CGRect(x: self.frame.maxX - (widther + 3), y: self.userChoiceImage.frame.minY, width: widther, height: widther))
        imageView.backgroundColor = self.opponentColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var ResultLabel: UILabel = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 3.0) - 8.0
        let view: UILabel = UILabel(frame:CGRect(x: 5, y: UIScreen.main.bounds.maxY + 90, width: UIScreen.main.bounds.width - 10, height: 80))
        view.text = "You Lost"
        view.textColor = UIColor.peachColor()
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 50)
        view.backgroundColor = UIColor.white
        view.layer.borderColor = UIColor.peachColor().cgColor
        view.layer.borderWidth = 3.0
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        view.adjustsFontSizeToFitWidth = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedLose)))
        view.textAlignment = NSTextAlignment.center
        return view
    }()
    
    func tappedLose() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.ResultLabel.frame = self.ResultLabel.frame.offsetBy(dx: 0, dy: 270)
            self.readyPlayButton.frame = CGRect(x: 5, y: UIScreen.main.bounds.maxY - 150, width: UIScreen.main.bounds.width - 10, height: 80)
            }, completion: {_ in
                self.readyPlayButton.isEnabled = true
        })
    }
    
    func showResultLabel(_ text: String) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.Rock.frame = self.Rock.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions(), animations: {
            self.Paper.frame = self.Paper.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.4, options: UIViewAnimationOptions(), animations: {
            self.Scissors.frame = self.Scissors.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                if !self.subviews.contains(self.ResultLabel) {
                    self.addSubview(self.ResultLabel)
                }
                self.ResultLabel.text = text
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.ResultLabel.frame = CGRect(x: 5, y: UIScreen.main.bounds.maxY - 150, width: UIScreen.main.bounds.width - 10, height: 80)
                    }, completion: nil)
        })
    }
    
}

public protocol RematchDelegate {
    func RematchTapped(_ rematchview: RematchView, quit: Bool)
}

open class RematchView: UIView {
    
    var delegate: RematchDelegate!
    
    var showing: Bool = false
    
    let userColor: UIColor = UIColor.infoBlueColor()
    let opponentColor: UIColor = UIColor.peachColor()
    
    class var sharedInstance: RematchView {
        struct Singleton {
            static let instance = RematchView(frame: CGRect(x: 15, y: (UIScreen.main.bounds.midY - 75) + UIScreen.main.bounds.height, width: UIScreen.main.bounds.width - 30, height: 150))
        }
        return Singleton.instance
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        (UIApplication.shared.delegate as! AppDelegate).window!.addSubview(self)
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
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
        }
        backgroundColor = self.userColor
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = 8.0
        layer.borderWidth = 2.0
        layer.masksToBounds = true
    }
    
    var result: Results = .win {
        didSet {
            if self.result == .win {
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
        let view: UILabel = UILabel(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 75))
        view.text = "You Won!"
        view.backgroundColor = self.userColor
        self.backgroundColor = self.userColor
        view.textColor = UIColor.white
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 50)
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = NSTextAlignment.center
        return view
    }()
    
    lazy var backButton : GradientButton = {
        let NoLabel: GradientButton = GradientButton(frame:CGRect(x: 0, y: 75, width: ((UIScreen.main.bounds.width - 30) / 2), height: 80))
        NoLabel.useRedStyle()
        NoLabel.setAttributedTitle(NSAttributedString(string: "Quit", attributes: [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 30)!]), for: UIControlState())
        NoLabel.addTarget(self, action: #selector(self.tappedQuit), for: UIControlEvents.touchUpInside)
        NoLabel.layer.borderColor = UIColor.white.cgColor
        NoLabel.layer.borderWidth = 1.0
        NoLabel.layer.cornerRadius = 0.0
        NoLabel.layer.masksToBounds = true
        NoLabel.isUserInteractionEnabled = true
        return NoLabel
    }()
    
    lazy var rematchButton : GradientButton = {
        let YesLabel: GradientButton = GradientButton(frame:CGRect(x: (UIScreen.main.bounds.width - 30) / 2, y: 75, width: ((UIScreen.main.bounds.width - 30) / 2), height: 80))
        YesLabel.useGreenStyle()
        YesLabel.setAttributedTitle(NSAttributedString(string: "Rematch", attributes: [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 30)!]), for: UIControlState())
        YesLabel.addTarget(self, action: #selector(self.tappedRematch), for: UIControlEvents.touchUpInside)
        YesLabel.layer.borderColor = UIColor.white.cgColor
        YesLabel.layer.borderWidth = 1.0
        YesLabel.layer.cornerRadius = 0.0
        YesLabel.layer.masksToBounds = true
        YesLabel.isUserInteractionEnabled = true
        return YesLabel
    }()
    
    func showRematch() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.frame = CGRect(x: 15, y: (UIScreen.main.bounds.midY), width: UIScreen.main.bounds.width - 30, height: 150)
        }, completion: {_ in self.showing = true})
    }
    
    func tappedQuit(_ sender : GradientButton) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.frame = self.frame.offsetBy(dx: 0, dy: UIScreen.main.bounds.height)
            }, completion: {_ in
                self.showing = false
                self.delegate.RematchTapped(self, quit: true)
        })
    }
    
    func tappedRematch(_ sender : GradientButton) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.frame = self.frame.offsetBy(dx: 0, dy: UIScreen.main.bounds.height)
            }, completion: {_ in
                self.showing = false
                self.delegate.RematchTapped(self, quit: false)
        })
    }
    
    func hide() {
        if self.showing {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.frame = self.frame.offsetBy(dx: 0, dy: UIScreen.main.bounds.height)
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
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                imageView.image = UIImage(cgImage: image.cgImage!)
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
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
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
    
    func checkWin(_ completion: WinCheckClosure) {
        self.Rock.isEnabled = false
        self.Paper.isEnabled = false
        self.Scissors.isEnabled = false
        self.moveImages()
        self.opponentStatus = false
        self.readyStatus = false
        self.subscriber!.view!.layer.borderColor = UIColor.red.cgColor
        self.publisher!.view!.layer.borderColor = UIColor.red.cgColor
        if self.choice == self.opponentChoice {
            completion(Results.tie)
        } else {
            switch self.choice {
            case .rock:
                if self.opponentChoice == .empty || self.opponentChoice == .scissors {
                    completion(Results.win)
                } else {
                    completion(Results.lose)
                }
            case .paper:
                if self.opponentChoice == .empty || self.opponentChoice == .rock {
                    completion(Results.win)
                } else {
                    completion(Results.lose)
                }
            case .scissors:
                if self.opponentChoice == .empty || self.opponentChoice == .paper {
                    completion(Results.win)
                } else {
                    completion(Results.lose)
                }
            case .empty:
                if self.opponentChoice == .empty {
                    completion(Results.tie)
                } else {
                    completion(Results.lose)
                }
            }
        }
    }
}
