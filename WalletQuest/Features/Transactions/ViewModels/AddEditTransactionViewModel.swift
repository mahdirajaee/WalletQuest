import Foundation
import Combine
import CoreData

final class AddEditTransactionViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var merchant: String = ""
    @Published var categoryId: UUID? = nil
    @Published var notes: String = ""
    @Published var isExcluded: Bool = false
    @Published var isRecurring: Bool = false

    private let repo: TransactionRepository

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.repo = TransactionRepository(context: context)
    }

    var isValid: Bool {
        Double(amount) != nil && !merchant.isEmpty
    }

    func save() throws {
        let amt = Double(amount) ?? 0
        try repo.add(amount: amt, date: date, merchant: merchant, categoryId: categoryId, notes: notes.isEmpty ? nil : notes, isRecurring: isRecurring, isExcluded: isExcluded)
    }
}

