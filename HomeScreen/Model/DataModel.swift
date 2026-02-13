import Foundation
import UIKit

struct Profile: Codable {
    let profileId: Int
    var firstName: String
    var lastName: String
    var nickName: String?
    var email: String
    let gender: Gender
    var dob: Date
    var profilePic: String
    var heightCm: Double
    var weightKg: Double
    var stepGoal: Int
    var caloriesGoal: Int
    var distanceGoal: Int
    var timeZone: String
    
    var vitalHourly: [VitalsHourly]
    var vitalDaily: [VitalsDaily]
    var activityHourly: [ActivityHourly]
    var activityDaily: [ActivityDaily]
    var sleep: [Sleep]
    
    var lastUpdatedAt: Date
    var isSynced: Bool
}

enum Gender: String, Codable {
    case male, female, others
}

struct Family: Codable {
    let familyId: Int
    var familyName: String
    var sharableCode: String
    var challenge: [ChallengeCompleted]
    
    var lastUpdatedAt: Date
    var isSynced: Bool
}

struct ChallengeCompleted: Codable {
    var challenges: Challenge
    var percentageCompleted: Double
    var memberProgress: [String: Double]
    
    var lastUpdatedAt: Date
    var isSynced: Bool
}

struct Challenge: Codable {
    let challengeId: Int
    let challengeName: String
    let challengeType: ChallengeType
    let challengeDescription: String
}

enum ChallengeType: String, Codable {
    case physical, emotional
}

struct Message: Codable {
    let messageId: Int
    let senderId: Int
    let receiverId: Int
    let timestampUTC: Date
    let message: String

    var deliveredAt: Date?
    var readAt: Date?

    var lastUpdatedAt: Date
    var isSynced: Bool
}

struct VitalsHourly: Codable {
    let vitalHourlyId: Int
    let vitalType: VitalType
    var minValue: Int
    var avgValue: Int
    var maxValue: Int
    var sampleCount: Int
    let hourBucket: Int
    var dateUTC: Date
    
    var lastUpdatedAt: Date
    var isSynced: Bool
}

struct VitalsDaily: Codable {
    let vitalDailyId: Int
    let vitalType: VitalType
    var minValue: Int
    var avgValue: Int
    var maxValue: Int
    let date: Date
    
    var lastUpdatedAt: Date
    var isSynced: Bool
}

enum VitalType: String, Codable {
    case heartRate, hrv, spo2, respiratoryRate
}

struct Sleep: Codable {
    let sleepId: Int
    let sleepStartUTC: Date
    let sleepEndUTC: Date
    let sleepDate: Date
    var totalSleepMinutes: Int
    var deepSleepMinutes: Int
    var remSleepMinutes: Int
    var lightSleepMinutes: Int
    var lastUpdatedAt: Date
    var isSynced: Bool
}

struct ActivityHourly: Codable {
    let activityHourlyId: Int
    let activityType: ActivityType
    var value: Int
    var unit: ActivityUnit
    let hourBucket: Int
    var dateUTC: Date
    var lastUpdatedAt: Date
    var isSynced: Bool
}

struct ActivityDaily: Codable {
    let activityDailyId: Int
    let activityType: ActivityType
    var value: Int
    var unit: ActivityUnit
    let data: Date
    var lastUpdatedAt: Date
    var isSynced: Bool
}

enum ActivityType: String, Codable {
    case stepCount, caloriesBurned, distanceCovered, wellnessScore
}

enum ActivityUnit: String, Codable {
    case step, kcal, meters, outof100
}
