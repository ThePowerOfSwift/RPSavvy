//
//  PulsingLayer.swift
//  RPSavas
//
//  Created by Dillon Murphy on 2/12/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//


import UIKit
import QuartzCore


class PulsingLayer: CALayer {
    
    var radius: CGFloat {
        set(r) {
            self.setupRadius(r)
        }
        get {
            return self.cornerRadius
        }
    }
    
    var animationDuration: TimeInterval = 1.0
    var pulseInterval: TimeInterval = 0
    var pulseColor: UIColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
    
    fileprivate var animationGroup: CAAnimationGroup!
    
    override init() {
        super.init()
        
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0
        
        self.radius = 60.0
        self.backgroundColor = pulseColor.cgColor
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
            self.setupAnimationGroup()
            if self.pulseInterval != Double.infinity {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.add(self.animationGroup, forKey: "pulse")
                })
            }
        })
    }
    
    convenience init(pulseColor: UIColor) {
        self.init()
        self.pulseColor = pulseColor
        self.backgroundColor = self.pulseColor.cgColor
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupRadius(_ radius: CGFloat) {
        
        let tempPos = self.position
        let diameter = radius * 2
        
        self.bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        self.cornerRadius = radius
        self.position = tempPos
    }
    
    
    fileprivate func setupAnimationGroup() {
        let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        self.animationGroup = CAAnimationGroup() as CAAnimationGroup
        self.animationGroup.duration = self.animationDuration + self.pulseInterval
        self.animationGroup.repeatCount = Float.infinity
        self.animationGroup.isRemovedOnCompletion = false
        self.animationGroup.timingFunction = defaultCurve
        self.animationGroup.animations = [scaleAnimation(), opacityAnimation()]
    }
    
    fileprivate func scaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = self.animationDuration
        return scaleAnimation
    }
    
    fileprivate func opacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = self.animationDuration
        opacityAnimation.values = [0.45, 0.45, 0]
        opacityAnimation.keyTimes = [0, 0.2, 1]
        opacityAnimation.isRemovedOnCompletion = false
        return opacityAnimation;
    }
    
}
