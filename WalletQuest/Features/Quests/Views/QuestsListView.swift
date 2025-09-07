import SwiftUI

struct QuestsListView: View {
    var body: some View {
        List {
            Section(footer: Text("Quests are coming soon.")) {
                Label("Weekly: Groceries Under Budget (+25 XP)", systemImage: "flag.checkered")
                Label("Daily: Log your spending (+5 XP)", systemImage: "checkmark.circle")
                Label("Weekend: No-Spend Day (+10 XP)", systemImage: "sun.max")
            }
        }
        .navigationTitle("Quests")
    }
}

#Preview { NavigationStack { QuestsListView() } }

