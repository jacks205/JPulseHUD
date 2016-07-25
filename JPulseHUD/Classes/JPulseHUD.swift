//
//  JPulseHUD.swift
//  Pods
//
//  Created by Mark Jackson on 7/24/16.
//
//

import UIKit

/// Tuple that represents the required values of an class extending JPulseNumberGenerator.
/// - parameter radius: Describes the max size of the pulse circle layer.
/// - parameter duration: The duration of the layer animation.
/// - parameter delay: The delay of when the layer enimation will execute.
/// - parameter opacity: Opacity of the layer.
public typealias JPulseNumberGeneratorValues = (radius: CGFloat, duration: Double, delay: Double, opacity: CGFloat)

/// Default pulse timing animation. Can be changed through `JPulseHUD`.
internal var animationTimingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1.0, 0.32, 1.0)

/**
 *  Protocol for constructing a custom sequence of values to determine the pulse rhythm.
 */
public protocol JPulseNumberGenerator {
    /// Seed object that will determine the random sequence of values.
    var seed: AnyObject { get set }
    
    /// Values generated based off seed.
    var values: [JPulseNumberGeneratorValues] { get }
    
    /**
     Updates the seed. Can leave blank if seed doesn't require to be updated.
     */
    func updateSeed()
}

/**
   Displays a transparent view over its superview and emits a circle pulse animation.
 
   This class is used for displaying a progress/loading indicator to the user during network or background thread work.
 
   Simple Usage:
   ```
       JPulseHUD.addHUDToView(view)
 
       // background thread work
       // invoke main thread
 
       JPulseHUD.removeHUDFromView(view)
   ```
 */
public class JPulseHUD: UIView {
    
    //MARK: - Properties
    
    /// Timing function for pulse animations.
    ///
    /// Default: `CAMediaTimingFunction(controlPoints: 0.23, 1.0, 0.32, 1.0)`
    public var timingFunction: CAMediaTimingFunction {
        get {
            return animationTimingFunction
        }
        set {
            animationTimingFunction = newValue
        }
    }
    
    /// Duration for HUD to be fade out and be removed when `hide(animated: true)`
    ///
    /// Default: `1.0`
    public var hideAnimationDuration = 1.0
    
    /// Duration offset for easily quickening or slowing down pulse animation speed.
    ///
    /// Default: `0.0`
    public var pulseDurationOffset = 0.0 {
        didSet {
            if let pulseNumberGenerator = pulseNumberGenerator as? JPulseDateNumberGenerator {
                pulseNumberGenerator.durationOffset = pulseDurationOffset
            }
        }
    }
    
    /// Custom JPulseNumberGenerator for building custom number sequences for the pulse animation.
    ///
    /// Default: `JPulseDateNumberGenerator()`
    public var pulseNumberGenerator: JPulseNumberGenerator = JPulseDateNumberGenerator()
    
    //MARK: - Initializers
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    /**
     Initializer for setting properties of HUD.
     */
    private func initialize() {
        backgroundColor = UIColor.clearColor()
        if let pulseNumberGenerator = pulseNumberGenerator as? JPulseDateNumberGenerator {
            pulseNumberGenerator.width = frame.width
            pulseNumberGenerator.durationOffset = pulseDurationOffset
        }
    }
    
    //MARK: - Static Functions

    /**
     Adds HUD to view as a subview and starts animation.
     
     Hide HUD by calling:
     ```
     JPulseHUD.removeHUDFromView(view)
     ```
     - parameter view: view to present HUD on.
     */
    public static func addHUDToView(view: UIView) {
        let currentHud = hudFromView(view)
        guard currentHud == nil else {
            return
        }
        let hud = JPulseHUD(frame: view.frame)
        view.addSubview(hud)
        hud.show()
    }
    
    /**
     Removes HUD from view if it exists.
     
     - parameter view:     view to remove HUD from.
     - parameter animated: animates HUD by fading out based on `hideAnimationDuration`.
     
     - returns: Bool indicating if HUD was successfully removed.
     */
    public static func removeHUDFromView(view: UIView, animated: Bool) -> Bool {
        let hud = hudFromView(view)
        guard hud != nil else {
            return false
        }
        hud?.removeFromSuperViewAnimated(animated)
        return true
    }
    
    /**
     Returns HUD object if it's located in view's subviews.
     
     - parameter view: view to search for HUD.
     
     - returns: HUD object.
     */
    public static func hudFromView(view: UIView) -> JPulseHUD? {
        let hud = view.subviews.filter { $0 is JPulseHUD }
        return hud.first as? JPulseHUD
    }
    
    //MARK: - Instance Functions
    
    /**
     Shows HUD in view.
     
     Hide HUD by calling:
     ```
     JPulseHUD.hide(animated: Bool)
     ```
     - parameter view: view to present HUD on.
     */
    public func showInView(view: UIView) {
        view.addSubview(self)
        show()
    }
    
