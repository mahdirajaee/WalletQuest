import SwiftUI

struct CategoriesListView: View {
    @StateObject var vm = CategoriesListViewModel()
    @State private var showingAdd = false

    var body: some View {
        List {
            ForEach(vm.items, id: \.objectID) { cat in
                HStack {
                    Text((cat.icon ?? "") + " " + (cat.name ?? ""))
                    Spacer()
                    Text((cat.type ?? "").capitalized)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingAdd, onDismiss: { vm.reload() }) {
            NavigationStack { AddEditCategoryView(vm: AddEditCategoryViewModel()) }
        }
    }
}

#Preview { NavigationStack { CategoriesListView() } }

