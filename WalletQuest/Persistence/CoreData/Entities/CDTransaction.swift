import CoreData

@objc(CDTransaction)
class CDTransaction: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var date: Date?
    @NSManaged var amount: Double
    @NSManaged var merchant: String?
    @NSManaged var categoryId: UUID?
    @NSManaged var notes: String?
    @NSManaged var isRecurring: Bool
    @NSManaged var isExcluded: Bool
    @NSManaged var source: String?
    @NSManaged var externalTxId: String?
    @NSManaged var txHash: String?
}
