
//
//  ScrollPager.swift
//  ScrollPager
//
//  Created by Aryan Ghassemi on 2/22/15.
//  Copyright (c) 2015 Aryan Ghassemi. All rights reserved.
//
//
//	https://github.com/aryaxt/ScrollPager
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

import UIKit
import Foundation
import ObjectiveC

@objc public protocol ScrollPagerDelegate: NSObjectProtocol {
    @objc optional func scrollPager(scrollPager: ScrollPager, changedIndex: Int)
}

@IBDesignable public class ScrollPager: UIView, UIScrollViewDelegate{
    
    private var selectedIndex = 0
    private let indicatorView = UIView()
    private var buttons = [UIButton]()
    private var views = [UIView]()
    private var animationInProgress = false
    @IBOutlet public weak var delegate: ScrollPagerDelegate!
    
    @IBOutlet public var scrollView: UIScrollView? {
        didSet {
            scrollView?.delegate = self
            scrollView?.pagingEnabled = true
            scrollView?.showsHorizontalScrollIndicator = false
        }
    }
    
    @IBInspectable public var textColor: UIColor = UIColor.wheatColor() {
        didSet { redrawComponents() }
    }
    
    @IBInspectable public var selectedTextColor: UIColor = UIColor.wheatColor().darkenedColor(0.1) {
        didSet { redrawComponents() }
    }
    
    @IBInspectable public var font: UIFont = UIFont(name: "AmericanTypewriter", size: 24)! {
        didSet { redrawComponents() }
    }
    
    @IBInspectable public var selectedFont: UIFont = UIFont(name: "AmericanTypewriter-Bold", size: 25)! {
        didSet { redrawComponents() }
    }
    
    @IBInspectable public var indicatorColor: UIColor = UIColor.wheatColor().darkenedColor(0.1) {
        didSet { indicatorView.backgroundColor = indicatorColor }
    }
    
    @IBInspectable public var indicatorSizeMatchesTitle: Bool = false {
        didSet { redrawComponents() }
    }
    
    @IBInspectable public var indicatorHeight: CGFloat = 3.5 {
        didSet { redrawComponents() }
    }
    
    /*@IBInspectable public var borderColor: UIColor? {
        didSet { self.layer.borderColor = borderColor?.CGColor }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }*/
    
    @IBInspectable public var animationDuration: CGFloat = 0.2
    
    // MARK: - Initializarion -
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    private func initialize() {
        addSegmentsWithTitles(["Following","Followers"])
    }
    
