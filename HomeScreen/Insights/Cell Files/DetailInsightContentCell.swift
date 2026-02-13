import UIKit
import DGCharts

enum TimeFilter: Int {
    case today = 0
    case week = 1
    case month = 2
}

class DetailInsightContentCell: UICollectionViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var chartView: BarChartView!

    private var currentType: InsightType = .steps
    private var currentProfile: Profile?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupChart()
    }

    // MARK: UI

    private func setupUI() {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Today", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Week", at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: "Month", at: 2, animated: false)
        segmentedControl.selectedSegmentIndex = 0

        segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged),
            for: .valueChanged
        )
    }

    // MARK: Chart Setup

    private func setupChart() {

        chartView.backgroundColor = .clear
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.isUserInteractionEnabled = false

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelFont = .systemFont(ofSize: 10)

        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
    }

    @objc private func segmentChanged() {
        guard let profile = currentProfile else { return }
        updateChart(for: currentType, profile: profile)
    }

    func configure(with type: InsightType, profile: Profile) {
        currentType = type
        currentProfile = profile
        updateChart(for: type, profile: profile)
    }

    // MARK: Chart Update

    private func updateChart(for type: InsightType, profile: Profile) {

        let filter = TimeFilter(rawValue: segmentedControl.selectedSegmentIndex) ?? .today
        let (values, labels) = getChartData(filter: filter, type: type)

        let color: UIColor = {
            switch type {
            case .steps: return .systemGreen
            case .sleep: return .systemIndigo
            case .calories: return .systemOrange
            case .heartRate: return .systemPink
            case .distance: return .systemTeal
            case .hrv: return .systemPurple
            case .spo2: return .systemCyan
            case .respiratoryRate: return .systemMint
            }
        }()

        renderChart(values: values, labels: labels, color: color)
    }

    // MARK: Render

    private func renderChart(values: [Double],
                             labels: [String],
                             color: UIColor) {

        let entries = values.enumerated().map {
            BarChartDataEntry(x: Double($0.offset), y: $0.element)
        }

        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = [color]
        dataSet.drawValuesEnabled = false

        let data = BarChartData(dataSet: dataSet)
        data.barWidth = values.count > 12 ? 0.45 : 0.65

        chartView.data = data

        let xAxis = chartView.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)

        xAxis.labelCount = min(labels.count, 8)

        chartView.fitBars = true
        chartView.notifyDataSetChanged()
    }

    // MARK: Data

    private func getChartData(filter: TimeFilter, type: InsightType)
    -> ([Double], [String]) {

        switch filter {

        case .today:
            let labels = (0..<24).map { "\($0)h" }
            let values = generateTodayData(for: type)
            return (values, labels)

        case .week:
            let labels = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
            let values = generateWeekData(for: type)
            return (values, labels)

        case .month:
            let labels = ["Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec"]
            let values = generateMonthData(for: type)
            return (values, labels)
        }
    }
    
    // MARK: Data Generation Helpers
    
    private func generateTodayData(for type: InsightType) -> [Double] {
        switch type {
        case .steps:
            return (0..<24).map { _ in Double.random(in: 20...500) }
        case .calories:
            return (0..<24).map { _ in Double.random(in: 10...200) }
        case .distance:
            return (0..<24).map { _ in Double.random(in: 0...2) }
        case .sleep:
            return (0..<24).map { _ in Double.random(in: 0...1) }
        case .heartRate:
            return (0..<24).map { _ in Double.random(in: 60...100) }
        case .hrv:
            return (0..<24).map { _ in Double.random(in: 20...80) }
        case .spo2:
            return (0..<24).map { _ in Double.random(in: 95...100) }
        case .respiratoryRate:
            return (0..<24).map { _ in Double.random(in: 12...20) }
        }
    }
    
    private func generateWeekData(for type: InsightType) -> [Double] {
        switch type {
        case .steps:
            return (0..<7).map { _ in Double.random(in: 3000...12000) }
        case .calories:
            return (0..<7).map { _ in Double.random(in: 1500...3000) }
        case .distance:
            return (0..<7).map { _ in Double.random(in: 2...15) }
        case .sleep:
            return (0..<7).map { _ in Double.random(in: 5...9) }
        case .heartRate:
            return (0..<7).map { _ in Double.random(in: 65...85) }
        case .hrv:
            return (0..<7).map { _ in Double.random(in: 30...70) }
        case .spo2:
            return (0..<7).map { _ in Double.random(in: 96...99) }
        case .respiratoryRate:
            return (0..<7).map { _ in Double.random(in: 14...18) }
        }
    }
    
    private func generateMonthData(for type: InsightType) -> [Double] {
        switch type {
        case .steps:
            return (0..<12).map { _ in Double.random(in: 80000...250000) }
        case .calories:
            return (0..<12).map { _ in Double.random(in: 40000...80000) }
        case .distance:
            return (0..<12).map { _ in Double.random(in: 50...300) }
        case .sleep:
            return (0..<12).map { _ in Double.random(in: 180...250) }
        case .heartRate:
            return (0..<12).map { _ in Double.random(in: 65...85) }
        case .hrv:
            return (0..<12).map { _ in Double.random(in: 35...65) }
        case .spo2:
            return (0..<12).map { _ in Double.random(in: 96...99) }
        case .respiratoryRate:
            return (0..<12).map { _ in Double.random(in: 14...17) }
        }
    }
}
