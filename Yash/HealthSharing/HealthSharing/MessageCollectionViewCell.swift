//
//  MessageCollectionViewCell.swift
//  HealthSharing
//
//  Created by GEU on 02/02/26.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {
    
    let dataManager = DataManager.shared

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func configure(with message: Message, currentUserId: Int?) {

        guard let currentUserId = currentUserId else { return }

        let otherUserId = message.senderId == currentUserId ? message.receiverId : message.senderId

        nameLabel.text = displayName(for: otherUserId)
        lastMessageLabel.text = message.message
        timeLabel.text = formatTime(message.timestampUTC)
        imageView.image = profileImage(for: otherUserId)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
    
    func displayName(for userId: Int) -> String {
        //Check other family members
        if let profile = dataManager.allProfiles.first(where: { $0.profileId == userId }) {
            return profile.nickName ?? profile.firstName
        }

        //Edge case: current user
        if let user = dataManager.currentUser, user.profileId == userId {
            return user.nickName ?? user.firstName
        }

        //Fallback
        return "User \(userId)"
    }

    func profileImage(for userId: Int) -> UIImage {
        //Other family members
        if let profile = dataManager.allProfiles.first(where: { $0.profileId == userId }) {
            if let image = UIImage(named: profile.profilePic) {
                return image
            }
        }

        //Current user (edge case)
        if let user = dataManager.currentUser, user.profileId == userId {
            if let image = UIImage(named: user.profilePic) {
                return image
            }
        }

        //Fallback image (IMPORTANT)
        return UIImage(systemName: "person.fill")!
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.width / 2
    }


}
