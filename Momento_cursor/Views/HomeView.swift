import SwiftUI

struct HomeView: View {
    @EnvironmentObject var wisdomStore: WisdomStore
    @State private var showingDailyWisdom = true
    @State private var dailyWisdom: Wisdom?
    @State private var showingAddWisdom = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 빠른 액션 버튼들 - 상단으로 이동
                    quickActionsSection
                    
                    // 오늘의 지혜
                    if showingDailyWisdom {
                        dailyWisdomCard
                    }
                    
                    // 지혜 저장소
                    WisdomListView()
                        .frame(maxHeight: .infinity)
                }
                .padding()
            }
            .navigationTitle("Momento")
            .onAppear {
                selectDailyWisdom()
            }
            .sheet(isPresented: $showingAddWisdom) {
                AddWisdomView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddWisdom = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    // 오늘의 지혜 카드
    private var dailyWisdomCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("오늘의 지혜")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    selectDailyWisdom()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
            }
            
            if let wisdom = dailyWisdom {
                VStack(alignment: .leading, spacing: 8) {
                    Text(wisdom.content)
                        .font(.title3)
                        .fontWeight(.medium)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Text(wisdom.source.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                        
                        Text(wisdom.category.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            } else {
                Text("지혜를 추가하면 여기에 표시됩니다.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.vertical)
    }
    
    // 빠른 액션 버튼들
    private var quickActionsSection: some View {
        VStack(spacing: 15) {
            Button(action: {
                showingAddWisdom = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("새로운 지혜 추가하기")
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
        .padding(.vertical, 10)
    }
    
    // 오늘의 지혜 선택
    private func selectDailyWisdom() {
        if !wisdomStore.wisdoms.isEmpty {
            dailyWisdom = wisdomStore.wisdoms.randomElement()
        } else {
            dailyWisdom = nil
        }
    }
    
    // 특정 카테고리의 지혜 개수 계산
    private func wisdomsCount(for category: WisdomCategory) -> Int {
        return wisdomStore.wisdoms.filter { $0.category == category }.count
    }
}

// 지혜 카드 컴포넌트
struct WisdomCard: View {
    let wisdom: Wisdom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(wisdom.content)
                .font(.subheadline)
                .lineLimit(2)
            
            HStack {
                Text(wisdom.source.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(wisdom.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// 카테고리 카드 컴포넌트
struct CategoryCard: View {
    let category: WisdomCategory
    let count: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(category.rawValue)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("\(count)개")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// 카테고리별 지혜 목록 뷰
struct CategoryWisdomsView: View {
    @EnvironmentObject var wisdomStore: WisdomStore
    let category: WisdomCategory
    
    var filteredWisdoms: [Wisdom] {
        wisdomStore.wisdoms.filter { $0.category == category }
    }
    
    var body: some View {
        List {
            ForEach(filteredWisdoms) { wisdom in
                NavigationLink(destination: WisdomDetailView(wisdom: wisdom)) {
                    WisdomRow(wisdom: wisdom)
                }
            }
        }
        .navigationTitle(category.rawValue)
        .listStyle(InsetGroupedListStyle())
    }
}

// 지혜 분석 뷰
struct WisdomAnalysisView: View {
    @EnvironmentObject var aiAssistant: AIAssistant
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("지혜 분석")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(aiAssistant.analyzeWisdoms())
                    .font(.body)
                    .lineSpacing(5)
            }
            .padding()
        }
        .navigationTitle("지혜 분석")
    }
}

#Preview {
    HomeView()
        .environmentObject(WisdomStore())
} 
