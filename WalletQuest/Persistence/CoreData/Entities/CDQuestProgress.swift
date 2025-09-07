import CoreData

@objc(CDQuestProgress)
class CDQuestProgress: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var questId: UUID?
    @NSManaged var startDate: Date?
    @NSManaged var status: String?
    @NSManaged var progressValue: Double
}

