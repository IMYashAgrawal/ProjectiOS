//
//  ViewController 2.swift
//  Insight
//
//  Created by Mohd Kushaad on 12/02/26.
//

import UIKit
class InsightFirstViewController: UIViewController {

    let data: [
        (
            name: String,
            scoreWeekly: [Int],
            scoreMonthly: [Int],
            colors: [UIColor],
            comparison: String
        )
    ] = [
        (
            name: memberWiseScore[0].profile,
            scoreWeekly: memberWiseScore[0].scoreWeekly,
            scoreMonthly: memberWiseScore[0].scoreMonthly,
            colors:[.systemOrange,.systemYellow,.systemGreen,.systemGreen,.systemGray,.systemGray,.systemGray],
            comparison: "20% better vs last Week"
        ),
        (
            name: memberWiseScore[1].profile,
            scoreWeekly: memberWiseScore[1].scoreWeekly,
            scoreMonthly: memberWiseScore[1].scoreMonthly,
            colors:[.systemOrange,.systemYellow,.systemGreen,.systemGreen,.systemGray,.systemGray,.systemGray],
            comparison: "10% better vs last Week"
        ),
        (
            name: memberWiseScore[2].profile,
            scoreWeekly: memberWiseScore[2].scoreWeekly,
            scoreMonthly: memberWiseScore[2].scoreMonthly,
            colors:[.systemOrange,.systemYellow,.systemGreen,.systemGreen,.systemGray,.systemGray,.systemGray],
            comparison: "5% lower vs last Week"
        ),
        (
            name: memberWiseScore[3].profile,
            scoreWeekly: memberWiseScore[3].scoreWeekly,
            scoreMonthly: memberWiseScore[3].scoreMonthly,
            colors:[.systemOrange,.systemYellow,.systemGreen,.systemGreen,.systemGray,.systemGray,.systemGray],
            comparison: "6% better vs last Week"
        ),
        (
            name: memberWiseScore[4].profile,
            scoreWeekly: memberWiseScore[4].scoreWeekly,
            scoreMonthly: memberWiseScore[4].scoreMonthly,
            colors:[.systemOrange,.systemYellow,.systemGreen,.systemGreen,.systemGray,.systemGray,.systemGray],
            comparison: "6% lower vs last Week"
        )
    ]
    private var isWeek = true

    @IBOutlet weak var graphCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        graphCollectionView.register(UINib(nibName: "GraphCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "graph_view_cell")
        //registering header
        graphCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header_view")
        
        // Set background to a light gray to make the white cards "pop"
        graphCollectionView.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        
        let layout = generateLayout()
        
        graphCollectionView.collectionViewLayout = layout
        
        graphCollectionView.dataSource = self
        graphCollectionView.delegate = self
    }
    
    func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            //definign item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // adding grrp
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(260)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            //adding section
            let section = NSCollectionLayoutSection(group: group)
            
            //adding section header for each card
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [headerItem]
            
            //adding paddings
            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 16, bottom: 20, trailing: 16)
            section.interGroupSpacing = 10 // Spacing between the cards
            
            return section
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailed_insight" {
            guard let destinationVC = segue.destination as? WellnessViewController,
                  let indexPath = sender as? IndexPath else {
                return
            }
            
            let selectedMemberName = data[indexPath.section].name
            
            // Create a combined array of all profiles (current user + all other members)
            var allFamilyMembers: [Profile] = []
            
            if let currentUser = DataManager.shared.currentUser {
                allFamilyMembers.append(currentUser)
            }
            allFamilyMembers.append(contentsOf: DataManager.shared.allProfiles)
            
            // Find the corresponding profile by matching name
            if let selectedProfile = allFamilyMembers.first(where: {
                // Match by nickname first, then firstName, or combination of firstName + lastName
                ($0.nickName == selectedMemberName) ||
                ($0.firstName == selectedMemberName) ||
                ("\($0.firstName) \($0.lastName)" == selectedMemberName)
            }) {
                destinationVC.currentUser = selectedProfile
                destinationVC.title = selectedMemberName
            }
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isWeek = true
        } else {
            isWeek = false
        }
        graphCollectionView.reloadData()
    }
    
}

extension InsightFirstViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        data.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graph_view_cell", for: indexPath) as! GraphCollectionViewCell
            
        let data = data[indexPath.section]
       
        //passing weekly data if segment contorl = 0
        if isWeek {
            cell.configureCell(score: data.scoreWeekly, comparison: data.comparison, isWeek: true)
        } else {
            //passing monthly data if segment control = 1
            cell.configureCell(score: data.scoreMonthly, comparison: data.comparison, isWeek: false)
        }
        
        cell.layer.cornerRadius = 12
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header_view", for: indexPath)
            
            // Remove old labels if reusing
            header.subviews.forEach { $0.removeFromSuperview() }
            
            // Create and style the label
            let label = UILabel()
            label.text = data[indexPath.section].name // Your profile name
            label.font = .systemFont(ofSize: 25, weight: .semibold)
            label.textColor = .label
            label.frame = CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height)
            
            header.addSubview(label)
            return header
        }
        
        return UICollectionReusableView()
    }
    
}

extension InsightFirstViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailed_insight", sender: indexPath)
    }
}
