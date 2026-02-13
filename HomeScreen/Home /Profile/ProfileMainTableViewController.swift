//
//  EditProfileMainViewController.swift
//  HealthSharing
//
//  Created by Mohd Kushaad on 06/02/26.
//

import UIKit

class ProfileMainTableViewController: UITableViewController {

    var rowPerSection = [1,2,2,3,4]
    
    var currentUser: Profile!
    var family: Family!
    var familyMembers: [Profile]!
    
    @IBOutlet weak var userNameTextLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        guard var currentUser = currentUser else {
            print("data not received from home to profile")
            return
        }
        configureCell()
        
        tableView.delegate = self
    }
    
    // MARK: - My Functions
    
    func configureCell() {
        profilePicture.image = UIImage(named: "\(currentUser.profilePic)")
        userNameTextLabel.text = "\(currentUser.firstName)"
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 2
        profilePicture.layer.borderColor = UIColor.white.cgColor
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //opening editting profile screen
        print("segue called: \(segue.identifier ?? "....")")
        if segue.identifier == "edit_profile_cell_to_edit_profile_screen" ||
            segue.identifier == "top_cell_to_edit_profile_screen" {
            
            if let destVC = segue.destination as? EditProfileTableViewController {
                destVC.currentUser = currentUser
                print("data sent from profile to editProfile vc")
            }
            
        }
        else if segue.identifier == "profile_main_to_family_members" {
            
            if let destVC = segue.destination as? FamilyMembersViewContoller
            {
//                destVC. = familyMembers
                destVC.familyName = family.familyName
                destVC.familyMembers = familyMembers
                print("sent data from profileMain to family vc thru navVC: \(family.familyName). No of members: \(familyMembers?.count ?? 100)")
            }
        }
    }
    

}

extension ProfileMainTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowPerSection[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return rowPerSection.count
    }
}
