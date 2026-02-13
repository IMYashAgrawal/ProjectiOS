//
//  AddChallengeTableViewController.swift
//  HealthSharing
//
//  Created by Mohd Kushaad on 08/02/26.
//

import UIKit

class AddChallengeTableViewController: UITableViewController {

    var challengesNames: [String] = ["10k Steps Daily",
                                     "7h Sleep Challenge",
                                     "15 hrs of Exercise in a Week",
                                     "Saturday Movie Night"    ]
    var challengesDescription: [String] = ["Take 10,000 steps each day to improve your cardiovascular health.",
                                           "Get 7 hours of sleep each night to boost your energy levels and overall well-being.",
                                           "Engage in at least 15 hours of exercise each week to maintain a healthy lifestyle.",
                                           "Plan a fun and relaxing Saturday movie night with your family or friends."]
    var challenges: [ChallengeCompleted] = []
    var isPhysicalSelected: Bool = false //to know which challenge type is selected
    
    @IBOutlet weak var selectTypeOfChallengeButton: UIButton!
    @IBOutlet weak var selectChallengeName: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if challenges.isEmpty {
            print("didnt receive from challengefirst vc")
        } 
        
        configureChallengeTypeButton()
        configurePhysicalChallengeButton()
        
    }

    // MARK: - My code
    
    func configurePhysicalChallengeButton() {
        // 1. Map your array of strings to an array of UIActions
            let menuActions = challengesNames.map { name in
                return UIAction(title: name) { [weak self] action in
                    // Handle the selection here
                    self?.handleChallengeSelection(name: action.title)
                }
            }

            // 2. Create the menu
        let menu = UIMenu(title: "Select Challenge", children: menuActions)
            
            // 3. Attach to button
            selectChallengeName.menu = menu
            selectChallengeName.showsMenuAsPrimaryAction = true // Makes the menu appear on the first tap
            selectChallengeName.changesSelectionAsPrimaryAction = true // Automatically updates the button title to the selected option
    }
    //used to update the local variable holding what challegne is selected
    func handleChallengeSelection(name: String) {
        print("User selected: \(name)")
        // Update your DataManager or local variables here
    }
    
    func configureChallengeTypeButton() {
        let eventAction = UIAction(title: "Event", image: UIImage(systemName: "calendar")) {
                _ in
                self.updateChallengeType(isPhysical: false)
            }
            
            let physicalAction = UIAction(title: "Physical", image: UIImage(systemName: "figure.walk")) { _ in
                self.updateChallengeType(isPhysical: true)
            }

            // 2. Create the menu
            let menu = UIMenu(title: "Select Type", children: [physicalAction, eventAction])
            
            // 3. Attach to button
            selectTypeOfChallengeButton.menu = menu
            selectTypeOfChallengeButton.showsMenuAsPrimaryAction = true // Makes the menu appear on the first tap
            selectTypeOfChallengeButton.changesSelectionAsPrimaryAction = true // Automatically updates the button title to the selected option
    }
    
    func updateChallengeType(isPhysical: Bool) {
        self.isPhysicalSelected = isPhysical
        
        selectChallengeName.isEnabled = isPhysical
        selectChallengeName.alpha = isPhysical ? 1.0 : 0.5 //making the button also look visually off
        
        tableView.beginUpdates()
//        tableView.endUpdates()
    }

//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        // Assuming Section 1 (index 1) contains the physical challenge details
//        if indexPath.section == 1 && !isPhysicalSelected {
//            return 0 // Hide if 'Event' is selected
//        }
//        return UITableView.automaticDimension
//    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let rowPerSections = [1,1]
        return 2
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
