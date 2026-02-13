//mock_data.json
//      ↓
//DataManager loads JSON
//      ↓
//SceneDelegate calls DataManager
//      ↓
//SceneDelegate injects data into HomeViewController
//      ↓
//HomeViewController uses data

import UIKit
import DGCharts

class HomeViewController: UIViewController {

    //
    var currentUser: Profile?
    var family: Family?
    var otherProfiles: [Profile] = []
    var messages: [Message] = []

    // MARK: - UI
    @IBOutlet weak var homeCollectionView: UICollectionView!

    // MARK: - Calendar
    private var dates: [Date] = []
    private var selectedDate = Date()
    private let calendar = Calendar.current
    private var didScrollToToday = false

    // MARK: - Derived Data
    private var wellnessCards: [WellnessCard] = []
    private var familyMembers: [Profile] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileButton()
        setupCollectionView()
        generateDates()
        buildFamilyMembers()
        loadWellnessData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didScrollToToday {
            scrollToToday()
            didScrollToToday = true
        }
    }
    
    private func setupProfileButton() {
        guard let user = currentUser else { return }

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImage(named: user.profilePic)
        button.setImage(image, for: .normal)

        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.layer.cornerRadius = 18

        button.addTarget(self,
                         action: #selector(profileTapped),
                         for: .touchUpInside)

        containerView.addSubview(button)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 36),
            button.heightAnchor.constraint(equalToConstant: 36),
            button.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            containerView.widthAnchor.constraint(equalToConstant: 36),
            containerView.heightAnchor.constraint(equalToConstant: 36)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: containerView)
    }

    @objc private func profileTapped() {
    performSegue(withIdentifier: "home_to_profile_", sender: self)
    }
  

    
    // MARK: - Open Member Wellness
    func openMemberWellness(profile: Profile) {
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "MemberWellnessVC"
        ) as? MemberWellnessViewController else { return }

        vc.profile = profile
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    // MARK: - Data Builders
    private func buildFamilyMembers() {
        guard let currentUser else { return }
        familyMembers = otherProfiles + [currentUser]
    }

    private func loadWellnessData() {
        guard let currentUser else { return }
        wellnessCards = WellnessDataProvider.getWellnessCards(for: currentUser)
    }

    // MARK: - CollectionView Setup
    private func setupCollectionView() {
        let nibs: [String: String] = [
            "CalendarCollectionViewCell": "calendar_cell",
            "FamilyActivityScoreCollectionViewCell": "family_cell",
            "ChallengesCollectionViewCell": "challenge_cell",
            "WellnessCardCell": "wellness_cell",
            "WellnessChartCell": "wellness_chart_cell"
        ]

        nibs.forEach { name, id in
            homeCollectionView.register(UINib(nibName: name, bundle: nil),
                                        forCellWithReuseIdentifier: id)
        }

        homeCollectionView.register(
            UINib(nibName: "SectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header_view"
        )

        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        homeCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }

    // MARK: - Layouts
    private func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { section, _ in
            switch section {
            case 0: return self.createCalendarSection()
            case 1: return self.createFamilyScoreSection()
            case 2: return self.createChallengesSection()
            case 3: return self.createWellnessSection()
            default: return self.createCalendarSection()
            }
        }
    }

    private func createCalendarSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0 / 7.0),
                heightDimension: .absolute(80)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80)),
            subitem: item,
            count: 7
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = .init(top: 10, leading: 16, bottom: 20, trailing: 16)
        section.interGroupSpacing = 0
        return section
    }

    private func createFamilyScoreSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .fractionalHeight(1.0))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(350)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 20, trailing: 16)
        section.boundarySupplementaryItems = [createHeader()]
        return section
    }

    private func createChallengesSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .fractionalHeight(1.0))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 20, trailing: 16)
        section.boundarySupplementaryItems = [createHeader()]
        return section
    }

    private func createWellnessSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(180)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 6, bottom: 0, trailing: 6)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(180)),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 0, leading: 16, bottom: 20, trailing: 16)
        section.boundarySupplementaryItems = [createHeader()]
        return section
    }

    private func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }

    // MARK: - Calendar Dates
    private func generateDates() {
        let today = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -30, to: today),
              let endDate = calendar.date(byAdding: .day, value: 6 - calendar.component(.weekday, from: today), to: today) else { return }

        var tempDates: [Date] = []
        var current = startDate
        while current <= endDate {
            tempDates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        dates = tempDates
    }

    private func scrollToToday() {
        guard let todayIndex = dates.firstIndex(where: calendar.isDateInToday) else { return }
        let indexPath = IndexPath(item: todayIndex, section: 0)
        DispatchQueue.main.async { [weak self] in
            self?.homeCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self?.selectedDate = self?.dates[todayIndex] ?? Date()
            self?.homeCollectionView.reloadItems(at: [indexPath])
        }
    }

    // MARK: - Activity Ring Data
    private func calculateActivityRingData(from profile: Profile) -> MiniActivityRingsView.RingData {
        let caloriesBurned = profile.activityDaily.first(where: { $0.activityType == .caloriesBurned })?.value ?? 0
        let moveProgress = CGFloat(caloriesBurned) / CGFloat(max(profile.caloriesGoal, 1))

        let todaySteps = profile.activityDaily.first(where: { $0.activityType == .stepCount })?.value ?? 0
        let activeMinutes = todaySteps / 100
        let exerciseProgress = CGFloat(activeMinutes) / 30.0

        return MiniActivityRingsView.RingData(
            moveProgress: moveProgress,
            exerciseProgress: exerciseProgress,
            moveValue: caloriesBurned,
            moveGoal: profile.caloriesGoal,
            exerciseValue: activeMinutes,
            exerciseGoal: 30
        )
    }

    private func wellnessCell(for card: WellnessCard, indexPath: IndexPath) -> UICollectionViewCell {
        if [.activityRings, .heartRate, .sleep].contains(card.type) {
            let cell = homeCollectionView.dequeueReusableCell(withReuseIdentifier: "wellness_cell", for: indexPath) as! WellnessCardCell
            if card.type == .activityRings, let currentUser {
                cell.configure(with: card, ringData: calculateActivityRingData(from: currentUser))
            } else { cell.configure(with: card) }
            return cell
        } else {
            let cell = homeCollectionView.dequeueReusableCell(withReuseIdentifier: "wellness_chart_cell", for: indexPath) as! WellnessChartCell
            cell.configure(with: card)
            return cell
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "home_to_profile_" {
            
            //            // destination is a nav controller, top is ProfileMainTableViewController
            if let navVC = segue.destination as? UINavigationController,
               let destinationVC = navVC.topViewController as? ProfileMainTableViewController {
                destinationVC.currentUser = currentUser
                destinationVC.family = family
                destinationVC.familyMembers = familyMembers
                print("number of memebers inside home vc: \(familyMembers.count)")
                print("home vc to profilevc thru nav")
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 4 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return dates.count
        case 3: return wellnessCards.count
        default: return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalendarCollectionViewCell
            let date = dates[indexPath.item]
            cell.configure(with: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate), isToday: calendar.isDateInToday(date))
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "family_cell", for: indexPath) as! FamilyActivityScoreCollectionViewCell
            cell.configure(members: familyMembers)
            cell.delegate = self
            return cell

        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "challenge_cell", for: indexPath) as! ChallengesCollectionViewCell
            if let challenge = family?.challenge.first { cell.configure(with: challenge, familyMembers: familyMembers) }
            return cell

        case 3:
            return wellnessCell(for: wellnessCards[indexPath.item], indexPath: indexPath)

        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header_view", for: indexPath) as! SectionHeaderView
        let titles = ["", "Family Wellness Score", "Challenge of the day", "My Wellness"]
        header.configure(withTitle: titles[indexPath.section])
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        let previousDate = selectedDate
        selectedDate = dates[indexPath.item]
        var reload = [indexPath]
        if let prev = dates.firstIndex(where: { calendar.isDate($0, inSameDayAs: previousDate) }) {
            reload.append(IndexPath(item: prev, section: 0))
        }
        collectionView.reloadItems(at: reload)
    }
}

// MARK: - FamilyMemberTapDelegate
extension HomeViewController: FamilyMemberTapDelegate {
    func didTapMember(_ profile: Profile) {
        guard profile.profileId != currentUser?.profileId else { return }
        openMemberWellness(profile: profile)
    }
}

