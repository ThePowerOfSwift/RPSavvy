//
//  MAGearRefreshControl.swift
//
//  Created by Michaël Azevedo on 20/05/2015.
//  Copyright (c) 2015 micazeve. All rights reserved.
//

import UIKit




///MARK: - MAGearRefreshDelegate protocol


/// Protocol between the MAGearRefreshControl and its delegate (mostly UITableViewController).
@objc protocol MAGearRefreshDelegate {
    
    /// Method called when the pull to refresh move was triggered.
    ///
    /// - parameter view: The MAGearRefreshControl object.
    func MAGearRefreshTableHeaderDidTriggerRefresh(_ view:MAGearRefreshControl)
    
    /// Method called to know if the data source is loading or no
    ///
    /// - parameter view: The MAGearRefreshControl object.
    ///
    /// - returns: true if the datasource is loading, false otherwise
    func MAGearRefreshTableHeaderDataSourceIsLoading(_ view:MAGearRefreshControl) -> Bool
}


//MARK: - MAGear Class

/// This class represents a gear in the most abstract way, without any graphical code related.
class MAGear {
    
    //MARK: Instance properties
    
    /// The circle on which two gears effectively mesh, about halfway through the tooth.
    let pitchDiameter:CGFloat
    
    /// Diameter of the gear, measured from the tops of the teeth.
    let outsideDiameter:CGFloat
    
    /// Diameter of the gear, measured at the base of the teeth.
    let insideDiameter:CGFloat
    
    /// The number of teeth per inch of the circumference of the pitch diameter. The diametral pitch of all meshing gears must be the same.
    let diametralPitch:CGFloat
    
    /// Number of teeth of the gear.
    let nbTeeth:UInt
    
    
    //MARK: Init method
    
    /// Init method.
    ///
    /// - parameter radius: of the gear
    /// - parameter nbTeeth: Number of teeth of the gear. Must be greater than 2.
    init (radius:CGFloat, nbTeeth:UInt) {
        
        assert(nbTeeth > 2)
        
        self.pitchDiameter = 2*radius
        self.diametralPitch = CGFloat(nbTeeth)/pitchDiameter
        self.outsideDiameter = CGFloat((nbTeeth+2))/diametralPitch
        self.insideDiameter = CGFloat((nbTeeth-2))/diametralPitch
        self.nbTeeth = nbTeeth
    }
}

//MARK: - MASingleGearView Class

/// This class is used to draw a gear in a UIView.
class MASingleGearView : UIView {
    
    //MARK: Instance properties
    
    /// Gear linked to this view.
    fileprivate var gear:MAGear
    
    /// Color of the gear.
    let gearColor:UIColor
    
    /// Phase of the gear. Varies between 0 and 1.
    /// A phase of 0 represents a gear with the rightmost tooth fully horizontal, while a phase of 0.5 represents a gear with a hole in the rightmost point.
    /// A phase of 1 thus is graphically equivalent to a phase of 0
    var phase:Double = 0
    
    /// Enum representing the style of the Gear
    enum MAGearStyle: UInt8 {
        case normal         // Default style, full gear
        case withBranchs    // With `nbBranches` inside the gear
    }
    
    /// Style of the gear
    let style:MAGearStyle
    
    /// Number of branches inside the gear. 
    /// Ignored if style == .Normal.
    /// Default value is 5.
    let nbBranches:UInt
    
    
    //MARK: Init methods
    
    /// Custom init method
    ///
    /// - parameter gear: Gear linked to this view
    /// - parameter gearColor: Color of the gear
    init(gear:MAGear, gearColor:UIColor, style:MAGearStyle = .normal, nbBranches:UInt = 5) {
        
        var width = Int(gear.outsideDiameter + 1)
        if width%2 == 1 {
            width += 1
        }

        self.style = style
        self.gearColor = gearColor
        self.nbBranches = nbBranches
        self.gear = gear
        
        super.init(frame: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(width)))
        
