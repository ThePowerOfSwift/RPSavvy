//
//  ActivityIndicatorAnimationImagesTrianglePath.swift
//  ActivityIndicatorAnimationImagesTrianglePath
//
//  Created by Dillon Murphy on 10/03/16.
//  Copyright © 2015 StrategynMobilePros. All rights reserved.
//

import UIKit

public class ActivityIndicatorAnimationImagesTrianglePath: UIView {
    
    public var images: [UIImage] = [UIImage(named: "rock")!,UIImage(named: "paper")!,UIImage(named: "scissors")!]
    
    //public var color: UIColor = UIColor.whiteColor()
    
    public var size: CGSize = CGSize(width: 100, height: 100)
    
    public var animating: Bool = false
    
    public var moving: Bool = false
    
    class var sharedInstance: ActivityIndicatorAnimationImagesTrianglePath {
        struct Singleton {
            static let instance = ActivityIndicatorAnimationImagesTrianglePath(frame: CGRect(origin: CGPoint(x: UIScreen.mainScreen().bounds.midX - 50, y: UIScreen.mainScreen().bounds.maxY), size: CGSize(width: 100, height: 100)))
        }
        return Singleton.instance
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        (UIApplication.sharedApplication().delegate as! AppDelegate).window!.addSubview(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        super.backgroundColor = UIColor.clearColor()
    }
    
    public func startAnimation() {
        if (self.layer.sublayers == nil) {
            setUpAnimation()
        }
        self.layer.speed = 1
        self.animating = true
        if self.moving != true {
            self.moving = true
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.frame = CGRect(origin: CGPoint(x: UIScreen.mainScreen().bounds.midX - 50, y: UIScreen.mainScreen().bounds.midY), size: CGSize(width: 100.0, height: 100.0))
                self.alpha = 1.0
                }, completion: {_ in
                self.moving = false
        })
        } else {
            self.waitforMoving()
        }
    }
    
    public func stopAnimation() {
        self.animating = false
        if self.moving != true {
            self.moving = true
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.frame = CGRect(origin: CGPoint(x: UIScreen.mainScreen().bounds.midX - 50, y: UIScreen.mainScreen().bounds.maxY), size: CGSize(width: 100.0, height: 100.0))
                self.alpha = 0.0
                }, completion: {_ in
                    self.moving = false
                    //self.layer.sublayers = nil
            })
        } else {
            self.waitforMoving()
        }
    }
    
    func waitforMoving() {
        if self.moving == true {
            _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.waitforMoving), userInfo: nil, repeats: false)
        } else {
            //self.moving = true
            if (self.animating) {
                UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.frame = CGRect(origin: CGPoint(x: UIScreen.mainScreen().bounds.midX, y: UIScreen.mainScreen().bounds.midY), size: CGSize(width: 100.0, height: 100.0))
                    self.alpha = 1.0
                    }, completion: {_ in
                        self.moving = false
                })
            } else {
                UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.frame = CGRect(origin: CGPoint(x: UIScreen.mainScreen().bounds.midX - 50, y: UIScreen.mainScreen().bounds.maxY), size: CGSize(width: 100.0, height: 100.0))
                    self.alpha = 0.0
                    }, completion: {_ in
                        //self.layer.sublayers = nil
                        self.moving = false
                })
            }
        }
    }
    
    // MARK: Privates
    
    private func setUpAnimation() {
        self.layer.sublayers = nil
        let circleSize = size.width / 3
        let deltaX = size.width / 2 - circleSize / 1.75
        let deltaY = size.height / 2 - circleSize / 1.75
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: CFTimeInterval = 2
        let timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        let animation = CAKeyframeAnimation(keyPath:"transform")
        animation.keyTimes = [0, 0.33, 0.66, 1]
        animation.timingFunctions = [timingFunction, timingFunction, timingFunction]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.removedOnCompletion = false
        layer.backgroundColor = UIColor(white: 0.9, alpha: 0.4).CGColor
        layer.cornerRadius = 10.0
        layer.borderColor = UIColor(colorLiteralRed: 184, green: 102, blue: 37, alpha: 1.0).CGColor
        layer.borderWidth = 1.0
        let topCenterCircle: UIImageView = UIImageView(image: images[0])
        changeAnimation(animation, values:["{0,0}", "{hx,fy}", "{-hx,fy}", "{0,0}"], deltaX: deltaX, deltaY: deltaY)
        topCenterCircle.frame = CGRectMake(x + size.width / 2 - circleSize / 2, y, circleSize, circleSize)
        topCenterCircle.layer.addAnimation(animation, forKey: "animation")
        layer.addSublayer(topCenterCircle.layer)
        let bottomLeftCircle: UIImageView = UIImageView(image: images[1])
        changeAnimation(animation, values: ["{0,0}", "{hx,-fy}", "{fx,0}", "{0,0}"], deltaX: deltaX, deltaY: deltaY)
        bottomLeftCircle.frame = CGRectMake(x, y + size.height - circleSize, circleSize, circleSize)
        bottomLeftCircle.layer.addAnimation(animation, forKey: "animation")
        layer.addSublayer(bottomLeftCircle.layer)
        let bottomRightCircle: UIImageView = UIImageView(image: images[2])
        changeAnimation(animation, values: ["{0,0}", "{-fx,0}", "{-hx,-fy}", "{0,0}"], deltaX: deltaX, deltaY:deltaY)
        bottomRightCircle.frame = CGRectMake(x + size.width - circleSize, y + size.height - circleSize, circleSize, circleSize)
        bottomRightCircle.layer.addAnimation(animation, forKey: "animation")
        layer.addSublayer(bottomRightCircle.layer)
        self.alpha = 0.0
    }
    
    func changeAnimation(animation: CAKeyframeAnimation, values rawValues: [String], deltaX: CGFloat, deltaY: CGFloat) -> CAAnimation {
        let values = NSMutableArray(capacity: 5)
        for rawValue in rawValues {
            let point = CGPointFromString(translateString(rawValue, deltaX: deltaX, deltaY: deltaY))
            values.addObject(NSValue(CATransform3D: CATransform3DMakeTranslation(point.x, point.y, 0)))
        }
        animation.values = values as [AnyObject]
        return animation
    }
    
    func translateString(valueString: String, deltaX: CGFloat, deltaY: CGFloat) -> String {
        let valueMutableString = NSMutableString(string: valueString)
        let fullDeltaX = 2 * deltaX
        let fullDeltaY = 2 * deltaY
        var range = NSMakeRange(0, valueMutableString.length)
        valueMutableString.replaceOccurrencesOfString("hx", withString: "\(deltaX)", options: NSStringCompareOptions.CaseInsensitiveSearch, range: range)
        range.length = valueMutableString.length
        valueMutableString.replaceOccurrencesOfString("fx", withString: "\(fullDeltaX)", options: NSStringCompareOptions.CaseInsensitiveSearch, range: range)
        range.length = valueMutableString.length
        valueMutableString.replaceOccurrencesOfString("hy", withString: "\(deltaY)", options: NSStringCompareOptions.CaseInsensitiveSearch, range: range)
        range.length = valueMutableString.length
        valueMutableString.replaceOccurrencesOfString("fy", withString: "\(fullDeltaY)", options: NSStringCompareOptions.CaseInsensitiveSearch, range: range)
        return valueMutableString as String
    }
    
}
