import CoreData

@objc(CDCategory)
class CDCategory: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var icon: String?
    @NSManaged var isCustom: Bool
}

