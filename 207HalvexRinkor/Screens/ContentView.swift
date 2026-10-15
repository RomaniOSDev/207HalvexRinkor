import SwiftUI

struct ContentView: View {
    @StateObject private var vault = HrxRinkVault()

    var body: some View {
        ZStack {
            if vault.onboardingCleared {
                HrxLaneShell()
                    .transition(.move(edge: .trailing))
            } else {
                HrxGlideIntroPane()
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: vault.onboardingCleared)
        .environmentObject(vault)
        .onAppear { vault.hrxStampVisit() }
    }
}
