//
//  DataManager.swift
//  HealthSharing
//

import Foundation
import UIKit

final class DataManager {

    static let shared = DataManager()  //allows to access shared app wide datax
    private init() {}

    var currentUser: Profile?
    var family: Family?
    var allProfiles: [Profile] = []   // includ all members expect current user
    var messages: [Message] = []

    //load json
    func loadAppData() {
        guard let url = Bundle.main.url(   //looks in app bundle for the json file
            forResource: "mock_data",
            withExtension: "json"
        ) else {
            print("JSON file not found")
            return
        }

        do {
            let data = try Data(contentsOf: url) //decoding json
            let decoder = JSONDecoder()  //converts json to swift structure

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]

            let dateOnlyFormatter = DateFormatter()
            dateOnlyFormatter.calendar = Calendar(identifier: .iso8601)
            dateOnlyFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateOnlyFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateOnlyFormatter.dateFormat = "yyyy-MM-dd"

            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let string = try container.decode(String.self)

                if let date = isoFormatter.date(from: string) {
                    return date
                }
                if let date = dateOnlyFormatter.date(from: string) {
                    return date
                }

                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date: \(string)"
                )
            }

            let root = try decoder.decode(Root.self, from: data)
          
            //assign decoded data
            self.family = root.family
            self.messages = root.messages

           //select current user
            guard let user = root.profiles.first else {
                print("No profiles found")
                return
            }

            self.currentUser = user
            self.allProfiles = root.profiles.filter {
                $0.profileId != user.profileId
            }

            print("App data loaded successfully")
            print("Current User:", user.firstName)
            print("Messages loaded:", messages.count)
            print("Other Members:", allProfiles.count)

        } catch {
            print("Error loading initial data:", error)
        }
    }
}

// MARK: - Root
private struct Root: Codable {
    let family: Family
    let profiles: [Profile]
    let messages: [Message]
}