        self.backgroundColor = UIColor.clear
    }
    
    /// Required initializer
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Drawing methods
    
    /// Override of drawing method
    override func draw(_ rect: CGRect) {
        CGColorSpaceCreateDeviceRGB()
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext!.clear(rect)
        
        let pitchRadius = gear.pitchDiameter/2
        let outsideRadius = gear.outsideDiameter/2
        let insideRadius = gear.insideDiameter/2
        
        currentContext!.saveGState()
        currentContext!.translateBy(x: rect.width/2, y: rect.height/2)
        currentContext!.addEllipse(in: CGRect(x: -insideRadius/3, y: -insideRadius/3, width: insideRadius*2/3, height: insideRadius*2/3));
        currentContext!.addEllipse(in: CGRect(x: -insideRadius, y: -insideRadius, width: insideRadius*2, height: insideRadius*2));
        
        if style == .withBranchs {
            
            let rayon1 = insideRadius*5/10
            let rayon2 = insideRadius*8/10
            
            let angleBig        = Double(360/nbBranches) * Double.pi / 180
            let angleSmall      = Double(min(10, 360/nbBranches/6)) * Double.pi / 180
            
            let originX = rayon1 * CGFloat(cos(angleSmall))
            let originY = -rayon1 * CGFloat(sin(angleSmall))
            
            let finX = sqrt(rayon2*rayon2 - originY*originY)
            
            let angle2 = Double(acos(finX/rayon2))
            
            let originX2 = rayon1 * CGFloat(cos(angleBig - angleSmall))
            let originY2 = -rayon1 * CGFloat(sin(angleBig - angleSmall))
            
            
            for i in 0..<nbBranches {
                // Saving the context before rotating it
                currentContext!.saveGState()
                
                let gearOriginAngle =  CGFloat((Double(i)) * Double.pi * 2 / Double(nbBranches))
                
                currentContext!.rotate(by: gearOriginAngle)
                
                currentContext!.move(to: CGPoint(x: originX, y: originY))
                currentContext!.addLine(to: CGPoint(x: finX, y: originY))
                
                currentContext!.addArc(center: CGPoint(x:0, y: 0), radius: rayon2, startAngle: -CGFloat(angle2), endAngle: -CGFloat(angleBig - angle2), clockwise: true)
                
                
                currentContext!.addLine(to: CGPoint(x: originX2, y: originY2))
                
                currentContext!.addArc(center: CGPoint(x:0, y: 0), radius: rayon1, startAngle: -CGFloat(angleBig -  angleSmall), endAngle: -CGFloat(angleSmall), clockwise: false)
                currentContext!.closePath()
                
                currentContext!.restoreGState()
            }
        }
        
        currentContext!.setFillColor(self.gearColor.cgColor)
        
        currentContext!.fillPath(using: CGPathFillRule.evenOdd)
        
        let angleUtile =  CGFloat(Double.pi / (2 * Double(gear.nbTeeth)))
        let angleUtileDemi = angleUtile/2
        
        // In order to draw the teeth quite easily, instead of having complexs calculations,
        // we calcule the needed point for drawing the rightmost horizontal tooth and will rotate the context
        // in order to use the same points
        
        let pointPitchHaut = CGPoint(x: cos(angleUtile) * pitchRadius, y: sin(angleUtile) * pitchRadius)
        let pointPitchBas = CGPoint(x: cos(angleUtile) * pitchRadius, y: -sin(angleUtile) * pitchRadius)
        
        let pointInsideHaut = CGPoint(x: cos(angleUtile) * insideRadius, y: sin(angleUtile) * insideRadius)
        let pointInsideBas = CGPoint(x: cos(angleUtile) * insideRadius, y: -sin(angleUtile) * insideRadius)
        
        let pointOutsideHaut = CGPoint(x: cos(angleUtileDemi) * outsideRadius, y: sin(angleUtileDemi) * outsideRadius)
        let pointOutsideBas = CGPoint(x: cos(angleUtileDemi) * outsideRadius, y: -sin(angleUtileDemi) * outsideRadius)
        
        
        for i in 0..<gear.nbTeeth {
            
            // Saving the context before rotating it
            currentContext!.saveGState()
            
            let gearOriginAngle =  CGFloat((Double(i)) * Double.pi * 2 / Double(gear.nbTeeth))
            
            currentContext!.rotate(by: gearOriginAngle)
            
            // Drawing the tooth
            currentContext!.move(to: CGPoint(x: pointInsideHaut.x, y: pointInsideHaut.y))
            currentContext!.addLine(to: CGPoint(x: pointPitchHaut.x, y: pointPitchHaut.y))
            currentContext!.addLine(to: CGPoint(x: pointOutsideHaut.x, y: pointOutsideHaut.y))
            currentContext!.addLine(to: CGPoint(x: pointOutsideBas.x, y: pointOutsideBas.y))
            currentContext!.addLine(to: CGPoint(x: pointPitchBas.x, y: pointPitchBas.y))
            currentContext!.addLine(to: CGPoint(x: pointInsideBas.x, y: pointInsideBas.y))
            currentContext!.fillPath()
            
            // Restoring the context
            currentContext!.restoreGState()
        }
        
        currentContext!.restoreGState()
    }
    
}

