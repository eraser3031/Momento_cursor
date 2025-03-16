//
//  ContentView.swift
//  Momento_cursor
//
//  Created by 김예훈 on 3/16/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var wisdomStore: WisdomStore
    @EnvironmentObject var aiAssistant: AIAssistant
    
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environmentObject(WisdomStore())
        .environmentObject(AIAssistant(wisdomStore: WisdomStore()))
}
