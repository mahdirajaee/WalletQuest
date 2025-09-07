import Foundation

enum DateRange {
    static func monthBounds(for date: Date) -> (Date, Date) {
        let cal = Calendar(identifier: .gregorian)
        let start = cal.date(from: cal.dateComponents([.year, .month], from: date)) ?? date
        let end = cal.date(byAdding: DateComponents(month: 1), to: start) ?? date
        return (start, end)
    }
}

