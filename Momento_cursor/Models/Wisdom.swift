import Foundation

enum WisdomSource: String, Codable, CaseIterable {
    case selfWritten = "직접 작성"
    case quote = "명언/인용"
    case book = "책"
    case movie = "영화"
    case conversation = "대화"
    case music = "음악"
    case other = "기타"
}

enum WisdomCategory: String, Codable, CaseIterable {
    case motivation = "동기부여"
    case reflection = "자기성찰"
    case healing = "치유/위로"
    case decision = "결정/선택"
    case relationship = "관계"
    case growth = "성장"
    case happiness = "행복"
    case other = "기타"
}

enum WisdomContentType: String, Codable, CaseIterable {
    case text = "텍스트"
    case image = "이미지"
    case url = "URL"
}

struct Wisdom: Identifiable, Codable {
    var id = UUID()
    var content: String
    var contentType: WisdomContentType
    var source: WisdomSource
    var category: WisdomCategory
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    var context: String?  // 이 지혜를 얻게 된 상황이나 배경
    var mediaURL: URL?    // 관련 이미지, 비디오 등의 URL
    
    init(
        content: String,
        contentType: WisdomContentType = .text,
        source: WisdomSource = .selfWritten,
        category: WisdomCategory = .other,
        context: String? = nil,
        mediaURL: URL? = nil,
        isFavorite: Bool = false
    ) {
        self.content = content
        self.contentType = contentType
        self.source = source
        self.category = category
        self.context = context
        self.mediaURL = mediaURL
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isFavorite = isFavorite
    }
}

// 지혜 데이터를 관리하는 클래스
class WisdomStore: ObservableObject {
    @Published var wisdoms: [Wisdom] = []
    
    private let saveKey = "savedWisdoms2"
    
    init() {
        loadWisdoms()
    }
    
    func addWisdom(_ wisdom: Wisdom) {
        wisdoms.append(wisdom)
        saveWisdoms()
    }
    
    func updateWisdom(_ wisdom: Wisdom) {
        if let index = wisdoms.firstIndex(where: { $0.id == wisdom.id }) {
            var updatedWisdom = wisdom
            updatedWisdom.updatedAt = Date()
            wisdoms[index] = updatedWisdom
            saveWisdoms()
        }
    }
    
    func deleteWisdom(at indexSet: IndexSet) {
        wisdoms.remove(atOffsets: indexSet)
        saveWisdoms()
    }
    
    func deleteWisdom(id: UUID) {
        wisdoms.removeAll { $0.id == id }
        saveWisdoms()
    }
    
    func toggleFavorite(_ wisdom: Wisdom) {
        if let index = wisdoms.firstIndex(where: { $0.id == wisdom.id }) {
            wisdoms[index].isFavorite.toggle()
            wisdoms[index].updatedAt = Date()
            saveWisdoms()
        }
    }
    
    func saveWisdoms() {
        if let encoded = try? JSONEncoder().encode(wisdoms) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadWisdoms() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Wisdom].self, from: data) {
                wisdoms = decoded
                return
            }
        }
        
        // 기본 데이터가 없으면 샘플 데이터 추가
        wisdoms = sampleWisdoms
    }
    
    // 샘플 데이터
    private var sampleWisdoms: [Wisdom] = [
        Wisdom(
            content: "오늘 할 수 있는 일을 내일로 미루지 마라.",
            source: .quote,
            category: .motivation,
            context: "일을 미루다가 결국 마감에 쫓겨 후회했을 때 발견한 명언"
        ),
        Wisdom(
            content: "실패는 성공의 어머니다. 실패에서 배우는 자세가 중요하다.",
            source: .selfWritten,
            category: .growth,
            context: "실패와 성장"
        ),
        Wisdom(
            content: "진정한 친구는 당신의 성공을 자신의 성공처럼 기뻐해 주는 사람이다.",
            source: .book,
            category: .relationship,
            context: "진정한 우정"
        )
    ]
} 
