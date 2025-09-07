import Foundation
import Combine
import CoreData

final class TransactionsListViewModel: ObservableObject {
    @Published var month: Date = Date()
    @Published var categoryId: UUID? = nil
    @Published var search: String = ""
    @Published var items: [CDTransaction] = []

    private let repo: TransactionRepository

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.repo = TransactionRepository(context: context)
        reload()
    }

    func reload() {
        let filter = TransactionFilter(month: month, categoryId: categoryId, search: search)
        items = (try? repo.fetch(filter: filter, batchSize: 100)) ?? []
    }
}

