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
        .onAppear { DataSeeder.run() }
    }
}

struct OnboardingFlowView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                StepIndicatorView(currentIndex: vm.currentIndex, total: vm.totalSteps)
                    .padding(.horizontal)
                Group {
                    switch vm.step {
                    case .welcome:
                        OnboardingWelcomeView(vm: vm)
                            .navigationBarBackButtonHidden()
                    case .auth:
                        OnboardingAuthView(vm: vm)
                    case .goals:
                        OnboardingGoalsView(vm: vm)
                    case .starterBudget:
                        StarterBudgetView(vm: StarterBudgetViewModel()) {
                            vm.next()
                        }
                    case .pickCategories:
                        PickCategoriesView(vm: PickCategoriesViewModel()) {
                            vm.next()
                        }
                    case .firstQuest:
                        FirstQuestView(vm: FirstQuestViewModel()) {
                            vm.next()
                        }
                    case .teaser:
                        PaywallTeaserView() { vm.next() }
                    case .completed:
                        EmptyView()
                    }
                }
                Spacer(minLength: 8)
                LegalFooterView()
            }
            .padding(.bottom)
            .onAppear {
                LoggerAnalytics.shared.track("onboarding_viewed", properties: ["step": String(describing: vm.step)])
            }
            .onChange(of: vm.step) { _, newValue in
                LoggerAnalytics.shared.track("onboarding_viewed", properties: ["step": String(describing: newValue)])
            }
        }
    }
}

#Preview { RootView() }
