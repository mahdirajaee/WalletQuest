import CoreData

@objc(CDQuest)
class CDQuest: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var type: String?
    @NSManaged var title: String?
    @NSManaged var desc: String?
    @NSManaged var targetMetric: String?
    @NSManaged var targetValue: Double
    @NSManaged var rewardXP: Int16
    @NSManaged var rewardCoins: Int16
    @NSManaged var premiumOnly: Bool
}

