import UIKit

enum WellnessCardType {
    case activityRings, steps, sleep, calories, heartRate
}

struct WellnessCard {
    let type: WellnessCardType
    let title: String
    let primaryValue: String
    let secondaryValue: String?
    let icon: String
    let iconColor: UIColor
    let chartData: [ChartDataPoint]?

    struct ChartDataPoint {
        let label: String
        let value: Double
        let rawValue: Int
    }
}

struct WellnessDataProvider {

    static func getWellnessCards(for profile: Profile) -> [WellnessCard] {
        [
            createActivityRingsCard(profile),
            createStepsCard(profile),
            createDistanceCard(profile),
            createSleepCard(profile),
            createHeartRateCard(profile),
            createCaloriesCard(profile)
        ]
    }


    private static func createActivityRingsCard(_ profile: Profile) -> WellnessCard {
        let burned = profile.firstValue(for: .caloriesBurned)
        let caloriesGoal = max(profile.caloriesGoal, 1)
        let steps = profile.firstValue(for: .stepCount)
        let activeMinutes = steps / 100

        return WellnessCard(
            type: .activityRings,
            title: "Activity",
            primaryValue: "\(burned)/\(caloriesGoal) KCAL",
            secondaryValue: "\(activeMinutes)/30 MIN",
            icon: "",
            iconColor: .systemRed,
            chartData: nil
        )
    }

    private static func createStepsCard(_ profile: Profile) -> WellnessCard {
        let today = profile.firstValue(for: .stepCount)
        let goal = max(profile.stepGoal, 1)
        let hourly = profile.activityHourlyValues(for: .stepCount)
        return WellnessCard(
            type: .steps,
            title: "Steps",
            primaryValue: "\(today)",
            secondaryValue: "of \(goal) steps",
            icon: "shoeprints.fill",
            iconColor: .systemGreen,
            chartData: createChart(from: hourly, goal: goal)
        )
    }

    private static func createCaloriesCard(_ profile: Profile) -> WellnessCard {
        let burned = profile.firstValue(for: .caloriesBurned)
        let goal = max(profile.caloriesGoal, 1)
        let hourly = profile.activityHourlyValues(for: .caloriesBurned)
        return WellnessCard(
            type: .calories,
            title: "Calories",
            primaryValue: "\(burned) kcal",
            secondaryValue: "of \(goal) kcal burn",
            icon: "flame.fill",
            iconColor: .systemOrange,
            chartData: createChart(from: hourly, goal: goal)
        )
    }

    private static func createDistanceCard(_ profile: Profile) -> WellnessCard {
        let today = profile.firstValue(for: .distanceCovered)
        let goal = max(profile.distanceGoal, 1)
        let hourly = profile.activityHourlyValues(for: .distanceCovered)
        return WellnessCard(
            type: .steps,
            title: "Distance",
            primaryValue: "\(Double(today)/1000) km",
            secondaryValue: "of \(Double(goal)/1000) km",
            icon: "figure.walk",
            iconColor: .systemTeal,
            chartData: createChart(from: hourly, goal: goal)
        )
    }

    private static func createSleepCard(_ profile: Profile) -> WellnessCard {
        guard let latest = profile.sleep.first else {
            return WellnessCard(
                type: .sleep,
                title: "Sleep",
                primaryValue: "No data",
                secondaryValue: nil,
                icon: "moon.fill",
                iconColor: .systemBlue,
                chartData: nil
            )
        }
        let h = latest.totalSleepMinutes / 60
        let m = latest.totalSleepMinutes % 60
        return WellnessCard(
            type: .sleep,
            title: "Sleep",
            primaryValue: "\(h)h \(m)m",
            secondaryValue: "of 8h sleep",
            icon: "moon.fill",
            iconColor: .systemBlue,
            chartData: nil
        )
    }

    private static func createHeartRateCard(_ profile: Profile) -> WellnessCard {
        guard let hr = profile.vitalDaily.first(where: { $0.vitalType == .heartRate }) else {
            return WellnessCard(
                type: .heartRate,
                title: "Heart Rate",
                primaryValue: "-- bpm",
                secondaryValue: nil,
                icon: "heart.fill",
                iconColor: .systemPink,
                chartData: nil
            )
        }
        return WellnessCard(
            type: .heartRate,
            title: "Heart Rate",
            primaryValue: "\(hr.avgValue) bpm",
            secondaryValue: "Avg: \(hr.minValue)-\(hr.maxValue) bpm",
            icon: "heart.fill",
            iconColor: .systemPink,
            chartData: nil
        )
    }

    private static func createChart(from values: [Int], goal: Int) -> [WellnessCard.ChartDataPoint] {
        let formatter = hourFormatter()
        return values.enumerated().map {
            WellnessCard.ChartDataPoint(
                label: formatter.string(from: Date()), 
                value: min(Double($0.element) / Double(goal), 1),
                rawValue: $0.element
            )
        }
    }

    private static func hourFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH"
        return f
    }
}


private extension Profile {
    func firstValue(for type: ActivityType) -> Int {
        activityDaily.first(where: { $0.activityType == type })?.value ?? 0
    }

    func activityHourlyValues(for type: ActivityType) -> [Int] {
        activityDaily.filter { $0.activityType == type }.map { $0.value }.sorted()
    }
}
