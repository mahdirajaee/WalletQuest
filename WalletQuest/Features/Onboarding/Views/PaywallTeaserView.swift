import SwiftUI

struct PaywallTeaserView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Premium pays for itself")
                .font(.title2).bold()
            Text("Average save $38/month. Try Premium later from the Home screen.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Continue to Home") { onContinue() }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("btn_teaser_continue")
        }
        .padding()
    }
}

#Preview { PaywallTeaserView(onContinue: {}) }
