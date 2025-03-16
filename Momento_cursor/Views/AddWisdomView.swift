import SwiftUI
import PhotosUI

struct AddWisdomView: View {
    @EnvironmentObject var wisdomStore: WisdomStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var content = ""
    @State private var source: WisdomSource = .selfWritten
    @State private var category: WisdomCategory = .other
    @State private var context = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var mediaURL: URL?
    
    @State private var showingSourceSheet = false
    @State private var showingSuccessAlert = false
    @State private var isImporting = false
    
    var body: some View {
        NavigationView {
            Form {
                // 내용 섹션
                Section(header: Text("내용")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                        .overlay(
                            Group {
                                if content.isEmpty {
                                    Text("여기에 지혜를 입력하세요...")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                // 분류 섹션
                Section(header: Text("분류")) {
                    HStack {
                        Text("출처")
                        Spacer()
                        Button(action: {
                            showingSourceSheet = true
                        }) {
                            HStack {
                                Text(source.rawValue)
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    Picker("카테고리", selection: $category) {
                        ForEach(WisdomCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                
                // 컨텍스트 섹션
                Section(header: Text("컨텍스트"), footer: Text("이 지혜를 얻게 된 상황이나 배경을 설명해주세요")) {
                    TextEditor(text: $context)
                        .frame(minHeight: 100)
                }
                
                // 빠른 추가 섹션
                Section(header: Text("빠른 추가")) {
                    Button(action: {
                        addFromClipboard()
                    }) {
                        Label("클립보드에서 가져오기", systemImage: "doc.on.clipboard")
                    }
                    
                    Button(action: {
                        // 카메라로 텍스트 인식 기능 (실제 앱에서 구현)
                        // 현재는 더미 기능
                        content = "카메라로 텍스트를 인식했습니다."
                    }) {
                        Label("카메라로 텍스트 인식", systemImage: "camera")
                    }
                }
            }
            .navigationTitle("지혜 추가")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveWisdom()
                    }
                    .disabled(content.isEmpty)
                }
            }
            .sheet(isPresented: $showingSourceSheet) {
                SourceSelectionView(selectedSource: $source)
            }
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("저장 완료"),
                    message: Text("지혜가 성공적으로 저장되었습니다."),
                    dismissButton: .default(Text("확인")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // 지혜 저장
    private func saveWisdom() {
        let wisdom = Wisdom(
            content: content,
            source: source,
            category: category,
            context: context.isEmpty ? nil : context,
            mediaURL: mediaURL
        )
        
        wisdomStore.addWisdom(wisdom)
        showingSuccessAlert = true
    }
    
    // 클립보드에서 가져오기
    private func addFromClipboard() {
        if let clipboardString = UIPasteboard.general.string, !clipboardString.isEmpty {
            content = clipboardString
        }
    }
}

// 출처 선택 뷰
struct SourceSelectionView: View {
    @Binding var selectedSource: WisdomSource
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
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
            }
            .navigationTitle("출처 선택")
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

#Preview {
    AddWisdomView()
        .environmentObject(WisdomStore())
} 