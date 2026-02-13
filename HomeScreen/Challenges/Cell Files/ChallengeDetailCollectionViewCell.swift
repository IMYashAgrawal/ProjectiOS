//
//  ChallengeDetailCollectionViewCell.swift
//  ChallengeCell
//
//  Created by GEU on 09/02/26.
//

import UIKit

class ChallengeDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var progressPercentValue: UILabel!
    @IBOutlet weak var progressPercentView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var numberOfMemberCompletedLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        numberOfMemberCompletedLabel.numberOfLines = 0
        numberOfMemberCompletedLabel.lineBreakMode = .byWordWrapping
    }

    func configure(with challenge: ChallengeCompleted) {
        descriptionLabel.text = challenge.challenges.challengeDescription
        numberOfMemberCompletedLabel.text = "1/4 Completed"
        imageView.image = UIImage(named: "challenge_image")
        setProgressPercent(progress: challenge.percentageCompleted)
    }

    func setProgressPercent(progress: Double) {
        progressPercentView.layer.cornerRadius = 12
        
        if progress == 100 {
            progressPercentView.backgroundColor = UIColor.systemGreen
            
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .black)
            if let symbolImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfiguration) {
                
                // 2. Create the attachment
                let attachment = NSTextAttachment()
                attachment.image = symbolImage
                
                // 3. Create the attributed string
                let attachmentString = NSAttributedString(attachment: attachment)
                
                // 4. Assign it to your label
                progressPercentValue.attributedText = attachmentString
            }
            return
        }
        
        progressPercentValue.text = "\(progress)%"
    }
    
}
