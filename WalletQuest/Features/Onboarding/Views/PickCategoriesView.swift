import SwiftUI

struct PickCategoriesView: View {
    @ObservedObject var vm: PickCategoriesViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Pick 3 categories").font(.title2).bold()
            Text("Choose at least three to focus on first.")
                .foregroundStyle(.secondary)

            List(vm.categories, id: \.objectID) { cat in
                HStack {
                    Text("\(cat.icon ?? "")  \(cat.name ?? "")")
                    Spacer()
                    if let id = cat.id, vm.selected.contains(id) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { vm.toggle(cat) }
            }
            .listStyle(.plain)

            Button("Continue") { onContinue() }
                .buttonStyle(.borderedProminent)
                .disabled(vm.selected.count < 3)
                .accessibilityIdentifier("btn_pick3_continue")
        }
        .padding()
    }
}

#Preview { PickCategoriesView(vm: PickCategoriesViewModel()) {} }
