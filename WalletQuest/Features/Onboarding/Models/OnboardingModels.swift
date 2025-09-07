import Foundation

enum OnboardingStep: Int, Codable {
    case welcome
    case auth
    case goals
    case completed
}

struct GoalOption: Identifiable, Hashable, Codable {
    let id: String
    let title: String
}

enum OnboardingConstants {
    static let goalOptions: [GoalOption] = [
        .init(id: "emergency", title: "Emergency fund"),
        .init(id: "debt", title: "Pay down debt"),
        .init(id: "trip", title: "Trip savings"),
        .init(id: "house", title: "Home savings"),
        .init(id: "car", title: "Car fund"),
        .init(id: "other", title: "Other goal")
    ]
}