    /**
     Shows HUD on superview.
     
     **Important**
     Make sure that the HUD is a subview of the view you wish to present the HUD on. Not doing so will result in the HUD not being presented.
     
     ```
        let hud = JPulseHUD(frame: view.frame)
        view.addSubview(hud) //required if calling hud.show()
        hud.show()
    ```
     
     Otherwise call `showInView(view: UIView)` for JPulseHUD to add the subview.
     */
    public func show() {
        let jpng = pulseNumberGenerator
        jpng.updateSeed()
        let delay = jpng.values.reduce(0) { (delay, values: JPulseNumberGeneratorValues) -> Double in
            return pulseWithDelay(delay, seedValues: values)
        }
        let jTimerObject = JTimerObject(hud: self, jpng: jpng)
        NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(updateSeedSelector), userInfo: jTimerObject, repeats: true)
    }
    
    /**
     Hides HUD.
     
     - parameter animated: animates HUD by fading out based on `hideAnimationDuration`.
     
     - returns: Bool indicating if HUD was successfully removed.
     */
    public func hide(animated: Bool) -> Bool {
        if let view = superview {
            return JPulseHUD.removeHUDFromView(view, animated: animated)
        }
        return false
    }
    
    //MARK: - Internal Instances Functions
    
    internal func removeFromSuperViewAnimated(animated: Bool) {
        if animated {
            UIView.animateWithDuration(hideAnimationDuration, delay: 0, options: .CurveEaseOut, animations: { [weak self] in
                self?.alpha = 0
            }) { [weak self] (_) in
                self?.removeFromSuperview()
            }
        } else {
            removeFromSuperview()
        }
    }
    
    internal func pulse(radius: CGFloat, duration: CFTimeInterval, delay: Double = 0, fillColor: UIColor = UIColor(white: 1, alpha: 0.2)) {
        let layer = JPulseLayer()
        layer.frame = frame
        layer.bounds = bounds
        layer.position = center
        layer.fillColor = fillColor.CGColor
        self.layer.addSublayer(layer)
        layer.pulse(center, radius: radius, duration: duration, delay: delay, fillColor: fillColor)
    }
    
    internal func updateSeedSelector(timer: NSTimer) {
        guard let jTimerObject = timer.userInfo as? JTimerObject else {
            timer.invalidate()
            return
        }
        let hud = jTimerObject.hud
        let jpng = jTimerObject.jpng
        jpng.updateSeed()
        let delay = jpng.values.reduce(0) { (delay, values: (CGFloat, Double, Double, CGFloat)) -> Double in
            return hud.pulseWithDelay(delay, seedValues: values)
        }
        timer.invalidate()
        NSTimer.scheduledTimerWithTimeInterval(delay, target: hud.self, selector: #selector(hud.updateSeedSelector), userInfo: jTimerObject, repeats: true)
    }
    
    internal func pulseWithDelay(delay: Double, seedValues: JPulseNumberGeneratorValues) -> Double {
        pulse(seedValues.0, duration: seedValues.1, delay: delay, fillColor: UIColor(white: 1, alpha: seedValues.3))
        return delay + seedValues.2
    }
}

internal class JPulseLayer: CAShapeLayer {
    
    convenience init(timingFunction: CAMediaTimingFunction) {
        self.init()
        animationTimingFunction = timingFunction
    }
    
    func pulse(center: CGPoint, radius: CGFloat, duration: CFTimeInterval, delay: Double, fillColor: UIColor) {
        animatePath(center, radius: radius, duration: duration, delay: delay)
        animateColor(duration, delay: delay)
    }
    
    private func animatePath(center: CGPoint, radius: CGFloat, duration: CFTimeInterval, delay: Double) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = UIBezierPath(ovalInRect: CGRect(origin: center, size: CGSizeZero)).CGPath
        animation.toValue = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: center.x - radius / 2, y: center.y - radius / 2), size: CGSize(width: radius, height: radius))).CGPath
        animation.duration = duration
        animation.removedOnCompletion = true
        animation.delegate = self
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = animationTimingFunction
        addAnimation(animation, forKey: animation.keyPath)
    }
    
    private func animateColor(duration: CFTimeInterval, delay: Double) {
        let colorAnim = CABasicAnimation(keyPath: "fillColor")
        colorAnim.toValue = UIColor.clearColor().CGColor
        colorAnim.duration = duration
        colorAnim.removedOnCompletion = true
        colorAnim.beginTime = CACurrentMediaTime() + delay
        colorAnim.fillMode = kCAFillModeForwards
        colorAnim.timingFunction = animationTimingFunction
        addAnimation(colorAnim, forKey: colorAnim.keyPath)
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag {
            removeFromSuperlayer()
        }
    }
}

public class JPulseDateNumberGenerator: JPulseNumberGenerator {
    
    public var seed: AnyObject = NSDate()
    private var seedString: String {
        let seconds = seed.timeIntervalSince1970 % 1.0
        let secondsString = "\(seconds)"
        return secondsString.substringFromIndex(secondsString.startIndex.advancedBy(2))
    }
    
    public var values: [JPulseNumberGeneratorValues] {
        return calculateValues(seedString)
    }
    
    public var durationOffset = 0.0
    public var width: CGFloat = 0
    
    public init(viewFrameWidth: CGFloat = 0, durationOffset: Double = 0) {
        width = viewFrameWidth
        self.durationOffset = durationOffset
    }
    
    public func updateSeed() {
        seed = NSDate()
    }
    
    private func calculateValues(seed: AnyObject) -> [JPulseNumberGeneratorValues] {
        guard let seedString = seed as? String else {
            fatalError("Error with seed -> \(seed)")
        }
        let randomValues = seedString.unicodeScalars.enumerate().map { (index, char) -> JPulseNumberGeneratorValues in
            let unicodeFloat = CGFloat(char.value)
            let delay = Double((unicodeFloat - 48.0) / 10.0)
            let opacity = delay > 0 ? CGFloat(delay) : 0.1
            let radius = index % 2 == 0 ? CGFloat(delay) * width : CGFloat(delay) / 2 * width
            let duration = Double(delay * 10) + durationOffset
            return (radius, duration, delay, opacity)
        }
        return randomValues
    }
}

internal class JTimerObject {
    let jpng: JPulseNumberGenerator
    let hud: JPulseHUD
    
    init(hud: JPulseHUD, jpng: JPulseNumberGenerator) {
        self.hud = hud
        self.jpng = jpng
    }
}
