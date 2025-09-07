import Foundation
import Combine
import UniformTypeIdentifiers
import CoreData

enum CSVField: String, CaseIterable, Identifiable {
    case date = "Date"
    case amount = "Amount"
    case merchant = "Merchant"
    case category = "Category"
    case notes = "Notes"
    var id: String { rawValue }
}

struct CSVPreviewRow: Identifiable {
    let id = UUID()
    let values: [CSVField: String]
    let isValid: Bool
}

final class CSVImportViewModel: ObservableObject {
    @Published var isImporterPresented = false
    @Published var filename: String? = nil
    @Published var headers: [String] = []
    @Published var rows: [[String]] = []
    @Published var mapping: [CSVField: String] = [:] // field -> header name
    @Published var preview: [CSVPreviewRow] = []
    @Published var importResult: (inserted: Int, skipped: Int)?
    @Published var canUndo = false

    private let context: NSManagedObjectContext
    private var lastInsertedIDs: [NSManagedObjectID] = []
    private let repo: TransactionRepository

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        self.repo = TransactionRepository(context: context)
    }

    func handlePickedFile(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            guard let parsed = CSVParser.parse(data) else { return }
            self.filename = url.lastPathComponent
            self.headers = parsed.headers
            self.rows = parsed.rows
            autoMap()
            buildPreview()
        } catch {
            print("CSV read error: \(error)")
        }
    }

    func autoMap() {
        let lower = headers.map { $0.lowercased() }
        func find(_ keys: [String]) -> String? { keys.compactMap { key in lower.firstIndex(where: { $0.contains(key) }) }.first.map { headers[$0] } }
        mapping[.date] = find(["date"]) ?? headers.first
        mapping[.amount] = find(["amount", "amt"]) ?? headers.dropFirst().first
        mapping[.merchant] = find(["merchant", "payee", "description"]) ?? headers.dropFirst(2).first
        mapping[.category] = find(["category", "cat"]) ?? nil
        mapping[.notes] = find(["note", "memo"]) ?? nil
    }

    func buildPreview(limit: Int = 20) {
        guard !headers.isEmpty else { preview = []; return }
        let headerIndex = Dictionary(uniqueKeysWithValues: headers.enumerated().map { ($1, $0) })
        preview = rows.prefix(limit).map { cols in
            var values: [CSVField: String] = [:]
            var valid = true
            for field in CSVField.allCases {
                if let header = mapping[field], let idx = headerIndex[header], idx < cols.count {
                    values[field] = cols[idx]
                } else {
                    values[field] = ""
                    if field == .date || field == .amount || field == .merchant { valid = false }
                }
            }
            return CSVPreviewRow(values: values, isValid: valid)
        }
    }

    func importAll() {
        guard !headers.isEmpty else { return }
        let headerIndex = Dictionary(uniqueKeysWithValues: headers.enumerated().map { ($1, $0) })
        var inserted = 0
        var skipped = 0
        lastInsertedIDs.removeAll()
        let df = ISO8601DateFormatter()
        let alt = DateFormatter(); alt.dateFormat = "yyyy-MM-dd"

        context.performAndWait {
            for cols in rows {
                guard let hDate = mapping[.date], let iDate = headerIndex[hDate], iDate < cols.count,
                      let hAmt = mapping[.amount], let iAmt = headerIndex[hAmt], iAmt < cols.count,
                      let hMerchant = mapping[.merchant], let iMerch = headerIndex[hMerchant], iMerch < cols.count
                else { skipped += 1; continue }

                let dateStr = cols[iDate]
                let amountStr = cols[iAmt]
                let merchStr = cols[iMerch]

                let date = df.date(from: dateStr) ?? alt.date(from: dateStr) ?? Date()
                let amount = Double(amountStr.replacingOccurrences(of: ",", with: "")) ?? 0
                let hash = TransactionRepository.makeHash(date: date, merchant: merchStr, amount: amount)

                // Duplicate check
                let req = NSFetchRequest<CDTransaction>(entityName: "CDTransaction")
                req.predicate = NSPredicate(format: "txHash == %@", hash)
                req.fetchLimit = 1
                if let count = try? context.count(for: req), count > 0 { skipped += 1; continue }

                let tx = NSEntityDescription.insertNewObject(forEntityName: "CDTransaction", into: context) as! CDTransaction
                tx.id = UUID()
                tx.date = date
                tx.amount = amount
                tx.merchant = merchStr
                if let hCat = mapping[.category], let iCat = headerIndex[hCat], iCat < cols.count, !cols[iCat].isEmpty {
                    let catName = cols[iCat]
                    if let cat = CategoryRepository(context: context).findByNameInsensitive(catName), let id = cat.id {
                        tx.categoryId = id
                    }
                }
                if let hNote = mapping[.notes], let iNote = headerIndex[hNote], iNote < cols.count { tx.notes = cols[iNote] }
                tx.isRecurring = false
                tx.isExcluded = false
                tx.source = "csv"
                tx.txHash = hash
                inserted += 1
                lastInsertedIDs.append(tx.objectID)
            }
            try? context.save()
        }

        self.importResult = (inserted, skipped)
        self.canUndo = !lastInsertedIDs.isEmpty
    }

    func undoLastImport() {
        guard !lastInsertedIDs.isEmpty else { return }
        context.performAndWait {
            for oid in lastInsertedIDs {
                if let obj = try? context.existingObject(with: oid) { context.delete(obj) }
            }
            try? context.save()
        }
        lastInsertedIDs.removeAll()
        canUndo = false
        importResult = nil
    }
}
