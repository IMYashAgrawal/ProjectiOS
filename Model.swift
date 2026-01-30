struct Profile {
    var profileId: Int
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var dob: Date
    var gender: String
    var profilePic: String
}

struct Challenge {
    var challengeId: Int
    var challengeName: String
    var challengeType: String
    var challengeDescription: String
}

struct Vitals {
    var minValue: Int
    var avgValue: Int
    var maxValue: Int
}

struct VitalsHourly {
    var vitalHourlyId: Int
    var userId: Int
    var vitalType: String
    var vitalValue: [Vitals]
    var sampleCount: Int
    var hourStart: Int
}

struct VitalsDaily {
    var vitalDailyId: Int
    var userId: Int
    var vitalType: String
    var vitalValue: [Vitals]
          
}
