import SwiftUI

struct LegalFooterView: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("By continuing, you agree to our Terms and Privacy Policy.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("legal_footer_text")
            HStack(spacing: 16) {
                Link("Terms", destination: URL(string: "https://example.com/terms")!)
                Link("Privacy", destination: URL(string: "https://example.com/privacy")!)
            }
            .font(.caption)
            .accessibilityIdentifier("legal_footer_links")
        }
        .padding(.vertical, 8)
    }
}

