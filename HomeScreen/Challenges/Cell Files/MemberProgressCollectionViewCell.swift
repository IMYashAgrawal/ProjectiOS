//
//  MemberProgressCollectionViewCell.swift
//  HealthSharing
//
//  Created by Mohd Kushaad on 08/02/26.
//

import UIKit

class MemberProgressCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var progressPercentLabel: UILabel!
    @IBOutlet weak var progressPercentView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressNumbersLabel: UILabel!
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var memberImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func checking(profile: Profile, progress: Double) {
        print("Cell created for name: \(profile.firstName)--progress: \(progress)")
    }
    
    func configureCell(profile: Profile, progress: Double, challenge: ChallengeCompleted)  {
        //checkign the data
        checking(profile: profile, progress: progress)
        memberImage.image = UIImage(named: profile.profilePic); setImageToRound(progress: progress)
        
        memberName.text = profile.nickName
        progressNumbersLabel.text = setProgressNumber(progress: progress, id: challenge.challenges.challengeId) //this will be fetched from real time data
        
        progressBar.progress = Float(progress) / 100.0;
        if ( progress == 100 ) {
            progressBar.progressTintColor = UIColor.systemGreen
        }
        
        setProgressPercent(progress: progress)
    }
    
    func setImageToRound(progress: Double) {
        memberImage.layer.cornerRadius = 32
        memberImage.clipsToBounds = true
        memberImage.layer.borderWidth = 1
        if ( progress == 100 ) {
            memberImage.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            memberImage.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    
    func setProgressPercent(progress: Double) {
        progressPercentView.layer.cornerRadius = 12
        
        if progress == 100 {
            progressPercentView.backgroundColor = UIColor.systemGreen
            
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            if let symbolImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfiguration) {
                
                // 2. Create the attachment
                let attachment = NSTextAttachment()
                attachment.image = symbolImage
                
                // 3. Create the attributed string
                let attachmentString = NSAttributedString(attachment: attachment)
                
                // 4. Assign it to your label
                progressPercentLabel.attributedText = attachmentString
            }
            return
        }
        
        progressPercentLabel.text = "\(progress)%"
    }
    
    func setProgressNumber(progress: Double, id: Int) -> String {
        var final = ""
        
        switch id{
        case 1: print("10k steps")
            if progress < 100 {
                let completed = (progress/100)*10000
                final = "\(Int(completed))/10000 Steps"
            } else {
                final = "Completed!"
            }
        case 2: print("7h Sleep Challenge")
            if progress < 100{
                let completed = (progress/100)*7
                final = "\(Int(completed))/7 hrs Slept"
            } else {
                final = "Completed!"
            }
        case 3: print("15 hrs of Exercise in a Week")
            if progress < 100{
                let completed = (progress/100)*10000
                final = "\(Int(completed))/15 hrs Exercised"
            } else {
                final = "Completed!"
            }
        case 4: print("Saturday Movie Night")
            if progress == 100 {
                final = "Completed"
            } else {
                final = "Not Completed"
            }
        default: print("No ID")
        }
        
        return final
    }
    
}

