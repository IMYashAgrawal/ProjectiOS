//
//  DataManager.swift
//  HealthSharing
//

import Foundation

final class DataManager {

    static let shared = DataManager()
    private init() {}

    // MARK: - App State
    var currentUser: Profile?
    var family: Family?
    var allProfiles: [Profile] = []   // excludes currentUser
    var messages: [Message] = []

    // MARK: - Load JSON
    func loadAppData() {
        guard let url = Bundle.main.url(
            forResource: "mani_family_final_dummy",
            withExtension: "json"
        ) else {
            print("❌ JSON file not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)

            let decoder = JSONDecoder()

            // MARK: - Date Decoding (supports ALL formats in your JSON)

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

                // Try full ISO8601 with time
                if let date = isoFormatter.date(from: string) {
                    return date
                }

                // Try date-only (sleepDate)
                if let date = dateOnlyFormatter.date(from: string) {
                    return date
                }

                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date: \(string)"
                )
            }

            // MARK: - Decode Root
            let root = try decoder.decode(Root.self, from: data)

            // MARK: - Assign decoded data
            self.family = root.family
            self.messages = root.messages

            // MARK: - Select current user
            guard let user = root.profiles.first else {
                print("❌ No profiles found")
                return
            }

            self.currentUser = user

            // MARK: - Remove currentUser from allProfiles
            self.allProfiles = root.profiles.filter {
                $0.profileId != user.profileId
            }

            // MARK: - Success Logs
            print("✅ App data loaded successfully")
            print("👤 Current User:", user.firstName)
            print("📩 Messages loaded:", messages.count)
            print("👥 Other Members:", allProfiles.count)

        } catch {
            print("❌ Error loading initial data:", error)
        }
    }
}

// MARK: - Root
private struct Root: Codable {
    let family: Family
    let profiles: [Profile]
    let messages: [Message]
}
