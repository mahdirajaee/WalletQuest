import Foundation
import Combine
import CoreData

final class BudgetViewModel: ObservableObject {
    @Published var month: Date = Date() {
        didSet { load() }
    }
    @Published var envelopes: [BudgetEnvelope] = []
    @Published var isLoading: Bool = false
    @Published var summary: BudgetSummary = .empty
    @Published var topOverspends: [BudgetDelta] = []
    @Published var topSavings: [BudgetDelta] = []

    private let context: NSManagedObjectContext
    private let service: BudgetService
    private let repo: BudgetRepository
    private let alertsStore = BudgetAlertsStore()

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        self.service = BudgetService(context: context)
        self.repo = BudgetRepository(context: context)
        load()
    }

    func load() {
        isLoading = true
        defer { isLoading = false }
        envelopes = service.loadEnvelopes(for: month)
        recomputeSummary()
    }

    func updateCap(for envelope: BudgetEnvelope, newCap: Double) {
        guard let budget = repo.budget(forMonth: envelope.monthKey, categoryId: envelope.categoryId) else {
            // upsert if missing
            _ = try? repo.upsert(month: envelope.monthKey, categoryId: envelope.categoryId, capAmount: newCap)
            load()
            return
        }
        try? repo.setCapAmount(newCap, for: budget)
        load()
    }

    func toggleRollover(for envelope: BudgetEnvelope, enabled: Bool) {
        guard let budget = repo.budget(forMonth: envelope.monthKey, categoryId: envelope.categoryId) else { return }
        try? repo.setRolloverEnabled(enabled, for: budget)
        load()
    }

    private func recomputeSummary() {
        summary = BudgetSummary.from(envelopes: envelopes)
        // Deltas
        let deltas: [BudgetDelta] = envelopes.map { e in
            let delta = e.spentAmount - e.effectiveCap
            return BudgetDelta(categoryId: e.categoryId,
                               icon: e.categoryIcon,
                               name: e.categoryName,
                               spent: e.spentAmount,
                               cap: e.effectiveCap,
                               delta: delta)
        }
        topOverspends = deltas.filter { $0.delta > 0 }.sorted { $0.delta > $1.delta }.prefix(3).map { $0 }
        topSavings = deltas.map { d in BudgetDelta(categoryId: d.categoryId, icon: d.icon, name: d.name, spent: d.spent, cap: d.cap, delta: d.cap - d.spent) }
            .filter { $0.delta > 0 }
            .sorted { $0.delta > $1.delta }
            .prefix(3).map { $0 }
    }

    // MARK: - Alert Acknowledgement
    func isAlertAcknowledged(for envelope: BudgetEnvelope, level: BudgetAlertLevel) -> Bool {
        alertsStore.isAcknowledged(monthKey: envelope.monthKey, categoryId: envelope.categoryId, level: level)
    }

    func acknowledgeAlert(for envelope: BudgetEnvelope, level: BudgetAlertLevel) {
        alertsStore.acknowledge(monthKey: envelope.monthKey, categoryId: envelope.categoryId, level: level)
        objectWillChange.send()
    }
}

struct BudgetSummary {
    var needsCap: Double
    var wantsCap: Double
    var needsSpent: Double
    var wantsSpent: Double

    static let empty = BudgetSummary(needsCap: 0, wantsCap: 0, needsSpent: 0, wantsSpent: 0)

    var needsProgress: Double { guard needsCap > 0 else { return 0 }; return min(needsSpent / needsCap, 1.0) }
    var wantsProgress: Double { guard wantsCap > 0 else { return 0 }; return min(wantsSpent / wantsCap, 1.0) }

    static func from(envelopes: [BudgetEnvelope]) -> BudgetSummary {
        var needsCap = 0.0, wantsCap = 0.0, needsSpent = 0.0, wantsSpent = 0.0
        for e in envelopes {
            if e.categoryType == "needs" {
                needsCap += e.effectiveCap
                needsSpent += e.spentAmount
            } else {
                wantsCap += e.effectiveCap
                wantsSpent += e.spentAmount
            }
        }
        return BudgetSummary(needsCap: needsCap, wantsCap: wantsCap, needsSpent: needsSpent, wantsSpent: wantsSpent)
    }
}

struct BudgetDelta: Identifiable, Hashable {
    var id: UUID { categoryId }
    let categoryId: UUID
    let icon: String
    let name: String
    let spent: Double
    let cap: Double
    /// For overspends this is (spent - cap). For savings this is (cap - spent).
    let delta: Double
}
