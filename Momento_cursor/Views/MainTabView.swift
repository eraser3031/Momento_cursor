import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 홈 탭
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(0)
            
            // AI 어시스턴트 탭
            AIAssistantView()
                .tabItem {
                    Label("어시스턴트", systemImage: "message.fill")
                }
                .tag(1)
            
            // 프로필 탭
            ProfileView()
                .tabItem {
                    Label("프로필", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(WisdomStore())
        .environmentObject(AIAssistant(wisdomStore: WisdomStore()))
} 