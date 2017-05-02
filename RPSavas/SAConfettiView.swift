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
    func confettiViewTapped(_ view: SAConfettiView)
}


open class SAConfettiView: UIView, AVAudioPlayerDelegate {
    
    var delegate: SAConfettiViewDelegate?
    
    public enum ConfettiType {
        case confetti
        case triangle
        case star
        case diamond
        case image(UIImage)
    }
    
    var emitter: CAEmitterLayer!
    open var colors: [UIColor]!
    open var intensity: Float!
    open var type: ConfettiType!
    fileprivate var active :Bool!
    
    lazy var Win: UILabel = {
        let view: UILabel = UILabel(frame: CGRect(x: 5, y: UIScreen.main.bounds.maxY + 90, width: UIScreen.main.bounds.width - 10, height: 80))
        view.textColor = UIColor.infoBlueColor()
        view.text = "You Win!"
        view.backgroundColor = UIColor.white
        view.layer.borderColor = UIColor.infoBlueColor().cgColor
        view.layer.borderWidth = 3.0
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        view.adjustsFontSizeToFitWidth = true
        view.isUserInteractionEnabled = true
        view.font = UIFont(name: "AmericanTypewriter-Bold", size: 50)
        view.textAlignment = NSTextAlignment.center
        return view
    }()
    
    
    
    var cheeringPlayer: AVAudioPlayer?
    
    open func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //cheeringPlayer?.play()
    }
    
    func tappedWin() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
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
        type = .confetti
        active = false
        let url = Bundle.main.url(forResource: "Cheering", withExtension: "wav")!
        do {
            cheeringPlayer = try AVAudioPlayer(contentsOf: url)
            cheeringPlayer?.delegate = self
            cheeringPlayer?.prepareToPlay()
            guard let player = cheeringPlayer else { return }
            player.volume = 1
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    open func startConfetti(_ view: GameView) {
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
        view.bringSubview(toFront: view.readyPlayButton)
        Win.frame = CGRect(x: 5, y: UIScreen.main.bounds.maxY + 90, width: UIScreen.main.bounds.width - 10, height: 80)
        self.addSubview(Win)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            view.Rock.frame = view.Rock.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions(), animations: {
            view.Paper.frame = view.Paper.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.4, options: UIViewAnimationOptions(), animations: {
            view.Scissors.frame = view.Scissors.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                self.cheeringPlayer?.play()
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.Win.frame = CGRect(x: 5, y: UIScreen.main.bounds.maxY - 150, width: UIScreen.main.bounds.width - 10, height: 80)
                    self.layer.addSublayer(self.emitter)
                    self.active = true
                    }, completion: {_ in
                        self.Win.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedWin)))
                })
        })
    }
    
    
    open func startConfettiPractice(_ practice: Practice) {
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
        practice.view.bringSubview(toFront: practice.readyPlayButton)
        Win.frame = CGRect(x: 5, y: UIScreen.main.bounds.maxY + 90, width: UIScreen.main.bounds.width - 10, height: 80)
        self.addSubview(Win)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            practice.Rock.frame = practice.Rock.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions(), animations: {
            practice.Paper.frame = practice.Paper.frame.offsetBy(dx: 0, dy: 300)
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.4, options: UIViewAnimationOptions(), animations: {
            practice.Scissors.frame = practice.Scissors.frame.offsetBy(dx: 0, dy: 300)
            }, completion: {_ in
                self.cheeringPlayer?.play()
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.Win.frame = CGRect(x: 5, y: UIScreen.main.bounds.maxY - 150, width: UIScreen.main.bounds.width - 10, height: 80)
                    self.layer.addSublayer(self.emitter)
                    self.active = true
                    }, completion: {_ in
                        self.Win.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedWin)))
                })
        })
    }

    
    
    open func startFinalConfettiPractice(_ practice: Practice) {
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
        practice.view.bringSubview(toFront: practice.readyPlayButton)
        self.layer.addSublayer(self.emitter)
        self.active = true
        practice.rematchView.showRematch()
    }
    
    open func startFinalConfetti(_ view: GameView) {
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
        view.bringSubview(toFront: view.readyPlayButton)
        self.layer.addSublayer(self.emitter)
        self.active = true
        view.rematchView.showRematch()
    }


    
    open func stopPractice(_ practice: Practice) {
        emitter?.birthRate = 0
        active = false
        cheeringPlayer?.stop()
        practice.view.bringSubview(toFront: practice.readyPlayButton)
    }
    
    open func stopConfettiPractice(_ practice: Practice) {
        emitter?.birthRate = 0
        active = false
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.Win.frame = self.Win.frame.offsetBy(dx: 0, dy: 270)
            practice.readyPlayButton.frame = CGRect(x: 5, y: UIScreen.main.bounds.maxY - 150, width: UIScreen.main.bounds.width - 10, height: 80)
            }, completion: {_ in
                self.Win.removeFromSuperview()
                self.cheeringPlayer?.stop()
                practice.readyPlayButton.isEnabled = true
        })
    }
    
    
    open func stop(_ view: GameView) {
        emitter?.birthRate = 0
        active = false
        cheeringPlayer?.stop()
        view.bringSubview(toFront: view.readyPlayButton)
    }
    
    open func stopConfetti(_ view: GameView) {
        emitter?.birthRate = 0
        active = false
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.Win.frame = self.Win.frame.offsetBy(dx: 0, dy: 270)
            view.readyPlayButton.frame = CGRect(x: 5, y: UIScreen.main.bounds.maxY - 150, width: UIScreen.main.bounds.width - 10, height: 80)
            }, completion: {_ in
                self.Win.removeFromSuperview()
                self.cheeringPlayer?.stop()
                view.readyPlayButton.isEnabled = true
        })
    }
    
    func imageForType(_ type: ConfettiType) -> UIImage? {
        var fileName: String!
        switch type {
        case .confetti:
            fileName = "confetti"
        case .triangle:
            fileName = "triangle"
        case .star:
            fileName = "star"
        case .diamond:
            fileName = "diamond"
        case let .image(customImage):
            return customImage
        }
        return UIImage(named: fileName)!
    }
    
    func confettiWithColor(_ color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        confetti.birthRate = 36.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.emissionRange = CGFloat(Double.pi/4)
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = imageForType(type)!.cgImage
        return confetti
    }
    
    open func isActive() -> Bool {
        return self.active
    }
}
