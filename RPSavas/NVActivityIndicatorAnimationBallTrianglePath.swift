//
//  ActivityIndicatorAnimationImagesTrianglePath.swift
//  ActivityIndicatorAnimationImagesTrianglePath
//
//  Created by Dillon Murphy on 10/03/16.
//  Copyright © 2015 StrategynMobilePros. All rights reserved.
//

import UIKit

open class ActivityIndicatorAnimationImagesTrianglePath: UIView {
    
    open var images: [UIImage] = [UIImage(named: "rock")!,UIImage(named: "paper")!,UIImage(named: "scissors")!]
    
    //public var color: UIColor = UIColor.whiteColor()
    
    open var size: CGSize = CGSize(width: 100, height: 100)
    
    open var animating: Bool = false
    
    open var moving: Bool = false
    
    class var sharedInstance: ActivityIndicatorAnimationImagesTrianglePath {
        struct Singleton {
            static let instance = ActivityIndicatorAnimationImagesTrianglePath(frame: CGRect(origin: CGPoint(x: UIScreen.main.bounds.midX - 50, y: UIScreen.main.bounds.maxY), size: CGSize(width: 100, height: 100)))
        }
        return Singleton.instance
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        (UIApplication.shared.delegate as! AppDelegate).window!.addSubview(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        super.backgroundColor = UIColor.clear
    }
    
    open func startAnimation() {
        if (self.layer.sublayers == nil) {
            setUpAnimation()
        }
        self.layer.speed = 1
        self.animating = true
        if self.moving != true {
            self.moving = true
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.midX - 50, y: UIScreen.main.bounds.midY), size: CGSize(width: 100.0, height: 100.0))
                self.alpha = 1.0
                }, completion: {_ in
                self.moving = false
        })
        } else {
            self.waitforMoving()
        }
    }
    
    open func stopAnimation() {
        self.animating = false
        if self.moving != true {
            self.moving = true
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.midX - 50, y: UIScreen.main.bounds.maxY), size: CGSize(width: 100.0, height: 100.0))
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
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.waitforMoving), userInfo: nil, repeats: false)
        } else {
            //self.moving = true
            if (self.animating) {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY), size: CGSize(width: 100.0, height: 100.0))
                    self.alpha = 1.0
                    }, completion: {_ in
                        self.moving = false
                })
            } else {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.midX - 50, y: UIScreen.main.bounds.maxY), size: CGSize(width: 100.0, height: 100.0))
                    self.alpha = 0.0
                    }, completion: {_ in
                        //self.layer.sublayers = nil
                        self.moving = false
                })
            }
        }
    }
    
    // MARK: Privates
    
    fileprivate func setUpAnimation() {
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
        animation.isRemovedOnCompletion = false
        layer.backgroundColor = UIColor(white: 0.9, alpha: 0.4).cgColor
        layer.cornerRadius = 10.0
        layer.borderColor = UIColor(colorLiteralRed: 184, green: 102, blue: 37, alpha: 1.0).cgColor
        layer.borderWidth = 1.0
        let topCenterCircle: UIImageView = UIImageView(image: images[0])
        changeAnimation(animation, values:["{0,0}", "{hx,fy}", "{-hx,fy}", "{0,0}"], deltaX: deltaX, deltaY: deltaY)
        topCenterCircle.frame = CGRect(x: x + size.width / 2 - circleSize / 2, y: y, width: circleSize, height: circleSize)
        topCenterCircle.layer.add(animation, forKey: "animation")
        layer.addSublayer(topCenterCircle.layer)
        let bottomLeftCircle: UIImageView = UIImageView(image: images[1])
        changeAnimation(animation, values: ["{0,0}", "{hx,-fy}", "{fx,0}", "{0,0}"], deltaX: deltaX, deltaY: deltaY)
        bottomLeftCircle.frame = CGRect(x: x, y: y + size.height - circleSize, width: circleSize, height: circleSize)
        bottomLeftCircle.layer.add(animation, forKey: "animation")
        layer.addSublayer(bottomLeftCircle.layer)
        let bottomRightCircle: UIImageView = UIImageView(image: images[2])
        changeAnimation(animation, values: ["{0,0}", "{-fx,0}", "{-hx,-fy}", "{0,0}"], deltaX: deltaX, deltaY:deltaY)
        bottomRightCircle.frame = CGRect(x: x + size.width - circleSize, y: y + size.height - circleSize, width: circleSize, height: circleSize)
        bottomRightCircle.layer.add(animation, forKey: "animation")
        layer.addSublayer(bottomRightCircle.layer)
        self.alpha = 0.0
    }
    
    func changeAnimation(_ animation: CAKeyframeAnimation, values rawValues: [String], deltaX: CGFloat, deltaY: CGFloat) -> CAAnimation {
        let values = NSMutableArray(capacity: 5)
        for rawValue in rawValues {
            let point = CGPointFromString(translateString(rawValue, deltaX: deltaX, deltaY: deltaY))
            values.add(NSValue(caTransform3D: CATransform3DMakeTranslation(point.x, point.y, 0)))
        }
        animation.values = values as [AnyObject]
        return animation
    }
    
    func translateString(_ valueString: String, deltaX: CGFloat, deltaY: CGFloat) -> String {
        let valueMutableString = NSMutableString(string: valueString)
        let fullDeltaX = 2 * deltaX
        let fullDeltaY = 2 * deltaY
        var range = NSMakeRange(0, valueMutableString.length)
        valueMutableString.replaceOccurrences(of: "hx", with: "\(deltaX)", options: NSString.CompareOptions.caseInsensitive, range: range)
        range.length = valueMutableString.length
        valueMutableString.replaceOccurrences(of: "fx", with: "\(fullDeltaX)", options: NSString.CompareOptions.caseInsensitive, range: range)
        range.length = valueMutableString.length
        valueMutableString.replaceOccurrences(of: "hy", with: "\(deltaY)", options: NSString.CompareOptions.caseInsensitive, range: range)
        range.length = valueMutableString.length
        valueMutableString.replaceOccurrences(of: "fy", with: "\(fullDeltaY)", options: NSString.CompareOptions.caseInsensitive, range: range)
        return valueMutableString as String
    }
    
}
