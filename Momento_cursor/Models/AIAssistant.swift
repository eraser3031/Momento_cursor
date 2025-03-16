import Foundation

enum AIPersonaType: String, CaseIterable, Identifiable {
    case motivator = "동기부여자"
    case counselor = "상담사"
    case philosopher = "철학자"
    case friend = "친구"
    case mentor = "멘토"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .motivator:
            return "당신에게 열정과 에너지를 불어넣어 줄 동기부여자입니다."
        case .counselor:
            return "당신의 고민을 경청하고 해결책을 함께 찾아줄 상담사입니다."
        case .philosopher:
            return "깊은 통찰력으로 삶의 의미를 함께 고민할 철학자입니다."
        case .friend:
            return "편안하게 대화할 수 있는 친구 같은 존재입니다."
        case .mentor:
            return "경험과 지혜를 바탕으로 당신의 성장을 도울 멘토입니다."
        }
    }
}

struct AIMessage: Identifiable {
    var id = UUID()
    var content: String
    var isUser: Bool
    var timestamp: Date
    var relatedWisdoms: [UUID]?  // 관련된 지혜 ID 목록
    
    init(content: String, isUser: Bool, relatedWisdoms: [UUID]? = nil) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.relatedWisdoms = relatedWisdoms
    }
}

class AIAssistant: ObservableObject {
    @Published var currentPersona: AIPersonaType = .mentor
    @Published var messages: [AIMessage] = []
    @Published var isProcessing = false
    
    private var wisdomStore: WisdomStore
    
    init(wisdomStore: WisdomStore) {
        self.wisdomStore = wisdomStore
        
        // 초기 메시지 추가
        addSystemMessage("안녕하세요! 저는 당신의 Momento 어시스턴트입니다. 어떻게 도와드릴까요?")
    }
    
    func changePersona(to persona: AIPersonaType) {
        currentPersona = persona
        addSystemMessage("\(persona.rawValue)로 전환했습니다. 무엇을 도와드릴까요?")
    }
    
    func addUserMessage(_ content: String) {
        let message = AIMessage(content: content, isUser: true)
        messages.append(message)
        
        // 실제 앱에서는 여기서 AI 응답을 생성하는 로직이 들어갑니다
        processUserMessage(content)
    }
    
    private func addSystemMessage(_ content: String) {
        let message = AIMessage(content: content, isUser: false)
        messages.append(message)
    }
    
