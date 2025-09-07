import CoreData

struct TransactionFilter {
    var month: Date
    var categoryId: UUID?
    var search: String?
}

struct TransactionRepository {
    let context: NSManagedObjectContext

    func add(amount: Double, date: Date, merchant: String, categoryId: UUID?, notes: String?, isRecurring: Bool = false, isExcluded: Bool = false, source: String = "manual", externalTxId: String? = nil) throws {
        let tx = NSEntityDescription.insertNewObject(forEntityName: "CDTransaction", into: context) as! CDTransaction
        tx.id = UUID()
        tx.amount = amount
        tx.date = date
        tx.merchant = merchant
        tx.categoryId = categoryId
        tx.notes = notes
        tx.isRecurring = isRecurring
        tx.isExcluded = isExcluded
        tx.source = source
        tx.externalTxId = externalTxId
        tx.txHash = Self.makeHash(date: date, merchant: merchant, amount: amount)
        try context.save()
    }

    func fetch(filter: TransactionFilter, batchSize: Int = 50) throws -> [CDTransaction] {
        let req = NSFetchRequest<CDTransaction>(entityName: "CDTransaction")
        var predicates: [NSPredicate] = []
        let (start, end) = DateRange.monthBounds(for: filter.month)
        predicates.append(NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate))
        if let cat = filter.categoryId { predicates.append(NSPredicate(format: "categoryId == %@", cat as CVarArg)) }
        if let q = filter.search, !q.isEmpty {
            predicates.append(NSPredicate(format: "merchant CONTAINS[cd] %@ OR notes CONTAINS[cd] %@", q, q))
        }
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        req.fetchBatchSize = batchSize
        return try context.fetch(req)
    }

    func delete(_ object: CDTransaction) throws {
        context.delete(object)
        try context.save()
    }

    static func makeHash(date: Date, merchant: String, amount: Double) -> String {
        let d = ISO8601DateFormatter().string(from: date)
        return "\(d)|\(merchant.uppercased())|\(String(format: "%.2f", amount))"
    }
}

