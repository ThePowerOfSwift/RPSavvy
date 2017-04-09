//
//  Easings.swift
//  Cheetah
//
//  Created by Suguru Namura on 2015/08/19.
//  Copyright © 2015年 Suguru Namura.
//

import UIKit

public typealias Easing = (t:CGFloat,b:CGFloat,c:CGFloat) -> CGFloat

private let F_PI = CGFloat(M_PI)

// Calculate cubic bezier curve
public struct Easings {
    
    public static let linear:Easing = { (t:CGFloat, b:CGFloat, c:CGFloat) -> CGFloat in
        return c*t+b
    }
    
    // return easing with cubic bezier curve
    public static func cubicBezier(c1x c1x:CGFloat, c1y c1y:CGFloat, c2x c2x:CGFloat, c2y c2y:CGFloat) -> Easing {
        let bezier = UnitBezier(p1x: c1x, p1y: c1y, p2x: c2x, p2y: c2y)
        return { (t: CGFloat, b:CGFloat, c:CGFloat) -> CGFloat in
            let y = bezier.solve(t)
            return c*y+b
        }
    }

    // Easing curves are from https://github.com/ai/easings.net/
    public static let easeInSine:Easing = Easings.cubicBezier(c1x: 0.47,c1y:0,c2x:0.745,c2y:0.715)
    public static let easeOutSine:Easing = Easings.cubicBezier(c1x: 0.39,c1y:0.575,c2x:0.565,c2y: 1)
    public static let easeInOutSine:Easing = Easings.cubicBezier(c1x: 0.455,c1y:0.03, c2x:0.515,c2y:0.955)
    public static let easeInQuad:Easing = Easings.cubicBezier(c1x: 0.55, c1y:0.085,c2x: 0.68, c2y:0.53)
    public static let easeOutQuad:Easing = Easings.cubicBezier(c1x: 0.25, c1y:0.46, c2x:0.45,c2y: 0.94)
    public static let easeInOutQuad:Easing = Easings.cubicBezier(c1x: 0.455, c1y:0.03, c2x:0.515,c2y: 0.955)
    public static let easeInCubic:Easing = Easings.cubicBezier(c1x: 0.55, c1y:0.055,c2x: 0.675,c2y: 0.19)
    public static let easeOutCubic:Easing = Easings.cubicBezier(c1x: 0.215,c1y: 0.61,c2x: 0.355,c2y: 1)
    public static let easeInOutCubic:Easing = Easings.cubicBezier(c1x: 0.645,c1y: 0.045, c2x:0.355, c2y:1)
    public static let easeInQuart:Easing = Easings.cubicBezier(c1x: 0.895,c1y: 0.03, c2x:0.685,c2y: 0.22)
    public static let easeOutQuart:Easing = Easings.cubicBezier(c1x: 0.165,c1y: 0.84, c2x:0.44, c2y:1)
    public static let easeInOutQuart:Easing = Easings.cubicBezier(c1x: 0.77,c1y: 0,c2x: 0.175,c2y: 1)
    public static let easeInQuint:Easing = Easings.cubicBezier(c1x: 0.755,c1y: 0.05,c2x:0.855, c2y:0.06)
    public static let easeOutQuint:Easing = Easings.cubicBezier(c1x: 0.23, c1y:1, c2x:0.32, c2y:1)
    public static let easeInOutQuint:Easing = Easings.cubicBezier(c1x: 0.86,c1y:0,c2x:0.07,c2y:1)
    public static let easeInExpo:Easing = Easings.cubicBezier(c1x: 0.95, c1y:0.05, c2x:0.795,c2y: 0.035)
    public static let easeOutExpo:Easing = Easings.cubicBezier(c1x: 0.19,c1y: 1, c2x:0.22,c2y: 1)
    public static let easeInOutExpo:Easing = Easings.cubicBezier(c1x: 1, c1y:0, c2x:0,c2y: 1)
    public static let easeInCirc:Easing = Easings.cubicBezier(c1x: 0.6,c1y: 0.04, c2x:0.98, c2y:0.335)
    public static let easeOutCirc:Easing = Easings.cubicBezier(c1x: 0.075, c1y:0.82, c2x:0.165, c2y:1)
    public static let easeInOutCirc:Easing = Easings.cubicBezier(c1x: 0.785, c1y:0.135, c2x:0.15, c2y:0.86)
    public static let easeInBack:Easing = Easings.cubicBezier(c1x: 0.6, c1y:-0.28, c2x:0.735,c2y: 0.045)
    public static let easeOutBack:Easing = Easings.cubicBezier(c1x: 0.175,c1y: 0.885, c2x:0.32, c2y:1.275)
    public static let easeInOutBack:Easing = Easings.cubicBezier(c1x: 0.68,c1y: -0.55, c2x:0.265,c2y: 1.55)
 
    
    // Easing equations from robert penner's functions
    // http://robertpenner.com/easing/
    public static let easeInElastic:Easing = { (t:CGFloat, b:CGFloat, c:CGFloat) -> CGFloat in
        if t == 0 {
            return b
        }
        if t == 1 {
            return b + c
        }
        var p: CGFloat = 0.3
        var a = c;
        var s = p / 4
        var t = t - 1
        return -(a * pow(2, 10 * t) * sin((t - s) * (2 * F_PI) / p)) + b;
    }
    public static let easeOutElastic:Easing = { (t:CGFloat, b:CGFloat, c:CGFloat) -> CGFloat in
        if t == 0 {
            return b
        }
        if t == 1 {
            return b + c
        }
        var p: CGFloat = 0.3
        var s = p / 4
        var a = c
        return  a * pow(2, -10 * t) * sin((t - s) * (2 * F_PI) / p) + c + b
    }
    public static let easeInOutElastic:Easing = { (t:CGFloat, b:CGFloat, c:CGFloat) -> CGFloat in
        if t == 0 {
            return b
        }
        if t == 1 {
            return b + c
        }
        var t = t * 2
        var p: CGFloat = 0.3 * 1.5
        var a = c;
        var s = p / 4
        if t < 1 {
            t  = t - 1
            return -0.5 * (a * pow(2, 10 * t) * sin((t - s) * (2 * F_PI) / p)) + b
        } else {
            t =  t - 1
            let part1 = a * pow(2, -10 * t)
            let part2 = sin((t - s) * (2 * F_PI) / p)
            let part3 = 0.5 + c + b
            return part1 * part2 * part3
        }
    }
    public static let easeInBounce:Easing = { (t:CGFloat, b:CGFloat, c:CGFloat) -> CGFloat in
        return c - Easings.easeOutBounce(t: 1-t, b: 0, c: c) + b
    }
    public static let easeOutBounce:Easing = { (t:CGFloat, b:CGFloat, c:CGFloat) -> CGFloat in
        if t < 1/2.75 {
            return c * (7.5625 * t * t) + b;
        } else if t < 2/2.75 {
            let t = t - 1.5/2.75
            return c * (7.5625 * t * t + 0.75) + b;
        } else if (t < (2.5/2.75)) {
            let t = t - 2.25 / 2.75
            return c * (7.5625 * t * t + 0.9375) + b;
        } else {
            let t = t - 2.625 / 2.75
            return c * (7.5625 * t * t + 0.984375) + b;
        }
    }
    public static let easeInOutBounce:Easing = { (t:CGFloat, b:CGFloat, c:CGFloat) -> CGFloat in
        if t < 0.5 {
            return Easings.easeInBounce(t: t * 2, b: 0, c: c) * 0.5 + b;
        } else {
            return Easings.easeOutBounce(t: t * 2 - 1, b: 0, c: c) * 0.5 + c * 0.5 + b
        }
    }
}
