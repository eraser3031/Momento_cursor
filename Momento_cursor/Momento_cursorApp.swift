//
//  Momento_cursorApp.swift
//  Momento_cursor
//
//  Created by 김예훈 on 3/16/25.
//

import SwiftUI

@main
struct Momento_cursorApp: App {
    // 앱 전체에서 사용할 환경 객체들
    @StateObject private var wisdomStore = WisdomStore()
    @StateObject private var aiAssistant: AIAssistant
    
    init() {
        // AIAssistant는 WisdomStore에 의존하므로 초기화 시 주입
        let wisdomStore = WisdomStore()
        _wisdomStore = StateObject(wrappedValue: wisdomStore)
        _aiAssistant = StateObject(wrappedValue: AIAssistant(wisdomStore: wisdomStore))
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(wisdomStore)
                .environmentObject(aiAssistant)
        }
    }
}
