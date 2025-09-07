import Foundation

enum BudgetAlertLevel: String {
    case soft75
    case hard90
}

struct BudgetAlertsStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func isAcknowledged(monthKey: String, categoryId: UUID, level: BudgetAlertLevel) -> Bool {
        defaults.bool(forKey: key(monthKey: monthKey, categoryId: categoryId, level: level))
    }

    func acknowledge(monthKey: String, categoryId: UUID, level: BudgetAlertLevel) {
        defaults.set(true, forKey: key(monthKey: monthKey, categoryId: categoryId, level: level))
    }

    private func key(monthKey: String, categoryId: UUID, level: BudgetAlertLevel) -> String {
        return "budget.alertAck.\(monthKey).\(categoryId.uuidString).\(level.rawValue)"
    }
}

