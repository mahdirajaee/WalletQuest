import Foundation
import CoreData

/// Computes last month's leftover for rollover-enabled budgets and applies it to the current month.
struct BudgetRolloverManager {
    private let context: NSManagedObjectContext
    private let defaults: UserDefaults

    private let lastProcessedKey = "rollover.lastProcessedMonth"

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext, defaults: UserDefaults = .standard) {
        self.context = context
        self.defaults = defaults
    }

    func processIfNeeded(today: Date = Date()) {
        let currentMonth = MonthFormatter.yyyymm(from: today)
        let last = defaults.string(forKey: lastProcessedKey)
        guard last != currentMonth else { return }

        applyRollover(toMonthKey: currentMonth, basedOnPreviousOf: today)
        defaults.set(currentMonth, forKey: lastProcessedKey)
    }

    private func applyRollover(toMonthKey monthKey: String, basedOnPreviousOf today: Date) {
        let prevKey = MonthService.previousMonthKey(from: today)
        let prevDate = MonthService.date(fromKey: prevKey)

        let budRepo = BudgetRepository(context: context)
        let service = BudgetService(context: context)

        guard let prevBudgets = try? budRepo.budgets(forMonth: prevKey), !prevBudgets.isEmpty else { return }

        for prev in prevBudgets where prev.rolloverEnabled {
            guard let cid = prev.categoryId else { continue }
            let spent = service.spentAmount(for: cid, monthDate: prevDate)
            let leftover = max(0, prev.capAmount - spent)

            if let current = budRepo.budget(forMonth: monthKey, categoryId: cid) {
                // Do not override existing cap/toggle; only set rollover amount.
                try? budRepo.setRolloverAmount(leftover, for: current)
            } else {
                // Create with previous cap and same rollover toggle state, then set rollover amount.
                if let created = try? budRepo.upsert(month: monthKey, categoryId: cid, capAmount: prev.capAmount) {
                    if prev.rolloverEnabled { try? budRepo.setRolloverEnabled(true, for: created) }
                    try? budRepo.setRolloverAmount(leftover, for: created)
                }
            }
        }
    }
}

