import Foundation

struct CSVParseResult {
    let headers: [String]
    let rows: [[String]]
}

enum CSVParser {
    static func parse(_ data: Data, delimiter: Character = ",") -> CSVParseResult? {
        guard let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) else { return nil }
        // Split by any newline variant and drop empty lines
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard !lines.isEmpty else { return nil }
        let headers = split(line: lines[0], delimiter: delimiter)
        let rows = lines.dropFirst().map { split(line: $0, delimiter: delimiter) }
        return CSVParseResult(headers: headers, rows: rows)
    }

    private static func split(line: String, delimiter: Character) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        for char in line {
            if char == "\"" { inQuotes.toggle(); continue }
            if char == delimiter && !inQuotes { result.append(current.trimmingCharacters(in: .whitespaces)); current = ""; continue }
            current.append(char)
        }
        result.append(current.trimmingCharacters(in: .whitespaces))
        return result
    }
}
