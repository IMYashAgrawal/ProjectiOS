import UIKit

// FLOW OF THIS CELL
// CollectionViewController fetches challenge data
// Controller calls configure() and passes data to this cell
// Cell updates title, progress value and avatars
// Progress bar width is adjusted using Auto Layout constraint
// Cell renders as a challenge card in the collection view


class ChallengesCollectionViewCell: UICollectionViewCell {   // Custom collection view cell

    @IBOutlet weak var containerView: UIView!   // Main rounded card container
    @IBOutlet weak var backgroundImageView: UIImageView!   // Background image
    @IBOutlet weak var titleLabel: UILabel!   // Challenge title label
    @IBOutlet weak var avatarStackView: UIStackView!   // Stack holding avatars
    @IBOutlet weak var progressLabel: UILabel!   // Text showing percentage
    @IBOutlet weak var progressBarBackground: UIView!   // Progress bar track
    @IBOutlet weak var progressBarFill: UIView!   // Filled progress portion

    @IBOutlet weak var progressBarFillWidthConstraint: NSLayoutConstraint!
    // Width constraint connected from XIB to control fill size

    private var currentProgress: Double = 0.0
    // Stores progress value normalized between 0 and 1

    override func awakeFromNib() {   // Called when cell is loaded from XIB
        super.awakeFromNib()   // Calls parent implementation
        setupUI()   // Applies initial styling
    }

    private func setupUI() {   // Configures visual appearance

        containerView.layer.cornerRadius = 32   // Rounded card corners
        containerView.layer.masksToBounds = true   // Clips content to shape

        backgroundImageView.layer.cornerRadius = 32   // Matches container shape

        progressBarBackground.layer.cornerRadius = 6   // Rounded progress track
        progressBarFill.layer.cornerRadius = 6   // Rounded fill bar
    }

    override func layoutSubviews() {   // Called after Auto Layout finishes
        super.layoutSubviews()   // Calls parent layout
        updateProgressBar()   // Updates fill width after size is known
    }

    func configure(   // Populates cell with data
        with challengeCompleted: ChallengeCompleted,
        familyMembers: [Profile]
    ) {

        titleLabel.text = challengeCompleted.challenges.challengeName
        // Sets challenge title

        if challengeCompleted.percentageCompleted > 1 {
            // Checks if value is in 0–100 format
            currentProgress =
                challengeCompleted.percentageCompleted / 100
            // Converts to 0–1 range
        } else {
            currentProgress =
                challengeCompleted.percentageCompleted
            // Already normalized
        }

        progressLabel.text =
            "\(Int(currentProgress * 100))% Complete"
        // Shows percentage text

        configureAvatars(   // Builds avatar views
            familyMembers: familyMembers,
            memberProgress:
                challengeCompleted.memberProgress
        )

        updateProgressBar()   // Updates progress bar width
    }

    private func updateProgressBar() {   // Adjusts fill width

        guard progressBarBackground.bounds.width > 0 else { return }
        // Ensures layout size is available

        let fillWidth =
            progressBarBackground.bounds.width *
            CGFloat(currentProgress)
        // Calculates new width

        progressBarFillWidthConstraint.constant =
            max(0, fillWidth)
        // Applies width to constraint
    }

    private func configureAvatars(   // Creates avatar views
        familyMembers: [Profile],
        memberProgress: [String: Double]
    ) {

        avatarStackView.arrangedSubviews.forEach {
            // Removes old avatar views
            avatarStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let sortedMembers = familyMembers.sorted {
            // Sorts members by progress
            let p1 = memberProgress[String($0.profileId)] ?? 0
            let p2 = memberProgress[String($1.profileId)] ?? 0
            return p1 > p2
        }

        for profile in sortedMembers {
            // Adds avatars in sorted order
            let avatarView =
                createAvatarView(profilePic:
                    profile.profilePic)

            avatarStackView.addArrangedSubview(avatarView)
        }
    }

    private func createAvatarView(   // Builds one avatar view
        profilePic: String
    ) -> UIView {

        let size: CGFloat = 50   // Avatar size constant

        let containerView = UIView()   // Wrapper view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        // Enables Auto Layout

        let ringView = UIView()   // Circular border view
        ringView.translatesAutoresizingMaskIntoConstraints = false
        ringView.backgroundColor = .clear
        ringView.layer.cornerRadius = size / 2   // Makes circle
        ringView.layer.borderWidth = 3   // Border thickness
        ringView.layer.borderColor = UIColor.white.cgColor
        // Border color

        let imageView = UIImageView()   // Profile image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: profilePic)
        // Loads image from assets
        imageView.contentMode = .scaleAspectFill
        // Fills circle properly
        imageView.backgroundColor = .lightGray
        // Placeholder color
        imageView.layer.cornerRadius = (size - 6) / 2
        // Inner circle radius
        imageView.clipsToBounds = true
        // Crops image to circle

        containerView.addSubview(ringView)
        // Adds ring to container
        ringView.addSubview(imageView)
        // Adds image inside ring

        NSLayoutConstraint.activate([
            // Applies size and alignment constraints

            containerView.widthAnchor.constraint(
                equalToConstant: size),
            containerView.heightAnchor.constraint(
                equalToConstant: size),

            ringView.widthAnchor.constraint(
                equalToConstant: size),
            ringView.heightAnchor.constraint(
                equalToConstant: size),
            ringView.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor),
            ringView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor),

            imageView.widthAnchor.constraint(
                equalToConstant: size - 6),
            imageView.heightAnchor.constraint(
                equalToConstant: size - 6),
            imageView.centerXAnchor.constraint(
                equalTo: ringView.centerXAnchor),
            imageView.centerYAnchor.constraint(
                equalTo: ringView.centerYAnchor)
        ])

        return containerView   // Returns completed avatar
    }
}
