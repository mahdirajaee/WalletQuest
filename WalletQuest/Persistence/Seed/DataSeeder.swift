import Foundation
import CoreData

enum DataSeeder {
    static func run() {
        let context = CoreDataStack.shared.viewContext
        CategoryRepository(context: context).seedDefaultsIfNeeded()
    }
}

