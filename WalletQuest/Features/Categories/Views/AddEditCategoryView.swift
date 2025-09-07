import SwiftUI

struct AddEditCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: AddEditCategoryViewModel

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $vm.name)
                Toggle("Needs (off = Wants)", isOn: $vm.isNeeds)
                TextField("Icon (emoji or SF Symbol name)", text: $vm.icon)
            }
        }
        .navigationTitle("New Category")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
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

#Preview { NavigationStack { AddEditCategoryView(vm: AddEditCategoryViewModel()) } }

