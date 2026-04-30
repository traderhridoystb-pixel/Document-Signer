import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingPaywall = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(showingPaywall: $showingPaywall)
                .tabItem {
                    Label("Documents", systemImage: "doc.text")
                }
                .tag(0)

            SignatureManagerView()
                .tabItem {
                    Label("Signatures", systemImage: "signature")
                }
                .tag(1)

            SettingsView(showingPaywall: $showingPaywall)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .tint(SignerColors.primary)
        .sheet(isPresented: $showingPaywall) {
            PaywallView(isFromOnboarding: false)
        }
    }
}
