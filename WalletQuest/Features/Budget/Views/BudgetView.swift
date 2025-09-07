import SwiftUI
import CoreData

struct BudgetView: View {
    @StateObject var vm = BudgetViewModel()

    var body: some View {
        List {
            Section {
                HStack {
                    DatePicker("Month", selection: $vm.month, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
            }

            SummarySection(summary: vm.summary, overspends: vm.topOverspends, savings: vm.topSavings)

            if vm.envelopes.isEmpty {
                VStack(alignment: .center, spacing: 8) {
                    Text("No budget caps yet")
                    Text("Set caps to start tracking")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                ForEach(vm.envelopes) { env in
                    BudgetEnvelopeRow(
                        envelope: env,
                        isSoftAcked: vm.isAlertAcknowledged(for: env, level: .soft75),
                        isHardAcked: vm.isAlertAcknowledged(for: env, level: .hard90)
                    ) { newCap in
                        vm.updateCap(for: env, newCap: newCap)
                    } toggleRollover: { enabled in
                        vm.toggleRollover(for: env, enabled: enabled)
                    } onAlertTapped: { level in
                        vm.acknowledgeAlert(for: env, level: level)
                    }
                }
            }
        }
        .navigationTitle("Budget")
        .onAppear { vm.load() }
    }
}

struct BudgetEnvelopeRow: View {
    let envelope: BudgetEnvelope
    let isSoftAcked: Bool
    let isHardAcked: Bool
    var onCapChange: (Double) -> Void
    var toggleRollover: (Bool) -> Void
    var onAlertTapped: (BudgetAlertLevel) -> Void

    @State private var capText: String = ""
    @State private var showQuestSuggestion: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(envelope.categoryIcon)
                Text(envelope.categoryName)
                    .font(.headline)
                Spacer()
                NeedsWantsBadge(type: envelope.categoryType)
            }

            ProgressView(value: envelope.progress)
                .tint(envelope.hardAlert ? .red : (envelope.softAlert ? .orange : .green))
            HStack {
                Text("Spent: \(CurrencyFormatter.string(from: envelope.spentAmount)) of \(CurrencyFormatter.string(from: envelope.effectiveCap))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            HStack(spacing: 12) {
                TextField("Cap", text: $capText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 120)
                    .onSubmit { commitCap() }
                    .onDisappear { commitCap() }

                Toggle("Rollover", isOn: Binding(get: { envelope.rolloverEnabled }, set: { toggleRollover($0) }))
                    .toggleStyle(.switch)
                    .labelsHidden()

                if envelope.softAlert && !isSoftAcked {
                    AlertPill(text: "75% reached", color: .orange) {
                        onAlertTapped(.soft75)
                        showQuestSuggestion = true
                    }
                }
                if envelope.hardAlert && !isHardAcked {
                    AlertPill(text: "90% reached", color: .red) {
                        onAlertTapped(.hard90)
                        showQuestSuggestion = true
                    }
                }
            }
        }
        .onAppear { capText = numberString(envelope.capAmount) }
        .sheet(isPresented: $showQuestSuggestion) {
            QuestSuggestionSheet(categoryName: envelope.categoryName)
        }
        .accessibilityElement(children: .combine)
    }

    private func commitCap() {
        guard let val = Double(capText) else { return }
        onCapChange(val)
    }

    private func numberString(_ val: Double) -> String {
        let f = NumberFormatter()
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: val)) ?? String(val)
    }
}

// MARK: - Summary

struct SummarySection: View {
    let summary: BudgetSummary
    let overspends: [BudgetDelta]
    let savings: [BudgetDelta]

    var body: some View {
        Section(header: Text("Summary")) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    GroupBox(label: Text("Needs").font(.caption).foregroundStyle(.secondary)) {
                        VStack(alignment: .leading, spacing: 6) {
                            ProgressView(value: summary.needsProgress)
                                .tint(.green)
                            HStack {
                                Text("\(CurrencyFormatter.string(from: summary.needsSpent)) / \(CurrencyFormatter.string(from: summary.needsCap))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        }
                        .padding(.top, 4)
                    }
                    GroupBox(label: Text("Wants").font(.caption).foregroundStyle(.secondary)) {
                        VStack(alignment: .leading, spacing: 6) {
                            ProgressView(value: summary.wantsProgress)
                                .tint(.blue)
                            HStack {
                                Text("\(CurrencyFormatter.string(from: summary.wantsSpent)) / \(CurrencyFormatter.string(from: summary.wantsCap))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        }
                        .padding(.top, 4)
                    }
                }

                if !overspends.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Top Overspends")
                            .font(.subheadline).bold()
                        ForEach(overspends) { d in
                            HStack {
                                Text("\(d.icon) \(d.name)")
                                Spacer()
                                Text("+\(CurrencyFormatter.string(from: d.delta))")
                                    .foregroundStyle(.red)
                                    .monospacedDigit()
                            }
                        }
                    }
                }

                if !savings.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Top Savings")
                            .font(.subheadline).bold()
                        ForEach(savings) { d in
                            HStack {
                                Text("\(d.icon) \(d.name)")
                                Spacer()
                                Text("\(CurrencyFormatter.string(from: d.delta)) saved")
                                    .foregroundStyle(.green)
                                    .monospacedDigit()
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct NeedsWantsBadge: View {
    let type: String
    var body: some View {
        Text(type.capitalized)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(type == "needs" ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
            .clipShape(Capsule())
    }
}

struct AlertPill: View {
    let text: String
    let color: Color
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                Text(text)
            }
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundColor(color)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.6), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct QuestSuggestionSheet: View {
    let categoryName: String
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("You're nearing your \(categoryName) cap.")
                    .font(.headline)
                Text("Try a quick quest to save: cook at home once, swap a ride for a walk, or pause one treat this week.")
                    .font(.body)
                Spacer()
                NavigationLink(destination: QuestsListView()) {
                    Label("View Quests", systemImage: "flag.checkered")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Take Action")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}

#Preview { NavigationStack { BudgetView() } }