    // 사용자 메시지 처리 및 AI 응답 생성
    private func processUserMessage(_ content: String) {
        isProcessing = true
        
        // 실제 앱에서는 여기서 OpenAI API 등을 호출하여 응답을 생성합니다
        // 현재는 간단한 시뮬레이션만 구현합니다
        
        // 관련 지혜 찾기
        let relatedWisdoms = findRelatedWisdoms(to: content)
        let wisdomIds = relatedWisdoms.map { $0.id }
        
        // 지연 효과를 위해 DispatchQueue 사용
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let response = self.generateResponse(to: content, with: relatedWisdoms)
            let aiMessage = AIMessage(content: response, isUser: false, relatedWisdoms: wisdomIds)
            self.messages.append(aiMessage)
            self.isProcessing = false
        }
    }
    
    // 관련 지혜 찾기 (간단한 키워드 매칭)
    private func findRelatedWisdoms(to message: String) -> [Wisdom] {
        // 실제 앱에서는 더 정교한 알고리즘을 사용해야 합니다
        // 현재는 간단한 키워드 매칭만 구현합니다
        
        let keywords = message.lowercased().split(separator: " ")
        
        return wisdomStore.wisdoms.filter { wisdom in
            let content = wisdom.content.lowercased()
            return keywords.contains { keyword in
                content.contains(keyword)
            }
        }
    }
    
    // 응답 생성 (페르소나에 따라 다른 응답 스타일)
    private func generateResponse(to message: String, with relatedWisdoms: [Wisdom]) -> String {
        // 실제 앱에서는 AI 모델을 사용하여 더 정교한 응답을 생성해야 합니다
        
        if relatedWisdoms.isEmpty {
            // 관련 지혜가 없는 경우
            switch currentPersona {
            case .motivator:
                return "당신의 이야기를 들었습니다. 어떤 목표를 향해 나아가고 계신가요? 함께 동기부여를 해보아요!"
            case .counselor:
                return "그런 상황이 있으셨군요. 더 자세히 이야기해주시겠어요? 함께 해결책을 찾아보겠습니다."
            case .philosopher:
                return "흥미로운 질문입니다. 이것에 대해 어떤 생각을 가지고 계신가요? 함께 깊이 생각해보겠습니다."
            case .friend:
                return "그렇군요! 더 이야기해주세요. 제가 들을게요."
            case .mentor:
                return "귀중한 경험을 공유해주셔서 감사합니다. 이런 상황에서 어떤 배움을 얻으셨나요?"
            }
        } else {
            // 관련 지혜가 있는 경우
            let wisdom = relatedWisdoms[0]  // 간단히 첫 번째 관련 지혜만 사용
            
            switch currentPersona {
            case .motivator:
                return "당신의 이야기를 들으니 이전에 기록하신 지혜가 생각납니다: '\(wisdom.content)' 이 말을 기억하며 앞으로 나아가보는 건 어떨까요?"
            case .counselor:
                return "당신이 이전에 기록한 지혜가 지금 상황에 도움이 될 것 같습니다: '\(wisdom.content)' 이것에 대해 어떻게 생각하시나요?"
            case .philosopher:
                return "흥미롭게도, 당신이 이전에 기록한 지혜가 이 상황과 연결됩니다: '\(wisdom.content)' 이 통찰력이 지금의 상황에 어떤 의미를 가질까요?"
            case .friend:
                return "이야기를 들으니 예전에 당신이 말했던 것이 생각나요: '\(wisdom.content)' 기억나시나요?"
            case .mentor:
                return "당신이 과거에 기록한 지혜를 되새겨볼 때입니다: '\(wisdom.content)' 이 지혜를 현재 상황에 어떻게 적용할 수 있을까요?"
            }
        }
    }
    
    // 지혜 분석 기능
    func analyzeWisdoms() -> String {
        let wisdoms = wisdomStore.wisdoms
        
        if wisdoms.isEmpty {
            return "아직 기록된 지혜가 없습니다. 지혜를 추가하면 분석을 제공해드릴게요."
        }
        
        // 카테고리별 분포 분석
        var categoryCount: [WisdomCategory: Int] = [:]
        for wisdom in wisdoms {
            categoryCount[wisdom.category, default: 0] += 1
        }
        
        // 가장 많은 카테고리 찾기
        let topCategory = categoryCount.max { $0.value < $1.value }?.key ?? .other
        
        // 소스별 분포 분석
        var sourceCount: [WisdomSource: Int] = [:]
        for wisdom in wisdoms {
            sourceCount[wisdom.source, default: 0] += 1
        }
        
        // 가장 많은 소스 찾기
        let topSource = sourceCount.max { $0.value < $1.value }?.key ?? .other
        
        // 분석 결과 생성
        var analysis = "현재까지 \(wisdoms.count)개의 지혜를 기록하셨습니다.\n\n"
        
        analysis += "가장 많이 기록하신 카테고리는 '\(topCategory.rawValue)'(\(categoryCount[topCategory] ?? 0)개)입니다. "
        
        switch topCategory {
        case .motivation:
            analysis += "동기부여를 중요하게 생각하시는군요. 목표를 향해 나아가는 열정이 느껴집니다.\n\n"
        case .reflection:
            analysis += "자기성찰을 중요하게 생각하시는군요. 깊이 있는 내면의 여정을 즐기시는 것 같습니다.\n\n"
        case .healing:
            analysis += "치유와 위로를 중요하게 생각하시는군요. 마음의 평화를 찾아가는 여정 중이신 것 같습니다.\n\n"
        case .decision:
            analysis += "결정과 선택에 관한 지혜를 많이 모으셨네요. 중요한 선택의 순간들을 현명하게 대처하고자 하시는군요.\n\n"
        case .relationship:
            analysis += "관계에 관한 지혜를 많이 모으셨네요. 타인과의 관계를 중요하게 생각하시는 것 같습니다.\n\n"
        case .growth:
            analysis += "성장에 관한 지혜를 많이 모으셨네요. 끊임없이 발전하고자 하는 마음이 느껴집니다.\n\n"
        case .happiness:
            analysis += "행복에 관한 지혜를 많이 모으셨네요. 삶의 기쁨을 찾고 누리는 것을 중요하게 생각하시는군요.\n\n"
        case .other:
            analysis += "다양한 주제에 관심을 가지고 계시는군요.\n\n"
        }
        
        analysis += "주로 '\(topSource.rawValue)'에서 지혜를 얻으시는 것 같습니다. "
        
        switch topSource {
        case .selfWritten:
            analysis += "스스로의 생각과 경험에서 지혜를 찾는 통찰력이 돋보입니다."
        case .quote:
            analysis += "명언과 인용구에서 영감을 얻으시는군요. 선인들의 지혜를 소중히 여기시는 것 같습니다."
        case .book:
            analysis += "책을 통해 많은 지혜를 얻으시는군요. 독서를 통한 배움을 중요하게 생각하시는 것 같습니다."
        case .movie:
            analysis += "영화에서 많은 지혜를 발견하시는군요. 시각적 스토리텔링에서 깊은 의미를 찾아내는 능력이 있으신 것 같습니다."
        case .conversation:
            analysis += "대화를 통해 많은 지혜를 얻으시는군요. 타인과의 소통을 중요하게 생각하시는 것 같습니다."
        case .music:
            analysis += "음악에서 많은 지혜를 발견하시는군요. 예술적 감성이 풍부하신 것 같습니다."
        case .other:
            analysis += "다양한 소스에서 지혜를 얻으시는 것 같습니다. 열린 마음으로 세상을 바라보고 계시는군요."
        }
        
        return analysis
    }
} 
