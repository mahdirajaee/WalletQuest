import SwiftUI

struct AddEditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: AddEditTransactionViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Amount", text: $vm.amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $vm.date, displayedComponents: .date)
                    TextField("Merchant", text: $vm.merchant)
                    TextField("Notes", text: $vm.notes)
                    Toggle("Exclude from budget", isOn: $vm.isExcluded)
                    Toggle("Recurring", isOn: $vm.isRecurring)
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? vm.save()
                        dismiss()
                    }
                    .disabled(!vm.isValid)
                }
            }
        }
    }
}

#Preview { AddEditTransactionView(vm: AddEditTransactionViewModel()) }

