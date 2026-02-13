import UIKit 
import DGCharts // Library used to draw bar charts

class WellnessChartCell: UICollectionViewCell { // Custom cell that shows a wellness chart

    // Main white card container
    @IBOutlet weak var containerView: UIView!
    
    // Icon image at the top of card
    @IBOutlet weak var iconImageView: UIImageView!
    
    // Title label (e.g., Steps, Sleep)
    @IBOutlet weak var titleLabel: UILabel!
    
    // Main value label (big number)
    @IBOutlet weak var primaryValueLabel: UILabel!
    
    // Optional extra information label
    @IBOutlet weak var secondaryValueLabel: UILabel!
    
    // Chart area that displays bars
    @IBOutlet weak var chartContainer: BarChartView!

    // Called when cell loads from xib/storyboard
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI() // Apply card styling
        setupChart() // Configure chart appearance
    }

    // Setup visual appearance of the card
    private func setupUI() {
        containerView.layer.cornerRadius = 20 // Rounded corners for card
        containerView.backgroundColor = .white // White card background
    }

    // Configure chart appearance and behavior
    private func setupChart() {
        
        // Enable x-axis but hide y-axes
        chartContainer.xAxis.enabled = true
        chartContainer.leftAxis.enabled = false
        chartContainer.rightAxis.enabled = false
        
        // Hide legend and description text
        chartContainer.legend.enabled = false
        chartContainer.chartDescription.enabled = false
        
        // Remove extra backgrounds and borders
        chartContainer.drawGridBackgroundEnabled = false
        chartContainer.drawBordersEnabled = false
        chartContainer.backgroundColor = .clear
        
        // Disable user interaction for clean static display
        chartContainer.isUserInteractionEnabled = false
        chartContainer.pinchZoomEnabled = false
        chartContainer.doubleTapToZoomEnabled = false

        // X-axis styling
        chartContainer.xAxis.drawGridLinesEnabled = true // Show vertical grid lines
        chartContainer.xAxis.drawAxisLineEnabled = false // Hide axis baseline
        chartContainer.xAxis.labelTextColor = .clear // Hide text labels
        chartContainer.xAxis.labelFont = .systemFont(ofSize: 8) // Small font size
        chartContainer.xAxis.granularity = 1 // One label per data point
    }

    // Configure cell with card data
    func configure(with card: WellnessCard) {
        
        // Set icon and its color
        iconImageView.image = UIImage(systemName: card.icon)
        iconImageView.tintColor = card.iconColor
        
        // Update text labels
        titleLabel.text = card.title
        primaryValueLabel.text = card.primaryValue
        
        // Show secondary label only if it exists
        if let secondary = card.secondaryValue, !secondary.isEmpty {
            secondaryValueLabel.text = secondary
            secondaryValueLabel.isHidden = false
        } else {
            secondaryValueLabel.isHidden = true
        }

        // Configure chart only if data is available
        if let chartData = card.chartData, !chartData.isEmpty {
            configureChart(with: chartData, color: card.iconColor)
        } else {
            chartContainer.data = nil // Clear chart for reuse safety
        }
    }

    // Create and display bar chart data
    private func configureChart(with dataPoints: [WellnessCard.ChartDataPoint], color: UIColor) {
        
        var entries: [BarChartDataEntry] = [] // Array to store bar entries
        
        // Convert data points into chart entries
        for (index, point) in dataPoints.enumerated() {
            entries.append(
                BarChartDataEntry(
                    x: Double(index), // Position on x-axis
                    y: point.value // Height of bar
                )
            )
        }

        // Create dataset for bars
        let dataSet = BarChartDataSet(entries: entries, label: "")
        dataSet.colors = [color.withAlphaComponent(0.6)] // Bar color
        dataSet.drawValuesEnabled = false // Hide value labels
        dataSet.highlightEnabled = false // Disable highlighting

        // Create final chart data
        let data = BarChartData(dataSet: dataSet)
        data.barWidth = 0.35 // Width of each bar

        // Assign data to chart
        chartContainer.data = data

        // Configure x-axis labels
        chartContainer.xAxis.labelCount = min(dataPoints.count, 24) // Limit labels
        chartContainer.xAxis.granularity = 1
        
        // Map labels from data points
        chartContainer.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: dataPoints.map { $0.label })

        // Animate chart appearance
        chartContainer.animate(
            yAxisDuration: 0.5,
            easingOption: .easeOutCubic
        )
    }
}
