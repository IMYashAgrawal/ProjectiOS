import Foundation
import UIKit

// MARK: - Age Group

enum AgeGroup {
    case child
    case adolescent
    case adult
    case senior
}

// MARK: - Wellness Calculator

struct WellnessScoreCalculator {

    static func clamp(_ value: Double) -> Double {
        return max(0.0, min(value, 1.0))
    }

    static func calculate(
        ageGroup: AgeGroup,
        steps: Int,
        caloriesBurned: Double,
        calorieTarget: Double,
        deepSleepPercent: Double,
        remSleepPercent: Double,
        lightSleepPercent: Double,
        restingHeartRate: Double,
        hrv: Double,
        spO2: Double,
        respiratoryRate: Double
    ) -> Double {

        // Step reference by age
        let stepRange: (min: Double, max: Double)

        switch ageGroup {
        case .child: stepRange = (8000, 12000)
        case .adolescent: stepRange = (7000, 11000)
        case .adult: stepRange = (5000, 10000)
        case .senior: stepRange = (4000, 8000)
        }

        // Steps (25%)
        let stepScore = clamp(
            (Double(steps) - stepRange.min) /
            (stepRange.max - stepRange.min)
        )

        // Calories (5%)
        let calorieScore = clamp(caloriesBurned / calorieTarget)

        // Sleep (30%)
        let deepScore = clamp((deepSleepPercent - 10) / 10)
        let remScore = clamp((remSleepPercent - 15) / 10)
        let lightScore = clamp(1 - abs(lightSleepPercent - 55) / 25)

        // Heart rate (10%)
        let hrScore: Double
        if restingHeartRate <= 70 {
            hrScore = 1
        } else if restingHeartRate >= 90 {
            hrScore = 0
        } else {
            hrScore = (90 - restingHeartRate) / 20
        }

        // HRV (12%)
        let hrvRef: Double = {
            switch ageGroup {
            case .child: return 65
            case .adolescent: return 55
            case .adult: return 40
            case .senior: return 25
            }
        }()
        let hrvScore = clamp(hrv / hrvRef)

        // SpO2 (4%)
        let spo2Score: Double
        if spO2 >= 96 {
            spo2Score = 1
        } else if spO2 <= 92 {
            spo2Score = 0
        } else {
            spo2Score = (spO2 - 92) / 4
        }

        // Respiratory rate (4%)
        let rrScore = clamp(1 - abs(respiratoryRate - 16) / 8)

        let total =
            stepScore * 25 +
            calorieScore * 5 +
            deepScore * 15 +
            remScore * 10 +
            lightScore * 5 +
            hrScore * 10 +
            hrvScore * 12 +
            spo2Score * 4 +
            rrScore * 4

        return total
    }
}

// MARK: - Profile Extension

extension Profile {

    func calculateWellnessScore() -> CGFloat {

        // Age from DOB
        let age = Calendar.current
            .dateComponents([.year], from: dob, to: Date())
            .year ?? 30

        let ageGroup: AgeGroup
        switch age {
        case 5...12: ageGroup = .child
        case 13...17: ageGroup = .adolescent
        case 18...64: ageGroup = .adult
        default: ageGroup = .senior
        }

        // Activity
        let steps = activityDaily
            .first(where: { $0.activityType == .stepCount })?
            .value ?? 0

        let calories = Double(
            activityDaily
                .first(where: { $0.activityType == .caloriesBurned })?
                .value ?? 0
        )

        let calorieTarget = Double(max(caloriesGoal, 1))

        // Sleep → convert minutes to %
        let sleepData = sleep.first
        let totalSleep = Double(max(sleepData?.totalSleepMinutes ?? 1, 1))

        let deep = Double(sleepData?.deepSleepMinutes ?? 0) / totalSleep * 100
        let rem = Double(sleepData?.remSleepMinutes ?? 0) / totalSleep * 100
        let light = Double(sleepData?.lightSleepMinutes ?? 0) / totalSleep * 100

        // Vitals
        let hr = Double(
            vitalDaily.first(where: { $0.vitalType == .heartRate })?.avgValue ?? 70
        )

        let hrv = Double(
            vitalDaily.first(where: { $0.vitalType == .hrv })?.avgValue ?? 40
        )

        let spo2 = Double(
            vitalDaily.first(where: { $0.vitalType == .spo2 })?.avgValue ?? 97
        )

        let rr = Double(
            vitalDaily.first(where: { $0.vitalType == .respiratoryRate })?.avgValue ?? 16
        )

        let score = WellnessScoreCalculator.calculate(
            ageGroup: ageGroup,
            steps: steps,
            caloriesBurned: calories,
            calorieTarget: calorieTarget,
            deepSleepPercent: deep,
            remSleepPercent: rem,
            lightSleepPercent: light,
            restingHeartRate: hr,
            hrv: hrv,
            spO2: spo2,
            respiratoryRate: rr
        )

        return CGFloat(score / 100.0) // convert to 0–1
    }
}
