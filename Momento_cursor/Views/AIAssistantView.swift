import SwiftUI

struct AIAssistantView: View {
    @EnvironmentObject var aiAssistant: AIAssistant
    @EnvironmentObject var wisdomStore: WisdomStore
    
    @State private var messageText = ""
    @State private var showingPersonaSheet = false
    @State private var scrollToBottom = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            headerView
            
            // 메시지 목록
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(aiAssistant.messages) { message in
                            MessageBubble(message: message, wisdomStore: wisdomStore)
                                .id(message.id)
                        }
                        
                        // 스크롤 위치를 위한 빈 뷰
                        Color.clear
                            .frame(height: 1)
                            .id("bottomID")
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                }
                .onChange(of: aiAssistant.messages.count) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomID", anchor: .bottom)
                    }
                }
                .onAppear {
                    withAnimation {
                        scrollView.scrollTo("bottomID", anchor: .bottom)
                    }
                }
            }
            
            // 입력 필드
            inputView
        }
        .navigationTitle("AI 어시스턴트")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPersonaSheet) {
            PersonaSelectionView(
                currentPersona: aiAssistant.currentPersona,
                onSelect: { persona in
                    aiAssistant.changePersona(to: persona)
                }
            )
        }
    }
    
    // 헤더 뷰
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    showingPersonaSheet = true
                }) {
                    HStack {
                        Text(aiAssistant.currentPersona.rawValue)
                            .font(.headline)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                }
                
                Spacer()
                
                Button(action: {
                    // 대화 내용 초기화
                    // 실제 앱에서는 확인 다이얼로그를 표시할 수 있습니다
                    aiAssistant.messages = []
                    aiAssistant.addUserMessage("안녕하세요!")
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                        .padding(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
        }
        .background(Color(.systemBackground))
    }
    
    // 입력 뷰
    private var inputView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                TextField("메시지 입력...", text: $messageText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .disabled(aiAssistant.isProcessing)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty || aiAssistant.isProcessing ? .gray : .blue)
                }
                .disabled(messageText.isEmpty || aiAssistant.isProcessing)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
    }
    
    // 메시지 전송
    private func sendMessage() {
        guard !messageText.isEmpty && !aiAssistant.isProcessing else { return }
        
        let text = messageText
        messageText = ""
        
        aiAssistant.addUserMessage(text)
    }
}

// 메시지 버블 컴포넌트
struct MessageBubble: View {
    let message: AIMessage
    let wisdomStore: WisdomStore
    
    @State private var showingRelatedWisdoms = false
    
    var relatedWisdoms: [Wisdom] {
        guard let relatedIds = message.relatedWisdoms else { return [] }
        return wisdomStore.wisdoms.filter { wisdom in
            relatedIds.contains(wisdom.id)
        }
    }
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if !message.isUser {
                    Image(systemName: "brain.head.profile")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding(.trailing, 4)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(message.content)
                        .padding(12)
                        .background(message.isUser ? Color.blue : Color(.systemGray6))
                        .foregroundColor(message.isUser ? .white : .primary)
                        .cornerRadius(16)
                    
                    if !message.isUser && !relatedWisdoms.isEmpty {
                        Button(action: {
                            showingRelatedWisdoms.toggle()
                        }) {
                            HStack {
                                Image(systemName: "quote.bubble")
                                Text("관련 지혜 \(relatedWisdoms.count)개")
                                Image(systemName: showingRelatedWisdoms ? "chevron.up" : "chevron.down")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding(.leading, 12)
                        
                        if showingRelatedWisdoms {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(relatedWisdoms) { wisdom in
                                    NavigationLink(destination: WisdomDetailView(wisdom: wisdom)) {
                                        RelatedWisdomRow(wisdom: wisdom)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                
                if message.isUser {
                    Image(systemName: "person.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding(.leading, 4)
                }
            }
            
            Text(formattedTime(message.timestamp))
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
        .padding(.vertical, 4)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// 관련 지혜 행 컴포넌트
struct RelatedWisdomRow: View {
    let wisdom: Wisdom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(wisdom.content)
                .font(.caption)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            HStack {
                Text(wisdom.source.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                Text(wisdom.category.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// 페르소나 선택 뷰
struct PersonaSelectionView: View {
    let currentPersona: AIPersonaType
    let onSelect: (AIPersonaType) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(AIPersonaType.allCases) { persona in
                    Button(action: {
                        onSelect(persona)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(persona.rawValue)
                                    .font(.headline)
                                
                                Text(persona.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if currentPersona == persona {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("어시스턴트 유형 선택")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// 프로필 뷰
struct ProfileView: View {
    @EnvironmentObject var wisdomStore: WisdomStore
    @EnvironmentObject var aiAssistant: AIAssistant
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("내 지혜 통계")) {
                    HStack {
                        Text("저장된 지혜")
                        Spacer()
                        Text("\(wisdomStore.wisdoms.count)개")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: WisdomAnalysisView()) {
                        Text("지혜 분석")
                    }
                }
                
                Section(header: Text("앱 정보")) {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: Text("개인정보 처리방침 내용").padding()) {
                        Text("개인정보 처리방침")
                    }
                    
                    NavigationLink(destination: Text("이용약관 내용").padding()) {
                        Text("이용약관")
                    }
                }
                
                Section {
                    Button(action: {
                        // 데이터 초기화 (실제 앱에서는 확인 다이얼로그 표시)
                        wisdomStore.wisdoms = []
                        wisdomStore.saveWisdoms()
                    }) {
                        Text("모든 데이터 초기화")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("프로필")
        }
    }
}

#Preview {
    AIAssistantView()
        .environmentObject(WisdomStore())
        .environmentObject(AIAssistant(wisdomStore: WisdomStore()))
} 