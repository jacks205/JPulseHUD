//
//  JPulseNumberGenerator.swift
//  Pods
//
//  Created by Mark Jackson on 7/25/16.
//
//

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
        width = viewFrameWidth / 5
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
            let radius = index % 2 == 0 ? CGFloat(delay) * width / 1.5 : CGFloat(delay) / 2 * width / 1.5
            let duration = Double(delay * 10) + durationOffset
            return (radius, duration, delay, opacity)
        }
        return randomValues
    }
}