//MARK: - MAMultiGearView Class

/// This class is used to draw multiples gears in a UIView.
class MAMultiGearView : UIView {
    
    //MARK: Instance properties
    
    /// Left border of the view.
    fileprivate var leftBorderView:UIView = UIView()
    
    /// Right border of the view.
    fileprivate var rightBorderView:UIView = UIView()
    
    /// Margin between the bars and the border of the screen.
    var barMargin:CGFloat   = 10
    
    /// Width of the bars
    var barWidth:CGFloat    = 20
    
    /// Color of the side bars
    var barColor = UIColor.white {
        didSet {
            leftBorderView.backgroundColor   = barColor
            rightBorderView.backgroundColor  = barColor
        }
    }
    
    /// Boolean used to display or hide the side bars.
    var showBars = true {
        didSet {
            leftBorderView.isHidden   = !showBars
            rightBorderView.isHidden  = !showBars
        }
    }
    
    /// Diametral pitch of the group of gear
    fileprivate var diametralPitch:CGFloat!
    
    /// Array of views of gear
    fileprivate var arrayViews:[MASingleGearView] = []
    
    /// Relations between the gears.
    /// Ex.  arrayRelations[3] = 2   ->    the 3rd gear is linked to the 2nd one.
    fileprivate var arrayRelations:[Int] = [0]
    
    /// Angles between the gears, in degree, according to the unit circle
    /// Ex.  arrayAngles[3] ->   the angle between the 3rd gear and its linked one
    fileprivate var arrayAngles:[Double] = [0]
    
    
    //MARK: Init methods
    
    /// Default initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        /*
        leftBorderView = UIView(frame:CGRectMake(barMargin, 0, barWidth, frame.height))
        leftBorderView.backgroundColor = barColor
        
