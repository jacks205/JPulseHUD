//
//  JPulseHUD.swift
//  Pods
//
//  Created by Mark Jackson on 7/24/16.
//
//

import UIKit

public typealias JPulseHUDCompletion = () -> Void
public typealias JPulseNumberGeneratorValues = (radius: CGFloat, duration: Double, delay: Double, opacity: CGFloat)

public protocol JPulseNumberGenerator {
    var seed: AnyObject { get set }
    var seedString: String { get }
    
    var values: [JPulseNumberGeneratorValues] { get }
    
    func updateSeed()
    
    func calculateValues(seed: AnyObject) -> [JPulseNumberGeneratorValues]
}

public class JPulseHUD: UIView {
    
    //MARK: - Properties
    
    public var timingFunction: CAMediaTimingFunction {
        get {
            return animationTimingFunction
        }
        set {
            animationTimingFunction = newValue
        }
    }
    
    public var hideAnimationDuration = 1.0
    
    public var pulseDurationOffset = 0.0
    
    //MARK: - Initializers
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = UIColor.clearColor()
    }
    
    //MARK: - Static Functions

    public static func addHUDToView(view: UIView) {
        let currentHud = hudFromView(view)
        guard currentHud == nil else {
            return
        }
        let hud = JPulseHUD(frame: view.frame)
        view.addSubview(hud)
        hud.show()
    }
    
    public static func removeHUDFromView(view: UIView, animated: Bool) -> Bool {
        let hud = hudFromView(view)
        guard hud != nil else {
            return false
        }
        hud?.removeFromSuperViewAnimated(animated)
        return true
    }
    
    public static func hudFromView(view: UIView) -> JPulseHUD? {
        let hud = view.subviews.filter { $0 is JPulseHUD }
        return hud.first as? JPulseHUD
    }
    
    //MARK: - Instance Functions
    
    public func showInView(view: UIView) {
        view.addSubview(self)
        show()
    }
    
    public func show() {
        let jpng = JPulseDateNumberGenerator(viewFrameWidth: frame.width, durationOffset: pulseDurationOffset)
        let delay = jpng.values.reduce(0) { (delay, values: JPulseNumberGeneratorValues) -> Double in
            return pulseWithDelay(delay, seedValues: values)
        }
        let jTimerObject = JTimerObject(hud: self, jpng: jpng)
        NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(updateSeedSelector), userInfo: jTimerObject, repeats: true)
    }
    
    public func hide(animated: Bool) -> Bool {
        if let view = superview {
            return JPulseHUD.removeHUDFromView(view, animated: animated)
        }
        return false
    }
    
    //MARK: - Internal Instances Functions
    
    internal func removeFromSuperViewAnimated(animated: Bool, completion: JPulseHUDCompletion? = nil) {
        if animated {
            UIView.animateWithDuration(hideAnimationDuration, delay: 0, options: .CurveEaseOut, animations: { [weak self] in
                self?.alpha = 0
            }) { [weak self] (_) in
                self?.removeFromSuperview()
                completion?()
            }
        } else {
            removeFromSuperview()
            completion?()
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

internal var animationTimingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1.0, 0.32, 1.0)

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
}

public class JPulseDateNumberGenerator: JPulseNumberGenerator {
    
    public var seed: AnyObject = NSDate()
    public var seedString: String {
        let seconds = seed.timeIntervalSince1970 % 1.0
        let secondsString = "\(seconds)"
        return secondsString.substringFromIndex(secondsString.startIndex.advancedBy(2))
    }
    
    public var values: [JPulseNumberGeneratorValues] {
        return calculateValues(seedString)
    }
    
    public var durationOffset = 0.0
    private let width: CGFloat
    
    public init(viewFrameWidth: CGFloat, durationOffset: Double) {
        width = viewFrameWidth
        self.durationOffset = durationOffset
    }
    
    public func updateSeed() {
        seed = NSDate()
    }
    
    public func calculateValues(seed: AnyObject) -> [JPulseNumberGeneratorValues] {
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
