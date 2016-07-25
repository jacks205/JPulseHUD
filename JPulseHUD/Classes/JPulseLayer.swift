//
//  JPulseLayer.swift
//  Pods
//
//  Created by Mark Jackson on 7/25/16.
//
//

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