        rightBorderView = UIView(frame:CGRectMake(frame.width - barMargin - barWidth, 0, barWidth, frame.height))
        rightBorderView.backgroundColor = barColor
        
        
        addSubview(leftBorderView)
        addSubview(rightBorderView)
        */
    }
    
    /// Required initializer
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Method to add gears
    
    /// Add the initial gear to the view. It is always centered in the view.
    ///
    /// - parameter nbTeeth: Number of teeth of the gear.
    /// - parameter color: Color of the gear.
    /// - parameter radius: Radius in pixel of the gear
    ///
    /// - returns: true if the gear was succesfully created, false otherwise (if at least one gear exists).
    func addInitialGear(nbTeeth:UInt, color: UIColor, radius:CGFloat, gearStyle: MASingleGearView.MAGearStyle = .normal, nbBranches:UInt = 5) -> Bool {
        
        if arrayViews.count > 0  {
            return false
        }
        
        diametralPitch = CGFloat(nbTeeth)/(2*radius)
        
        let gear = MAGear(radius: radius, nbTeeth: nbTeeth)
        
        let view = MASingleGearView(gear: gear, gearColor:color, style:gearStyle, nbBranches: nbBranches)
        view.phase = 0
        
        view.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        
        arrayViews.append(view)
        self.insertSubview(view, belowSubview: leftBorderView)
        
        return true
    }
    /// Add another gear to the view and link it to another already existing gear
    ///
    /// - parameter gearLinked: Index of the previously created gear
    /// - parameter nbTeeth: Number of teeth of the gear.
    /// - parameter color: Color of the gear.
    /// - parameter angleInDegree: Angle (in degree) between the gear to create and the previous gear, according to the unit circle.
    ///
    /// - returns: true if the gear was succesfully created, false otherwise (if the gearLinked index is incorrect).
    func addLinkedGear(_ gearLinked: Int, nbTeeth:UInt, color:UIColor, angleInDegree:Double, gearStyle:MASingleGearView.MAGearStyle = .normal, nbBranches:UInt = 5) -> Bool {
        
        if gearLinked >= arrayViews.count || gearLinked < 0 {
            return false
        }
        
        let linkedGearView      = arrayViews[gearLinked]
        let linkedGear          = linkedGearView.gear
        
        let newRadius = CGFloat(nbTeeth)/(2*diametralPitch)
        
        let gear = MAGear(radius:newRadius, nbTeeth: nbTeeth)
        
        let dist = Double(gear.pitchDiameter + linkedGear.pitchDiameter)/2
        
        let xValue = CGFloat(dist*cos(angleInDegree*Double.pi/180))
        let yValue = CGFloat(-dist*sin(angleInDegree*Double.pi/180))
        
        
        let angleBetweenMainTeethsInDegree = 360/Double(linkedGear.nbTeeth)
        
        let nbDentsPassees = angleInDegree / angleBetweenMainTeethsInDegree
        let phaseForAngle = nbDentsPassees -  Double(Int(nbDentsPassees))
        
        
        var phaseNewGearForAngle = 0.5 + phaseForAngle - linkedGearView.phase
        if gear.nbTeeth%2 == 1 {
            phaseNewGearForAngle += 0.5
        }
        phaseNewGearForAngle = phaseNewGearForAngle - trunc(phaseNewGearForAngle)
        
        let angleBetweenNewTeethsInDegree = 360/Double(gear.nbTeeth)
        let nbNewDentsPassees = angleInDegree / angleBetweenNewTeethsInDegree
        let phaseForNewAngle = 1-(nbNewDentsPassees -  Double(Int(nbNewDentsPassees)))
        
        
        let view = MASingleGearView(gear: gear, gearColor:color, style: gearStyle, nbBranches:nbBranches)
        view.center = CGPoint(x: linkedGearView.center.x + xValue, y: linkedGearView.center.y + yValue)
        
        arrayRelations.append(gearLinked)
        arrayAngles.append(angleInDegree)
        view.phase = phaseNewGearForAngle - phaseForNewAngle
        
        arrayViews.append(view)
        self.insertSubview(view, belowSubview: leftBorderView)
        return true
    }
    
    
    /// Set the phase for the first gear and calculate it for all the linked gears
    ///
    /// - parameter phase: Each incrementation of the phase means the gear rotated from one tooth
    func setMainGearPhase(_ phase:Double) {
        if arrayViews.count == 0  {
            return
        }
        
        let newPhase = phase
        
        arrayViews[0].phase = newPhase
        
        for i in 1..<arrayViews.count {
            
            let gearView = arrayViews[i]
            
            
            let gear                = gearView.gear
            let linkedGearView      = arrayViews[arrayRelations[i]]
            let linkedGear          = linkedGearView.gear
            
            
            let angleInDegree = arrayAngles[i]
            
            let angleBetweenMainTeethsInDegree = 360/Double(linkedGear.nbTeeth)
            
            let nbDentsPassees = angleInDegree / angleBetweenMainTeethsInDegree
            let phaseForAngle = nbDentsPassees -  Double(Int(nbDentsPassees))
            
            var phaseNewGearForAngle = 0.5 + phaseForAngle - linkedGearView.phase
            if gear.nbTeeth%2 == 1 {
                phaseNewGearForAngle += 0.5
            }
            
            let angleBetweenNewTeethsInDegree = 360/Double(gear.nbTeeth)
            
            let nbNewDentsPassees = angleInDegree / angleBetweenNewTeethsInDegree
            let phaseForNewAngle = 1-(nbNewDentsPassees -  Double(Int(nbNewDentsPassees)))
            
            
            let finalPhase = phaseNewGearForAngle - phaseForNewAngle
            
            arrayViews[i].phase  = finalPhase
            
            
        }
        for view in arrayViews {
            
            let angleInRad = -view.phase * 2 * Double.pi / Double(view.gear.nbTeeth)
            view.transform = CGAffineTransform(rotationAngle: CGFloat(angleInRad))
            
        }
    }
    
    //MARK: View configuration
    
    /// Method used to reset the position of all the gear according to the view frame. Is used principally when the frame is changed
    fileprivate func configureView()
    {
        if arrayViews.count == 0 {
            return
        }
        
        arrayViews[0].center.x = frame.size.width/2
        arrayViews[0].center.y = frame.height/2
        
        
        for i in 1..<arrayViews.count {
            
            let angleBetweenGears = arrayAngles[i]
            
            let gearView = arrayViews[i]
            let gear = gearView.gear
            
            
            let linkedGearView      = arrayViews[arrayRelations[i]]
            let linkedGear          = linkedGearView.gear
            let dist = Double(gear.pitchDiameter + linkedGear.pitchDiameter)/2
            let xValue = CGFloat(dist*cos(angleBetweenGears*Double.pi/180))
            let yValue = CGFloat(-dist*sin(angleBetweenGears*Double.pi/180))
            
            gearView.center = CGPoint(x: linkedGearView.center.x + xValue, y: linkedGearView.center.y + yValue)
            
            arrayViews[i].gear = gear
            
        }
        
        leftBorderView.frame    = CGRect(x: 10,  y: 0, width: barWidth, height: frame.height)
        rightBorderView.frame   = CGRect(x: frame.size.width - 10 - barWidth, y: 0, width: barWidth, height: frame.height)
        
    }
    
    //MARK: Override setFrame
    
    override var frame:CGRect  {
        didSet {
            configureView()
        }
    }
    
}


