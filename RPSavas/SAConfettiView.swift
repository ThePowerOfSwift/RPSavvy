//
//  SAConfettiView.swift
//  Pods
//
//  Created by Sudeep Agarwal on 12/14/15.
//
//

import UIKit
import QuartzCore

public protocol SAConfettiViewDelegate: class {
    func confettiViewTapped(view: SAConfettiView)
}


public class SAConfettiView: UIView, AVAudioPlayerDelegate {
    
    var delegate: SAConfettiViewDelegate?
    
    public enum ConfettiType {
        case Confetti
        case Triangle
        case Star
        case Diamond
        case Image(UIImage)
    }
    
    var emitter: CAEmitterLayer!
    public var colors: [UIColor]!
    public var intensity: Float!
    public var type: ConfettiType!
    private var active :Bool!
    
    lazy var Win: UILabel = {
        let view: UILabel = UILabel(frame: CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY + 90, width: UIScreen.mainScreen().bounds.width - 10, height: 80))
        view.textColor = UIColor.infoBlueColor()
        view.text = "You Win!"
        view.backgroundColor = UIColor.whiteColor()
        view.layer.borderColor = UIColor.infoBlueColor().CGColor
        view.layer.borderWidth = 3.0
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        view.adjustsFontSizeToFitWidth = true
        view.userInteractionEnabled = true
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 50)
        view.textAlignment = NSTextAlignment.Center
        return view
    }()
    
    
    
    var cheeringPlayer: AVAudioPlayer?
    
    public func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        //cheeringPlayer?.play()
    }
    
    func tappedWin() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Win.frame = self.Win.frame.offsetBy(dx: 0, dy: 270)//self.bounds.height)
            }, completion: {_ in
                if self.delegate != nil {
                    self.delegate!.confettiViewTapped(self)
                }
        })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
                  UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
                  UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
                  UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
                  UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        intensity = 1.0
        type = .Confetti
        active = false
        let url = NSBundle.mainBundle().URLForResource("Cheering", withExtension: "wav")!
        do {
            cheeringPlayer = try AVAudioPlayer(contentsOfURL: url)
            cheeringPlayer?.delegate = self
            cheeringPlayer?.prepareToPlay()
            guard let player = cheeringPlayer else { return }
            player.volume = 1
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    public func startConfetti(view: GameView) {
        emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)
        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color))
        }
        emitter.emitterCells = cells
        view.addSubview(self)
        view.bringSubviewToFront(view.readyPlayButton)
        Win.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY + 90, width: UIScreen.mainScreen().bounds.width - 10, height: 80)
        self.addSubview(Win)
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            view.Rock.frame = view.Rock.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            view.Paper.frame = view.Paper.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            view.Scissors.frame = view.Scissors.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                self.cheeringPlayer?.play()
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.Win.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY - 150, width: UIScreen.mainScreen().bounds.width - 10, height: 80)
                    self.layer.addSublayer(self.emitter)
                    self.active = true
                    }, completion: {_ in
                        self.Win.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedWin)))
                })
        })
    }
    
    
    public func startConfettiPractice(practice: Practice) {
        emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)
        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color))
        }
        emitter.emitterCells = cells
        practice.view.addSubview(self)
        practice.view.bringSubviewToFront(practice.readyPlayButton)
        Win.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY + 90, width: UIScreen.mainScreen().bounds.width - 10, height: 80)
        self.addSubview(Win)
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            practice.Rock.frame = practice.Rock.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            practice.Paper.frame = practice.Paper.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            practice.Scissors.frame = practice.Scissors.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                self.cheeringPlayer?.play()
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.Win.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY - 150, width: UIScreen.mainScreen().bounds.width - 10, height: 80)
                    self.layer.addSublayer(self.emitter)
                    self.active = true
                    }, completion: {_ in
                        self.Win.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedWin)))
                })
        })
    }

    
    
    public func startFinalConfettiPractice(practice: Practice) {
        cheeringPlayer?.play()
        emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)
        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color))
        }
        emitter.emitterCells = cells
        practice.view.addSubview(self)
        practice.view.bringSubviewToFront(practice.readyPlayButton)
        self.layer.addSublayer(self.emitter)
        self.active = true
        practice.rematchView.showRematch()
    }
    
    public func startFinalConfetti(view: GameView) {
        cheeringPlayer?.play()
        emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)
        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color))
        }
        emitter.emitterCells = cells
        view.addSubview(self)
        view.bringSubviewToFront(view.readyPlayButton)
        self.layer.addSublayer(self.emitter)
        self.active = true
        view.rematchView.showRematch()
    }


    
    public func stopPractice(practice: Practice) {
        emitter?.birthRate = 0
        active = false
        cheeringPlayer?.stop()
        practice.view.bringSubviewToFront(practice.readyPlayButton)
    }
    
    public func stopConfettiPractice(practice: Practice) {
        emitter?.birthRate = 0
        active = false
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Win.frame = self.Win.frame.offsetBy(dx: 0, dy: 270)
            practice.readyPlayButton.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY - 150, width: UIScreen.mainScreen().bounds.width - 10, height: 80)
            }, completion: {_ in
                self.Win.removeFromSuperview()
                self.cheeringPlayer?.stop()
                practice.readyPlayButton.enabled = true
        })
    }
    
    
    public func stop(view: GameView) {
        emitter?.birthRate = 0
        active = false
        cheeringPlayer?.stop()
        view.bringSubviewToFront(view.readyPlayButton)
    }
    
    public func stopConfetti(view: GameView) {
        emitter?.birthRate = 0
        active = false
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.Win.frame = self.Win.frame.offsetBy(dx: 0, dy: 270)
            view.readyPlayButton.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.maxY - 150, width: UIScreen.mainScreen().bounds.width - 10, height: 80)
            }, completion: {_ in
                self.Win.removeFromSuperview()
                self.cheeringPlayer?.stop()
                view.readyPlayButton.enabled = true
        })
    }
    
    func imageForType(type: ConfettiType) -> UIImage? {
        var fileName: String!
        switch type {
        case .Confetti:
            fileName = "confetti"
        case .Triangle:
            fileName = "triangle"
        case .Star:
            fileName = "star"
        case .Diamond:
            fileName = "diamond"
        case let .Image(customImage):
            return customImage
        }
        return UIImage(named: fileName)!
    }
    
    func confettiWithColor(color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        confetti.birthRate = 36.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.CGColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat(M_PI)
        confetti.emissionRange = CGFloat(M_PI_4)
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = imageForType(type)!.CGImage
        return confetti
    }
    
    public func isActive() -> Bool {
        return self.active
    }
}
