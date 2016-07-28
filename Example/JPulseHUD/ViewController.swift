//
//  ViewController.swift
//  JPulseHUD
//
//  Created by Mark Jackson on 07/24/2016.
//  Copyright (c) 2016 Mark Jackson. All rights reserved.
//

import UIKit
import JPulseHUD

class ViewController: UIViewController {
    
    let addHUDSimpleBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Add HUD Simple", forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        return btn
    }()
    
    let addHUDInstanceBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Add HUD Instance", forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        return btn
    }()
    
    let timingFncEaseInBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Timing Function Ease In", forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        return btn
    }()
    
    let timingFncEaseInOutBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Timing Function Ease In Ease Out", forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(addHUDSimpleBtn)
        view.addSubview(addHUDInstanceBtn)
        view.addSubview(timingFncEaseInBtn)
        view.addSubview(timingFncEaseInOutBtn)
        addHUDSimpleBtn.addTarget(self, action: #selector(addHUDStaticClick), forControlEvents: .TouchUpInside)
        addHUDInstanceBtn.addTarget(self, action: #selector(addHUDInstanceClick), forControlEvents: .TouchUpInside)
        timingFncEaseInBtn.addTarget(self, action: #selector(timingFncEaseInClick), forControlEvents: .TouchUpInside)
        timingFncEaseInOutBtn.addTarget(self, action: #selector(timingFncEaseInOutClick), forControlEvents: .TouchUpInside)
        setConstraints()
        view.backgroundColor = UIColor.blackColor()
    }
    
    func addHUDStaticClick(sender: AnyObject) {
        JPulseHUD.addHUDToView(view)
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(20 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                JPulseHUD.removeHUDFromView(self.view, animated: true)
            }
        }
    }
    
    func addHUDInstanceClick(sender: AnyObject) {
        let hud = JPulseHUD(frame: view.frame)
        hud.pulseDurationOffset = -0.1
        hud.pulseFillColor = UIColor.redColor()
        hud.timingFunction = CAMediaTimingFunction(controlPoints: 0, 1, 1, 0.5)
        hud.showInView(view)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(8 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            hud.hide(true)
        }
    }
    
    func timingFncEaseInClick(sender: AnyObject) {
        let hud = JPulseHUD(frame: view.frame)
        hud.hideAnimationDuration = 5
        hud.pulseDurationOffset = 2
        hud.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        hud.showInView(view)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(8 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            hud.hide(true)
        }
    }
    
    func timingFncEaseInOutClick(sender: AnyObject) {
        let hud = JPulseHUD(frame: view.frame)
        hud.pulseFillColor = UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1)
        hud.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        hud.showInView(view)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(8 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            hud.hide(true)
        }
    }
    
    private func setConstraints() {
        addHUDSimpleBtn.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor, constant: 36).active = true
        addHUDSimpleBtn.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        addHUDInstanceBtn.topAnchor.constraintEqualToAnchor(addHUDSimpleBtn.bottomAnchor, constant: 16).active = true
        addHUDInstanceBtn.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        timingFncEaseInBtn.topAnchor.constraintEqualToAnchor(addHUDInstanceBtn.bottomAnchor, constant: 16).active = true
        timingFncEaseInBtn.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        timingFncEaseInOutBtn.topAnchor.constraintEqualToAnchor(timingFncEaseInBtn.bottomAnchor, constant: 16).active = true
        timingFncEaseInOutBtn.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    }

}
