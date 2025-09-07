import Foundation
import CoreData

enum DataSeeder {
    static func run() {
        let context = CoreDataStack.shared.viewContext
        CategoryRepository(context: context).seedDefaultsIfNeeded()
        // Apply budget rollover once per calendar month on app start.
        BudgetRolloverManager(context: context).processIfNeeded()
    }
}
