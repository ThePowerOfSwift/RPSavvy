//
//  CountdownView.swift
//  RPSavvy
//
//  Created by Dillon Murphy on 7/29/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation

protocol CountdownDelegate: class {
    func countdownFinished(view: CountdownView)
}

class CountdownView: UIView {
    
    let countdownFrom: Int = 3
    var finishText: String = "Shoot!"
    var countdownColor: UIColor = UIColor.whiteColor()
    var fontName: String = "AmericanTypewriter-Bold"
    var backgroundAlpha: CGFloat = 0.3
    var backColor: UIColor = UIColor.whiteColor()
    var animateDuration: Double = 0.9
    var counting: Bool = false
    
    var timer: NSTimer!
    
    var timer2: NSTimer!
    var currentCountdownValue: Int  = 3
    var scaleFactor: CGFloat = 0.3
    
    var Muted = false
    
    var delegate: CountdownDelegate?    
    
    private var animationGroup: CAAnimationGroup!
    lazy var haloLayer: CALayer = {
        var halo = CALayer()
        halo.contentsScale = UIScreen.mainScreen().scale
        halo.opacity = 0
        halo.bounds = CGRect(x:0, y:0, width:self.countdownLabel.frame.width * 2, height:self.countdownLabel.frame.width * 2)
        halo.cornerRadius = halo.bounds.width/2
        halo.backgroundColor = self.countdownColor.CGColor
        halo.position = self.center
        halo.zPosition = CGFloat(MAXFLOAT)
        return halo
    }()
    
    lazy var countdownLabel: UILabel = {
        let fontSize = self.bounds.size.width * self.scaleFactor
        let view: UILabel = UILabel(frame: CGRect(x:self.frame.size.width/4, y:self.frame.size.height/4, width:self.frame.size.width/2, height:self.frame.size.height/2))
        view.textColor = self.countdownColor
        view.font = UIFont(name: self.fontName, size: fontSize)
        view.text = "\(self.countdownFrom)"
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = NSTextAlignment.Center
        view.opaque = true
        view.alpha = 1.0
        return view
    }()
    
    lazy var visualEffectView:VisualEffectView = {
        let visualEffectView:VisualEffectView = VisualEffectView(frame: self.frame)
        visualEffectView.colorTint = self.backColor
        visualEffectView.colorTintAlpha = self.backgroundAlpha
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        return visualEffectView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.updateAppearance()
    }
    
    func countdownFinished(view: CountdownView) {
        view.removeFromSuperview()
    }
    
    func updateAppearance() {
        self.subviews.forEach { (sub) in
            sub.removeFromSuperview()
        }
        self.opaque = false
        self.addSubview(self.countdownLabel)
    }
    
    func updatePracticeAppearance() {
        self.subviews.forEach { (sub) in
            sub.removeFromSuperview()
        }
        self.opaque = false
        self.addSubview(self.countdownLabel)
    }

    func start(view: GameView) {
        if !self.counting {
            view.addSubview(self)
            [view.Rock,view.Paper,view.Scissors].forEach { (viewer) in
                view.bringSubviewToFront(viewer)
            }
            self.stop()
            self.currentCountdownValue = self.countdownFrom
            self.layer.addSublayer(haloLayer)
            self.countdownLabel.text = "\(self.countdownFrom)"
            self.counting = true
            self.setupAnimationGroup()
            self.vibrate()
            //self.beepPlayer?.prepareToPlay()
            self.haloLayer.addAnimation(self.animationGroup, forKey: "pulse")
            self.animate()
            //let url = NSBundle.mainBundle().URLForResource("Beep", withExtension: "m4a")!//URLForResource("Swoosh", withExtension: "wav")!//
            //view.myAudioDevice.playRingtone(from: url, count: 3)
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:#selector(self.animate), userInfo:nil, repeats:true)
        }
    }
    
    var practice: Bool = false
    
    func startPractice(practice: Practice) {
        if !self.counting {
            practice.view.addSubview(self)
            [practice.Rock,practice.Paper,practice.Scissors].forEach { (viewer) in
                practice.view.bringSubviewToFront(viewer)
            }
            self.stop()
            self.currentCountdownValue = self.countdownFrom
            self.layer.addSublayer(haloLayer)
            self.countdownLabel.text = "\(self.countdownFrom)"
            self.counting = true
            self.setupAnimationGroup()
            self.vibrate()
            
            
            let url = NSBundle.mainBundle().URLForResource("Swoosh", withExtension: "wav")!
            do {
                beepPlayer = try AVAudioPlayer(contentsOfURL: url)
                guard let player = beepPlayer else { return}
                player.prepareToPlay()
                player.volume = 0.7
            } catch let error as NSError {
                print(error.description)
            }
            self.haloLayer.addAnimation(self.animationGroup, forKey: "pulse")
            self.practice = true
            self.playSound()
            self.animate()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:#selector(self.animate), userInfo:nil, repeats:true)
            self.timer2 = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:#selector(self.playSound), userInfo:nil, repeats:true)
        }
    }

    func stop() {
        if (self.timer != nil && self.timer.valid == true) {
            self.timer.invalidate()
        }
        if (self.timer2 != nil && self.timer2.valid == true) {
            self.timer2.invalidate()
        }
    }
    
    
    var beepPlayer: AVAudioPlayer?
    
    func vibrate() {
        let systemSoundID: SystemSoundID = 4095
        AudioServicesPlaySystemSound (systemSoundID)
    }
    
    func playSound() {
        if !Muted || practice == true {
            beepPlayer?.play()
        }
    }

    
    private func setupAnimationGroup() {
        let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        self.animationGroup = CAAnimationGroup() as CAAnimationGroup
        self.animationGroup.duration = self.animateDuration
        self.animationGroup.repeatCount = 3
        self.animationGroup.removedOnCompletion = false
        self.animationGroup.timingFunction = defaultCurve
        self.animationGroup.animations = [scaleAnimation(), opacityAnimation()]
    }
    
    private func scaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = self.animateDuration
        return scaleAnimation
    }
    
    private func opacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = self.animateDuration
        opacityAnimation.values = [0.45, 0.45, 0]
        opacityAnimation.keyTimes = [0, 0.2, 1]
        opacityAnimation.removedOnCompletion = false
        return opacityAnimation;
    }
    
    func animate() {
        UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.countdownLabel.transform = CGAffineTransformMakeScale(2.5, 2.5)
            self.countdownLabel.alpha = 0
        }) { (finished) in
            if (finished) {
                if (self.currentCountdownValue == 0) {
                    self.stop()
                    if ((self.delegate) != nil) {
                        self.delegate!.countdownFinished(self)
                        self.removeFromSuperview()
                    }
                    /*do {
                        try AVAudioSession.sharedInstance().setActive(false)
                    } catch let error as NSError {
                        print(error.description)
                    }*/
                    self.countdownLabel.transform = CGAffineTransformIdentity
                    self.countdownLabel.alpha = 1.0
                    self.counting = false
                } else {
                    self.countdownLabel.transform = CGAffineTransformIdentity
                    self.countdownLabel.alpha = 1.0
                    self.currentCountdownValue -= 1
                    if (self.currentCountdownValue == 0) {
                        self.countdownLabel.text = self.finishText
                    } else {
                        self.countdownLabel.text = "\(self.currentCountdownValue)"
                    }
                }
            }
        }
    }
    
}
