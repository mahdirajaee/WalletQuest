import Foundation
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var step: OnboardingStep
    @Published var selectedGoals: Set<GoalOption>

    private let storage: OnboardingStorage

    init(storage: OnboardingStorage = .live()) {
        self.storage = storage
        self.step = storage.loadStep()
        self.selectedGoals = Set(storage.loadSelectedGoals())
    }

    func next() {
        switch step {
        case .welcome: step = .auth
        case .auth: step = .goals
        case .goals: step = .starterBudget
        case .starterBudget: step = .pickCategories
        case .pickCategories: step = .firstQuest
        case .firstQuest: step = .teaser
        case .teaser: step = .completed
        case .completed: break
        }
        persist()
    }

    func back() {
        switch step {
        case .welcome: break
        case .auth: step = .welcome
        case .goals: step = .auth
        case .starterBudget: step = .goals
        case .pickCategories: step = .starterBudget
        case .firstQuest: step = .pickCategories
        case .teaser: step = .firstQuest
        case .completed: step = .teaser
        }
        persist()
    }

    func toggleGoal(_ goal: GoalOption) {
        if selectedGoals.contains(goal) { selectedGoals.remove(goal) } else { selectedGoals.insert(goal) }
        storage.saveSelectedGoals(Array(selectedGoals))
    }

    func persist() {
        storage.saveStep(step)
    }

    // MARK: - Steps & Analytics helpers
    private var orderedSteps: [OnboardingStep] {
        [.welcome, .auth, .goals, .starterBudget, .pickCategories, .firstQuest, .teaser]
    }

    var currentIndex: Int { orderedSteps.firstIndex(of: step) ?? 0 }
    var totalSteps: Int { orderedSteps.count }
}

struct OnboardingStorage {
    var loadStep: () -> OnboardingStep
    var saveStep: (OnboardingStep) -> Void
    var loadSelectedGoals: () -> [GoalOption]
    var saveSelectedGoals: ([GoalOption]) -> Void

    static func live() -> OnboardingStorage {
        let defaults = UserDefaults.standard
        let stepKey = "onboarding.step"
        let goalsKey = "onboarding.goals"
        return OnboardingStorage(
            loadStep: {
                if let raw = defaults.value(forKey: stepKey) as? Int, let s = OnboardingStep(rawValue: raw) { return s }
                return .welcome
            },
            saveStep: { step in defaults.set(step.rawValue, forKey: stepKey) },
            loadSelectedGoals: {
                guard let data = defaults.data(forKey: goalsKey) else { return [] }
                return (try? JSONDecoder().decode([GoalOption].self, from: data)) ?? []
            },
            saveSelectedGoals: { goals in
                let data = try? JSONEncoder().encode(goals)
                defaults.set(data, forKey: goalsKey)
            }
        )
    }
}
