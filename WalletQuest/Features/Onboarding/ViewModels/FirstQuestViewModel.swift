import Foundation
import Combine
import CoreData

struct QuestDef: Identifiable, Hashable {
    let id: UUID
    let title: String
    let type: String
    let estSavings: Double
    let rewardXP: Int
}

final class FirstQuestViewModel: ObservableObject {
    @Published var quests: [QuestDef] = [
        .init(id: UUID(), title: "Cut Dining by $15", type: "weekly", estSavings: 15, rewardXP: 25),
        .init(id: UUID(), title: "No-Spend Weekend", type: "weekly", estSavings: 20, rewardXP: 25),
        .init(id: UUID(), title: "Groceries Under Budget", type: "weekly", estSavings: 10, rewardXP: 25),
        .init(id: UUID(), title: "Cancel a Dead Subscription", type: "weekly", estSavings: 8, rewardXP: 25)
    ]

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }

    func start(_ q: QuestDef) {
        let quest = NSEntityDescription.insertNewObject(forEntityName: "CDQuest", into: context) as! CDQuest
        quest.id = q.id
        quest.type = q.type
        quest.title = q.title
        quest.targetMetric = "savings"
        quest.targetValue = q.estSavings
        quest.rewardXP = Int16(q.rewardXP)
        quest.rewardCoins = 0
        quest.premiumOnly = false

        let prog = NSEntityDescription.insertNewObject(forEntityName: "CDQuestProgress", into: context) as! CDQuestProgress
        prog.id = UUID()
        prog.questId = q.id
        prog.startDate = Date()
        prog.status = "inProgress"
        prog.progressValue = 0

        try? context.save()
    }
}

