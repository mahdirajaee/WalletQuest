import SwiftUI
import UniformTypeIdentifiers

struct CSVImportView: View {
    @ObservedObject var vm: CSVImportViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    Text(vm.filename ?? "Choose a CSV file").font(.subheadline)
                    Spacer()
                    Button("Browse") { vm.isImporterPresented = true }
                }
                .padding(.horizontal)

                if !vm.headers.isEmpty {
                    Form {
                        Section(header: Text("Map Columns")) {
                            ForEach(CSVField.allCases) { field in
                                Picker(field.rawValue, selection: binding(for: field)) {
                                    Text("—").tag("")
                                    ForEach(vm.headers, id: \.self) { h in Text(h).tag(h) }
                                }
                            }
                        }

                        Section(header: Text("Preview")) {
                            if vm.preview.isEmpty {
                                Text("No rows to preview")
                            } else {
                                ForEach(vm.preview) { row in
                                    HStack {
                                        Text(row.values[.date] ?? "").frame(width: 90, alignment: .leading)
                                        Text(row.values[.merchant] ?? "").frame(maxWidth: .infinity, alignment: .leading)
                                        Text(row.values[.amount] ?? "").frame(width: 80, alignment: .trailing)
                                    }
                                    .foregroundStyle(row.isValid ? Color.primary : Color.red)
                                }
                            }
                        }

                        if let result = vm.importResult {
                            Section(header: Text("Result")) {
                                Text("Inserted: \(result.inserted), Skipped: \(result.skipped)")
                                if vm.canUndo { Button("Undo last import") { vm.undoLastImport() } }
                            }
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("Select a CSV to begin")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Import CSV")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") { vm.importAll() }
                        .disabled(vm.headers.isEmpty)
                }
            }
        }
        .fileImporter(isPresented: $vm.isImporterPresented, allowedContentTypes: [.commaSeparatedText, .plainText]) { res in
            if case .success(let url) = res { vm.handlePickedFile(url: url) }
        }
    }
}

private extension CSVImportView {
    func binding(for field: CSVField) -> Binding<String> {
        Binding<String>(
            get: { vm.mapping[field] ?? "" },
            set: { newValue in
                vm.mapping[field] = newValue
                vm.buildPreview()
            }
        )
    }
}

#Preview { CSVImportView(vm: CSVImportViewModel()) }
