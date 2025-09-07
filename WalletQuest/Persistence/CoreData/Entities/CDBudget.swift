import CoreData

@objc(CDBudget)
class CDBudget: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var month: String?
    @NSManaged var categoryId: UUID?
    @NSManaged var capAmount: Double
    @NSManaged var rolloverEnabled: Bool
    @NSManaged var rolloverAmount: Double
}

