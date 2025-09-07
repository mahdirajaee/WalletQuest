import SwiftUI
import Combine

enum AppRoute {
    case onboarding
    case home
}

final class AppRouter: ObservableObject {
    @Published var route: AppRoute = .home
}
