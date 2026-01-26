//
//  ViewController.swift
//  HealthSharing
//
//  Created by Himadri  on 26/01/26.
//

import UIKit

// MARK: - Family Member Model
struct FamilyMember {
    let name: String
    let heartRate: String
    let sleep: String
    let steps: String
    let activity: String
    
    // Activity metrics (0.0 to 1.0)
    let moveProgress: CGFloat
    let exerciseProgress: CGFloat
    let standProgress: CGFloat
    
    // Overall progress
    var overallProgress: CGFloat {
        return (moveProgress + exerciseProgress + standProgress) / 3.0
    }
    
    // Ring color
    var ringColor: UIColor {
        if overallProgress < 0.30 {
            return UIColor(red: 0.52, green: 0.80, blue: 0.58, alpha: 1.0)  // Soft Green - Needs Care
        } else {
            return UIColor(red: 0.45, green: 0.65, blue: 0.95, alpha: 1.0)  // Blue - Healthy
        }
    }
    
    var needsCare: Bool {
        return overallProgress < 0.30
    }
}

// MARK: - Challenge Model
struct Challenge {
    let title: String
    let name: String
    let progress: CGFloat // 0.0 to 1.0
    
    var progressPercentage: String {
        return "\(Int(progress * 100))% Complete"
    }
}

class ViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let calendarStackView = UIStackView()
    let activityRingsContainer = UIView()
    let vitalsPopup = VitalsPopupView()

    var currentChallenge: Challenge = Challenge(
        title: "Challenge of the day",
        name: "Virtual Family Trek",
        progress: 0.0
    )
    
    // Start with just one member (current user)
    var familyMembers: [FamilyMember] = [
        FamilyMember(name: "You", heartRate: "72bpm", sleep: "7.5hrs", steps: "8.5K", activity: "65min", moveProgress: 0.25, exerciseProgress: 0.20, standProgress: 0.28)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupScrollView()
        setupNavigationBar()
        setupCalendarView()
        setupActivityRingsSection()
        setupChallengeSection()
        setupVitalsPopup()
    }
    
    func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.93, green: 0.95, blue: 0.99, alpha: 1.0).cgColor,
            UIColor(red: 0.97, green: 0.98, blue: 1.0, alpha: 1.0).cgColor
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80), // Space for tab bar
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    func setupNavigationBar() {

        // Enable large title
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Home"

        // Liquid glass navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = .white
        

        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        // Right profile button
        let profileButton = UIButton(type: .custom)
        profileButton.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        profileButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        profileButton.layer.cornerRadius = 18

        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        let userImage = UIImage(systemName: "person.fill", withConfiguration: config)
        profileButton.setImage(userImage, for: .normal)
        profileButton.tintColor = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0)

        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    }

        
    func setupCalendarView() {
        let calendarContainer = UIView()
        calendarContainer.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        calendarContainer.layer.cornerRadius = 16
        calendarContainer.layer.borderWidth = 1
        calendarContainer.layer.borderColor = UIColor(white: 1.0, alpha: 0.6).cgColor
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(calendarContainer)
        
        calendarStackView.axis = .horizontal
        calendarStackView.spacing = 8
        calendarStackView.distribution = .fillEqually
        calendarStackView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainer.addSubview(calendarStackView)
        
        NSLayoutConstraint.activate([
            calendarContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            calendarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            calendarContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            calendarContainer.heightAnchor.constraint(equalToConstant: 80),
            
            calendarStackView.topAnchor.constraint(equalTo: calendarContainer.topAnchor, constant: 12),
            calendarStackView.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor, constant: 12),
            calendarStackView.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor, constant: -12),
            calendarStackView.bottomAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: -12)
        ])
        
        generateCalendarDates()
    }
    
    func generateCalendarDates() {
        let calendar = Calendar.current
        let today = Date()
        
        for dayOffset in -2...2 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let dateView = createDateView(for: date, isToday: dayOffset == 0)
            calendarStackView.addArrangedSubview(dateView)
        }
    }
    
    func createDateView(for date: Date, isToday: Bool) -> UIView {
        let containerView = UIView()
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        if isToday {
            containerView.backgroundColor = UIColor(red: 0.45, green: 0.65, blue: 0.95, alpha: 0.4)
            containerView.layer.borderWidth = 1.5
            containerView.layer.borderColor = UIColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 0.6).cgColor
        } else {
            containerView.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
            containerView.layer.borderWidth = 0.5
            containerView.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        let dayName = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "d"
        let dateNumber = dateFormatter.string(from: date)
        
        let dayLabel = UILabel()
        dayLabel.text = dayName
        dayLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        dayLabel.textAlignment = .center
        dayLabel.textColor = isToday ? UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0) : UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        dateLabel.text = dateNumber
        dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        dateLabel.textAlignment = .center
        dateLabel.textColor = isToday ? UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0) : UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(dayLabel)
        containerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dayLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            
            dateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        containerView.tag = Int(date.timeIntervalSince1970)
        
        return containerView
    }
    
    // MARK: - Activity Rings Section
    func setupActivityRingsSection() {
        // Title outside the glass container
        let titleLabel = UILabel()
        titleLabel.text = "Family Activity Score"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Glass container for rings
        let container = UIView()
        container.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(white: 1.0, alpha: 0.6).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        
        // Rings container
        activityRingsContainer.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(activityRingsContainer)
        
        // "Needs Care" indicator (only if needed)
        if familyMembers[0].needsCare {
            let needsCareLabel = createNeedsCareLabel()
            needsCareLabel.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(needsCareLabel)
            
            NSLayoutConstraint.activate([
                needsCareLabel.topAnchor.constraint(equalTo: activityRingsContainer.bottomAnchor, constant: 16),
                needsCareLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor)
            ])
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: calendarStackView.superview!.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            container.heightAnchor.constraint(equalToConstant: familyMembers[0].needsCare ? 360 : 320),
            
            activityRingsContainer.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            activityRingsContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            activityRingsContainer.widthAnchor.constraint(equalToConstant: 280),
            activityRingsContainer.heightAnchor.constraint(equalToConstant: 280)
        ])
        
        drawActivityRings()
    }
    
    func createNeedsCareLabel() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.52, green: 0.80, blue: 0.58, alpha: 0.15)
        containerView.layer.cornerRadius = 12
        
        let label = UILabel()
        label.text = "Needs Care"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(red: 0.35, green: 0.65, blue: 0.45, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        return containerView
    }
    
    func drawActivityRings() {
        // Clear previous rings
        activityRingsContainer.subviews.forEach { $0.removeFromSuperview() }
        activityRingsContainer.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let center = CGPoint(x: 140, y: 140)
        
        // Draw only existing members
        for (index, member) in familyMembers.enumerated() where index < 4 {
            let radius: CGFloat = 120 - CGFloat(index * 30)
            drawMemberRing(member: member, radius: radius, center: center, index: index)
        }
    }
    
    func drawMemberRing(member: FamilyMember, radius: CGFloat, center: CGPoint, index: Int) {
        let lineWidth: CGFloat = 25
        let color = member.ringColor
        
        // Background ring
        let backgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true)
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.strokeColor = color.withAlphaComponent(0.15).cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineCap = .round
        activityRingsContainer.layer.addSublayer(backgroundLayer)
        
        // Progress ring
        let endAngle = (-.pi / 2) + (2 * .pi * member.overallProgress)
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: endAngle, clockwise: true)
        let progressLayer = CAShapeLayer()
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeColor = color.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        activityRingsContainer.layer.addSublayer(progressLayer)
        
        // Animation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        progressLayer.add(animation, forKey: "ringAnimation")
        
        // Profile button at end of progress
        let angle = endAngle
        let buttonX = center.x + radius * cos(angle) - 28
        let buttonY = center.y + radius * sin(angle) - 28
        
        let profileButton = createProfileButton(for: member, at: CGPoint(x: buttonX, y: buttonY), index: index)
        activityRingsContainer.addSubview(profileButton)
    }
    
    func createProfileButton(for member: FamilyMember, at position: CGPoint, index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: position.x, y: position.y, width: 56, height: 56)
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        button.layer.cornerRadius = 28
        button.layer.borderWidth = 3
        button.layer.borderColor = member.ringColor.cgColor
        button.layer.shadowColor = member.ringColor.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 8
        button.tag = index
        button.addTarget(self, action: #selector(memberTapped(_:)), for: .touchUpInside)
        
        // Same icon as navbar profile
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let userIcon = UIImage(systemName: "person.fill", withConfiguration: config)
        button.setImage(userIcon, for: .normal)
        button.tintColor = member.ringColor
        
        return button
    }
    
    // MARK: - Challenge Section
    func setupChallengeSection() {

        // ---- TITLE (OUTSIDE GLASS, SAME AS FAMILY ACTIVITY SCORE) ----
        let titleLabel = UILabel()
        titleLabel.text = currentChallenge.title
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // ---- GLASS CONTAINER ----
        let challengeContainer = UIView()
        challengeContainer.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        challengeContainer.layer.cornerRadius = 20
        challengeContainer.layer.borderWidth = 1
        challengeContainer.layer.borderColor = UIColor(white: 1.0, alpha: 0.6).cgColor
        challengeContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(challengeContainer)

        // ---- CHALLENGE NAME ----
        let challengeNameLabel = UILabel()
        challengeNameLabel.text = currentChallenge.name
        challengeNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        challengeNameLabel.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.35, alpha: 1.0)
        challengeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        challengeContainer.addSubview(challengeNameLabel)

        // ---- PARTICIPANTS ----
        let participantsStack = UIStackView()
        participantsStack.axis = .horizontal
        participantsStack.spacing = -12
        participantsStack.translatesAutoresizingMaskIntoConstraints = false
        challengeContainer.addSubview(participantsStack)

        for (index, member) in familyMembers.enumerated() where index < 4 {
            let icon = createParticipantIcon(for: member, zIndex: index)
            participantsStack.addArrangedSubview(icon)
        }

        // ---- APPLE STANDARD PROGRESS ----
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.0 // ALWAYS START ZERO
        progressView.trackTintColor = UIColor(white: 0.85, alpha: 0.5)
        progressView.progressTintColor = UIColor(red: 0.45, green: 0.65, blue: 0.95, alpha: 1.0)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        challengeContainer.addSubview(progressView)

        // ---- POSITIONING ----
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: activityRingsContainer.superview!.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            challengeContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            challengeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            challengeContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            challengeContainer.heightAnchor.constraint(equalToConstant: 160),
            challengeContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            challengeNameLabel.topAnchor.constraint(equalTo: challengeContainer.topAnchor, constant: 20),
            challengeNameLabel.leadingAnchor.constraint(equalTo: challengeContainer.leadingAnchor, constant: 20),

            participantsStack.topAnchor.constraint(equalTo: challengeNameLabel.bottomAnchor, constant: 16),
            participantsStack.leadingAnchor.constraint(equalTo: challengeContainer.leadingAnchor, constant: 20),
            participantsStack.heightAnchor.constraint(equalToConstant: 50),

            progressView.topAnchor.constraint(equalTo: participantsStack.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: challengeContainer.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: challengeContainer.trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 6)
        ])

        // ---- OPTIONAL: Animate later when challenge updates ----
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            progressView.setProgress(Float(self.currentChallenge.progress), animated: true)
        }
    }

    
    func createParticipantIcon(for member: FamilyMember, zIndex: Int) -> UIView {
        let iconSize: CGFloat = 50
        let profileBlue = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        
        // Icon background
        let iconView = UIView()
        iconView.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        iconView.layer.cornerRadius = iconSize / 2
        iconView.layer.borderWidth = 3
        
        // Color based on member's ring color
        iconView.layer.borderColor = profileBlue.cgColor
        
        iconView.layer.shadowColor = UIColor.black.cgColor
        iconView.layer.shadowOpacity = 0.1
        iconView.layer.shadowOffset = CGSize(width: 0, height: 2)
        iconView.layer.shadowRadius = 4
        iconView.frame = CGRect(x: 0, y: 0, width: iconSize, height: iconSize)
        containerView.addSubview(iconView)
        
        // User icon
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let userIcon = UIImageView(image: UIImage(systemName: "person.fill", withConfiguration: config))
        userIcon.tintColor = profileBlue
        userIcon.contentMode = .center
        userIcon.frame = iconView.bounds
        iconView.addSubview(userIcon)
        
        // Layer for overlapping effect
        containerView.layer.zPosition = CGFloat(10 - zIndex)
        
        return containerView
    }
    
    
    func handleTabSelection(index: Int) {
        // Handle tab selection
        print("Selected tab: \(index)")
        // You can add navigation logic here later
    }
    
    // MARK: - Vitals Popup
    func setupVitalsPopup() {
        vitalsPopup.alpha = 0
        vitalsPopup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        vitalsPopup.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vitalsPopup)
        
        NSLayoutConstraint.activate([
            vitalsPopup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vitalsPopup.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            vitalsPopup.widthAnchor.constraint(equalToConstant: 280),
            vitalsPopup.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        // Tap outside to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func memberTapped(_ sender: UIButton) {
        let member = familyMembers[sender.tag]
        vitalsPopup.configure(with: member)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.vitalsPopup.alpha = 1
            self.vitalsPopup.transform = .identity
        })
    }
    
    @objc func dismissPopup() {
        UIView.animate(withDuration: 0.2) {
            self.vitalsPopup.alpha = 0
            self.vitalsPopup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    @objc func dateTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            tappedView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                tappedView.transform = .identity
            }
        }
        
        calendarStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let calendar = Calendar.current
        let today = Date()
        let date = Date(timeIntervalSince1970: TimeInterval(tappedView.tag))
        
        for dayOffset in -2...2 {
            guard let checkDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let isSameDay = calendar.isDate(checkDate, inSameDayAs: date)
            let dateView = createDateView(for: checkDate, isToday: isSameDay)
            calendarStackView.addArrangedSubview(dateView)
        }
    }
    
    @objc func profileTapped() {
        // Show vitals for the current user
        let member = familyMembers[0]
        vitalsPopup.configure(with: member)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.vitalsPopup.alpha = 1
            self.vitalsPopup.transform = .identity
        })
    }
}

// MARK: - Vitals Popup View (Only vitals, no insights)
class VitalsPopupView: UIView {
    
    let nameLabel = UILabel()
    let heartRateLabel = UILabel()
    let sleepLabel = UILabel()
    let stepsLabel = UILabel()
    let activityLabel = UILabel()
    let closeButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = UIColor(white: 1.0, alpha: 0.75)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1.0, alpha: 0.8).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 20
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        nameLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0)
        stack.addArrangedSubview(nameLabel)
        
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.widthAnchor.constraint(equalToConstant: 240).isActive = true
        stack.addArrangedSubview(divider)
        
        [heartRateLabel, sleepLabel, stepsLabel, activityLabel].forEach { label in
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
            stack.addArrangedSubview(label)
        }
        
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        closeButton.setTitleColor(UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            closeButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func configure(with member: FamilyMember) {
        nameLabel.text = member.name
        heartRateLabel.text = "❤️  Heart Rate: \(member.heartRate)"
        sleepLabel.text = "🌙  Sleep: \(member.sleep)"
        stepsLabel.text = "👣  Steps: \(member.steps)"
        activityLabel.text = "🔥  Activity: \(member.activity)"
    }
}
