//
//  GraphCollectionViewCell.swift
//  Insight
//
//  Created by Mohd Kushaad on 12/02/26.
//

import UIKit
import DGCharts

class GraphCollectionViewCell: UICollectionViewCell {

    private var barChartView: BarChartView!
    private var days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    private var storedDays = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    private var storedDates = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                               "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                               "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                               "31"]
    var xLabel: [String] = []
    var isWeek: Bool = true
    
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var comparisonLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupCardStyle()
        setupBarChart()
    }

    private func setupCardStyle() {
        // 1. The Masked Corner (Applied to ContentView)
        self.contentView.layer.cornerRadius = 20
        self.contentView.layer.masksToBounds = true // This forces the "rounding"
        self.contentView.backgroundColor = .white

        // 2. The Shadow (Applied to the Cell itself)
        self.layer.masksToBounds = false // This allows the shadow to "bleed" out
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.08
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 12
        
        // 3. Performance boost for shadows
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 20).cgPath
    }
    
    private func setupBarChart() {
        barChartView = BarChartView()
        barChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        graphView.addSubview(barChartView)
        
        // Hide unnecessary elements for the minimalist look
        barChartView.legend.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false // No Y-axis numbers or lines
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawBordersEnabled = false
        barChartView.isUserInteractionEnabled = false
        
        // setitng up x axis
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false // Removes the solid bottom line
        xAxis.labelTextColor = .systemGray
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .medium)
        
        
            
        // tap single bar to change top text label
        barChartView.isUserInteractionEnabled = true
        barChartView.highlightPerTapEnabled = true
        
        //disabling zoom
        barChartView.doubleTapToZoomEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
    
        barChartView.delegate = self
        }
    
    func configureCell(score: [Int], comparison: String, isWeek: Bool) {
        self.isWeek = isWeek
        if isWeek {
            xLabel = days
        } else {
            xLabel = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                          "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                          "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                          "31"]
        }
        
        titleLabel.text = "Today's Progress"
        progressLabel.text = "\(score[4])%" //choose current day by default
        comparisonLabel.text = comparison
        comparisonLabel.textColor = .systemGreen
        
        let entries = score.enumerated().map {
            BarChartDataEntry(x: Double($0.offset), y: Double($0.element))
        }
        
        let dataSet = BarChartDataSet(entries: entries)
        
        // Colors matching your "Today's Progress" bars
        dataSet.colors = [UIColor.systemOrange, UIColor.systemYellow, UIColor.systemGreen, UIColor.systemGreen]
        dataSet.drawValuesEnabled = false // No text numbers on top of bars
        
        let data = BarChartData(dataSet: dataSet)
        data.barWidth = 0.3 // Keeps bars thin like the reference
        
        barChartView.data = data
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xLabel)
        barChartView.xAxis.granularity = 1
        
        // Smooth entrance animation
        barChartView.animate(yAxisDuration: 1.0, easingOption: .easeOutBack)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the chart fills the container view exactly
        barChartView.frame = graphView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Clear data to prevent "ghosting" when scrolling
        barChartView.data = nil
    }
}

extension GraphCollectionViewCell: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        if isWeek {
            let dayIndex = Int(entry.x)
            if dayIndex < storedDays.count {
                let dayName = storedDays[dayIndex]
                
                // 2. Update the labels
                titleLabel.text = "\(dayName)'s progress"
                progressLabel.text = "\(Int(entry.y))%"
            }
        } else {
            let dateIndex = Int(entry.x)
            if dateIndex < storedDates.count {
                let date = storedDates[dateIndex]
                
                titleLabel.text = "\(date)'s progress"
                progressLabel.text = "\(Int(entry.y))%"
            }
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        // Reset to default when the user taps away
        titleLabel.text = "Today's progress"
        // You might want to store the original 'percentage' to reset it here
    }
}
