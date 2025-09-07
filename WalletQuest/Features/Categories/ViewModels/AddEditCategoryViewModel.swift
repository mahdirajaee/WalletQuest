import Foundation
import Combine
import CoreData

final class AddEditCategoryViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var isNeeds: Bool = true
    @Published var icon: String = ""

    private let context: NSManagedObjectContext
    private let repo: CategoryRepository
    private let existing: CDCategory?

    init(category: CDCategory? = nil, context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        self.repo = CategoryRepository(context: context)
        self.existing = category
        if let c = category {
            name = c.name ?? ""
            isNeeds = (c.type ?? "needs") == "needs"
            icon = c.icon ?? ""
        }
    }

    var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    func save() throws {
        let type = isNeeds ? "needs" : "wants"
        if let c = existing {
            try repo.update(c, name: name, type: type, icon: icon)
        } else {
            _ = try repo.create(name: name, type: type, icon: icon, isCustom: true)
        }
    }
}

