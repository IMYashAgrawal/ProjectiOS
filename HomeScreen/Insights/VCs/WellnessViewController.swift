//
//  WellnessViewController.swift
//  HomeScreen
//
//  Created by GEU on 09/02/26.
//

import UIKit

class WellnessViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var currentUser: Profile?
    private var expandedIndices: Set<Int> = []
    private let insightTypes: [InsightType] = [.steps, .sleep, .calories, .heartRate, .hrv, .spo2, .respiratoryRate]
 

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Wellness"
        currentUser = DataManager.shared.currentUser
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }

    private func setupCollectionView() {
        // Register wellness header
        collectionView.register(
            UINib(nibName: "WellnessHeaderCell", bundle: nil),
            forCellWithReuseIdentifier: "WellnessHeaderCell"
        )
        
        // Register detail insight header
        collectionView.register(
            UINib(nibName: "DetailInsightHeaderCell", bundle: nil),
            forCellWithReuseIdentifier: "DetailInsightHeaderCell"
        )
        
        // Register detail insight content
        collectionView.register(
            UINib(nibName: "DetailInsightContentCell", bundle: nil),
            forCellWithReuseIdentifier: "DetailInsightContentCell"
        )

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
    }
}

// MARK: - UICollectionViewDataSource

extension WellnessViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 1 wellness header + insight headers + expanded content cells
        var count = 1
        for i in 0..<insightTypes.count {
            count += 1 // header
            if expandedIndices.contains(i) {
                count += 1 // content
            }
        }
        return count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let user = currentUser else {
            return UICollectionViewCell()
        }
        
        // First cell is always wellness header
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "WellnessHeaderCell",
                for: indexPath
            ) as! WellnessHeaderCell
            cell.configure(with: user)
            return cell
        }
        
        // Map indexPath to insight index and determine if it's header or content
        var currentIndex = 1
        var insightIndex = 0
        var isContent = false
        
        for i in 0..<insightTypes.count {
            // Check if this is the header
            if currentIndex == indexPath.item {
                insightIndex = i
                isContent = false
                break
            }
            currentIndex += 1
            
            // Check if this insight is expanded and if this is the content cell
            if expandedIndices.contains(i) {
                if currentIndex == indexPath.item {
                    insightIndex = i
                    isContent = true
                    break
                }
                currentIndex += 1
            }
        }
        
        if isContent {
            // Return content cell
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DetailInsightContentCell",
                for: indexPath
            ) as! DetailInsightContentCell
            cell.configure(with: insightTypes[insightIndex], profile: user)
            return cell
        } else {
            // Return header cell
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DetailInsightHeaderCell",
                for: indexPath
            ) as! DetailInsightHeaderCell
            
            let isExpanded = expandedIndices.contains(insightIndex)
            cell.configure(with: insightTypes[insightIndex], profile: user, index: insightIndex, isExpanded: isExpanded)
            cell.delegate = self
            return cell
        }
    }
}

extension WellnessViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width

        if indexPath.item == 0 {
            return CGSize(width: width, height: 220)
        }

        var currentIndex = 1
        var isContent = false

        for i in 0..<insightTypes.count {

            if currentIndex == indexPath.item {
                isContent = false
                break
            }

            currentIndex += 1

            if expandedIndices.contains(i) {
                if currentIndex == indexPath.item {
                    isContent = true
                    break
                }
                currentIndex += 1
            }
        }

        // ✅ Chart full width (same as header)
        if isContent {
            return CGSize(width: width - 32, height: 300)
        }

        return CGSize(width: width - 32, height: 70)
    }
}

// MARK: - DetailInsightHeaderCellDelegate

extension WellnessViewController: DetailInsightHeaderCellDelegate {
    func didTapHeader(at index: Int) {
        let wasExpanded = expandedIndices.contains(index)
        
        // Calculate index paths that need to be inserted or deleted
        var indexPathsToModify: [IndexPath] = []
        var currentItem = 1
        
        // Find the position of the content cell for this index
        for i in 0..<insightTypes.count {
            currentItem += 1 // header
            
            if i == index {
                // This is the tapped section
                let contentIndexPath = IndexPath(item: currentItem, section: 0)
                indexPathsToModify.append(contentIndexPath)
                break
            }
            
            if expandedIndices.contains(i) {
                currentItem += 1 // content
            }
        }
        
        // Update the expanded state
        if wasExpanded {
            expandedIndices.remove(index)
        } else {
            expandedIndices.insert(index)
        }
        
        // Perform batch updates
        collectionView.performBatchUpdates({
            if wasExpanded {
                // Collapse - delete content cell
                collectionView.deleteItems(at: indexPathsToModify)
            } else {
                // Expand - insert content cell
                collectionView.insertItems(at: indexPathsToModify)
            }
            
            // Reload the header to update chevron animation
            if let headerIndexPath = indexPathsToModify.first {
                let headerIndex = IndexPath(item: headerIndexPath.item - 1, section: 0)
                collectionView.reloadItems(at: [headerIndex])
            }
        }, completion: nil)
    }
}
