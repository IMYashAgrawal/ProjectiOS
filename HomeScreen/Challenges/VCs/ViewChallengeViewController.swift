//
//  ViewChallengeViewController.swift
//  HealthSharing
//
//  Created by Mohd Kushaad on 08/02/26.
//

import UIKit

class ViewChallengeViewController: UIViewController {

    var challenge: ChallengeCompleted!
    var familyMembers: [Profile]!
    
    @IBOutlet weak var memberProgressCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = challenge.challenges.challengeName
        
        guard let _ = challenge,
              let _ = familyMembers else {
                    print("didnt receive challenge or family members in ViewChallengeViewController"); return }
        
        let currentUser = DataManager.shared.currentUser
        familyMembers.append(currentUser!)
        
        //registering cells
        registerCell(ofKind: "MemberProgressCollectionViewCell", with: "member_progress_cell")
        registerCell(ofKind: "ChallengeDetailCollectionViewCell", with: "first_cell")
        
        //registering title for sections
        memberProgressCV.register(UICollectionReusableView.self,
                                  forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: "header")
        
        memberProgressCV.collectionViewLayout = generateLayout()
        
        memberProgressCV.dataSource = self
    }
    
    // MARK: - My code
    
    func registerCell(ofKind cell: String, with identifier: String) {
        memberProgressCV.register(UINib(nibName: cell, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
                
            if sectionIndex == 0 {
                // top section
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(400))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
                return section
                
            } else {
                // member progress cells
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                // Create the size for the header
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))                // Create the supplementary item (the header)
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                // Add it to the section
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16)
                
                return section
            }
        }
//        //first thing is to create the size of the item
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//        //create the item and give the size
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
////        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 10)
//        
//        //creating group size and group
//        let grpSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grpSize, repeatingSubitem: item, count: 1)
//        //adding spacing between item, since we are having multiple items
////        group.interItemSpacing = .fixed(10)
//        
//        
//        
//        //creating section
//        let section = NSCollectionLayoutSection(group: group)
////        creating space between sections and groups
//        section.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16)
//        //creating space between cards
//        section.interGroupSpacing = 2
//        
//        //creating layout
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        
//        return layout
    }
    
}

extension ViewChallengeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return familyMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            //first_cell for section 0
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "first_cell", for: indexPath) as! ChallengeDetailCollectionViewCell
            cell.configure(with: challenge)
            return cell
        } else {
            //member_progress_cel for section 1
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "member_progress_cell", for: indexPath) as! MemberProgressCollectionViewCell
            
            let member = familyMembers[indexPath.row]

            let progress = challenge.memberProgress[String(indexPath.row + 1)] ?? 0.0
            
            cell.configureCell(profile: member, progress: progress, challenge: challenge)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        
        // Only add the label if it's not already there (prevents duplicates when scrolling)
        if header.subviews.isEmpty {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height))
            label.text = "Member Progress"
            label.font = .systemFont(ofSize: 18, weight: .bold)
            label.textColor = .label
            header.addSubview(label)
        }
        
        return header
    }
}
