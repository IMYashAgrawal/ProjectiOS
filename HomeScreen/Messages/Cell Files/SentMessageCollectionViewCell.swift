//
//  SentMessageCollectionViewCell.swift
//  HealthSharing
//
//  Created by GEU on 06/02/26.
//

import UIKit

class SentMessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        
        // Important: Let the label expand vertically
        messageLabel.setContentHuggingPriority(.required, for: .vertical)
        messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.backgroundColor = UIColor.systemGreen 
    }
    
    func configure(with message: Message) {
        messageLabel.text = message.message
        timeLabel.text = formatTime(message.timestampUTC)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoLayoutSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        let frame = CGRect(
            x: layoutAttributes.frame.origin.x,
            y: layoutAttributes.frame.origin.y,
            width: layoutAttributes.frame.width,
            height: autoLayoutSize.height
        )
        
        layoutAttributes.frame = frame
        return layoutAttributes
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

}
