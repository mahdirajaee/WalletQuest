import Foundation
import Combine
import CoreData

final class PickCategoriesViewModel: ObservableObject {
    @Published var categories: [CDCategory] = []
    @Published var selected: Set<UUID> = []

    private let context: NSManagedObjectContext
    private let storageKey = "onboarding.pick3"

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        reload()
        if let data = UserDefaults.standard.array(forKey: storageKey) as? [String] {
            selected = Set(data.compactMap { UUID(uuidString: $0) })
        }
    }

    func reload() {
        let repo = CategoryRepository(context: context)
        categories = (try? repo.all()) ?? []
    }

    func toggle(_ cat: CDCategory) {
        guard let id = cat.id else { return }
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
        UserDefaults.standard.set(Array(selected).map { $0.uuidString }, forKey: storageKey)
    }
}

