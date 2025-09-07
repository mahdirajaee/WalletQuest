import SwiftUI

struct RootView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var onboardingVM = OnboardingViewModel()

    var body: some View {
        Group {
            if onboardingVM.step == .completed {
                HomeView()
            } else {
                OnboardingFlowView(vm: onboardingVM)
            }
        }
    }
}

struct OnboardingFlowView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        switch vm.step {
        case .welcome:
            OnboardingWelcomeView(vm: vm)
        case .auth:
            OnboardingAuthView(vm: vm)
        case .goals:
            OnboardingGoalsView(vm: vm)
        case .completed:
            EmptyView()
        }
    }
}

#Preview { RootView() }
