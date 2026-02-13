//
//  DataModels.swift
//  Insight
//
//  Created by Mohd Kushaad on 12/02/26.
//

struct FamilyMemberScores: Codable {
    var profile: String //it will be the struct 'Profile' when implementing
    var scoreWeekly: [Int]
    var scoreMonthly: [Int]
}
var fam  = FamilyMemberScores(profile: "Family",
                              scoreWeekly: [60, 99, 78, 55, 87, 73, 92],
                              scoreMonthly: [57, 62, 85, 91, 68, 74, 96, 50, 79, 88, 63, 72, 100, 54, 67, 81, 90, 59, 75, 97, 56, 83, 94, 65, 77, 89, 52, 95, 58, 84])
var me = FamilyMemberScores(profile: "Me",
                            scoreWeekly: [72, 95, 61, 88, 54, 79, 100],
                            scoreMonthly: [56, 78, 92, 65, 81, 99, 73, 60, 85, 91, 57, 69, 74, 88, 96, 53, 80, 62, 90, 77, 55, 84, 98, 71, 63, 89, 76, 94, 58, 87])
var dad = FamilyMemberScores(profile: "Dad",
                             scoreWeekly: [50, 67, 89, 76, 93, 58, 81],
                             scoreMonthly: [64, 75, 82, 90, 55, 97, 68, 73, 86, 100, 59, 70, 91, 83, 62, 78, 95, 54, 88, 60, 72, 99, 56, 84, 77, 92, 65, 87, 51, 96])
var mom = FamilyMemberScores(profile: "Mom",
                             scoreWeekly: [83, 74, 66, 98, 59, 91, 70],
                             scoreMonthly: [52, 61, 79, 88, 94, 67, 75, 80, 97, 63, 85, 90, 58, 72, 100, 54, 69, 77, 92, 55, 84, 96, 60, 73, 89, 71, 87, 95, 56, 81])
var sister = FamilyMemberScores(profile: "Sister",
                                scoreWeekly: [60, 99, 78, 55, 87, 73, 92],
                                scoreMonthly: [57, 62, 85, 91, 68, 74, 96, 50, 79, 88, 63, 72, 100, 54, 67, 81, 90, 59, 75, 97, 56, 83, 94, 65, 77, 89, 52, 95, 58, 84])

var memberWiseScore: [FamilyMemberScores] = [fam, dad, mom, sister, me]
