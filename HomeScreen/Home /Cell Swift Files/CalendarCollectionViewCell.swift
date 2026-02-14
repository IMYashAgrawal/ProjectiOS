//
//  CalendarCollectionViewCell.swift
//  HomeScreen
//
//  Created by Himadri on 30/01/26.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {

    // Background view used to highlight selected date
    @IBOutlet weak var selectionBackgroundView: UIView!
    
    // Label to show short day name (Mon, Tue, etc.)
    @IBOutlet weak var dayNameLabel: UILabel!
    
    // Label to show date number (1, 2, 3, etc.)
    @IBOutlet weak var dayNumberLabel: UILabel!
    
    // Boolean to track if this day is selected
    var isSelectedDay: Bool = false {
        didSet {
            updateSelectionState() // Update UI whenever selection changes
        }
    }
    
    // Called when cell loads from storyboard/xib
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI() // Setup initial UI styling
    }
    
    // Setup rounded corners for selection background
    private func setupUI() {
        selectionBackgroundView.layer.cornerRadius = 12 // Rounded corners
        selectionBackgroundView.clipsToBounds = true // Prevent overflow
    }
    
    // Configure cell with date data and state
    func configure(with date: Date, isSelected: Bool, isToday: Bool) {
        
        let calendar = Calendar.current // Get current calendar
        
        // Formatter to convert date to short day name
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE" // Example: Mon, Tue
        
        // Set day name label text
        dayNameLabel.text = dayFormatter.string(from: date)
        
        // Extract day number from date
        let day = calendar.component(.day, from: date)
        
        // Set day number label text
        dayNumberLabel.text = "\(day)"
        
        // Update selection state
        self.isSelectedDay = isSelected
        
        // Change text colors based on state
        if isToday && !isSelected {
            // Highlight today with blue color
            dayNameLabel.textColor = .systemBlue
            dayNumberLabel.textColor = .systemBlue
            
        } else if isSelected {
            // Selected day text color
            dayNameLabel.textColor = .black
            dayNumberLabel.textColor = .black
            
        } else {
            // Default unselected color
            dayNameLabel.textColor = .lightGray
            dayNumberLabel.textColor = .darkGray
        }
    }
    
    // Update background and border when selection changes
    private func updateSelectionState() {
        
        // Animation removed — direct UI update
        
        if self.isSelectedDay {
            // Show light background and border when selected
            self.selectionBackgroundView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            self.selectionBackgroundView.layer.borderWidth = 2
            self.selectionBackgroundView.layer.borderColor = UIColor.black.cgColor
            
        } else {
            // Remove highlight when not selected
            self.selectionBackgroundView.backgroundColor = .clear
            self.selectionBackgroundView.layer.borderWidth = 0
        }
    }
}

