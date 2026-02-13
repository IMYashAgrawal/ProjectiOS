import UIKit

class WellnessCardCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var primaryValueLabel: UILabel!
    @IBOutlet weak var secondaryValueLabel: UILabel!
    
    private var activityRingsView: MiniActivityRingsView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
    }
    
    func configure(with card: WellnessCard, ringData: MiniActivityRingsView.RingData? = nil) {
        // Remove old activity rings if any
        activityRingsView?.removeFromSuperview()
        activityRingsView = nil
        
        // Show/hide icon based on card type
        if card.type == .activityRings {
            iconImageView.isHidden = true
            
            // Add activity rings
            let ringSize: CGFloat = 48  // Bigger rings
            let ringsView = MiniActivityRingsView()
            
            // Position in place of icon
            let iconFrame = iconImageView.frame
            let ringX = iconFrame.midX - ringSize / 2
            let ringY = iconFrame.midY - ringSize / 2
            ringsView.frame = CGRect(x: ringX, y: ringY, width: ringSize, height: ringSize)
            ringsView.backgroundColor = .clear
            
            containerView.addSubview(ringsView)
            activityRingsView = ringsView
            
            // Set ring data from parameter
            if let ringData = ringData {
                ringsView.ringData = ringData
            }
        } else {
            iconImageView.isHidden = false
            iconImageView.image = UIImage(systemName: card.icon)
            iconImageView.tintColor = card.iconColor
        }
        
        // Text
        titleLabel.text = card.title
        primaryValueLabel.text = card.primaryValue
        
        // Hide secondary value if nil or empty
        if let secondary = card.secondaryValue, !secondary.isEmpty {
            secondaryValueLabel.text = secondary
            secondaryValueLabel.isHidden = false
        } else {
            secondaryValueLabel.isHidden = true
        }
       
    }
}
