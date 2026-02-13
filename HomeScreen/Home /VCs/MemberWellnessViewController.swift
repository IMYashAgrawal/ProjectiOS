import UIKit

class MemberWellnessViewController: UIViewController {
    var profile: Profile?

    @IBOutlet weak var collectionView: UICollectionView!

    private var wellnessCards: [WellnessCard] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let profile else { return }

        view.backgroundColor = .systemGray6


        let name = profile.nickName ?? profile.firstName
        title = "\(name)’s Wellness"
        
        addBackButton() //added by kushaad, to make the view dismiss
        
        setupCollectionView()
        loadWellnessData()
    }

    private func addBackButton() {
        //make the button using code
        let backButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(backButtonTapped)
            )
        backButton.tintColor = .label
        self.navigationItem.leftBarButtonItem = backButton

    }
    
    @objc func backButtonTapped() {
        // 4. Dismiss the current view controller
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func loadWellnessData() {
        guard let profile else { return }

        wellnessCards =
            WellnessDataProvider.getWellnessCards(for: profile)

        collectionView.reloadData()
    }

    private func calculateActivityRingData(
        from profile: Profile
    ) -> MiniActivityRingsView.RingData {

        let caloriesGoal = profile.caloriesGoal

        let caloriesBurned =
            profile.activityDaily
                .first(where: {
                    $0.activityType == .caloriesBurned
                })?.value ?? 0

        let moveProgress =
            CGFloat(caloriesBurned) /
            CGFloat(max(caloriesGoal, 1))

        let todaySteps =
            profile.activityDaily
                .first(where: {
                    $0.activityType == .stepCount
                })?.value ?? 0

        let activeMinutes = todaySteps / 100
        let exerciseGoal = 30

        let exerciseProgress =
            CGFloat(activeMinutes) /
            CGFloat(exerciseGoal)

        return MiniActivityRingsView.RingData(
            moveProgress: moveProgress,
            exerciseProgress: exerciseProgress,
            moveValue: caloriesBurned,
            moveGoal: caloriesGoal,
            exerciseValue: activeMinutes,
            exerciseGoal: exerciseGoal
        )
    }

    private func setupCollectionView() {

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(
            UINib(nibName: "WellnessCardCell", bundle: nil),
            forCellWithReuseIdentifier: "wellness_cell"
        )

        collectionView.register(
            UINib(nibName: "WellnessChartCell", bundle: nil),
            forCellWithReuseIdentifier: "wellness_chart_cell"
        )

        collectionView.setCollectionViewLayout(
            generateLayout(),
            animated: false
        )
    }

    private func generateLayout()
    -> UICollectionViewLayout {

        let itemSize =
            NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(180)
            )

        let item =
            NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets =
            .init(top: 0, leading: 6,
                  bottom: 0, trailing: 6)

        let group =
            NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(180)
                ),
                subitems: [item]
            )

        let section =
            NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = 12

        section.contentInsets =
            .init(top: 16,
                  leading: 16,
                  bottom: 20,
                  trailing: 16)

        return UICollectionViewCompositionalLayout(
            section: section
        )
    }
}

extension MemberWellnessViewController:
UICollectionViewDataSource,
UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return wellnessCards.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let profile else {
            return UICollectionViewCell()
        }

        let card = wellnessCards[indexPath.item]


        if card.type == .activityRings {

            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "wellness_cell",
                    for: indexPath
                ) as! WellnessCardCell

            let ringData =
                calculateActivityRingData(from: profile)

            cell.configure(
                with: card,
                ringData: ringData
            )

            return cell
        }


        if card.type == .heartRate ||
           card.type == .sleep {

            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "wellness_cell",
                    for: indexPath
                ) as! WellnessCardCell

            cell.configure(with: card)
            return cell
        }

        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "wellness_chart_cell",
                for: indexPath
            ) as! WellnessChartCell

        cell.configure(with: card)
        return cell
    }
}
