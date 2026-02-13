//
//  EditProfileTableViewController.swift
//  HealthSharing
//
//  Created by Mohd Kushaad on 27/01/26.
//

import UIKit

class EditProfileTableViewController: UITableViewController {

    
    var currentUser: Profile!
    var currentName: String!
    
    
    @IBOutlet weak var nameLabelSection0: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dobValue: UILabel!
    @IBOutlet weak var heightValue: UILabel!
    @IBOutlet weak var weightValue: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if currentUser != nil  {
            print("data loaded from ProfileMain in editProfile vc")
        } else {  print("data not loaded in editProfile vc"); return }
        
        configureProfileCell()
        
//        populateUserDataInTheView()
        
        
    }

    // MARK: - My functions
    
    //here prepare function works as a messenger, which tells this vc to reload screen
    //which then automatically calls viewWillAppear(), which reloads new data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if weight is called
        if segue.identifier == "toEditWeight" {
            // casting to nav controller first
            if let navVC = segue.destination as? UINavigationController,
               let destVC = navVC.viewControllers.first as? EditWeightViewController {
                
                destVC.onSave = { [weak self] in
                    self?.refreshProfileData() //if save is pressed then this is called
                }
            }
        } else if segue.identifier == "toEditHeight" {
            if let navVC = segue.destination as? UINavigationController,
               let destVC = navVC.viewControllers.first as? EditHeightViewController {
                
                destVC.onSave = { [weak self] in
                    self?.refreshProfileData()
                }
            }
        } else if segue.identifier == "toEditDOB" {
            if let navVC = segue.destination as? UINavigationController,
               let destVC = navVC.viewControllers.first as? EditDOBViewController {
                destVC.onSave = { [weak self] in
                    self?.refreshProfileData()
                }
            }
        }
    }
    
    //used to reload new data when save is tapped in weight/height/dob picker
    private func refreshProfileData() {
        // Force the table to reload with the new data from DataManager
        print("DEBUG: Refreshing profile data now.")
        DispatchQueue.main.async {
            
            self.currentUser = DataManager.shared.currentUser //update data
            self.populateUserDataInTheView() //load the updated data
            self.tableView.beginUpdates()
//            self.tableView.reloadData() //reload vc with new data
            self.tableView.endUpdates()
            print("Data refreshed and Table reloaded")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //updating variable everytime view appears to have the latest values
        refreshProfileData()
        configureProfileCell()
    }
    
    func populateUserDataInTheView() {
        
        nameLabelSection0.text = "\(currentUser.firstName)"
        profilePicture.image = UIImage(named: "\(currentUser.profilePic)")
        
        
        nameTextField.text = "\(currentUser.firstName)"
        heightValue.text = "\(Int(currentUser.heightCm)) cm"
        weightValue.text = "\(Int(currentUser.weightKg)) kg"
        if true == true {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            let date = formatter.string(from: currentUser.dob)
            dobValue.text = "\(date)"
        }
            
    }
    
    func configureProfileCell() {
//        profileName.text = "Admin" //change to take input from data model, later
        
        //turning hte image view into circle
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 2
        profilePicture.layer.borderColor = UIColor.white.cgColor
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowPerSection = [1,4]
        
        return rowPerSection[section]
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


}
