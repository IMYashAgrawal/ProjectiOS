//
//  FamilyMembersCollectionViewCell.swift
//  HealthSharing
//
//  Created by Mohd Kushaad on 01/02/26.
//

import UIKit

class FamilyMembersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var realNameTextLabel: UILabel!
    @IBOutlet weak var nickNameTextLabel: UILabel!
    @IBOutlet weak var profilePictureImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(with member: Profile) {
        realNameTextLabel.text = member.firstName + " " + member.lastName
        nickNameTextLabel.text = member.nickName
        profilePictureImage.image = UIImage(named: "\(member.profilePic)")
        profilePictureImage.layer.cornerRadius = profilePictureImage.frame.size.width / 2
        profilePictureImage.clipsToBounds = true
        profilePictureImage.layer.borderWidth = 1
        profilePictureImage.layer.borderColor = UIColor.green.cgColor
    }

}
