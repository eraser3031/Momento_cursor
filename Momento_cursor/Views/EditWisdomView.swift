import SwiftUI

struct EditWisdomView: View {
    @Binding var wisdom: Wisdom
    @Binding var isPresented: Bool
    
    @State private var content: String
    @State private var source: WisdomSource
    @State private var category: WisdomCategory
    @State private var context: String
    
    init(wisdom: Binding<Wisdom>, isPresented: Binding<Bool>) {
        self._wisdom = wisdom
        self._isPresented = isPresented
        
        _content = State(initialValue: wisdom.wrappedValue.content)
        _source = State(initialValue: wisdom.wrappedValue.source)
        _category = State(initialValue: wisdom.wrappedValue.category)
        _context = State(initialValue: wisdom.wrappedValue.context ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("내용")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
                
                Section(header: Text("분류")) {
                    Picker("출처", selection: $source) {
                        ForEach(WisdomSource.allCases, id: \.self) { source in
                            Text(source.rawValue).tag(source)
                        }
                    }
                    
                    Picker("카테고리", selection: $category) {
                        ForEach(WisdomCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section(header: Text("컨텍스트"), footer: Text("이 지혜를 얻게 된 상황이나 배경을 설명해주세요")) {
                    TextEditor(text: $context)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("지혜 편집")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        updateWisdom()
                        isPresented = false
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }
    
    private func updateWisdom() {
        wisdom.content = content
        wisdom.source = source
        wisdom.category = category
        wisdom.context = context.isEmpty ? nil : context
    }
} 
