import Foundation
import Combine
import CoreData

struct SuggestedCap: Identifiable, Hashable {
    let id = UUID()
    let category: CDCategory
    var amount: Double
}

final class StarterBudgetViewModel: ObservableObject {
    @Published var netIncome: String = ""
    @Published var suggestions: [SuggestedCap] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        loadSuggestions()
    }

    private func loadSuggestions() {
        let repo = CategoryRepository(context: context)
        let cats = (try? repo.all()) ?? []
        let defaults: [String: Double] = [
            "Rent": 0.3, "Groceries": 0.15, "Utilities": 0.1, "Transport": 0.1,
            "Dining": 0.1, "Entertainment": 0.05, "Health": 0.05, "Shopping": 0.05
        ]
        let income = Double(netIncome) ?? 0
        suggestions = cats.map { c in
            let pct = defaults[c.name ?? ""] ?? 0.05
            return SuggestedCap(category: c, amount: (income * pct).rounded())
        }
    }

    func onIncomeChange(_ text: String) {
        netIncome = text
        loadSuggestions()
    }

    func saveBudgets() {
        let month = MonthFormatter.yyyymm()
        for s in suggestions {
            let b = NSEntityDescription.insertNewObject(forEntityName: "CDBudget", into: context) as! CDBudget
            b.id = UUID()
            b.month = month
            b.categoryId = s.category.id
            b.capAmount = s.amount
            b.rolloverEnabled = false
            b.rolloverAmount = 0
        }
        try? context.save()
    }
}

