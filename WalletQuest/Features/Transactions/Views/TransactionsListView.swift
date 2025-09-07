import SwiftUI
import CoreData

struct TransactionsListView: View {
    @StateObject var vm = TransactionsListViewModel()
    @State private var showingAdd = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        DatePicker("Month", selection: $vm.month, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        TextField("Search", text: $vm.search)
                            .textFieldStyle(.roundedBorder)
                    }
                    CategoryFilterBar(selected: Binding(
                        get: { vm.categoryId },
                        set: { vm.categoryId = $0; vm.reload() }
                    ))
                }
                .onChange(of: vm.month) { _, _ in vm.reload() }
                .onChange(of: vm.search) { _, _ in vm.reload() }
            }

            if vm.items.isEmpty {
                VStack(alignment: .center, spacing: 8) {
                    Text("No transactions yet")
                    Text("Add your first purchase")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                ForEach(vm.items, id: \.objectID) { tx in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(tx.merchant ?? "Merchant")
                            Text(tx.date ?? Date(), style: .date)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(CurrencyFormatter.string(from: tx.amount))
                            .monospacedDigit()
                    }
                }
                .onDelete { indexSet in
                    // Optional: implement
                }
            }
        }
        .navigationTitle("Transactions")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAdd = true } label: { Image(systemName: "plus") }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: CSVImportView(vm: CSVImportViewModel())) {
                    Image(systemName: "square.and.arrow.down")
                }
                .accessibilityIdentifier("btn_nav_import_csv")
            }
        }
        .sheet(isPresented: $showingAdd, onDismiss: { vm.reload() }) {
            AddEditTransactionView(vm: AddEditTransactionViewModel())
        }
        .onAppear { vm.reload() }
    }
}

#Preview { NavigationStack { TransactionsListView() } }

// MARK: - Category Filter Bar

struct CategoryFilterBar: View {
    @State private var categories: [CDCategory] = []
    @Binding var selected: UUID?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selected == nil) {
                    selected = nil
                }
                ForEach(categories, id: \.objectID) { c in
                    let sel = (c.id != nil) && (selected == c.id!)
                    FilterChip(title: (c.icon ?? "") + " " + (c.name ?? ""), isSelected: sel) {
                        selected = c.id
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .onAppear { load() }
    }

    private func load() {
        let repo = CategoryRepository(context: CoreDataStack.shared.viewContext)
        categories = (try? repo.all()) ?? []
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
