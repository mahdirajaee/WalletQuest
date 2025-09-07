import SwiftUI

struct FirstQuestView: View {
    @ObservedObject var vm: FirstQuestViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose your first quest").font(.title2).bold()
            List(vm.quests) { q in
                HStack {
                    VStack(alignment: .leading) {
                        Text(q.title).bold()
                        Text("Weekly • est save $\(Int(q.estSavings)) • \(q.rewardXP) XP")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Start") {
                        vm.start(q)
                        onContinue()
                    }
                    .accessibilityIdentifier("btn_firstquest_start")
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

#Preview { FirstQuestView(vm: FirstQuestViewModel()) {} }