//MARK: - MAAnimatedMultiGearView Class

/// This class is used to draw and animate multiple gears

class MAAnimatedMultiGearView: MAMultiGearView {
    
    //MARK: Instance properties
    
    
    /// Enum representing the animation style
    enum MAGearRefreshAnimationStyle: UInt8 {
        case singleGear    // Only the main gear is rotating when the data is refreshing
        case keepGears     // All the gear are still visible during the refresh and disappear only when its finished
    }
    
    /// Animation style of the refresh control
    fileprivate var style = MAGearRefreshAnimationStyle.keepGears
    
    /// Array of rotational angle for the refresh
    fileprivate var arrayOfRotationAngle:[CGFloat] = [180]
    
    /// Workaround for the issue with the CGAffineTransformRotate (when angle > Double.pi its rotate clockwise beacause it's shorter)
    fileprivate var divisionFactor: CGFloat = 1
    
    /// Variable used to rotate or no the gear
    var stopRotation = true
    
    /// Boolean used to know if the view is already animated
    var isRotating = false
    
    //MARK: Various methods
    
    /// Override of the `addLinkedGear` method in order to update the array of rotational angle when a gear is added
    override func addLinkedGear(_ gearLinked: Int, nbTeeth:UInt, color:UIColor, angleInDegree:Double, gearStyle:MASingleGearView.MAGearStyle = .normal, nbBranches:UInt = 5) -> Bool {
        
        let ret = super.addLinkedGear(gearLinked, nbTeeth: nbTeeth, color: color, angleInDegree: angleInDegree, gearStyle:gearStyle, nbBranches:nbBranches)
        if !ret {
            return false
        }
        
        let ratio = CGFloat(arrayViews[gearLinked].gear.nbTeeth) / CGFloat(arrayViews[arrayViews.count - 1].gear.nbTeeth)
        let newAngle = -1 * arrayOfRotationAngle[gearLinked] * ratio
        /*
        NSLog("addLinkedGear \(gearLinked) , \(nbTeeth) , \(angleInDegree)")
        
        NSLog("     angleOtherGear : \(arrayOfRotationAngle[gearLinked])")
        NSLog("     ratio : \(ratio)")
        NSLog("     newAngle : \(newAngle)")
        */
        
        arrayOfRotationAngle.append(newAngle)
        
        let angleScaled = 1+floor(abs(newAngle)/180)
        
        if angleScaled > divisionFactor {
            divisionFactor = angleScaled
        }
        
        return true
    }
    
    
    /// Method called to rotate the main gear by 360 degree
    fileprivate func rotate() {
        
        if !stopRotation && !isRotating {
            
            isRotating = true
            
            let duration = TimeInterval(1/divisionFactor)
            /*
            NSLog("rotation 0 \(self.arrayOfRotationAngle[0] / 180 * CGFloat(Double.pi) / self.divisionFactor)" )
            NSLog(" -> duration : \(duration)")
            */
            UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: { () -> Void in
                
                switch self.style {
                case .singleGear:
                    self.arrayViews[0].transform = self.arrayViews[0].transform.rotated(by: self.arrayOfRotationAngle[0] / 180 * CGFloat(Double.pi))
                case .keepGears:
                    for i in 0..<self.arrayViews.count {
                        let view = self.arrayViews[i]
                        view.transform = view.transform.rotated(by: self.arrayOfRotationAngle[i] / 180 * CGFloat(Double.pi) / self.divisionFactor)
                    }
                }
                
                
                }, completion: { (finished) -> Void in
                   // NSLog("     -> completion \(finished)")
                    self.isRotating = false
                    self.rotate()
            })
        }
    }
    
    /// Public method to start rotating
    func startRotating() {
        stopRotation = false
        rotate()
    }
    
    
    /// Public method to start rotating
    func stopRotating() {
        stopRotation = true
    }
}



