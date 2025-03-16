import SwiftUI

struct WisdomListView: View {
    @EnvironmentObject var wisdomStore: WisdomStore
    @State private var searchText = ""
    @State private var selectedSource: WisdomSource? = nil
    @State private var selectedCategory: WisdomCategory? = nil
    @State private var showingFilterSheet = false
    @State private var showingAddWisdom = false
    
    var filteredWisdoms: [Wisdom] {
        var result = wisdomStore.wisdoms
        
        // 검색어로 필터링
        if !searchText.isEmpty {
            result = result.filter { wisdom in
                wisdom.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 소스로 필터링
        if let source = selectedSource {
            result = result.filter { $0.source == source }
        }
        
        // 카테고리로 필터링
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        return result
    }
    
    var body: some View {
        VStack {
            // 검색 바
            SearchBar(text: $searchText)
            
            // 필터 버튼
            HStack {
                Text("지혜 저장소")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    showingFilterSheet = true
                }) {
                    HStack {
                        Text("필터")
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // 필터 표시
            if selectedSource != nil || selectedCategory != nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        if let source = selectedSource {
                            FilterChip(
                                text: source.rawValue,
                                onRemove: { selectedSource = nil }
                            )
                        }
                        
                        if let category = selectedCategory {
                            FilterChip(
                                text: category.rawValue,
                                onRemove: { selectedCategory = nil }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            if filteredWisdoms.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text(searchText.isEmpty && selectedSource == nil && selectedCategory == nil
                         ? "아직 추가된 지혜가 없습니다."
                         : "검색 결과가 없습니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    if !searchText.isEmpty || selectedSource != nil || selectedCategory != nil {
                        Button(action: {
                            searchText = ""
                            selectedSource = nil
                            selectedCategory = nil
                        }) {
                            Text("필터 초기화")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ForEach(filteredWisdoms) { wisdom in
                    NavigationLink(destination: WisdomDetailView(wisdom: wisdom)) {
                        WisdomRow(wisdom: wisdom)
                    }
                    .buttonStyle(.plain)
                    .compositingGroup()
                    .shadow(radius: 1)
                }
                .onDelete(perform: deleteWisdoms)
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterView(
                selectedSource: $selectedSource,
                selectedCategory: $selectedCategory
            )
        }
        .sheet(isPresented: $showingAddWisdom) {
            AddWisdomView()
        }
    }
    
    private func deleteWisdoms(at offsets: IndexSet) {
        wisdomStore.deleteWisdom(at: offsets)
    }
}

// 지혜 행 컴포넌트
struct WisdomRow: View {
    let wisdom: Wisdom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(wisdom.content)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            HStack {
                Text(wisdom.source.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                Text(wisdom.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
                
                Spacer()
                
                if wisdom.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding(8)
        .background(.background, in: .rect(cornerRadius: 12))
    }
}

// 검색 바 컴포넌트
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("검색", text: $text)
                .foregroundColor(.primary)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// 필터 칩 컴포넌트
struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .font(.caption)
                .padding(.leading, 8)
                .padding(.vertical, 4)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .padding(.trailing, 8)
            .padding(.vertical, 4)
        }
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// 필터 뷰
struct FilterView: View {
    @Binding var selectedSource: WisdomSource?
    @Binding var selectedCategory: WisdomCategory?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("출처")) {
                    ForEach(WisdomSource.allCases, id: \.self) { source in
                        Button(action: {
                            selectedSource = source
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text(source.rawValue)
                                Spacer()
                                if selectedSource == source {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        selectedSource = nil
                    }) {
                        Text("모두 보기")
                            .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("카테고리")) {
                    ForEach(WisdomCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text(category.rawValue)
                                Spacer()
                                if selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        selectedCategory = nil
                    }) {
                        Text("모두 보기")
                            .foregroundColor(.blue)
                    }
                }
                
                Section {
                    Button(action: {
                        selectedSource = nil
                        selectedCategory = nil
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("필터 초기화")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("필터")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    WisdomListView()
        .environmentObject(WisdomStore())
} 
