import SwiftUI

struct OnboardingGoalsView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Pick your goals").font(.title2).bold()
            Text("Choose at least one to personalize your plan.")
                .foregroundStyle(.secondary)

            List {
                ForEach(OnboardingConstants.goalOptions) { goal in
                    HStack {
                        Text(goal.title)
                        Spacer()
                        if vm.selectedGoals.contains(goal) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint) }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { vm.toggleGoal(goal) }
                }
            }
            .listStyle(.plain)

            Button("Continue") { vm.next() }
                .buttonStyle(.borderedProminent)
                .disabled(vm.selectedGoals.isEmpty)
        }
        .padding()
    }
}

#Preview {
    OnboardingGoalsView(vm: OnboardingViewModel())
}

