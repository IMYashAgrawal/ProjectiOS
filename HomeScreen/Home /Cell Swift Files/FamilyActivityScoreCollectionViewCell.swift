import UIKit

// FLOW OF THIS CELL
// Home View Controller sends family members data to this cell
// Cell calculates wellness score for each member
// Rings are drawn using CAShapeLayer based on scores
// Avatars are placed on rings and can be tapped
// Delegate notifies controller when a member is tapped

protocol FamilyMemberTapDelegate: AnyObject {
    // Delegate protocol for avatar tap events
    func didTapMember(_ profile: Profile)
    // Sends tapped member back to controller
}

class FamilyActivityScoreCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var infoButton: UIButton!
    // Button that shows legend info

    @IBOutlet weak var containerView: UIView!
    // Main white rounded card

    @IBOutlet weak var ringsContainer: UIView!
    // View where rings and avatars are drawn

    weak var delegate: FamilyMemberTapDelegate?
    // Weak to avoid retain cycle with controller

    private var membersData: [Profile] = []
    // Stores members for tap handling

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    @IBAction func infoTapped(_ sender: UIButton) {
        // Called when info button is pressed
        showLegendOverlay(from: sender)
    }

    private func showLegendOverlay(from source: UIView) {
        // Creates legend popup
        let alert = UIAlertController(
            title: "Wellness Score Legend",
            message: "🟢Green = High\n🔵Blue = Good\n🟡Yellow = Medium\n🔴Red = Low",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "", style: .cancel))
        // Required cancel action for dismissal

        alert.popoverPresentationController?.sourceView = source
        // iPad safety anchor

        alert.popoverPresentationController?.sourceRect = source.bounds

        if let vc = self.parentViewController {
            // Finds parent controller
            vc.present(alert, animated: true)
            // Presents alert
        }
    }

    private func setupUI() {
        // Styles cell appearance
        backgroundColor = .clear
        // Transparent cell background
        contentView.backgroundColor = .clear
        containerView.backgroundColor = .white
        // White card background
        containerView.layer.cornerRadius = 32
        // Rounded corners
    }

    func configure(members: [Profile]) {
        // Main entry point to populate cell
        guard ringsContainer != nil else { return }
        // Safety check
        membersData = members
        // Stores data for tap use
        ringsContainer.subviews.forEach { $0.removeFromSuperview() }
        // Removes old avatar views
        ringsContainer.layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        // Removes old ring layers
        layoutIfNeeded()
        // Ensures container size is ready
        let scoredMembers = members.map {
            ($0, $0.calculateWellnessScore())
        }
        // Pairs each member with score
        let sorted = scoredMembers.sorted { $0.1 > $1.1 }
        // Sorts highest score first
        var colorMap: [Int: UIColor] = [:]
        // Stores ranking color per member
        for (index, item) in sorted.enumerated() {

            let color: UIColor

            switch index {
            case 0: color = .systemGreen
            case 1: color = .systemBlue
            case 2: color = .systemYellow
            default: color = .systemRed
            }

            colorMap[item.0.profileId] = color
            // Assigns ranking color
        }

        let center = CGPoint(
            x: ringsContainer.bounds.midX,
            y: ringsContainer.bounds.midY
        )
        // Center point for rings
        let ringWidth: CGFloat = 28
        // Thickness of each ring
        let ringGap: CGFloat = 5
        // Spacing between rings
        let avatarSize: CGFloat = 45
        // Size of avatar image
        var currentRadius =
            ringsContainer.bounds.width * 0.42
        // Starting radius
        for (index, member) in members.enumerated() {

            if currentRadius < 35 { break }
            // Stops if rings become too small
            let progress =
                member.calculateWellnessScore()
            // Member score (0–1)
            let ringColor =
                colorMap[member.profileId] ?? .systemGray
            let startAngle = -CGFloat.pi / 2
            // Top starting point
            let endAngle =
                startAngle + (2 * .pi * progress)

            let path = UIBezierPath(
                arcCenter: center,
                radius: currentRadius,
                startAngle: startAngle,
                endAngle: startAngle + 2 * .pi,
                clockwise: true
            )
            // Full circular path
            let track = CAShapeLayer()
            // Background ring
            track.path = path.cgPath
            track.strokeColor =
                ringColor.withAlphaComponent(0.15).cgColor
            track.lineWidth = ringWidth
            track.lineCap = .round
            track.fillColor = UIColor.clear.cgColor

            ringsContainer.layer.addSublayer(track)

            let progressLayer = CAShapeLayer()
            // Foreground progress arc
            progressLayer.path = path.cgPath
            progressLayer.strokeColor =
                ringColor.cgColor
            progressLayer.lineWidth = ringWidth
            progressLayer.lineCap = .round
            progressLayer.fillColor =
                UIColor.clear.cgColor
            progressLayer.strokeEnd = progress

            ringsContainer.layer.addSublayer(progressLayer)

            let avatarCenter = CGPoint(
                x: center.x +
                    currentRadius * cos(endAngle),
                y: center.y +
                    currentRadius * sin(endAngle)
            )
            // Position of avatar
            let imageView = UIImageView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: avatarSize,
                    height: avatarSize
                )
            )
            imageView.image =
                UIImage(named: member.profilePic)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius =
                avatarSize / 2
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor =
                UIColor.white.cgColor
            imageView.clipsToBounds = true
            imageView.center = avatarCenter
            imageView.tag = index
            imageView.isUserInteractionEnabled = true

            let tap = UITapGestureRecognizer(
                target: self,
                action: #selector(avatarTapped(_:))
            )
            // Tap recognizer
            imageView.addGestureRecognizer(tap)

            ringsContainer.addSubview(imageView)
            // Adds avatar to view

            currentRadius -=
                (ringWidth + ringGap)
            // Moves inward for next ring
        }

        containerView.bringSubviewToFront(infoButton)
        // Keeps info button visible
    }

    @objc private func avatarTapped(
        _ gesture: UITapGestureRecognizer
    ) {
        guard let imageView = gesture.view else { return }
        let index = imageView.tag
        guard index < membersData.count else { return }
        let member = membersData[index]
        delegate?.didTapMember(member)
        // Notifies controller
    }
}

// Extension to find parent view controller
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let vc =
                parentResponder as? UIViewController {
                return vc
            }
        }
        return nil
    }
}
