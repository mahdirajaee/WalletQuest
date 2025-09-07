import SwiftUI

struct OnboardingWelcomeView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to WalletQuest").font(.title2).bold()
            Text("Turn saving money into a game.")
                .foregroundStyle(.secondary)

            Button("Get started") { vm.next() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    OnboardingWelcomeView(vm: OnboardingViewModel())
}
