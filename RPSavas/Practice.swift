//
//  Practice.swift
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

open class Practice: UIViewController {
    
    let rematchView: RematchView = RematchView.sharedInstance
    
    var countdown: CountdownView!
    
    func startGame() {
        self.choice = .empty
        self.opponentChoice = .empty
        self.Rock.isEnabled = true
        self.Paper.isEnabled = true
        self.Scissors.isEnabled = true
        self.countdown.startPractice(self)
    }
    
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
                    self.rematchView.result = .win
                    self.confetti.startFinalConfettiPractice(self)
                } else if self.userScoreInt != 0 {
                    self.confetti.startConfettiPractice(self)
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
    
    override open func viewDidLoad() {
        setUp()
        self.navigationItem.setLeftBarButton(UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.disconnect)), animated: false)
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Reset", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.resetMatch)), animated: false)
        view.GradLayer()
        title = "Practice"
    }
    
    var loaded: Bool = false
    
    override open func viewDidAppear(_ animated: Bool) {
        if !loaded {
            self.loaded = true
            self.showReadyPlay()
        }
    }
    
    func setUp() {
        [viewPanel,vsPanel,userChoiceImage,Score,userScore,Dash,opponentScore,opponentChoiceImage,prevUserChoice,prevOpponentChoice,prevUserChoiceImage,lastUserChoiceImage,lastOpponentChoiceImage,prevOpponentChoiceImage,readyPlayButton,Rock,Paper,Scissors].forEach { (view) in
            self.view.addSubview(view)
        }
        countdown = CountdownView(frame: self.view.bounds)
        countdown.delegate = self
        countdown.updatePracticeAppearance()
        rematchView.delegate = self
        self.addBlurBackground(CGRect(origin: CGPoint(x: viewPanel.frame.minX, y:viewPanel.frame.minY), size: CGSize(width: view.frame.width - 6, height: viewPanel.frame.height)))
        if PFUser.current()!["picture"] != nil {
            self.viewPanel.file = PFUser.current()!["picture"] as? PFFile
            self.viewPanel.loadInBackground()
        } else {
            if PFUser.current()!["fullname"] != nil {
                self.viewPanel.imageWithString(PFUser.current()!["fullname"] as! String, color: self.userColor, circular: false, fontAttributes: nil)
            } else {
                self.viewPanel.imageWithString("R P S", color: self.userColor, circular: false, fontAttributes: nil)
            }
        }
        self.vsPanel.imageWithString("R P S", color: self.opponentColor, circular: false, fontAttributes: nil)
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
        self.view.insertSubview(visualEffectView, at: 0)
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
        button.layer.masksToBounds = true
        button.useGreenStyle()
        button.setAttributedTitle(NSAttributedString(string: "Ready to Play!", attributes: [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont(name: "AmericanTypewriter-Bold", size: 30)!]), for: UIControlState())
        button.addTarget(self, action: #selector(self.readyUp), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    func readyUp(_ sender: GradientButton) {
        sender.isSelected = !sender.isSelected
        self.delay(0.3, closure: {
            sender.isSelected = !sender.isSelected
            self.confetti.removeFromSuperview()
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
                        self.startGame()
                })
        })
    }
    
    
    func getRects() -> [CGRect] {
        var rockframe: CGRect!
        var paperframe: CGRect!
        var scissorsframe: CGRect!
        if view.bounds.size.height >= 736 {
            let widther: CGFloat = (self.view.bounds.width / 3.0) - 6.0
            rockframe = CGRect(x: 3, y: self.view.bounds.height - (widther + 5), width: widther, height: widther)
            paperframe = CGRect(x: rockframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
            scissorsframe = CGRect(x: paperframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
        } else if UIScreen.main.bounds.size.height < 736 && UIScreen.main.bounds.size.height >= 667 {
            let widther: CGFloat = (self.view.bounds.width / 3.0) - 6.0
            rockframe = CGRect(x: 3, y: self.view.bounds.height - (widther + 5), width: widther, height: widther)
            paperframe = CGRect(x: rockframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
            scissorsframe = CGRect(x: paperframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
        } else {
            let widther: CGFloat = (self.view.bounds.width / 3.5) - 6.0
            rockframe = CGRect(x: 10, y: self.view.bounds.height - (widther + 5), width: widther, height: widther)
            paperframe = CGRect(x: self.view.bounds.midX - (widther / 2), y: rockframe.minY, width: widther, height: widther)
            scissorsframe = CGRect(x: self.view.bounds.maxX - (widther + 10), y: rockframe.minY, width: widther, height: widther)
        }
        return [rockframe,paperframe,scissorsframe]
    }
    
    func getStartRects() -> [CGRect] {
        var rockframe: CGRect!
        var paperframe: CGRect!
        var scissorsframe: CGRect!
        if view.bounds.size.height >= 736 {
            let widther: CGFloat = (self.view.bounds.width / 3.0) - 6.0
            rockframe = CGRect(x: 3, y: self.view.bounds.height - (widther + 75), width: widther, height: widther)
            paperframe = CGRect(x: rockframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
            scissorsframe = CGRect(x: paperframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
        } else if UIScreen.main.bounds.size.height < 736 && UIScreen.main.bounds.size.height >= 667 {
            let widther: CGFloat = (self.view.bounds.width / 3.0) - 6.0
            rockframe = CGRect(x: 3, y: self.view.bounds.height - (widther + 75), width: widther, height: widther)
            paperframe = CGRect(x: rockframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
            scissorsframe = CGRect(x: paperframe.maxX + 6, y: rockframe.minY, width: widther, height: widther)
        } else {
            let widther: CGFloat = (self.view.bounds.width / 3.5) - 6.0
            rockframe = CGRect(x: 10, y: self.view.bounds.height - (widther + 75), width: widther, height: widther)
            paperframe = CGRect(x: self.view.bounds.midX - (widther / 2), y: rockframe.minY, width: widther, height: widther)
            scissorsframe = CGRect(x: self.view.bounds.maxX - (widther + 10), y: rockframe.minY, width: widther, height: widther)
        }
        return [rockframe,paperframe,scissorsframe]
    }
    
    lazy var Rock: UIButton = {
        let button:UIButton = UIButton(frame: self.getStartRects()[0])
        button.backgroundColor = UIColor.clear
        button.isEnabled = false
        button.setImage(UIImage(named: "rock"), for: UIControlState())
        button.addTarget(self, action: #selector(self.TappedRock), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var Paper: UIButton = {
        let button:UIButton = UIButton(frame: self.getStartRects()[1])
        button.backgroundColor = UIColor.clear
        button.isEnabled = false
        button.setImage(UIImage(named: "paper"), for: UIControlState())
        button.addTarget(self, action: #selector(self.TappedPaper), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var Scissors: UIButton = {
        let button:UIButton = UIButton(frame: self.getStartRects()[2])
        button.backgroundColor = UIColor.clear
        button.isEnabled = false
        button.setImage(UIImage(named: "scissors"), for: UIControlState())
        button.addTarget(self, action: #selector(self.TappedScissors), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    let userColor: UIColor = UIColor.infoBlueColor()
    let opponentColor: UIColor = UIColor.peachColor()
    
    lazy var confetti: SAConfettiView = {
        let view:SAConfettiView = SAConfettiView(frame: self.view.bounds)
        view.type = .confetti
        view.delegate = self
        view.colors = [UIColor.red, UIColor.green, UIColor.blue]
        view.intensity = 1.0
        return view
    }()
    
    lazy var viewPanel: PFImageView = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 2.0) - 6.0
        let view: PFImageView = PFImageView(frame: CGRect(x: 3, y: 25, width: widther, height: widther))
        view.backgroundColor = self.userColor
        view.imageWithString("R P S", color: self.userColor, circular: false, fontAttributes: nil)
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var vsPanel: PFImageView = {
        let widther: CGFloat = (UIScreen.main.bounds.width / 2.0) - 6.0
        let view: PFImageView = PFImageView(frame: CGRect(x: self.viewPanel.frame.maxX + 6, y: 25, width: widther, height: widther))
        view.backgroundColor = self.opponentColor
        view.imageWithString("R P S", color: self.opponentColor, circular: false, fontAttributes: nil)
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
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
        let view: UILabel = UILabel(frame: CGRect(x: self.view.frame.midX - 10, y: self.userScore.frame.midY - 30, width: 20, height: 40))
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
        let imageView:UIImageView = UIImageView(frame: CGRect(x: self.view.frame.maxX - (widther + 3), y: self.userChoiceImage.frame.minY, width: widther, height: widther))
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
                if !self.view.subviews.contains(self.ResultLabel) {
                    self.view.addSubview(self.ResultLabel)
                }
                self.ResultLabel.text = text
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.ResultLabel.frame = CGRect(x: 5, y: UIScreen.main.bounds.maxY - 150, width: UIScreen.main.bounds.width - 10, height: 80)
                    }, completion: nil)
        })
    }
    
}


extension Practice: RematchDelegate, SAConfettiViewDelegate, CountdownDelegate {
    
    func countdownFinished(_ view: CountdownView) {
        self.Rock.isEnabled = false
        self.Paper.isEnabled = false
        self.Scissors.isEnabled = false
        switch Int(arc4random_uniform(3)) {
        case 0: self.opponentChoice = .rock
        case 1: self.opponentChoice = .paper
        case 2: self.opponentChoice = .scissors
        default: break
        }
        self.checkWin({ (results) in
            switch results {
            case .win: self.userScoreInt += 1
            case .lose: self.opponentScoreInt += 1
            case .tie: self.showResultLabel("Tied!")
            }
        })
    }
    
    
    func disconnect() {
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
        sideMenuNavigationController!.popViewController(animated: true)
        self.rematchView.hide()
    }
    
    public func confettiViewTapped(_ view: SAConfettiView) {
        self.confetti.stopConfettiPractice(self)
    }
    
    public func RematchTapped(_ rematchview: RematchView, quit: Bool) {
        if quit == false {
            self.confetti.stopPractice(self)
            self.resetMatch()
        } else {
            self.disconnect()
        }
    }
    
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

