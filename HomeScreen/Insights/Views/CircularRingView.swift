//
//  CircularRingView.swift
//  HomeScreen
//
//  Created by GEU on 09/02/26.
//

import UIKit

class CircularRingView: UIView {
    private let iconView = UIImageView()
    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    var lineWidth: CGFloat = 6

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {

        backgroundColor = .clear

        // Background track
        backgroundLayer.strokeColor = UIColor.systemGray5.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = 6
        layer.addSublayer(backgroundLayer)

        // Progress ring
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 6
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)

        // Icon
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 8

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )

        backgroundLayer.path = path.cgPath
        progressLayer.path = path.cgPath

        // smaller icon (Apple style)
        iconView.frame = bounds.insetBy(dx: 18, dy: 18)
    }

    func setProgress(_ value: CGFloat, color: UIColor) {
        let clamped = max(0, min(value, 1))
        progressLayer.strokeColor = color.cgColor
        progressLayer.strokeEnd = clamped

        // icon matches ring color
        iconView.tintColor = color
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = clamped
        animation.duration = 0.8
        progressLayer.add(animation, forKey: "progress")

    }

    func setIcon(_ name: String) {
        iconView.image = UIImage(systemName: name)
    }

}
