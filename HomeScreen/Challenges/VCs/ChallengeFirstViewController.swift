//
//  ChallengeFirstViewController.swift
//  HealthSharing
//
//  Created by Mohd Kushaad on 07/02/26.
//

import UIKit

class ChallengeFirstViewController: UIViewController {
    
    var challenges: [ChallengeCompleted]?
    var familyMembers: [Profile]?
    var filteredChallenges: [ChallengeCompleted] = []
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var challengeCV: UICollectionView!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
//        title = "Challenges"
        
        //registering the cell
        challengeCV.register(UINib(nibName: "ChallengeCollectionViewCell", bundle: nil),
                             forCellWithReuseIdentifier: "challenge_cell")
        
        //dividing challenges into ongoing and past
        divideChallenges()
        
        let layout = generateLayout()
        challengeCV.collectionViewLayout = layout
        
        challengeCV.dataSource = self
        challengeCV.delegate = self
    }
    
    // MARK: - My code
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        segmentControl.selectedSegmentIndex = 0
        divideChallenges()
        
        //also if the challenge is added, i need to update the struct 'challenges' here
        //to reflect back the changes
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        print("segment called/changed")
        divideChallenges()
    }
    
    func divideChallenges() {
        guard let allChallenges = challenges else {
            print("didnt receive any value for challenges in ChallengeFirst vc")
            return
        }
        
        //assign values to each ongoing and past
        if segmentControl.selectedSegmentIndex == 0 {
            filteredChallenges = allChallenges.filter{ $0.percentageCompleted < 100}
            print("challenges under ongoing: \(filteredChallenges.count)")
        } else {
            filteredChallenges = allChallenges.filter{ $0.percentageCompleted == 100}
            print("challenges under past: \(filteredChallenges.count)")
        }
        
        challengeCV.reloadData()
    }
    
    func generateLayout() -> UICollectionViewLayout {
        //first thing is to create the size of the item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        //create the item and give the size
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 10)
        
        //creating group size and group
        let grpSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grpSize, repeatingSubitem: item, count: 1)
        //adding spacing between item, since we are having multiple items
//        group.interItemSpacing = .fixed(10)
        
        
        
        //creating section
        let section = NSCollectionLayoutSection(group: group)
//        creating space between sections and groups
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        //creating space between cards
        section.interGroupSpacing = 10
        
        
        //creating layout
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "open_challenge_details" {
            guard let destinationVC = segue.destination as? ViewChallengeViewController,
                  let indexPath = challengeCV.indexPathsForSelectedItems?.first else {
                return
            }
            
            let challenge = filteredChallenges[indexPath.row]
            destinationVC.challenge = challenge
            destinationVC.familyMembers = familyMembers
            
        } else if segue.identifier == "add_challenge" {
            guard let navVC = segue.destination as? UINavigationController,
                  let destVC = navVC.topViewController as? AddChallengeTableViewController else { return }
            
            destVC.challenges = self.challenges ?? []
            
        }
    }

}


extension ChallengeFirstViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredChallenges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "challenge_cell", for: indexPath) as! ChallengeCollectionViewCell
        
        cell.configureCell(challenge: filteredChallenges[indexPath.row])
        
        cell.layer.cornerRadius = 12
        
        return cell
        
    }
}

extension ChallengeFirstViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "open_challenge_details", sender: nil)
    }
}
