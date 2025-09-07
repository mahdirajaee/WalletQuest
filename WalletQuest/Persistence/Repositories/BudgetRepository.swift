import CoreData

struct BudgetRepository {
    let context: NSManagedObjectContext

    func budgets(forMonth monthKey: String) throws -> [CDBudget] {
        let req = NSFetchRequest<CDBudget>(entityName: "CDBudget")
        req.predicate = NSPredicate(format: "month == %@", monthKey)
        req.sortDescriptors = [NSSortDescriptor(key: "categoryId", ascending: true)]
        return try context.fetch(req)
    }

    func budget(forMonth monthKey: String, categoryId: UUID) -> CDBudget? {
        let req = NSFetchRequest<CDBudget>(entityName: "CDBudget")
        req.predicate = NSPredicate(format: "month == %@ AND categoryId == %@", monthKey, categoryId as CVarArg)
        req.fetchLimit = 1
        return try? context.fetch(req).first
    }

    @discardableResult
    func upsert(month monthKey: String, categoryId: UUID, capAmount: Double) throws -> CDBudget {
        if let existing = budget(forMonth: monthKey, categoryId: categoryId) {
            existing.capAmount = capAmount
            try context.save()
            return existing
        }

        let obj = NSEntityDescription.insertNewObject(forEntityName: "CDBudget", into: context) as! CDBudget
        obj.id = UUID()
        obj.month = monthKey
        obj.categoryId = categoryId
        obj.capAmount = capAmount
        obj.rolloverEnabled = false
        obj.rolloverAmount = 0
        try context.save()
        return obj
    }

    func setRolloverEnabled(_ enabled: Bool, for budget: CDBudget) throws {
        budget.rolloverEnabled = enabled
        try context.save()
    }

    func setCapAmount(_ amount: Double, for budget: CDBudget) throws {
        budget.capAmount = amount
        try context.save()
    }

    /// Persist a computed rollover amount for the budget's month (leftover from this month)
    func setRolloverAmount(_ amount: Double, for budget: CDBudget) throws {
        budget.rolloverAmount = amount
        try context.save()
    }
}

