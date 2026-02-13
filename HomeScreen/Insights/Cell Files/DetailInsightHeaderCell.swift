//
//  DetailInsightHeaderCell.swift
//  HomeScreen
//
//  Created by GEU on 10/02/26.
//

import UIKit

protocol DetailInsightHeaderCellDelegate: AnyObject {
    func didTapHeader(at index: Int)
}
class DetailInsightHeaderCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    weak var delegate: DetailInsightHeaderCellDelegate?
    var index: Int = 0
    var isExpanded: Bool = false {
        didSet {
            updateChevron()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 12
        containerView.backgroundColor = .systemGray6
        
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        chevronImageView.image = UIImage(systemName: "chevron.down")
        chevronImageView.tintColor = .systemGray
        chevronImageView.contentMode = .scaleAspectFit
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    @objc private func headerTapped() {
        delegate?.didTapHeader(at: index)
    }
    
    private func updateChevron() {
        UIView.animate(withDuration: 0.3) {
            self.chevronImageView.transform = self.isExpanded
                ? CGAffineTransform(rotationAngle: .pi)
                : .identity
        }
    }
    
    func configure(with type: InsightType, profile: Profile, index: Int, isExpanded: Bool) {
        self.index = index
        self.isExpanded = isExpanded
        
        switch type {
        case .steps:
            configureSteps()
        case .sleep:
            configureSleep()
        case .calories:
            configureCalories()
        case .heartRate:
            configureHeartRate()
        case .distance:
            configureDistance()
        case .hrv:
            configureHRV()
        case .spo2:
            configureSPO2()
        case .respiratoryRate:
            configureRespiratoryRate()
        }
        updateChevron()
    }
    
    private func configureSteps() {
        iconImageView.image = UIImage(systemName: "shoeprints.fill")
        iconImageView.tintColor = .systemGreen
        titleLabel.text = "Steps"
    }
    
    private func configureSleep() {
        iconImageView.image = UIImage(systemName: "moon.fill")
        iconImageView.tintColor = .systemIndigo
        titleLabel.text = "Sleep Duration"
    }
    
    private func configureCalories() {
        iconImageView.image = UIImage(systemName: "flame.fill")
        iconImageView.tintColor = .systemOrange
        titleLabel.text = "Calories Burned"
    }
    
    private func configureHeartRate() {
        iconImageView.image = UIImage(systemName: "heart.fill")
        iconImageView.tintColor = .systemPink
        titleLabel.text = "Heart Rate"
    }
    
    private func configureDistance() {
        iconImageView.image = UIImage(systemName: "figure.walk")
        iconImageView.tintColor = .systemTeal
        titleLabel.text = "Distance"
    }
    
    private func configureHRV() {
        iconImageView.image = UIImage(systemName: "waveform.path.ecg")
        iconImageView.tintColor = .systemPurple
        titleLabel.text = "Heart Rate Variability"
    }
    
    private func configureSPO2() {
        iconImageView.image = UIImage(systemName: "lungs.fill")
        iconImageView.tintColor = .systemCyan
        titleLabel.text = "Blood Oxygen (SpO2)"
    }
    
    private func configureRespiratoryRate() {
        iconImageView.image = UIImage(systemName: "wind")
        iconImageView.tintColor = .systemMint
        titleLabel.text = "Respiratory Rate"
    }
}
