# JPulseHUD

[![CI Status](http://img.shields.io/travis/Mark Jackson/JPulseHUD.svg?style=flat)](https://travis-ci.org/Mark Jackson/JPulseHUD)
[![Version](https://img.shields.io/cocoapods/v/JPulseHUD.svg?style=flat)](http://cocoapods.org/pods/JPulseHUD)
[![License](https://img.shields.io/cocoapods/l/JPulseHUD.svg?style=flat)](http://cocoapods.org/pods/JPulseHUD)
[![Platform](https://img.shields.io/cocoapods/p/JPulseHUD.svg?style=flat)](http://cocoapods.org/pods/JPulseHUD)

JPulseHUD is a drop in class for displaying a translucent view over a controller when work is being done on a background thread or you're awaiting the result of a network request. This HUD was inspired by [Acorns](https://www.acorns.com/) similar pulse animation within their iOS app.

<img src="https://raw.githubusercontent.com/jacks205/JPulseHUD/master/image/jpulsehud1.png" width="240"/>
<img src="https://raw.githubusercontent.com/jacks205/JPulseHUD/master/image/jpulsehud2.gif" width="240"/>
<img src="https://raw.githubusercontent.com/jacks205/JPulseHUD/master/image/jpulsehud1.gif" width="240"/>

Each time the JPulseHUD is shown, the pulse animation is unique due to the `JPulseNumberGenerator` that generates a new sequence of values to determine the pulses radius, duration, opacity, etc.

## Example

To run the example project, clone the repo, and open the workspace project in Xcode.

## Requirements

- iOS 9+

## Installation

### CocoaPods

JPulseHUD is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JPulseHUD'
```

### Source Files

JPulseHUD can be added by importing the `JPulseHUD/` directory to your project. Make sure it includes all 3 source files:

- `JPulseHUD.swift`
- `JPulseLayer.swift`
- `JPulseNumberGenerator.swift`

## Usage 

The primary use of JPulseHUD should be to provide a progress/loading animation to users during background tasks or network calls. It is recommended that JPulseHUD is shown/hidden on the main thread before/after an asynchronous task.

```swift
JPulseHUD.addHUDToView(view)
dispatch_async(dispatch_get_global_queue(priority, 0)) {
    // do some task
    dispatch_async(dispatch_get_main_queue()) {
        JPulseHUD.removeHUDFromView(self.view, animated: true)
    }
}
```

Alternatively, you can instantiate JPulseHUD to allow for some customizability to fit your needs.

```swift
let hud = JPulseHUD(frame: view.frame)
hud.pulseFillColor = UIColor.redColor()
hud.timingFunction = CAMediaTimingFunction(controlPoints: 0, 1, 1, 0.5)
hud.showInView(view)

// Some async task
self.retreiveAPI() { results in
    hud.hide(true)
}
```

### Customization

```swift
/// Timing function for pulse animations.
public var timingFunction: CAMediaTimingFunction

/// Duration for HUD to be fade out and be removed when `hide(animated: true)`
public var hideAnimationDuration

/// Duration offset for easily quickening or slowing down pulse animation speed.
public var pulseDurationOffset

/// Point offset for the pulse animation from the frame center.
public var pulseOffset: CGPoint

/// Fill color for the pulse layer.
public var pulseFillColor: UIColor

/// Custom JPulseNumberGenerator for building custom number sequences for the pulse animation. (See more below)
public var pulseNumberGenerator: JPulseNumberGenerator
```

> If you're interested in customizing `timingFunction`, checkout this [useful site](http://dbaron.org/css/timing-function-graphs) for visually creating a transition timing function.

## JPulseNumberGenerator

JPulseNumberGenerator is a protocol that allows the creation of a unique sequence of numbers that will dictate the behaviour of the pulse animations in JPulseHUD.

Here is the protocol for JPulseNumberGenerator
```swift
/// Tuple that represents the required values of an class extending JPulseNumberGenerator.
/// - parameter radius: Describes the max size of the pulse circle layer.
/// - parameter duration: The duration of the layer animation.
/// - parameter delay: The delay of when the layer enimation will execute.
/// - parameter opacity: Opacity of the layer.
public typealias JPulseNumberGeneratorValues = (radius: CGFloat, duration: Double, delay: Double, opacity: CGFloat)

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
```

Create your own JPulseNumberGenerator and replace the default `pulseNumberGenerator` in JPulseHUD before presenting.

## TODO
- Tests
- RxSwift extensions
- `JPulseNumberGenerator` example

## Author

Mark Jackson, markjacks205@gmail.com

## License

JPulseHUD is available under the MIT license. See the LICENSE file for more info.
