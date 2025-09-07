import Foundation

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
        case .goals: step = .completed
        case .completed: break
        }
        persist()
    }

    func back() {
        switch step {
        case .welcome: break
        case .auth: step = .welcome
        case .goals: step = .auth
        case .completed: step = .goals
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

