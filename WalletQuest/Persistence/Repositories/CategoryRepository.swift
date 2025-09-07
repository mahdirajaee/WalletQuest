import CoreData

struct CategoryRepository {
    let context: NSManagedObjectContext

    func all() throws -> [CDCategory] {
        let req = NSFetchRequest<CDCategory>(entityName: "CDCategory")
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try context.fetch(req)
    }

    func findByNameInsensitive(_ name: String) -> CDCategory? {
        let req = NSFetchRequest<CDCategory>(entityName: "CDCategory")
        req.predicate = NSPredicate(format: "name =[c] %@", name)
        req.fetchLimit = 1
        return try? context.fetch(req).first
    }

    @discardableResult
    func create(name: String, type: String, icon: String, isCustom: Bool = true) throws -> CDCategory {
        let obj = NSEntityDescription.insertNewObject(forEntityName: "CDCategory", into: context) as! CDCategory
        obj.id = UUID()
        obj.name = name
        obj.type = type
        obj.icon = icon
        obj.isCustom = isCustom
        try context.save()
        return obj
    }

    func update(_ category: CDCategory, name: String, type: String, icon: String) throws {
        category.name = name
        category.type = type
        category.icon = icon
        try context.save()
    }

    func delete(_ category: CDCategory) throws {
        context.delete(category)
        try context.save()
    }

    func seedDefaultsIfNeeded() {
        let req = NSFetchRequest<NSNumber>(entityName: "CDCategory")
        req.resultType = .countResultType
        let count = (try? context.count(for: req)) ?? 0
        guard count == 0 else { return }

        let defaults: [(String,String,String,Bool)] = [
            ("Groceries","needs","🛒",false),
            ("Rent","needs","🏠",false),
            ("Utilities","needs","💡",false),
            ("Transport","needs","🚗",false),
            ("Dining","wants","🍽️",false),
            ("Entertainment","wants","🎬",false),
            ("Health","needs","🩺",false),
            ("Shopping","wants","🛍️",false)
        ]

        for (name, type, icon, isCustom) in defaults {
            let obj = NSEntityDescription.insertNewObject(forEntityName: "CDCategory", into: context) as! CDCategory
            obj.id = UUID()
            obj.name = name
            obj.type = type
            obj.icon = icon
            obj.isCustom = isCustom
        }

        try? context.save()
    }
}
