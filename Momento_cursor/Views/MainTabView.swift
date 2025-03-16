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
            
            // 지혜 저장소 탭
            WisdomListView()
                .tabItem {
                    Label("지혜", systemImage: "book.fill")
                }
                .tag(1)
            
            // AI 어시스턴트 탭
            AIAssistantView()
                .tabItem {
                    Label("어시스턴트", systemImage: "message.fill")
                }
                .tag(2)
            
            // 프로필 탭
            ProfileView()
                .tabItem {
                    Label("프로필", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(WisdomStore())
        .environmentObject(AIAssistant(wisdomStore: WisdomStore()))
} 