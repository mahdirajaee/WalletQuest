import SwiftUI

struct StepIndicatorView: View {
    let currentIndex: Int
    let total: Int

    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: Double(currentIndex + 1), total: Double(total))
                .accessibilityLabel("Progress")
                .accessibilityValue("Step \(currentIndex + 1) of \(total)")
            Text("Step \(currentIndex + 1) of \(total)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .accessibilityIdentifier("onboarding_step_indicator")
    }
}