    // MARK: - UIView Methods -
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        redrawComponents()
        //moveToIndex(selectedIndex, animated: false, moveScrollView: true)
    }
    
    // MARK: - Public Methods -
    
    public func addSegmentsWithTitlesAndViews(segments: [(title: String, view: UIView)]) {
        
        addButtons(segments.map { $0.title as AnyObject })
        addViews(segments.map { $0.view })
        
        redrawComponents()
    }
    
    public func addSegmentsWithImagesAndViews(segments: [(image: UIImage, view: UIView)]) {
        addButtons(segments.map { $0.image })
        addViews(segments.map { $0.view })
        redrawComponents()
    }
    
    public func addSegmentsWithTitles(segmentTitles: [String]) {
        addButtons(segmentTitles as [AnyObject])
        redrawComponents()
    }
    
    public func addSegmentsWithImages(segmentImages: [UIImage]) {
        addButtons(segmentImages)
        redrawComponents()
    }
    
    public func setSelectedIndex(index: Int, animated: Bool) {
        setSelectedIndex(index, animated: animated, moveScrollView: true)
    }
    
    // MARK: - Private -
    
    private func setSelectedIndex(index: Int, animated: Bool, moveScrollView: Bool) {
        selectedIndex = index
        moveToIndex(index, animated: animated, moveScrollView: moveScrollView)
    }
    
    private func addViews(segmentViews: [UIView]) {
        guard let scrollView = scrollView else { fatalError("trying to add views but the scrollView is nil") }
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        for i in 0..<segmentViews.count {
            let view = segmentViews[i]
            scrollView.addSubview(view)
            views.append(view)
        }
    }
    
    private func addButtons(titleOrImages: [AnyObject]) {
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons.removeAll()
        for i in 0..<titleOrImages.count {
            let button = UIButton(type: .Custom)
            button.tag = i
            button.addTarget(self, action: #selector(ScrollPager.buttonSelected(_:)), forControlEvents: .TouchUpInside)
            buttons.append(button)
            if let title = titleOrImages[i] as? String {
                button.setTitle(title, forState: .Normal)
            } else if let image = titleOrImages[i] as? UIImage {
                button.setImage(image, forState: .Normal)
            }
            addSubview(button)
            addSubview(indicatorView)
        }
    }
    
    private func moveToIndex(index: Int, animated: Bool, moveScrollView: Bool) {
        animationInProgress = true
        
        UIView.animateWithDuration(animated ? NSTimeInterval(animationDuration) : 0.0, delay: 0.0, options: .CurveEaseOut, animations: { [weak self] in
            
            guard let strongSelf = self else { return }
            let width = strongSelf.frame.size.width / CGFloat(strongSelf.buttons.count)
            let button = strongSelf.buttons[index]
            
            strongSelf.redrawButtons()
            
            if strongSelf.indicatorSizeMatchesTitle {
                guard let string = button.titleLabel?.text else { fatalError("missing title on button, title is required for width calculation") }
                guard let font = button.titleLabel?.font else { fatalError("missing dont on button, title is required for width calculation")  }
                let myString: NSString = string as NSString
                let size: CGSize = myString.sizeWithAttributes([NSFontAttributeName: font])
                let x = width * CGFloat(index) + ((width - size.width) / CGFloat(2))
                strongSelf.indicatorView.frame = CGRect(x: x, y: strongSelf.frame.size.height - strongSelf.indicatorHeight, width: size.width, height: strongSelf.indicatorHeight)
            } else {
                strongSelf.indicatorView.frame = CGRect(x: width * CGFloat(index), y: strongSelf.frame.size.height - strongSelf.indicatorHeight, width: button.frame.size.width, height: strongSelf.indicatorHeight)
            }
            
            if let scrollView = strongSelf.scrollView {
                if moveScrollView {
                    scrollView.contentOffset = CGPoint(x: CGFloat(index) * scrollView.frame.size.width, y: 0)
                }
            }
            
            }, completion: { [weak self] finished in
                // Storyboard crashes on here for some odd reasons, do a nil check
                self?.animationInProgress = false
            })
    }
    
    private func redrawComponents() {
        redrawButtons()
        
        if buttons.count > 0 {
            moveToIndex(selectedIndex, animated: false, moveScrollView: false)
        }
        
        if let scrollView = scrollView {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(buttons.count), height: scrollView.frame.size.height)
            
            for i in 0..<views.count {
                views[i].frame = CGRect(x: scrollView.frame.size.width * CGFloat(i), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            }
        }
    }
    
    private func redrawButtons() {
        if buttons.count == 0 {
            return
        }
        
        let width = frame.size.width / CGFloat(buttons.count)
        let height = frame.size.height - indicatorHeight
        
        for i in 0..<buttons.count {
            let button = buttons[i]
            button.frame = CGRect(x: width * CGFloat(i), y: 0, width: width, height: height)
            button.setTitleColor((i == selectedIndex) ? selectedTextColor : textColor, forState: .Normal)
            button.titleLabel?.font = (i == selectedIndex) ? selectedFont : font
        }
    }
    
    internal func buttonSelected(sender: UIButton) {
        if sender.tag == selectedIndex {
            return
        }
        
        delegate?.scrollPager?(self, changedIndex: sender.tag)
        
        setSelectedIndex(sender.tag, animated: true, moveScrollView: true)
    }
    
    // MARK: - UIScrollView Delegate -
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if !animationInProgress {
            var page = scrollView.contentOffset.x / scrollView.frame.size.width
            if fmod(page, 1) > 0.5 {
                page = page + CGFloat(1)
            }
            
            if Int(page) != selectedIndex {
                setSelectedIndex(Int(page), animated: true, moveScrollView: false)
                delegate?.scrollPager?(self, changedIndex: Int(page))
            }
        }
    }
    
}
