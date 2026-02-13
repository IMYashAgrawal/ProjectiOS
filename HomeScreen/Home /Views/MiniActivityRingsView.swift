import UIKit

// FLOW OF THIS VIEW (Simple Explanation)
// SceneDelegate loads app data using DataManager
// HomeViewController receives that data
// HomeViewController creates RingData and assigns it to this view
// ringData triggers didSet and calls updateRings()
// CAShapeLayer updates strokeEnd values
// Rings redraw and appear on screen

// Custom UIView that draws activity rings
final class MiniActivityRingsView: UIView {

    // Model struct that holds ring progress and raw values
    struct RingData {
        let moveProgress: CGFloat  // progress value (0–1) for outer ring
        let exerciseProgress: CGFloat // progress value (0–1) for inner ring
        let moveValue: Int // actual calories value
        let moveGoal: Int // calorie goal
        let exerciseValue: Int // actual exercise minutes
        let exerciseGoal: Int // exercise goal
    }

    // Property used by controllers to update the rings
    var ringData: RingData? { // optional because data may not exist at start
        didSet { // runs automatically when value changes
            updateRings()// update rings instantly (no animation)
        }
    }

    // Drawing constants grouped to avoid hard-coded numbers
    private enum Constants {
        static let lineWidth: CGFloat = 7 // thickness of ring stroke
        static let gap: CGFloat = 3 // spacing between rings
        static let moveColor = UIColor(red: 0.98, green: 0.22, blue: 0.35, alpha: 1.0) // outer ring color
        static let exerciseColor = UIColor(red: 0.62, green: 0.98, blue: 0.20, alpha: 1.0) // inner ring color
        static let trackAlpha: CGFloat = 0.15 // background ring opacity
        static let startAngle: CGFloat = -.pi / 2 // start drawing from top
    }

    // Shape layers for background tracks and progress
    private let moveTrackLayer = CAShapeLayer()  // outer background ring
    private let moveProgressLayer = CAShapeLayer()  // outer progress ring
    private let exerciseTrackLayer = CAShapeLayer()  // inner background ring
    private let exerciseProgressLayer = CAShapeLayer() // inner progress ring

    override init(frame: CGRect) { // initializer for programmatic creation
        super.init(frame: frame)
        setupLayers() // configure and add layers
    }

    required init?(coder: NSCoder) { // initializer for storyboard/xib usage
        super.init(coder: coder)
        setupLayers() // configure and add layers
    }

    override func layoutSubviews() {  // called when view size/layout changes
        super.layoutSubviews()
        layoutRings()  // recalculate ring paths
    }

    private func setupLayers() {
        configureTrackLayer(moveTrackLayer, color: Constants.moveColor)          // style outer track
        configureTrackLayer(exerciseTrackLayer, color: Constants.exerciseColor)  // style inner track
        configureProgressLayer(moveProgressLayer, color: Constants.moveColor)    // style outer progress
        configureProgressLayer(exerciseProgressLayer, color: Constants.exerciseColor) // style inner progress

        layer.addSublayer(moveTrackLayer) // add outer track to view
        layer.addSublayer(exerciseTrackLayer)  // add inner track to view
        layer.addSublayer(moveProgressLayer)   // add outer progress
        layer.addSublayer(exerciseProgressLayer) // add inner progress
    }

    private func configureTrackLayer(_ layer: CAShapeLayer, color: UIColor) {
        layer.fillColor = UIColor.clear.cgColor  // no fill, only stroke
        layer.strokeColor = color.withAlphaComponent(Constants.trackAlpha).cgColor // faded color
        layer.lineWidth = Constants.lineWidth   // apply thickness
        layer.lineCap = .round  // rounded ring edges
    }

    private func configureProgressLayer(_ layer: CAShapeLayer, color: UIColor) {
        layer.fillColor = UIColor.clear.cgColor // no fill
        layer.strokeColor = color.cgColor    // solid progress color
        layer.lineWidth = Constants.lineWidth  // apply thickness
        layer.lineCap = .round   // rounded edges
        layer.strokeEnd = 0      // start empty
    }

    private func layoutRings() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY) // center of view
        let maxRadius = min(bounds.width, bounds.height) / 2 // fit circle inside view

        let outerRadius = maxRadius - Constants.lineWidth / 2 // adjust for stroke width
        let innerRadius = outerRadius - Constants.lineWidth - Constants.gap // inner ring size

        let outerPath = circularPath(center: center, radius: outerRadius) // outer circle path
        let innerPath = circularPath(center: center, radius: innerRadius) // inner circle path

        moveTrackLayer.path = outerPath   // assign outer track path
        moveProgressLayer.path = outerPath   // assign outer progress path
        exerciseTrackLayer.path = innerPath  // assign inner track path
        exerciseProgressLayer.path = innerPath  // assign inner progress path
    }

    private func circularPath(center: CGPoint, radius: CGFloat) -> CGPath {
        UIBezierPath(      // create circular bezier path
            arcCenter: center,
            radius: radius,
            startAngle: Constants.startAngle,
            endAngle: Constants.startAngle + 2 * .pi,
            clockwise: true
        ).cgPath    // convert to CGPath for CAShapeLayer
    }

    private func updateRings() {
        guard let data = ringData else { return } // ensure data exists

        updateLayer(moveProgressLayer, to: min(data.moveProgress, 1)) // update outer ring
        updateLayer(exerciseProgressLayer, to: min(data.exerciseProgress, 1)) // update inner ring
    }

    private func updateLayer(_ layer: CAShapeLayer, to value: CGFloat) {
        layer.strokeEnd = value // instantly update ring progress (no animation)
    }
}