//MARK: - MAGearRefreshControl Class

/// This class is used to draw an animated group of gears and offers the same interactions as an UIRefreshControl
class MAGearRefreshControl: MAAnimatedMultiGearView {
    
    //MARK: Instance properties
    
    /// Enum representing the different state of the refresh control
    enum MAGearRefreshState: UInt8 {
        case normal         // The user is pulling but hasn't reach the activation threshold yet
        case pulling        // The user is still pulling and has passed the activation threshold
        case loading        // The refresh control is animating
    }
    
    /// State of the refresh control
    fileprivate var state = MAGearRefreshState.normal
    
    /// Delegate conforming to the MAGearRefreshDelegate protocol. Most of time it's an UITableViewController
    var delegate:MAGearRefreshDelegate?
    
    /// Content offset of the tableview
    fileprivate var contentOffset:CGFloat = 0
    
    /// Variable used to allow the end of the refresh
    /// We must wait for the end of the animation of the contentInset before allowing the refresh
    fileprivate var endRefreshAllowed = false
    
    /// Variable used to know if the end of the refresh has been asked
    fileprivate var endRefreshAsked = false
    
    
    
    
    //MARK: Various methods
    
    /// Set the state of the refresh control.
    ///
    /// - parameter aState: New state of the refresh control.
    fileprivate func setState(_ aState:MAGearRefreshState) {
        NSLog("setState : \(aState.rawValue)")
        switch aState {
            
        case .loading:
            self.rotate()
            if style == .singleGear {
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    for i in 1..<self.arrayViews.count {
                        self.arrayViews[i].alpha = 0
                        
                    } }, completion:nil)
            }
            
