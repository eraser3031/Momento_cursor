import SwiftUI
import PhotosUI

struct AddWisdomView: View {
    @EnvironmentObject var wisdomStore: WisdomStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentStep = 0
    @State private var selectedContentType: WisdomContentType?
    @State private var content = ""
    @State private var source: WisdomSource = .selfWritten
    @State private var category: WisdomCategory = .other
    @State private var context = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var mediaURL: URL?
    @State private var urlString = ""
    
    @State private var showingSourceSheet = false
    @State private var showingSuccessAlert = false
    @State private var showingURLError = false
    
    var body: some View {
        NavigationView {
            VStack {
                switch currentStep {
                case 0:
                    contentTypeSelectionView
                case 1:
                    contentInputView
                case 2:
                    additionalInfoView
                default:
                    EmptyView()
                }
            }
            .navigationTitle("지혜 추가")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentStep > 0 {
                        Button("이전") {
                            currentStep -= 1
                        }
                    } else {
                        Button("취소") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if currentStep < 2 {
                        Button("다음") {
                            moveToNextStep()
                        }
                        .disabled(!canMoveToNextStep)
                    } else {
                        Button("저장") {
                            saveWisdom()
                        }
                        .disabled(!canSave)
                    }
                }
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
    
    // 컨텐츠 타입 선택 뷰
    private var contentTypeSelectionView: some View {
        VStack(spacing: 20) {
            Text("어떤 형태의 지혜를 추가하시겠습니까?")
                .font(.headline)
                .padding(.top)
            
            ForEach(WisdomContentType.allCases, id: \.self) { type in
                Button(action: {
                    selectedContentType = type
                }) {
                    HStack {
                        Image(systemName: iconName(for: type))
                            .font(.title2)
                        
                        Text(type.rawValue)
                            .font(.title3)
                        
                        Spacer()
                        
                        if selectedContentType == type {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedContentType == type ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // 컨텐츠 입력 뷰
    private var contentInputView: some View {
        VStack {
            switch selectedContentType {
            case .text:
                TextEditor(text: $content)
                    .frame(maxHeight: .infinity)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        Group {
                            if content.isEmpty {
                                Text("여기에 지혜를 입력하세요...")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )
                
            case .image:
                VStack {
                    if let selectedImageData = selectedImageData,
                       let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(8)
                        
                        Button("이미지 변경") {
                            self.selectedImageData = nil
                            self.selectedItem = nil
                        }
                        .padding(.top)
                    } else {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .padding()
                                Text("이미지 선택")
                            }
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                    }
                }
                
            case .url:
                VStack(alignment: .leading, spacing: 8) {
                    TextField("URL을 입력하세요", text: $urlString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    if showingURLError {
                        Text("올바른 URL을 입력해주세요")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
            case .none:
                EmptyView()
            }
        }
        .padding()
    }
    
    // 추가 정보 입력 뷰
    private var additionalInfoView: some View {
        Form {
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
    }
    
    // 다음 단계로 이동
    private func moveToNextStep() {
        if currentStep == 1 && selectedContentType == .url {
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                showingURLError = false
                currentStep += 1
            } else {
                showingURLError = true
                return
            }
        } else {
            currentStep += 1
        }
    }
    
    // 다음 단계로 이동 가능 여부
    private var canMoveToNextStep: Bool {
        switch currentStep {
        case 0:
            return selectedContentType != nil
        case 1:
            switch selectedContentType {
            case .text:
                return !content.isEmpty
            case .image:
                return selectedImageData != nil
            case .url:
                return !urlString.isEmpty
            case .none:
                return false
            }
        default:
            return true
        }
    }
    
    // 저장 가능 여부
    private var canSave: Bool {
        return true // 추가 정보는 선택사항이므로 항상 true
    }
    
    // 컨텐츠 타입별 아이콘
    private func iconName(for type: WisdomContentType) -> String {
        switch type {
        case .text:
            return "text.quote"
        case .image:
            return "photo"
        case .url:
            return "link"
        }
    }
    
    // 지혜 저장
    private func saveWisdom() {
        var finalContent = ""
        var finalMediaURL: URL? = nil
        
        switch selectedContentType {
        case .text:
            finalContent = content
        case .image:
            if let imageData = selectedImageData {
                // 이미지 데이터를 파일로 저장하고 URL 생성
                // 실제 앱에서는 적절한 저장소에 저장
                finalContent = "이미지"
                finalMediaURL = URL(string: "image://local/\(UUID().uuidString)")
            }
        case .url:
            finalContent = urlString
            finalMediaURL = URL(string: urlString)
        case .none:
            return
        }
        
        let wisdom = Wisdom(
            content: finalContent,
            contentType: selectedContentType ?? .text,
            source: source,
            category: category,
            context: context.isEmpty ? nil : context,
            mediaURL: finalMediaURL
        )
        
        wisdomStore.addWisdom(wisdom)
        showingSuccessAlert = true
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