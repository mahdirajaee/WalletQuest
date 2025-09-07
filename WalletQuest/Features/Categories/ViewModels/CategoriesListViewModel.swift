import Foundation
import Combine
import CoreData

final class CategoriesListViewModel: ObservableObject {
    @Published var items: [CDCategory] = []
    private let repo: CategoryRepository

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.repo = CategoryRepository(context: context)
        reload()
    }

    func reload() {
        items = (try? repo.all()) ?? []
    }
}