            break
        default:
            break
        }
        state = aState
    }
    
    
    //MARK: Public methods
    
    /// Method to call when the scrollview was scrolled.
    ///
    /// - parameter scrollView: The scrollview.
    func MAGearRefreshScrollViewDidScroll(_ scrollView:UIScrollView) {
        
        configureWithContentOffsetY(-scrollView.contentOffset.y)
        
        if (state == .loading) {
            
            var offset = max(scrollView.contentOffset.y * -1, 0)
            offset = min(offset, 60)
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0)
            
        } else {
            if (scrollView.isDragging) {
                
                var loading = false
                
                if let load = delegate?.MAGearRefreshTableHeaderDataSourceIsLoading(self) {
                    loading = load
                }
                
                if state == .pulling && scrollView.contentOffset.y > -65 && scrollView.contentOffset.y < 0 && !loading {
                    setState(.normal)
                } else if state == .normal && scrollView.contentOffset.y < -65 && !loading {
                    setState(.pulling)
                }
                
                
                if (scrollView.contentInset.top != 0) {
                    scrollView.contentInset = UIEdgeInsets.zero;
                }
            }
           
            let phase = -Double(scrollView.contentOffset.y/20)
           // phase -= Double(Int(phase))
            if stopRotation {
                setMainGearPhase(phase)
            }
        }
    }
    
    /// Method to call when the scrollview ended dragging
    ///
    /// - parameter scrollView: The scrollview.
    func MAGearRefreshScrollViewDidEndDragging(_ scrollView:UIScrollView) {
        
        NSLog("MAGearRefreshScrollViewDidEndDragging")
        /*if state == .Loading {
            NSLog("return")
            return
        }*/
        
        var loading = false
        
        if let load = delegate?.MAGearRefreshTableHeaderDataSourceIsLoading(self) {
            loading = load
        }
        
        if scrollView.contentOffset.y <= -65.0 && !loading {
            
            self.stopRotation = false
            delegate?.MAGearRefreshTableHeaderDidTriggerRefresh(self)
            
            setState(.loading)
            
            let contentOffset = scrollView.contentOffset
            
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
               
                scrollView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
                scrollView.contentOffset = contentOffset;          // Workaround for smooth transition on iOS8
                }, completion: { (completed) -> Void in
                    NSLog("completed")
                    let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.6 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                        // your function here
                        self.endRefreshAllowed = true
                        if self.endRefreshAsked {
                            NSLog("self.endRefreshAsked")
                            self.endRefreshAsked = false
                            self.MAGearRefreshScrollViewDataSourceDidFinishedLoading(scrollView)
                        }
                    })
                    
                    
            })
            
        }
    }
    
    /// Method to call when the datasource finished loading
    ///
    /// - parameter scrollView: The scrollview.
    func MAGearRefreshScrollViewDataSourceDidFinishedLoading(_ scrollView:UIScrollView) {
        
        NSLog("MAGearRefreshScrollViewDataSourceDidFinishedLoading")
        
        if !endRefreshAllowed {
            endRefreshAsked = true
            return
        }
        endRefreshAllowed = false
        self.setState(.normal)
        
        scrollView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.arrayViews[0].transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { (finished) -> Void in
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    
                    if self.style == .keepGears {
                        for i in 1..<self.arrayViews.count {
                            self.arrayViews[i].alpha = 0
                        }
                    }
                    
                    
                    self.arrayViews[0].transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                })
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveLinear, animations: { () -> Void in
                    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    scrollView.contentOffset = CGPoint(x: 0, y: 0);          // Workaround for smooth transition on iOS8
                    }, completion: { (finished) -> Void in
                        self.stopRotation = true
                        scrollView.isUserInteractionEnabled = true
                        for view in self.arrayViews {
                            view.alpha = 1
                            view.transform = CGAffineTransform.identity
                            
                        }
                })
        }) 
    }
    
    
    //MARK: View configuration
    
    /// Method to configure the view with an Y offset of the scrollview
    ///
    /// - parameter offset: Offset of the scrollView
    fileprivate func configureWithContentOffsetY(_ offset:CGFloat)
    {
        contentOffset = offset
        configureView()
    }
    
    /// Override of configureView(). The override is needed since we don't want the first gear to be centered within the view.
    /// Instead, we want it to be centered within the visible part of the view
    override fileprivate func configureView() {
        if arrayViews.count == 0 {
            return
        }
        
        arrayViews[0].center.x = frame.size.width/2
        arrayViews[0].center.y = frame.height  - contentOffset/2
        
        
        for i in 1..<arrayViews.count {
            
            let angleBetweenGears = arrayAngles[i]
            
            let gearView = arrayViews[i]
            let gear = gearView.gear
            
            
            let linkedGearView      = arrayViews[arrayRelations[i]]
            let linkedGear          = linkedGearView.gear
            let dist = Double(gear.pitchDiameter + linkedGear.pitchDiameter)/2
            let xValue = CGFloat(dist*cos(angleBetweenGears*Double.pi/180))
            let yValue = CGFloat(-dist*sin(angleBetweenGears*Double.pi/180))
            
            gearView.center = CGPoint(x: linkedGearView.center.x + xValue, y: linkedGearView.center.y + yValue)
            
            arrayViews[i].gear = gear
            
        }
        
        leftBorderView.frame    = CGRect(x: barMargin, y: frame.height - contentOffset, width: barWidth, height: contentOffset)
        rightBorderView.frame   = CGRect(x: frame.size.width - barMargin - barWidth, y: frame.height - contentOffset, width: barWidth, height: contentOffset)
    }
    
    //MARK: Public methods override
    
    /// Override of startRotating in order to disable this portion of code (must be triggered from the tableview)
    override func startRotating() {
        
    }
    
    /// Override of stopRotating in order to disable this portion of code (must be triggered from delegate)
    override func stopRotating()
    {
    }
}
