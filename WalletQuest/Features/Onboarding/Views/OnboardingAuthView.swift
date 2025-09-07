import SwiftUI
import AuthenticationServices

struct OnboardingAuthView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Sign in to save your progress")
                .font(.title2).bold()
                .multilineTextAlignment(.center)

            SignInWithAppleButton(.continue) { _ in
                // In MVP, assume success; integrate real handler later
                vm.next()
            } onCompletion: { _ in }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 48)
            .accessibilityIdentifier("btn_signin_apple")

            Button("Use email instead") { vm.next() }
                .accessibilityIdentifier("btn_use_email")

            Button("Continue without account") { vm.next() }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("btn_continue_without_account")
        }
        .padding()
    }
}

#Preview {
    OnboardingAuthView(vm: OnboardingViewModel())
}
