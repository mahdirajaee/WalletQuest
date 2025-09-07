import SwiftUI

struct StarterBudgetView: View {
    @ObservedObject var vm: StarterBudgetViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Starter budget").font(.title2).bold()
            TextField("Monthly net income", text: Binding(
                get: { vm.netIncome },
                set: { vm.onIncomeChange($0) }
            ))
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)

            List(vm.suggestions) { cap in
                HStack {
                    Text(cap.category.name ?? "Category")
                    Spacer()
                    Text(String(format: "$%.0f", cap.amount))
                        .monospacedDigit()
                }
            }
            .listStyle(.plain)

            Button("Save & continue") {
                vm.saveBudgets()
                onContinue()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("btn_starterbudget_continue")
        }
        .padding()
    }
}

#Preview {
    StarterBudgetView(vm: StarterBudgetViewModel()) { }
}
