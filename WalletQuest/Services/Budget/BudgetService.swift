import Foundation
import CoreData

struct BudgetEnvelope: Identifiable, Hashable {
    let id: UUID
    let categoryId: UUID
    let categoryName: String
    let categoryIcon: String
    let categoryType: String // "needs" | "wants"

    let monthKey: String
    var capAmount: Double
    var spentAmount: Double
    var effectiveCap: Double // capAmount + prevRollover (if any)
    var rolloverEnabled: Bool
    var prevRolloverAmount: Double

    var progress: Double { guard effectiveCap > 0 else { return 0 }; return min(spentAmount / max(effectiveCap, 0.01), 1.0) }
    var softAlert: Bool { effectiveCap > 0 && spentAmount / effectiveCap >= 0.75 && spentAmount / effectiveCap < 0.90 }
    var hardAlert: Bool { effectiveCap > 0 && spentAmount / effectiveCap >= 0.90 }
}

/// Provides budget math and aggregation over Core Data.
struct BudgetService {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }

    /// Build envelopes for a given month date (uses UTC yyyymm key)
    func loadEnvelopes(for monthDate: Date) -> [BudgetEnvelope] {
        let monthKey = MonthFormatter.yyyymm(from: monthDate)
        let prevMonthKey = MonthService.previousMonthKey(from: monthDate)

        let catRepo = CategoryRepository(context: context)
        let cats = (try? catRepo.all()) ?? []

        let budRepo = BudgetRepository(context: context)
        let budgets = (try? budRepo.budgets(forMonth: monthKey)) ?? []
        let prevBudgets = (try? budRepo.budgets(forMonth: prevMonthKey)) ?? []
        let prevRolloverByCat: [UUID: Double] = Dictionary(uniqueKeysWithValues: prevBudgets.compactMap { (b: CDBudget) -> (UUID, Double)? in
            guard let cid = b.categoryId else { return nil }
            let amount = (b.rolloverEnabled ? max(0, b.capAmount - spentAmount(for: cid, monthDate: MonthService.date(fromKey: prevMonthKey))) : 0)
            return (cid, amount)
        })

        let budgetByCat: [UUID: CDBudget] = Dictionary(uniqueKeysWithValues: budgets.compactMap { (b: CDBudget) -> (UUID, CDBudget)? in
            guard let cid = b.categoryId else { return nil }
            return (cid, b)
        })

        return cats.compactMap { (c: CDCategory) -> BudgetEnvelope? in
            guard let cid = c.id else { return nil }
            let cap = budgetByCat[cid]?.capAmount ?? 0
            let rolloverEnabled = budgetByCat[cid]?.rolloverEnabled ?? false
            let prevRoll = prevRolloverByCat[cid] ?? (budgetByCat[cid]?.rolloverAmount ?? 0)
            let spent = spentAmount(for: cid, monthDate: monthDate)
            return BudgetEnvelope(
                id: UUID(),
                categoryId: cid,
                categoryName: c.name ?? "",
                categoryIcon: c.icon ?? "",
                categoryType: c.type ?? "needs",
                monthKey: monthKey,
                capAmount: cap,
                spentAmount: spent,
                effectiveCap: cap + prevRoll,
                rolloverEnabled: rolloverEnabled,
                prevRolloverAmount: prevRoll
            )
        }
        .sorted { $0.categoryName < $1.categoryName }
    }

    /// Sum of non-excluded spending in a category for the given month.
    func spentAmount(for categoryId: UUID, monthDate: Date) -> Double {
        let (start, end) = DateRange.monthBounds(for: monthDate)
        let req = NSFetchRequest<NSDictionary>(entityName: "CDTransaction")
        req.resultType = .dictionaryResultType
        req.propertiesToFetch = ["amount"]
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "categoryId == %@", categoryId as CVarArg),
            NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate),
            NSPredicate(format: "isExcluded == NO")
        ])
        do {
            let items = try context.fetch(req)
            let amounts = items.compactMap { $0["amount"] as? Double }
            // Support both conventions: if any negative exists, treat negatives (abs) as spend.
            // Otherwise treat positives as spend.
            let containsNegative = amounts.contains(where: { $0 < 0 })
            if containsNegative {
                return amounts.reduce(0) { $0 + ($1 < 0 ? -$1 : 0) }
            } else {
                return amounts.reduce(0) { $0 + ($1 > 0 ? $1 : 0) }
            }
        } catch {
            return 0
        }
    }
}

enum MonthService {
    static func previousMonthKey(from date: Date) -> String {
        let cal = Calendar(identifier: .gregorian)
        let prev = cal.date(byAdding: .month, value: -1, to: date) ?? date
        return MonthFormatter.yyyymm(from: prev)
    }

    static func date(fromKey key: String) -> Date {
        let comps = key.split(separator: "-")
        guard comps.count == 2, let y = Int(comps[0]), let m = Int(comps[1]) else { return Date() }
        var dc = DateComponents()
        dc.year = y; dc.month = m; dc.day = 1
        return Calendar(identifier: .gregorian).date(from: dc) ?? Date()
    }
}
