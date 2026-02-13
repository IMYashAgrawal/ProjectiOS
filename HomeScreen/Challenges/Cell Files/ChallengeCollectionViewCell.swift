//
//  ChallengeCollectionViewCell.swift
//  HealthSharing
//
//  Created by Mohd Kushaad on 08/02/26.
//

import UIKit

class ChallengeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var challengeProgressView: UIProgressView!
//    @IBOutlet weak var completionLabel: UILabel!
    @IBOutlet weak var challengeNameLabel: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(challenge: ChallengeCompleted) {
        
        print("challenge selected: \(challenge.challenges.challengeName)")
        print("progress of this challenge: \(challenge.percentageCompleted)")
        //code is for before adding challenge lists
        challengeNameLabel.text = challenge.challenges.challengeName
        challengeProgressView.progress = Float(challenge.percentageCompleted) / 100.0
//        if challenge.percentageCompleted == 100 {
//            completionLabel.text = "Completed!"
//        } else {
////            completionLabel.text = "Incomplete"
//        }
        bgImage.image = UIImage(named: "challenge_image")
    }
    
}
